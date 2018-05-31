GO
/****** Object:  Table [dbo].[SSAS_MonitoringParameters]    Script Date: 2018. 05. 28. 15:20:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SSAS_MonitoringParameters](
	[ParamName] [nvarchar](50) NOT NULL,
	[ParamValue] [nvarchar](255) NOT NULL
) ON [PRIMARY]
GO

/****** Object:  Index [UQ_SSAS_MonitoringParameters_ParamName]    Script Date: 2018. 05. 28. 15:20:55 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UQ_SSAS_MonitoringParameters_ParamName] ON [dbo].[SSAS_MonitoringParameters]
(
	[ParamName] ASC
)

GO

-- Initial load, change filenames a path corresponding to the xEvent's setup
GO
INSERT [dbo].[SSAS_MonitoringParameters] ([ParamName], [ParamValue]) VALUES (N'xEventStat_LastQueryDate', CAST(GETDATE() AS nvarchar(255)))
GO
INSERT [dbo].[SSAS_MonitoringParameters] ([ParamName], [ParamValue]) VALUES (N'xEventStat_FileOffset', N'0')
GO
INSERT [dbo].[SSAS_MonitoringParameters] ([ParamName], [ParamValue]) VALUES (N'xEventStat_FilePath', N'C:\Program Files\Microsoft SQL Server\MSAS14.SQL2017\OLAP\Log\')
GO
INSERT [dbo].[SSAS_MonitoringParameters] ([ParamName], [ParamValue]) VALUES (N'xEventStat_FileName', N'Stat')
GO
INSERT [dbo].[SSAS_MonitoringParameters] ([ParamName], [ParamValue]) VALUES (N'xEventStat_InitialFileName', N'Stat_0_131719810864740000')
GO
