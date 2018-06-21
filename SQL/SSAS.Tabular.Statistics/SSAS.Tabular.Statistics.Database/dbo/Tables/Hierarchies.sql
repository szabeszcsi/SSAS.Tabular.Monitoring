CREATE TABLE [dbo].[Hierarchies] (
    [HierarchyId]   INT            IDENTITY (0, 1) NOT NULL,
    [TableId]       INT            NOT NULL,
    [HierarchyName] NVARCHAR (255) NOT NULL,
    [IsActive]      BIT            DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([HierarchyId] ASC),
    CONSTRAINT [FK_Hierarchy_Table] FOREIGN KEY ([TableId]) REFERENCES [dbo].[Tables] ([TableId])
);

