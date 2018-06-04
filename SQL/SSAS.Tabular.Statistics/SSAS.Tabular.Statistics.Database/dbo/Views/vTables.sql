CREATE VIEW dbo.vTables
AS
SELECT [TableId]
      ,[DatabaseId]
      ,[TableName]
      ,[IsActive]
  FROM [SSAS_Stat].[dbo].[Tables]