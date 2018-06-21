USE [AUDIT]
GO
 
/****** Object:  StoredProcedure [PRC].[Load_StatDb]    Script Date: 2018.06.07. 10:18:01 ******/
SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE PROCEDURE [PRC].[Load_StatDb]
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

DECLARE @mergeSql NVARCHAR(MAX)
DECLARE @sql NVARCHAR(MAX)
DECLARE @OpenRowSetBaseSql NVARCHAR(MAX)
DECLARE @ssasDMVQuery NVARCHAR(MAX)
DECLARE @dataSrc NVARCHAR(MAX) = N'''DATASOURCE=cscsql01wdv\tabular; INITIAL CATALOG = '
SET @OpenRowSetBaseSql = 
CONCAT(
N'FROM OPENrowset(''MSOLAP'',',@dataSrc
)
 
--dbs
MERGE REP.[Databases] AS TRG
USING
(
SELECT CAST(DATABASE_ID AS NVARCHAR(255)) AS DATABASE_ID FROM OPENQUERY
([TABULAR_DEV], 'select * from $System.DBSCHEMA_CATALOGS')
)SRC
ON TRG.DatabaseName = SRC.DATABASE_ID collate database_default
AND TRG.DatabaseId > 0 --do not update unknown
WHEN NOT MATCHED THEN
INSERT(DatabaseName) VALUES(SRC.DATABASE_ID);
 

 -- ITERATE THRU DBS
DECLARE @dbName NVARCHAR(255)
DECLARE dbParser CURSOR READ_ONLY FORWARD_ONLY FAST_FORWARD FOR SELECT DatabaseName FROM [REP].[Databases] WHERE DatabaseId > 0
OPEN dbParser
FETCH NEXT FROM dbParser INTO @dbName
WHILE @@FETCH_STATUS = 0
BEGIN
 

-- TABLES
SET @ssasDMVQuery = N'select * from $System.DBSCHEMA_TABLES WHERE TABLE_TYPE = ''''TABLE'''' AND LEFT(TABLE_SCHEMA,1) <> ''''$'''''''
SET @sql = 
CONCAT(
N'SELECT 
 CAST(TABLE_CATALOG AS nvarchar(255)) AS TABLE_CATALOG
,REPLACE(CAST(TABLE_NAME  AS nvarchar(255)),''$'','''') AS TABLE_NAME
',
@OpenRowSetBaseSql,@dbName,''',','''',@ssasDMVQuery,')'
)

SET @mergeSql = CONCAT(N'
;WITH CurrentDbTables([TableId],[DatabaseId],[TableName],[IsActive])
AS
(
	SELECT [TableId],T.[DatabaseId],[TableName],T.[IsActive]
	FROM [REP].[Tables] T
	INNER JOIN [REP].[Databases] D
		ON T.DatabaseId = D.DatabaseId
	WHERE D.DatabaseName = ''',@dbName,'''
)

MERGE CurrentDbTables AS TRG
USING
(
	SELECT Q.*,D.DatabaseId
	FROM
	(
	',@sql,'	
	) Q
	INNER JOIN [REP].[Databases] D 
		ON D.DatabaseName = Q.TABLE_CATALOG collate database_default
)SRC
ON TRG.TableName = SRC.TABLE_NAME collate database_default
AND TRG.DatabaseId = SRC.DatabaseId
AND TRG.TableId > 0 --do not update unknown
WHEN NOT MATCHED THEN
INSERT(DatabaseId,TableName,IsActive) VALUES(SRC.DatabaseId,SRC.TABLE_NAME,1)
WHEN NOT MATCHED BY SOURCE THEN UPDATE SET IsActive = 0;'
)
--print @mergeSql
exec (@mergeSql)


--------------------------------------------------------------------------------------------------------------------
-- COLUMNS
SET @ssasDMVQuery = N'select * from $System.DBSCHEMA_COLUMNS WHERE COLUMN_OLAP_TYPE = ''''ATTRIBUTE'''' AND LEFT(TABLE_SCHEMA,1) <> ''''$'''''''
SET @sql = 
CONCAT(
N'SELECT 
CAST(TABLE_CATALOG AS nvarchar(255)) AS TABLE_CATALOG
,REPLACE(CAST(TABLE_NAME  AS nvarchar(255)),''$'','''') AS TABLE_NAME
,CAST(COLUMN_NAME AS nvarchar(255)) AS COLUMN_NAME		
',
@OpenRowSetBaseSql,@dbName,''',','''',@ssasDMVQuery,')'
)

SET @mergeSql = CONCAT(N'
;WITH CurrentDbColumns([ColumnId],[TableId],[ColumName],[IsActive])
AS
(
	SELECT [ColumnId],C.[TableId],[ColumName],C.[IsActive]
	FROM [REP].[Columns] C
	INNER JOIN [REP].[Tables] T
		ON C.TableId = T.TableId
	INNER JOIN [REP].[Databases] D
		ON T.DatabaseId = D.DatabaseId
	WHERE D.DatabaseName = ''',@dbName,'''
)

MERGE CurrentDbColumns AS TRG
USING
(
	SELECT Q.*,D.DatabaseId, T.TableId
	FROM
	(',@sql,'
	) Q
	INNER JOIN [REP].[Databases] D 
		ON D.DatabaseName = Q.TABLE_CATALOG collate database_default
	INNER JOIN [REP].[Tables] T
		ON T.TableName = Q.TABLE_NAME collate database_default
		AND T.[DatabaseId] = D.[DatabaseId]
)SRC
ON TRG.ColumName = SRC.COLUMN_NAME collate database_default
AND TRG.TableId = SRC.TableId
AND TRG.ColumnId > 0 --do not update unknown
WHEN NOT MATCHED THEN
INSERT(TableId,ColumName,IsActive) VALUES(SRC.TableId,SRC.COLUMN_NAME,1)
WHEN NOT MATCHED BY SOURCE THEN UPDATE SET IsActive = 0;'
)
--print @mergeSql
exec (@mergeSql)
 


--------------------------------------------------------------------------------------------------------------------
-- MEASURES
SET @ssasDMVQuery = N'select * from $System.MDSCHEMA_MEASURES WHERE LEFT(CUBE_NAME,1) <> ''''$'''''''
SET @sql = 
CONCAT(
N'SELECT 
CAST(CATALOG_NAME  AS nvarchar(255)) as TABLE_CATALOG
,CAST(MEASUREGROUP_NAME  AS nvarchar(255)) AS TABLE_NAME
,CAST(MEASURE_NAME  AS nvarchar(255)) as MEASURE_NAME  		
',
@OpenRowSetBaseSql,@dbName,''',','''',@ssasDMVQuery,')',' WHERE MEASUREGROUP_NAME IS NOT NULL'
)

SET @mergeSql = CONCAT(N'
;WITH CurrentDbMeasures([MeasureId],[TableId],[MeasureName],[IsActive])
AS
(
	SELECT [MeasureId],M.[TableId],[MeasureName],M.[IsActive]
	FROM [REP].[Measures] M
	INNER JOIN [REP].[Tables] T
		ON M.TableId = T.TableId
	INNER JOIN [REP].[Databases] D
		ON T.DatabaseId = D.DatabaseId
	WHERE D.DatabaseName = ''',@dbName,'''
)

MERGE CurrentDbMeasures AS TRG
USING
(
	SELECT Q.*,D.DatabaseId, T.TableId
	FROM
	(',@sql,'		
	) Q
	INNER JOIN [REP].[Databases] D 
		ON D.DatabaseName = Q.TABLE_CATALOG collate database_default
	INNER JOIN [REP].[Tables] T
		ON T.TableName = Q.TABLE_NAME collate database_default
		AND T.[DatabaseId] = D.[DatabaseId]
)SRC
ON TRG.MeasureName = SRC.MEASURE_NAME collate database_default
AND TRG.TableId = SRC.TableId
AND TRG.MeasureId > 0 -- do not overwrite UNKNOWN
WHEN NOT MATCHED THEN
INSERT(TableId,MeasureName,IsActive) VALUES(SRC.TableId,SRC.MEASURE_NAME,1)
WHEN NOT MATCHED BY SOURCE THEN UPDATE SET IsActive = 0;'
)
--print @mergeSql
exec (@mergeSql)



--------------------------------------------------------------------------------------------------------------------
-- HIERARCHIES
SET @ssasDMVQuery = N'select * from $System.MDSchema_hierarchies WHERE HIERARCHY_ORIGIN = 1 AND LEFT(CUBE_NAME,1) = ''''$'''''''
SET @sql = 
CONCAT(
N'SELECT 
CAST(CATALOG_NAME AS nvarchar(255)) AS TABLE_CATALOG
,REPLACE(CAST(CUBE_NAME  AS nvarchar(255)),''$'','') AS TABLE_NAME
,REPLACE(CAST(HIERARCHY_NAME  AS nvarchar(255)),''$'','') AS HIERARCHY_NAME  		
',
@OpenRowSetBaseSql,@dbName,''',','''',@ssasDMVQuery,')'
)

SET @mergeSql = CONCAT(N'
;WITH CurrentDbHierarchies([HierarchyId],[TableId],[HierarchyName],[IsActive])
AS
(
	SELECT [HierarchyId],H.[TableId],[HierarchyName],H.[IsActive]
	FROM [REP].[Hierarchies] H
	INNER JOIN [REP].[Tables] T
		ON H.TableId = T.TableId
	INNER JOIN [REP].[Databases] D
		ON T.DatabaseId = D.DatabaseId
	WHERE D.DatabaseName = ''',@dbName,'''
)

MERGE CurrentDbHierarchies AS TRG
USING
(
	SELECT Q.*,D.DatabaseId, T.TableId
	FROM
	(',@sql,'		
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
WHEN NOT MATCHED BY SOURCE THEN UPDATE SET IsActive = 0;'
)
--print @mergeSql
exec (@mergeSql)

FETCH NEXT FROM dbParser INTO @dbName
END
CLOSE dbParser
DEALLOCATE dbParser

 
-- query
MERGE [REP].[Queries] TRG
USING
(
SELECT DISTINCT
[QueryText]
,CONVERT(VARCHAR(40),HASHBYTES('MD5',[QueryText]),2) AS QueryHash
,ISNULL(D.DatabaseId,0) AS DatabaseId
FROM [PRC].[SSAS_Monitoring] M
INNER JOIN [dbo].[Databases] D
	ON D.DatabaseName = M.DatabaseName
) SRC
       ON TRG.[QueryHash] = SRC.QueryHash
WHEN NOT MATCHED THEN INSERT(QueryText,QueryHash,DatabaseId) VALUES(SRC.QueryText,SRC.QueryHash,SRC.DatabaseId);
 
 
-- query executionsn
DECLARE @lastRun DATETIME2 = (SELECT [ParamValue] FROM [PRC].[SSAS_MonitoringParameters] WHERE [ParamName] = 'StatExtract_LastRun')
INSERT INTO [REP].[QueryExecutions]([QueryId],[UserName],[ExecutionTime],[Duration],[CPUTime])
SELECT
Q.QueryId
,STAT.UserName
,STAT.StartTime
,STAT.Duration
,STAT.CPUTime
FROM [REP].[Queries] Q
INNER JOIN
(
SELECT
M.*
,CONVERT(VARCHAR(40),HASHBYTES('MD5',[QueryText]),2) AS QueryHash
FROM [PRC].[SSAS_Monitoring] M
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

	SELECT @DbId = MIN(DatabaseId) FROM [REP].[Databases]
	WHERE DatabaseId > @DbId

	IF @DbId IS NULL BREAK
	
	-- columns
	WHILE (1=1)
	BEGIN
		SELECT @ColumnId = MIN(ColumnId) 
		FROM REP.[Columns] C
		INNER JOIN [REP].[Tables] T
			ON C.TableId = T.TableId			
		WHERE T.DatabaseId = @DbId AND ColumnId > @ColumnId

		IF @ColumnId IS NULL BREAK

		SELECT
		@ColumnId = C.ColumnId, 
		@PatternToFind = CONCAT(N'"[',T.TableName, N'].[',C.ColumName,N']"')
		FROM [REP].[Tables] T
		INNER JOIN  REP.[Columns] C
			ON C.TableId = T.TableId  
		WHERE T.DatabaseId = @DbId
		AND C.ColumnId = @ColumnId

		IF @ColumnId IS NULL BREAK

		MERGE [REP].[ColumnsInQuery] TRG
		USING
		(
			SELECT 
			Q.QueryId, @ColumnId AS ColumnId
			FROM [REP].[Queries] Q
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
		FROM REP.Measures M
		INNER JOIN [REP].[Tables] T
			ON M.TableId = T.TableId			
		WHERE T.DatabaseId = @DbId AND MeasureId > @MeasureId

		IF @MeasureId IS NULL BREAK

		SELECT
		@MeasureId = M.MeasureId, 
		@PatternToFind = CONCAT(N'"[Measures].[',M.MeasureName,N']"')
		FROM [REP].[Tables] T
		INNER JOIN REP.Measures M
			ON M.TableId = T.TableId  
		WHERE T.DatabaseId = @DbId
		AND  M.MeasureId = @MeasureId		

		MERGE [REP].[MeasuresInQuery] TRG
		USING
		(
			SELECT 
			Q.QueryId, @MeasureId AS MeasureId
			FROM [REP].[Queries] Q
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
		FROM REP.Hierarchies H
		INNER JOIN [REP].[Tables] T
			ON H.TableId = T.TableId			
		WHERE T.DatabaseId = @DbId AND [HierarchyId] > @HierarchyId

		SELECT @HierarchyId = MIN([HierarchyId]) 
		FROM REP.Hierarchies H
		INNER JOIN [REP].[Tables] T
			ON H.TableId = T.TableId			
		WHERE T.DatabaseId = @DbId AND [HierarchyId] > @HierarchyId

		IF @HierarchyId IS NULL BREAK

		SELECT
		H.[HierarchyId], 
		CONCAT(N'"',H.HierarchyName,N'"')
		FROM [REP].[Tables] T
		INNER JOIN REP.Hierarchies H
			ON H.TableId = T.TableId  
		WHERE T.DatabaseId = @DbId
		AND  H.[HierarchyId] = @HierarchyId		

		SELECT
		@HierarchyId = H.[HierarchyId], 
		@PatternToFind = CONCAT(N'"',H.HierarchyName,N'"')
		FROM [REP].[Tables] T
		INNER JOIN REP.Hierarchies H
			ON H.TableId = T.TableId  
		WHERE T.DatabaseId = @DbId
		AND  H.[HierarchyId] = @HierarchyId		

		print @PatternToFind

		SELECT 
			Q.QueryId, @HierarchyId AS [HierarchyId]
			FROM [REP].[Queries] Q
			WHERE Q.DatabaseId = @DbId
			AND CONTAINS([QueryText],@PatternToFind)

		MERGE [REP].[HierarchiesInQuery] TRG
		USING
		(
			SELECT 
			Q.QueryId, @HierarchyId AS [HierarchyId]
			FROM [REP].[Queries] Q
			WHERE Q.DatabaseId = @DbId
			AND CONTAINS([QueryText],@PatternToFind)
		)SRC
			ON TRG.QueryId = SRC.QueryId
			AND TRG.[HierarchyId] = SRC.[HierarchyId]
		WHEN NOT MATCHED THEN INSERT ([HierarchyId],QueryId) VALUES (SRC.[HierarchyId],SRC.QueryId);

	END -- EOF hierarchies

END -- eof dbs

--insert not matched columns
INSERT INTO [REP].[ColumnsInQuery] (ColumnId, QueryId)
SELECT 0, Q.QueryId
FROM [REP].[Queries] Q
LEFT JOIN [REP].[ColumnsInQuery] CQ
	ON Q.QueryId = CQ.QueryId
WHERE CQ.QueryId IS NULL


--insert not matched measures
INSERT INTO [REP].[MeasuresInQuery] (MeasureId, QueryId)
SELECT 0, Q.QueryId
FROM [REP].[Queries] Q
LEFT JOIN [REP].[MeasuresInQuery] MQ
	ON Q.QueryId = MQ.QueryId
WHERE MQ.QueryId IS NULL


--insert not matched hierarchies
INSERT INTO [REP].[HierarchiesInQuery] ([HierarchyId], QueryId)
SELECT 0, Q.QueryId
FROM [REP].[Queries] Q
LEFT JOIN [REP].[HierarchiesInQuery] MQ
	ON Q.QueryId = MQ.QueryId
WHERE MQ.QueryId IS NULL
 
 
-- update param
UPDATE [PRC].[SSAS_MonitoringParameters]
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
GO

