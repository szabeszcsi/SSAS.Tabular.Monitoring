/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM [SSAS_Stat].[dbo].[HierarchiesInQuery] HQ
  INNER JOIN [dbo].[Queries] Q
	ON HQ.QueryId = Q.QueryId
  INNER JOIN [dbo].[Hierarchies] H
	ON HQ.HierarchyId = H.HierarchyId