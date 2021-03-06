﻿/*
Deployment script for SSAS.Tabular.Statistics.Database

This code was generated by a tool.
Changes to this file may cause incorrect behavior and will be lost if
the code is regenerated.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "SSAS.Tabular.Statistics.Database"
:setvar DefaultFilePrefix "SSAS.Tabular.Statistics.Database"
:setvar DefaultDataPath ""
:setvar DefaultLogPath ""

GO
:on error exit
GO
/*
Detect SQLCMD mode and disable script execution if SQLCMD mode is not supported.
To re-enable the script after enabling SQLCMD mode, execute the following:
SET NOEXEC OFF; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'SQLCMD mode must be enabled to successfully execute this script.';
        SET NOEXEC ON;
    END


GO
USE [master];


GO

IF (DB_ID(N'$(DatabaseName)') IS NOT NULL) 
BEGIN
    ALTER DATABASE [$(DatabaseName)]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [$(DatabaseName)];
END

GO
PRINT N'Creating $(DatabaseName)...'
GO
CREATE DATABASE [$(DatabaseName)] COLLATE SQL_Latin1_General_CP1_CI_AS
GO
USE [$(DatabaseName)];


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ANSI_NULLS ON,
                ANSI_PADDING ON,
                ANSI_WARNINGS ON,
                ARITHABORT ON,
                CONCAT_NULL_YIELDS_NULL ON,
                NUMERIC_ROUNDABORT OFF,
                QUOTED_IDENTIFIER ON,
                ANSI_NULL_DEFAULT ON,
                CURSOR_DEFAULT LOCAL,
                RECOVERY FULL,
                CURSOR_CLOSE_ON_COMMIT OFF,
                AUTO_CREATE_STATISTICS ON,
                AUTO_SHRINK OFF,
                AUTO_UPDATE_STATISTICS ON,
                RECURSIVE_TRIGGERS OFF 
            WITH ROLLBACK IMMEDIATE;
        ALTER DATABASE [$(DatabaseName)]
            SET AUTO_CLOSE OFF 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET ALLOW_SNAPSHOT_ISOLATION OFF;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET READ_COMMITTED_SNAPSHOT OFF 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET AUTO_UPDATE_STATISTICS_ASYNC OFF,
                PAGE_VERIFY NONE,
                DATE_CORRELATION_OPTIMIZATION OFF,
                DISABLE_BROKER,
                PARAMETERIZATION SIMPLE,
                SUPPLEMENTAL_LOGGING OFF 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF IS_SRVROLEMEMBER(N'sysadmin') = 1
    BEGIN
        IF EXISTS (SELECT 1
                   FROM   [master].[dbo].[sysdatabases]
                   WHERE  [name] = N'$(DatabaseName)')
            BEGIN
                EXECUTE sp_executesql N'ALTER DATABASE [$(DatabaseName)]
    SET TRUSTWORTHY OFF,
        DB_CHAINING OFF 
    WITH ROLLBACK IMMEDIATE';
            END
    END
ELSE
    BEGIN
        PRINT N'The database settings cannot be modified. You must be a SysAdmin to apply these settings.';
    END


GO
IF IS_SRVROLEMEMBER(N'sysadmin') = 1
    BEGIN
        IF EXISTS (SELECT 1
                   FROM   [master].[dbo].[sysdatabases]
                   WHERE  [name] = N'$(DatabaseName)')
            BEGIN
                EXECUTE sp_executesql N'ALTER DATABASE [$(DatabaseName)]
    SET HONOR_BROKER_PRIORITY OFF 
    WITH ROLLBACK IMMEDIATE';
            END
    END
ELSE
    BEGIN
        PRINT N'The database settings cannot be modified. You must be a SysAdmin to apply these settings.';
    END


GO
ALTER DATABASE [$(DatabaseName)]
    SET TARGET_RECOVERY_TIME = 0 SECONDS 
    WITH ROLLBACK IMMEDIATE;


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET FILESTREAM(NON_TRANSACTED_ACCESS = OFF),
                CONTAINMENT = NONE 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET AUTO_CREATE_STATISTICS ON(INCREMENTAL = OFF),
                MEMORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT = OFF,
                DELAYED_DURABILITY = DISABLED 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET QUERY_STORE (QUERY_CAPTURE_MODE = ALL, DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_PLANS_PER_QUERY = 200, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 367), MAX_STORAGE_SIZE_MB = 100) 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE [$(DatabaseName)]
            SET QUERY_STORE = OFF 
            WITH ROLLBACK IMMEDIATE;
    END


GO
IF EXISTS (SELECT 1
           FROM   [master].[dbo].[sysdatabases]
           WHERE  [name] = N'$(DatabaseName)')
    BEGIN
        ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
        ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
        ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
        ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
        ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
        ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;
        ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
        ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;
    END


GO
IF fulltextserviceproperty(N'IsFulltextInstalled') = 1
    EXECUTE sp_fulltext_database 'enable';


GO
PRINT N'Creating [SSAS]...';


GO
EXECUTE sp_addlinkedserver @server = N'SSAS', @srvproduct = N'MSOLAP', @provider = N'MSOLAP', @datasrc = N'TSZDELL2015\SQL2017';


GO
PRINT N'Creating [dbo].[SSAS_MonitoringParameters]...';


GO
CREATE TABLE [dbo].[SSAS_MonitoringParameters] (
    [ParamName]  NVARCHAR (50)  NOT NULL,
    [ParamValue] NVARCHAR (255) NOT NULL
);


GO
PRINT N'Creating [dbo].[SSAS_MonitoringParameters].[UQ_SSAS_MonitoringParameters_ParamName]...';


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_SSAS_MonitoringParameters_ParamName]
    ON [dbo].[SSAS_MonitoringParameters]([ParamName] ASC);


GO
PRINT N'Creating [dbo].[SSAS_Monitoring]...';


GO
CREATE TABLE [dbo].[SSAS_Monitoring] (
    [TimeStampUtc] DATETIME2 (7)  NOT NULL,
    [EventType]    NVARCHAR (60)  NOT NULL,
    [ServerName]   NVARCHAR (255) NULL,
    [DatabaseName] NVARCHAR (255) NULL,
    [UserName]     NVARCHAR (255) NULL,
    [StartTime]    DATETIME       NULL,
    [Duration]     INT            NULL,
    [CPUTime]      INT            NULL,
    [QueryText]    NVARCHAR (MAX) NULL,
    [ObjectName]   NVARCHAR (MAX) NULL
);


GO
PRINT N'Creating [dbo].[QueryExecutions]...';


GO
CREATE TABLE [dbo].[QueryExecutions] (
    [QueryExecutionId] INT            IDENTITY (1, 1) NOT NULL,
    [QueryId]          INT            NOT NULL,
    [UserName]         NVARCHAR (255) NOT NULL,
    [ExecutionTime]    DATETIME       NOT NULL,
    [Duration]         INT            NOT NULL,
    [CPUTime]          INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([QueryExecutionId] ASC)
);


GO
PRINT N'Creating [dbo].[Queries]...';


GO
CREATE TABLE [dbo].[Queries] (
    [QueryId]   INT            IDENTITY (1, 1) NOT NULL,
    [QueryText] NVARCHAR (MAX) NOT NULL,
    [QueryHash] VARCHAR (40)   NOT NULL,
    PRIMARY KEY CLUSTERED ([QueryId] ASC)
);


GO
PRINT N'Creating [dbo].[Queries].[Idx_Queries_QueryHash]...';


GO
CREATE NONCLUSTERED INDEX [Idx_Queries_QueryHash]
    ON [dbo].[Queries]([QueryHash] ASC);


GO
PRINT N'Creating [dbo].[MeasuresInQuery]...';


GO
CREATE TABLE [dbo].[MeasuresInQuery] (
    [MeasuresInQueryId] INT IDENTITY (1, 1) NOT NULL,
    [MeasureId]         INT NOT NULL,
    [QueryId]           INT NOT NULL,
    PRIMARY KEY CLUSTERED ([MeasuresInQueryId] ASC)
);


GO
PRINT N'Creating [dbo].[ColumnsInQuery]...';


GO
CREATE TABLE [dbo].[ColumnsInQuery] (
    [ColumnsInQueryId] INT IDENTITY (1, 1) NOT NULL,
    [ColumnId]         INT NOT NULL,
    [QueryId]          INT NOT NULL,
    PRIMARY KEY CLUSTERED ([ColumnsInQueryId] ASC)
);


GO
PRINT N'Creating [dbo].[Tables]...';


GO
CREATE TABLE [dbo].[Tables] (
    [TableId]    INT            IDENTITY (0, 1) NOT NULL,
    [DatabaseId] INT            NOT NULL,
    [TableName]  NVARCHAR (255) NOT NULL,
    [IsActive]   BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([TableId] ASC)
);


GO
PRINT N'Creating [dbo].[Columns]...';


GO
CREATE TABLE [dbo].[Columns] (
    [ColumnId]  INT            IDENTITY (0, 1) NOT NULL,
    [TableId]   INT            NOT NULL,
    [ColumName] NVARCHAR (255) NOT NULL,
    [IsActive]  BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([ColumnId] ASC)
);


GO
PRINT N'Creating [dbo].[Measures]...';


GO
CREATE TABLE [dbo].[Measures] (
    [MeasureId]   INT            IDENTITY (0, 1) NOT NULL,
    [TableId]     INT            NOT NULL,
    [MeasureName] NVARCHAR (255) NOT NULL,
    [IsActive]    BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([MeasureId] ASC)
);


GO
PRINT N'Creating [dbo].[Databases]...';


GO
CREATE TABLE [dbo].[Databases] (
    [DatabaseId]   INT            IDENTITY (0, 1) NOT NULL,
    [DatabaseName] NVARCHAR (255) NOT NULL,
    PRIMARY KEY CLUSTERED ([DatabaseId] ASC)
);


GO
PRINT N'Creating unnamed constraint on [dbo].[Tables]...';


GO
ALTER TABLE [dbo].[Tables]
    ADD DEFAULT ((1)) FOR [IsActive];


GO
PRINT N'Creating unnamed constraint on [dbo].[Columns]...';


GO
ALTER TABLE [dbo].[Columns]
    ADD DEFAULT ((1)) FOR [IsActive];


GO
PRINT N'Creating unnamed constraint on [dbo].[Measures]...';


GO
ALTER TABLE [dbo].[Measures]
    ADD DEFAULT ((1)) FOR [IsActive];


GO
PRINT N'Creating [dbo].[FK_QueryExecutions_Query]...';


GO
ALTER TABLE [dbo].[QueryExecutions]
    ADD CONSTRAINT [FK_QueryExecutions_Query] FOREIGN KEY ([QueryId]) REFERENCES [dbo].[Queries] ([QueryId]);


GO
PRINT N'Creating [dbo].[FK_MeasuresInQuery_Measure]...';


GO
ALTER TABLE [dbo].[MeasuresInQuery]
    ADD CONSTRAINT [FK_MeasuresInQuery_Measure] FOREIGN KEY ([MeasureId]) REFERENCES [dbo].[Measures] ([MeasureId]);


GO
PRINT N'Creating [dbo].[FK_MeasuresInQuery_Query]...';


GO
ALTER TABLE [dbo].[MeasuresInQuery]
    ADD CONSTRAINT [FK_MeasuresInQuery_Query] FOREIGN KEY ([QueryId]) REFERENCES [dbo].[Queries] ([QueryId]);


GO
PRINT N'Creating [dbo].[FK_ColumnsInQuery_Column]...';


GO
ALTER TABLE [dbo].[ColumnsInQuery]
    ADD CONSTRAINT [FK_ColumnsInQuery_Column] FOREIGN KEY ([ColumnId]) REFERENCES [dbo].[Columns] ([ColumnId]);


GO
PRINT N'Creating [dbo].[FK_ColumnsInQuery_Query]...';


GO
ALTER TABLE [dbo].[ColumnsInQuery]
    ADD CONSTRAINT [FK_ColumnsInQuery_Query] FOREIGN KEY ([QueryId]) REFERENCES [dbo].[Queries] ([QueryId]);


GO
PRINT N'Creating [dbo].[FK_Table_Database]...';


GO
ALTER TABLE [dbo].[Tables]
    ADD CONSTRAINT [FK_Table_Database] FOREIGN KEY ([DatabaseId]) REFERENCES [dbo].[Databases] ([DatabaseId]);


GO
PRINT N'Creating [dbo].[FK_Column_Table]...';


GO
ALTER TABLE [dbo].[Columns]
    ADD CONSTRAINT [FK_Column_Table] FOREIGN KEY ([TableId]) REFERENCES [dbo].[Tables] ([TableId]);


GO
PRINT N'Creating [dbo].[FK_Measure_Table]...';


GO
ALTER TABLE [dbo].[Measures]
    ADD CONSTRAINT [FK_Measure_Table] FOREIGN KEY ([TableId]) REFERENCES [dbo].[Tables] ([TableId]);


GO
PRINT N'Creating [dbo].[vColumns]...';


GO
CREATE VIEW dbo.vColumns
AS
SELECT [ColumnId]
      ,[TableId]
      ,[ColumName]
      ,[IsActive]
FROM [dbo].[Columns]
GO
PRINT N'Creating [dbo].[vColumnsInQuery]...';


GO
CREATE VIEW dbo.vColumnsInQuery
AS
SELECT [ColumnsInQueryId]
      ,[ColumnId]
      ,[QueryId]
FROM [dbo].[ColumnsInQuery]
GO
PRINT N'Creating [dbo].[vDatabases]...';


GO
CREATE VIEW dbo.vDatabases
AS
SELECT [DatabaseId]
      ,[DatabaseName]
  FROM [dbo].[Databases]
GO
PRINT N'Creating [dbo].[vMeasures]...';


GO
CREATE VIEW dbo.vMeasures
AS
SELECT [MeasureId]
      ,[TableId]
      ,[MeasureName]
      ,[IsActive]
FROM [dbo].[Measures]
GO
PRINT N'Creating [dbo].[vMeasuresInQuery]...';


GO
CREATE VIEW dbo.vMeasuresInQuery
AS
SELECT [MeasuresInQueryId]
      ,[MeasureId]
      ,[QueryId]
  FROM [dbo].[MeasuresInQuery]
GO
PRINT N'Creating [dbo].[vQueries]...';


GO
CREATE VIEW dbo.vQueries
AS
SELECT [QueryId]
      ,[QueryText]
      --,[QueryHash]
FROM [dbo].[Queries]
GO
PRINT N'Creating [dbo].[vQueryExecutions]...';


GO
CREATE VIEW dbo.vQueryExecutions
AS
SELECT [QueryId]
      ,[UserName]
      ,CONVERT(date,[ExecutionTime]) AS [ExecutionDate]
	  ,CONVERT(time(0),[ExecutionTime]) AS [ExecutionTime]
      ,[Duration]
      ,[CPUTime]
  FROM [dbo].[QueryExecutions]
GO
PRINT N'Creating [dbo].[vTables]...';


GO
CREATE VIEW dbo.vTables
AS
SELECT [TableId]
      ,[DatabaseId]
      ,[TableName]
      ,[IsActive]
  FROM [dbo].[Tables]
GO
PRINT N'Creating [dbo].[GetxEventsStat]...';


GO
CREATE PROCEDURE [dbo].GetxEventsStat
AS BEGIN
SET NOCOUNT ON;

DECLARE @PATH NVARCHAR(MAX) = (SELECT ParamValue FROM [dbo].[SSAS_MonitoringParameters] WHERE [ParamName] = 'xEventStat_FilePath');
DECLARE @FILE NVARCHAR(MAX) = (SELECT ParamValue FROM [dbo].[SSAS_MonitoringParameters] WHERE [ParamName] = 'xEventStat_FileName');
DECLARE @INITIALFILE NVARCHAR(MAX) = (SELECT ParamValue FROM [dbo].[SSAS_MonitoringParameters] WHERE [ParamName] = 'xEventStat_InitialFileName');
DECLARE @FILEOFFSET BIGINT = (SELECT CAST(ParamValue AS BIGINT) FROM [dbo].[SSAS_MonitoringParameters] WHERE [ParamName] = 'xEventStat_FileOffset');
DECLARE @LASTQUERYTIME DATETIME = (SELECT CAST(ParamValue as DATETIME) FROM [dbo].[SSAS_MonitoringParameters] WHERE [ParamName] = 'xEventStat_LastQueryDate');

DECLARE @FULLFILE NVARCHAR(MAX) = CONCAT(@PATH, @FILE,'*.xel');
DECLARE @FULLINITIALFILE NVARCHAR(MAX) = CONCAT(@PATH, @INITIALFILE,'.xel');

IF OBJECT_ID('tempdb..#TEMP_xEventStat') IS NOT NULL DROP TABLE #TEMP_xEventStat;
CREATE TABLE #TEMP_xEventStat
(
 XMLDATA XML
,EventType NVARCHAR(60)
,TimeStampUtc DATETIME2(7)
,FileOffset BIGINT
)

IF(@FILEOFFSET > 0)
BEGIN
	INSERT INTO #TEMP_xEventStat
	SELECT
	CAST(event_data AS XML) AS XMLDATA,
	object_name AS EventType,
	timestamp_utc AS TimeStampUtc,
	file_offset AS FileOffset
	FROM sys.fn_xe_file_target_read_file(@FULLFILE, null, @FULLINITIALFILE, @FILEOFFSET)	
	WHERE cast(timestamp_utc as datetime)>= @lastQueryTime
END
ELSE BEGIN
	INSERT INTO #TEMP_xEventStat
	SELECT
	CAST(event_data AS XML) AS XMLDATA,
	object_name AS EventType,
	timestamp_utc AS TimeStampUtc,
	file_offset AS FileOffset
	FROM sys.fn_xe_file_target_read_file(@FULLFILE, null, null, null) 
	WHERE cast(timestamp_utc as datetime)>= @lastQueryTime

END;

IF(SELECT COUNT(1) FROM #TEMP_xEventStat) = 0
	RETURN;

;WITH CTE_QueryEnd(QueryEventData, EventType, TimeStampUtc)
AS
(
SELECT CAST(C.query('.') AS XML) AS QueryEventData, EventType, TimeStampUtc
FROM 
(
	SELECT
	XMLDATA, EventType, TimeStampUtc
	FROM #TEMP_xEventStat	
) a
CROSS APPLY a.XMLDATA.nodes('/event') as T(C)
)

INSERT INTO [dbo].[SSAS_Monitoring]
SELECT 
 TimeStampUtc
,EventType
,QueryEventData.value('(//event/data[@name="ServerName"]/value)[1]', 'nvarchar(255)') AS ServerName
,QueryEventData.value('(//event/data[@name="DatabaseName"]/value)[1]', 'nvarchar(255)') AS DatabaseName
,QueryEventData.value('(//event/data[@name="NTCanonicalUserName"]/value)[1]', 'nvarchar(255)') AS UserName
,QueryEventData.value('(//event/data[@name="StartTime"]/value)[1]', 'datetime') AS StartTime
,QueryEventData.value('(//event/data[@name="Duration"]/value)[1]', 'int') AS Duration
,QueryEventData.value('(//event/data[@name="CPUTime"]/value)[1]', 'int') AS CPUTime
,QueryEventData.value('(//event/data[@name="TextData"]/value)[1]', 'nvarchar(max)') AS QueryText
,QueryEventData.value('(//event/data[@name="ObjectName"]/value)[1]', 'nvarchar(max)') AS ObjectName
FROM CTE_QueryEnd;


SELECT @LASTQUERYTIME = MAX(TimeStampUtc) FROM #TEMP_xEventStat;
SET @FILEOFFSET = (SELECT TOP(1) FileOffset FROM #TEMP_xEventStat ORDER BY ROW_NUMBER() OVER(ORDER BY TimeStampUtc) DESC);

UPDATE [dbo].[SSAS_MonitoringParameters] 
SET ParamValue = CAST(@FILEOFFSET AS nvarchar(MAX))
WHERE [ParamName] = 'xEventStat_FileOffset'

UPDATE [dbo].[SSAS_MonitoringParameters] 
SET ParamValue = CAST(@LASTQUERYTIME AS nvarchar(MAX))
WHERE [ParamName] = 'xEventStat_LastQueryDate'

TRUNCATE TABLE #TEMP_xEventStat;
DROP TABLE #TEMP_xEventStat;

END
GO
PRINT N'Creating [dbo].[CleanUp_SSAS_Monitoring]...';


GO
CREATE PROCEDURE dbo.CleanUp_SSAS_Monitoring
AS BEGIN

SET NOCOUNT ON;

BEGIN TRY
BEGIN TRAN

DECLARE @RETENTIONDAYS INT = (SELECT CAST(ParamValue AS INT) FROM [dbo].[SSAS_MonitoringParameters] WHERE [ParamName] = 'StatExtract_RetentionDays');

DELETE FROM [dbo].[SSAS_Monitoring]
WHERE DATEADD(DAY, @RETENTIONDAYS, [TimeStampUtc]) < GETDATE()

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
PRINT N'Creating [dbo].[Load_StatDb]...';


GO
CREATE PROCEDURE [dbo].[Load_StatDb]
AS BEGIN
SET NOCOUNT ON;

BEGIN TRY
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
WHEN NOT MATCHED THEN INSERT(QueryText,QueryHash) VALUES(SRC.QueryText,SRC.QueryHash);


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
	FROM [dbo].[Queries] Q
	INNER JOIN
	(
		SELECT C.ColumnId, CONCAT('[[]',T.TableName, '].[[]',C.ColumName,']') as PatternToFind
		FROM [dbo].[Tables] T
		INNER JOIN  dbo.[Columns] C
		ON C.TableId = T.TableId  
	)C
	ON PATINDEX(CONCAT('%',PatternToFind,'%'),Q.QueryText) > 0
)SRC
	ON TRG.QueryId = SRC.QueryId
	AND TRG.ColumnId = SRC.ColumnId
WHEN NOT MATCHED THEN INSERT (ColumnId,QueryId) VALUES (SRC.ColumnId,SRC.QueryId);

--insert not matched
INSERT INTO [dbo].[ColumnsInQuery] (ColumnId, QueryId)
SELECT 0, Q.QueryId
FROM [dbo].[Queries] Q
LEFT JOIN [dbo].[ColumnsInQuery] CQ
	ON Q.QueryId = CQ.QueryId
WHERE CQ.QueryId IS NULL


-- meausers in queries
MERGE [dbo].[MeasuresInQuery] TRG
USING
(
	SELECT 
	 Q.QueryId
	,C.MeasureId
	FROM [dbo].[Queries] Q
	INNER JOIN
	(
		SELECT M.MeasureId, CONCAT('[[]Measures].[[]',M.MeasureName,']') as PatternToFind
		FROM [dbo].[Tables] T
		INNER JOIN dbo.Measures M
		ON M.TableId = T.TableId  
	)C
	ON PATINDEX(CONCAT('%',PatternToFind,'%'),Q.QueryText) > 0
)SRC
	ON TRG.QueryId = SRC.QueryId
	AND TRG.MeasureId = SRC.MeasureId
WHEN NOT MATCHED THEN INSERT (MeasureId,QueryId) VALUES (SRC.MeasureId,SRC.QueryId);

--insert not matched
INSERT INTO [dbo].[MeasuresInQuery] (MeasureId, QueryId)
SELECT 0, Q.QueryId
FROM [dbo].[Queries] Q
LEFT JOIN [dbo].[MeasuresInQuery] MQ
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
GO
/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/
GO
INSERT [dbo].[SSAS_MonitoringParameters] ([ParamName], [ParamValue]) VALUES (N'xEventStat_LastQueryDate', N'Jun  4 2018  4:38AM')
GO
INSERT [dbo].[SSAS_MonitoringParameters] ([ParamName], [ParamValue]) VALUES (N'xEventStat_FileOffset', N'223744')
GO
INSERT [dbo].[SSAS_MonitoringParameters] ([ParamName], [ParamValue]) VALUES (N'xEventStat_FilePath', N'C:\Program Files\Microsoft SQL Server\MSAS14.SQL2017\OLAP\Log\')
GO
INSERT [dbo].[SSAS_MonitoringParameters] ([ParamName], [ParamValue]) VALUES (N'xEventStat_FileName', N'Stat')
GO
INSERT [dbo].[SSAS_MonitoringParameters] ([ParamName], [ParamValue]) VALUES (N'xEventStat_InitialFileName', N'Stat_0_131723109417830000')
GO
INSERT [dbo].[SSAS_MonitoringParameters] ([ParamName], [ParamValue]) VALUES (N'StatExtract_LastRun', N'2018-06-04T07:07:36.457')
GO
INSERT [dbo].[SSAS_MonitoringParameters] ([ParamName], [ParamValue]) VALUES (N'StatExtract_RetentionDays', N'14')
GO

GO
SET IDENTITY_INSERT [dbo].[Databases] ON
INSERT INTO [dbo].[Databases] ([DatabaseId],[DatabaseName]) VALUES (0,'SYSTEM/UNKNOWN')
SET IDENTITY_INSERT [dbo].[Databases] OFF

GO
SET IDENTITY_INSERT [dbo].[Tables] ON
INSERT INTO [dbo].[Tables] ([TableId],[DatabaseId],[TableName],[IsActive]) VALUES(0,0,'SYSTEM/UNKNOWN',1)
SET IDENTITY_INSERT [dbo].[Tables] OFF

GO
SET IDENTITY_INSERT [dbo].[Columns] ON
INSERT INTO [dbo].[Columns] ([ColumnId],[TableId],[ColumName],[IsActive]) VALUES (0, 0, 'SYSTEM/UNKNOWN',1)
SET IDENTITY_INSERT [dbo].[Columns] OFF
GO

GO
SET IDENTITY_INSERT [dbo].[Measures] ON
INSERT INTO [dbo].[Measures] ([MeasureId], [TableId],[MeasureName],[IsActive]) VALUES (0, 0, 'SYSTEM/UNKNOWN',1)
SET IDENTITY_INSERT [dbo].[Measures] OFF
GO

GO

GO
DECLARE @VarDecimalSupported AS BIT;

SELECT @VarDecimalSupported = 0;

IF ((ServerProperty(N'EngineEdition') = 3)
    AND (((@@microsoftversion / power(2, 24) = 9)
          AND (@@microsoftversion & 0xffff >= 3024))
         OR ((@@microsoftversion / power(2, 24) = 10)
             AND (@@microsoftversion & 0xffff >= 1600))))
    SELECT @VarDecimalSupported = 1;

IF (@VarDecimalSupported > 0)
    BEGIN
        EXECUTE sp_db_vardecimal_storage_format N'$(DatabaseName)', 'ON';
    END


GO
ALTER DATABASE [$(DatabaseName)]
    SET MULTI_USER 
    WITH ROLLBACK IMMEDIATE;


GO
PRINT N'Update complete.';


GO
