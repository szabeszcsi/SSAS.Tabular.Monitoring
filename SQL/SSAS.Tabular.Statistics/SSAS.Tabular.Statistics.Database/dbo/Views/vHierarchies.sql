
CREATE VIEW [dbo].[vHierarchies]
AS
SELECT [HierarchyId]
      ,[TableId]
      ,[HierarchyName]
      ,[IsActive]
  FROM [dbo].[Hierarchies]