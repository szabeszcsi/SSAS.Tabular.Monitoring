CREATE PROCEDURE [dbo].[Load_StatDb]
AS BEGIN
SET NOCOUNT ON;

BEGIN TRY
BEGIN TRAN

--dbs
MERGE dbo.Databases AS TRG
USING
(
 SELECT CAST(DATABASE_ID AS NVARCHAR(255)) AS DATABASE_ID FROM OPENQUERY
([SSAS], 'select * from $System.DBSCHEMA_CATALOGS')
)SRC
ON TRG.DatabaseName = SRC.DATABASE_ID
WHEN NOT MATCHED THEN
INSERT(DatabaseName) VALUES(DATABASE_ID);


-- tables
MERGE dbo.Tables AS TRG
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
	INNER JOIN dbo.Databases D 
		ON D.DatabaseName = Q.TABLE_CATALOG
)SRC
ON TRG.TableName = SRC.TABLE_NAME
AND TRG.DatabaseId = SRC.DatabaseId
WHEN NOT MATCHED THEN
INSERT(DatabaseId,TableName,IsActive) VALUES(DatabaseId,TABLE_NAME,1)
WHEN NOT MATCHED BY SOURCE THEN UPDATE SET IsActive = 0;


-- columns
MERGE dbo.Columns AS TRG
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
	INNER JOIN dbo.Databases D 
		ON D.DatabaseName = Q.TABLE_CATALOG
	INNER JOIN dbo.Tables T
		ON T.TableName = Q.TABLE_NAME
		AND T.[DatabaseId] = D.[DatabaseId]
)SRC
ON TRG.ColumName = SRC.COLUMN_NAME
AND TRG.TableId = SRC.TableId
WHEN NOT MATCHED THEN
INSERT(TableId,ColumName,IsActive) VALUES(TableId,COLUMN_NAME,1)
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
	INNER JOIN dbo.Databases D 
		ON D.DatabaseName = Q.TABLE_CATALOG
	INNER JOIN dbo.Tables T
		ON T.TableName = Q.TABLE_NAME
		AND T.[DatabaseId] = D.[DatabaseId]
)SRC
ON TRG.MeasureName = SRC.MEASURE_NAME
AND TRG.TableId = SRC.TableId
WHEN NOT MATCHED THEN
INSERT(TableId,MeasureName,IsActive) VALUES(TableId,MEASURE_NAME,1)
WHEN NOT MATCHED BY SOURCE THEN UPDATE SET IsActive = 0;


-- query
MERGE [dbo].[Queries] TRG
USING
(
SELECT DISTINCT
 [QueryText]
,CONVERT(VARCHAR(40),HASHBYTES('MD5',[QueryText]),2) AS QueryHash
FROM [dbo].[SSAS_Monitoring]
) SRC
	ON TRG.[QueryHash] = SRC.QueryHash
WHEN NOT MATCHED THEN INSERT(QueryText,QueryHash) VALUES(QueryText,QueryHash);


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


-- columns in queries
MERGE [dbo].[ColumnsInQuery] TRG
USING
(
	SELECT 
	 Q.QueryId
	,C.ColumnId
	FROM [SSAS_Stat].[dbo].[Queries] Q
	INNER JOIN
	(
		SELECT C.ColumnId, CONCAT('[[]',T.TableName, '].[[]',C.ColumName,']') as PatternToFind
		FROM [dbo].[Tables] T
		INNER JOIN  dbo.Columns C
		ON C.TableId = T.TableId  
	)C
	ON PATINDEX(CONCAT('%',PatternToFind,'%'),Q.QueryText) > 0
)SRC
	ON TRG.QueryId = SRC.QueryId
	AND TRG.ColumnId = SRC.ColumnId
WHEN NOT MATCHED THEN INSERT (ColumnId,QueryId) VALUES (ColumnId,QueryId);


-- meausers in queries
MERGE [dbo].[MeasuresInQuery] TRG
USING
(
	SELECT 
	 Q.QueryId
	,C.MeasureId
	FROM [SSAS_Stat].[dbo].[Queries] Q
	INNER JOIN
	(
		SELECT M.MeasureId, CONCAT('[[]Measures].[[]',M.MeasureName,']') as PatternToFind
		FROM [dbo].[Tables] T
		INNER JOIN  dbo.Measures M
		ON M.TableId = T.TableId  
	)C
	ON PATINDEX(CONCAT('%',PatternToFind,'%'),Q.QueryText) > 0
)SRC
	ON TRG.QueryId = SRC.QueryId
	AND TRG.MeasureId = SRC.MeasureId
WHEN NOT MATCHED THEN INSERT (MeasureId,QueryId) VALUES (MeasureId,QueryId);


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