CREATE TABLE [dbo].[SSAS_MonitoringParameters] (
    [ParamName]  NVARCHAR (50)  NOT NULL,
    [ParamValue] NVARCHAR (255) NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_SSAS_MonitoringParameters_ParamName]
    ON [dbo].[SSAS_MonitoringParameters]([ParamName] ASC);

