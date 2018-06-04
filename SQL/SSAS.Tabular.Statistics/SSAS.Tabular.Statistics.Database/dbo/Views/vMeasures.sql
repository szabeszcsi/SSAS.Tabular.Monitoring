CREATE VIEW dbo.vMeasures
AS
SELECT [MeasureId]
      ,[TableId]
      ,[MeasureName]
      ,[IsActive]
FROM [SSAS_Stat].[dbo].[Measures]