
CREATE PROCEDURE [dbo].[Load_StatDb_FullText]
AS BEGIN
SET NOCOUNT ON;

BEGIN TRY

DECLARE @MAXWAIT INT = 0
WHILE (SELECT FULLTEXTCATALOGPROPERTY('QueryTextCat','PopulateStatus')) != 0 AND @MAXWAIT < 50
BEGIN
	SET @MAXWAIT = @MAXWAIT + 1
	WAITFOR DELAY '00:00:01'
END

BEGIN TRAN

--dbs
MERGE dbo.[Databases] AS TRG
USING
(
 SELECT CAST(DATABASE_ID AS NVARCHAR(255)) AS DATABASE_ID FROM OPENQUERY
([SSAS], 'select * from $System.DBSCHEMA_CATALOGS')
)SRC
ON TRG.DatabaseName = SRC.DATABASE_ID collate database_default
AND TRG.DatabaseId > 0 --do not update unknown
WHEN NOT MATCHED THEN
INSERT(DatabaseName) VALUES(SRC.DATABASE_ID);


-- tables
MERGE dbo.[Tables] AS TRG
USING
(
	SELECT Q.*,D.DatabaseId
	FROM
	(
		SELECT 
		CAST(TABLE_CATALOG AS nvarchar(255)) AS TABLE_CATALOG
		,REPLACE(CAST(TABLE_NAME  AS nvarchar(255)),'$','') AS TABLE_NAME
		FROM OPENQUERY([SSAS], 'select * from $System.DBSCHEMA_TABLES WHERE TABLE_TYPE = ''TABLE'' AND LEFT(TABLE_SCHEMA,1) <> ''$''')
	) Q
	INNER JOIN dbo.[Databases] D 
		ON D.DatabaseName = Q.TABLE_CATALOG collate database_default
)SRC
ON TRG.TableName = SRC.TABLE_NAME collate database_default
AND TRG.DatabaseId = SRC.DatabaseId
AND TRG.TableId > 0 --do not update unknown
WHEN NOT MATCHED THEN
INSERT(DatabaseId,TableName,IsActive) VALUES(SRC.DatabaseId,SRC.TABLE_NAME,1)
WHEN NOT MATCHED BY SOURCE THEN UPDATE SET IsActive = 0;


-- columns
MERGE dbo.[Columns] AS TRG
USING
(
	SELECT Q.*,D.DatabaseId, T.TableId
	FROM
	(
		SELECT 
		 CAST(TABLE_CATALOG AS nvarchar(255)) AS TABLE_CATALOG
		,REPLACE(CAST(TABLE_NAME  AS nvarchar(255)),'$','') AS TABLE_NAME
		,CAST(COLUMN_NAME AS nvarchar(255)) AS COLUMN_NAME		
		FROM OPENQUERY([SSAS], 'select * from $System.DBSCHEMA_COLUMNS where COLUMN_OLAP_TYPE=''ATTRIBUTE'' AND LEFT(TABLE_SCHEMA,1) <> ''$''')
	) Q
	INNER JOIN dbo.[Databases] D 
		ON D.DatabaseName = Q.TABLE_CATALOG collate database_default
	INNER JOIN dbo.[Tables] T
		ON T.TableName = Q.TABLE_NAME collate database_default
		AND T.[DatabaseId] = D.[DatabaseId]
)SRC
ON TRG.ColumName = SRC.COLUMN_NAME collate database_default
AND TRG.TableId = SRC.TableId
AND TRG.ColumnId > 0 --do not update unknown
WHEN NOT MATCHED THEN
INSERT(TableId,ColumName,IsActive) VALUES(SRC.TableId,SRC.COLUMN_NAME,1)
WHEN NOT MATCHED BY SOURCE THEN UPDATE SET IsActive = 0;


