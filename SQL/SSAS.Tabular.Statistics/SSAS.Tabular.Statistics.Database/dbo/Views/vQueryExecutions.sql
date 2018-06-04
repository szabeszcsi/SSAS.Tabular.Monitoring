CREATE VIEW dbo.vQueryExecutions
AS
SELECT [QueryId]
      ,[UserName]
      ,CONVERT(date,[ExecutionTime]) AS [ExecutionDate]
	  ,CONVERT(time(0),[ExecutionTime]) AS [ExecutionTime]
      ,[Duration]
      ,[CPUTime]
  FROM [dbo].[QueryExecutions]