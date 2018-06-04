CREATE TABLE [dbo].[Tables] (
    [TableId]    INT            IDENTITY (0, 1) NOT NULL,
    [DatabaseId] INT            NOT NULL,
    [TableName]  NVARCHAR (255) NOT NULL,
    [IsActive]   BIT            DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([TableId] ASC),
    CONSTRAINT [FK_Table_Database] FOREIGN KEY ([DatabaseId]) REFERENCES [dbo].[Databases] ([DatabaseId])
);

