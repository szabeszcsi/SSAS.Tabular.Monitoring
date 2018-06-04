CREATE TABLE [dbo].[Columns] (
    [ColumnId]  INT            IDENTITY (0, 1) NOT NULL,
    [TableId]   INT            NOT NULL,
    [ColumName] NVARCHAR (255) NOT NULL,
    [IsActive]  BIT            DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([ColumnId] ASC),
    CONSTRAINT [FK_Column_Table] FOREIGN KEY ([TableId]) REFERENCES [dbo].[Tables] ([TableId])
);

