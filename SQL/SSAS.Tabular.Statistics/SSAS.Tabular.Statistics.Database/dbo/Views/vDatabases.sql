CREATE VIEW dbo.vDatabases
AS
SELECT [DatabaseId]
      ,[DatabaseName]
  FROM [SSAS_Stat].[dbo].[Databases]