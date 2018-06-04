CREATE VIEW dbo.vQueries
AS
SELECT [QueryId]
      ,[QueryText]
      --,[QueryHash]
FROM [SSAS_Stat].[dbo].[Queries]