-- measures
MERGE dbo.Measures AS TRG
USING
(
	SELECT Q.*,D.DatabaseId, T.TableId
	FROM
	(
	
		SELECT 
		 CAST(CATALOG_NAME  AS nvarchar(255)) as TABLE_CATALOG
		,CAST(MEASUREGROUP_NAME  AS nvarchar(255)) AS TABLE_NAME
		,CAST(MEASURE_NAME  AS nvarchar(255)) as MEASURE_NAME  
		FROM OPENQUERY([SSAS], 'select * from $System.MDSCHEMA_MEASURES where LEFT(CUBE_NAME,1) <> ''$''')
		WHERE MEASUREGROUP_NAME IS NOT NULL
	) Q
	INNER JOIN dbo.[Databases] D 
		ON D.DatabaseName = Q.TABLE_CATALOG collate database_default
	INNER JOIN dbo.[Tables] T
		ON T.TableName = Q.TABLE_NAME collate database_default
		AND T.[DatabaseId] = D.[DatabaseId]
)SRC
ON TRG.MeasureName = SRC.MEASURE_NAME collate database_default
AND TRG.TableId = SRC.TableId
AND TRG.MeasureId > 0 -- do not overwrite UNKNOWN
WHEN NOT MATCHED THEN
INSERT(TableId,MeasureName,IsActive) VALUES(SRC.TableId,SRC.MEASURE_NAME,1)
WHEN NOT MATCHED BY SOURCE THEN UPDATE SET IsActive = 0;


-- hierarchies
MERGE dbo.[Hierarchies] AS TRG
USING
(
	SELECT Q.*,D.DatabaseId, T.TableId
	FROM
	(
		SELECT 
		 CAST(CATALOG_NAME AS nvarchar(255)) AS TABLE_CATALOG
		,REPLACE(CAST(CUBE_NAME  AS nvarchar(255)),'$','') AS TABLE_NAME
		,REPLACE(CAST(HIERARCHY_NAME  AS nvarchar(255)),'$','') AS HIERARCHY_NAME
		FROM OPENQUERY([SSAS], 'select * from $System.MDSchema_hierarchies WHERE HIERARCHY_ORIGIN = 1 AND LEFT(CUBE_NAME,1) = ''$''')
	) Q
	INNER JOIN dbo.[Tables] T 
		ON T.TableName = Q.TABLE_NAME collate database_default
	INNER JOIN [dbo].[Databases] D
		ON Q.TABLE_CATALOG = D.DatabaseName collate database_default
		AND T.DatabaseId = D.DatabaseId
)SRC
ON TRG.HierarchyName = SRC.HIERARCHY_NAME collate database_default
AND TRG.TableId = SRC.TableId
AND TRG.HierarchyId > 0 --do not update unknown
WHEN NOT MATCHED THEN
INSERT(TableId,HierarchyName,IsActive) VALUES(SRC.TableId,SRC.HIERARCHY_NAME,1)
WHEN NOT MATCHED BY SOURCE THEN UPDATE SET IsActive = 0;


-- query
MERGE [dbo].[Queries] TRG
USING
(
SELECT DISTINCT
 [QueryText]
,CONVERT(VARCHAR(40),HASHBYTES('MD5',[QueryText]),2) AS QueryHash
,ISNULL(D.DatabaseId,0) AS DatabaseId
FROM [dbo].[SSAS_Monitoring] M
INNER JOIN [dbo].[Databases] D
	ON D.DatabaseName = M.DatabaseName
) SRC
	ON TRG.[QueryHash] = SRC.QueryHash
WHEN NOT MATCHED THEN INSERT(QueryText,QueryHash,DatabaseId) VALUES(SRC.QueryText,SRC.QueryHash,SRC.DatabaseId);


-- query executionsn
DECLARE @lastRun DATETIME2 = (SELECT [ParamValue] FROM [dbo].[SSAS_MonitoringParameters] WHERE [ParamName] = 'StatExtract_LastRun')
INSERT INTO [dbo].[QueryExecutions]([QueryId],[UserName],[ExecutionTime],[Duration],[CPUTime])
SELECT
 Q.QueryId
