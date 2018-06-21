CREATE TABLE [dbo].[HierarchiesInQuery] (
    [HierarchiesInQueryId] INT IDENTITY (1, 1) NOT NULL,
    [HierarchyId]          INT NOT NULL,
    [QueryId]              INT NOT NULL,
    PRIMARY KEY CLUSTERED ([HierarchiesInQueryId] ASC),
    CONSTRAINT [FK_HierarchiesInQuery_Hierarchy] FOREIGN KEY ([HierarchyId]) REFERENCES [dbo].[Hierarchies] ([HierarchyId]),
    CONSTRAINT [FK_HierarchiesInQuery_Query] FOREIGN KEY ([QueryId]) REFERENCES [dbo].[Queries] ([QueryId])
);

