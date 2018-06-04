CREATE VIEW dbo.vTables
AS
SELECT [TableId]
      ,[DatabaseId]
      ,[TableName]
      ,[IsActive]
  FROM [dbo].[Tables]