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

