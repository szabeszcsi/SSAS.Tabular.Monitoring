CREATE TABLE [dbo].[ColumnsInQuery] (
    [ColumnsInQueryId] INT IDENTITY (1, 1) NOT NULL,
    [ColumnId]         INT NOT NULL,
    [QueryId]          INT NOT NULL,
    PRIMARY KEY CLUSTERED ([ColumnsInQueryId] ASC),
    CONSTRAINT [FK_ColumnsInQuery_Column] FOREIGN KEY ([ColumnId]) REFERENCES [dbo].[Columns] ([ColumnId]),
    CONSTRAINT [FK_ColumnsInQuery_Query] FOREIGN KEY ([QueryId]) REFERENCES [dbo].[Queries] ([QueryId])
);