,STAT.UserName
,STAT.StartTime
,STAT.Duration
,STAT.CPUTime
FROM [dbo].[Queries] Q
INNER JOIN
(
 SELECT
 M.*
,CONVERT(VARCHAR(40),HASHBYTES('MD5',[QueryText]),2) AS QueryHash
 FROM [dbo].[SSAS_Monitoring] M
 WHERE M.TimeStampUtc >= @lastRun
) STAT
	ON Q.QueryHash = STAT.QueryHash


DECLARE @I INT = 1
DECLARE @DbId INT = 0
DECLARE @ColumnId INT = 0
DECLARE @MeasureId INT = 0
DECLARE @HierarchyId INT = 0
DECLARE @PatternToFind NVARCHAR(4000)
WHILE (1 = 1)
BEGIN

	SET @ColumnId = 0
	SET @MeasureId = 0
	SET @HierarchyId = 0

	SELECT @DbId = MIN(DatabaseId) FROM [dbo].[Databases]
	WHERE DatabaseId > @DbId

	IF @DbId IS NULL BREAK
	
	-- columns
	WHILE (1=1)
	BEGIN
		SELECT @ColumnId = MIN(ColumnId) 
		FROM dbo.[Columns] C
		INNER JOIN [dbo].[Tables] T
			ON C.TableId = T.TableId			
		WHERE T.DatabaseId = @DbId AND ColumnId > @ColumnId

		IF @ColumnId IS NULL BREAK

		SELECT
		@ColumnId = C.ColumnId, 
		@PatternToFind = CONCAT(N'"[',T.TableName, N'].[',C.ColumName,N']"')
		FROM [dbo].[Tables] T
		INNER JOIN  dbo.[Columns] C
			ON C.TableId = T.TableId  
		WHERE T.DatabaseId = @DbId
		AND C.ColumnId = @ColumnId

		IF @ColumnId IS NULL BREAK

		MERGE [dbo].[ColumnsInQuery] TRG
		USING
		(
			SELECT 
			Q.QueryId, @ColumnId AS ColumnId
			FROM [dbo].[Queries] Q
			WHERE Q.DatabaseId = @DbId
			AND CONTAINS([QueryText],@PatternToFind)
		)SRC
			ON TRG.QueryId = SRC.QueryId
			AND TRG.ColumnId = SRC.ColumnId
		WHEN NOT MATCHED THEN INSERT (ColumnId,QueryId) VALUES (SRC.ColumnId,SRC.QueryId);

	END -- eof columns

	-- measures
	WHILE (1=1)
	BEGIN
		SELECT @MeasureId = MIN(MeasureId) 
		FROM dbo.Measures M
		INNER JOIN [dbo].[Tables] T
			ON M.TableId = T.TableId			
		WHERE T.DatabaseId = @DbId AND MeasureId > @MeasureId

		IF @MeasureId IS NULL BREAK

		SELECT
		@MeasureId = M.MeasureId, 
		@PatternToFind = CONCAT(N'"[Measures].[',M.MeasureName,N']"')
		FROM [dbo].[Tables] T
		INNER JOIN dbo.Measures M
			ON M.TableId = T.TableId  
		WHERE T.DatabaseId = @DbId
		AND  M.MeasureId = @MeasureId		

		MERGE [dbo].[MeasuresInQuery] TRG
		USING
		(
			SELECT 
			Q.QueryId, @MeasureId AS MeasureId
			FROM [dbo].[Queries] Q
			WHERE Q.DatabaseId = @DbId
			AND CONTAINS([QueryText],@PatternToFind)
		)SRC
			ON TRG.QueryId = SRC.QueryId
			AND TRG.MeasureId = SRC.MeasureId
		WHEN NOT MATCHED THEN INSERT (MeasureId,QueryId) VALUES (SRC.MeasureId,SRC.QueryId);

	END -- eof measures

	
	-- hierarchies
	WHILE (1=1)
	BEGIN
	print 'db' print @DbId
	print 'hr' print @HierarchyId

	SELECT*
		FROM dbo.Hierarchies H
		INNER JOIN [dbo].[Tables] T
			ON H.TableId = T.TableId			
		WHERE T.DatabaseId = @DbId AND [HierarchyId] > @HierarchyId

		SELECT @HierarchyId = MIN([HierarchyId]) 
		FROM dbo.Hierarchies H
		INNER JOIN [dbo].[Tables] T
			ON H.TableId = T.TableId			
		WHERE T.DatabaseId = @DbId AND [HierarchyId] > @HierarchyId

		IF @HierarchyId IS NULL BREAK

		SELECT
		H.[HierarchyId], 
		CONCAT(N'"',H.HierarchyName,N'"')
		FROM [dbo].[Tables] T
		INNER JOIN dbo.Hierarchies H
			ON H.TableId = T.TableId  
		WHERE T.DatabaseId = @DbId
		AND  H.[HierarchyId] = @HierarchyId		

		SELECT
		@HierarchyId = H.[HierarchyId], 
		@PatternToFind = CONCAT(N'"',H.HierarchyName,N'"')
		FROM [dbo].[Tables] T
		INNER JOIN dbo.Hierarchies H
			ON H.TableId = T.TableId  
		WHERE T.DatabaseId = @DbId
		AND  H.[HierarchyId] = @HierarchyId		

		print @PatternToFind

		SELECT 
			Q.QueryId, @HierarchyId AS [HierarchyId]
			FROM [dbo].[Queries] Q
			WHERE Q.DatabaseId = @DbId
			AND CONTAINS([QueryText],@PatternToFind)

		MERGE [dbo].[HierarchiesInQuery] TRG
		USING
		(
			SELECT 
			Q.QueryId, @HierarchyId AS [HierarchyId]
			FROM [dbo].[Queries] Q
			WHERE Q.DatabaseId = @DbId
			AND CONTAINS([QueryText],@PatternToFind)
		)SRC
			ON TRG.QueryId = SRC.QueryId
			AND TRG.[HierarchyId] = SRC.[HierarchyId]
		WHEN NOT MATCHED THEN INSERT ([HierarchyId],QueryId) VALUES (SRC.[HierarchyId],SRC.QueryId);

	END -- EOF hierarchies

