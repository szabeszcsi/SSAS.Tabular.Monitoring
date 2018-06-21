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
SET IDENTITY_INSERT [dbo].[Hierarchies] ON
INSERT INTO [dbo].[Hierarchies] ([HierarchyId], [TableId],[HierarchyName],[IsActive]) VALUES (0, 0, 'SYSTEM/UNKNOWN',1)
SET IDENTITY_INSERT [dbo].[Hierarchies] OFF
GO


