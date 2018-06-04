CREATE VIEW dbo.vColumns
AS
SELECT [ColumnId]
      ,[TableId]
      ,[ColumName]
      ,[IsActive]
FROM [SSAS_Stat].[dbo].[Columns]