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