END -- eof dbs

--insert not matched columns
INSERT INTO [dbo].[ColumnsInQuery] (ColumnId, QueryId)
SELECT 0, Q.QueryId
FROM [dbo].[Queries] Q
LEFT JOIN [dbo].[ColumnsInQuery] CQ
	ON Q.QueryId = CQ.QueryId
WHERE CQ.QueryId IS NULL


--insert not matched measures
INSERT INTO [dbo].[MeasuresInQuery] (MeasureId, QueryId)
SELECT 0, Q.QueryId
FROM [dbo].[Queries] Q
LEFT JOIN [dbo].[MeasuresInQuery] MQ
	ON Q.QueryId = MQ.QueryId
WHERE MQ.QueryId IS NULL


--insert not matched hierarchies
INSERT INTO [dbo].[HierarchiesInQuery] ([HierarchyId], QueryId)
SELECT 0, Q.QueryId
FROM [dbo].[Queries] Q
LEFT JOIN [dbo].[HierarchiesInQuery] MQ
	ON Q.QueryId = MQ.QueryId
WHERE MQ.QueryId IS NULL


-- update param
UPDATE [dbo].[SSAS_MonitoringParameters] 
SET [ParamValue] =  CONVERT(NVARCHAR,(DATEADD(HOUR,-2,GETDATE())),126)
WHERE [ParamName] = 'StatExtract_LastRun'


COMMIT TRAN
END TRY

BEGIN CATCH

IF @@TRANCOUNT > 0
	ROLLBACK TRAN

DECLARE @ERRORMESSAGE NVARCHAR(MAX), @ERRORSEVERITY INT, @ERRORSTATE INT;
SELECT @ERRORMESSAGE = ERROR_MESSAGE() + ' LINE ' + CAST(ERROR_LINE() AS NVARCHAR(5)), @ERRORSEVERITY = ERROR_SEVERITY(), @ERRORSTATE = ERROR_STATE();

RAISERROR (@ERRORMESSAGE, @ERRORSEVERITY, @ERRORSTATE);

END CATCH

END