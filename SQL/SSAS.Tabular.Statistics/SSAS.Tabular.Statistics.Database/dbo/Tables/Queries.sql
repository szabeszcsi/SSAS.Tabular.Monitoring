CREATE TABLE [dbo].[Queries] (
    [QueryId]    INT            IDENTITY (1, 1) NOT NULL,
    [QueryText]  NVARCHAR (MAX) NOT NULL,
    [QueryHash]  VARCHAR (40)   NOT NULL,
    [DatabaseId] INT            NULL,
    CONSTRAINT [PK__Queries__5967F7DBA0877554] PRIMARY KEY CLUSTERED ([QueryId] ASC),
    CONSTRAINT [FK_Queries_Database] FOREIGN KEY ([DatabaseId]) REFERENCES [dbo].[Databases] ([DatabaseId])
);










GO
CREATE NONCLUSTERED INDEX [Idx_Queries_QueryHash]
    ON [dbo].[Queries]([QueryHash] ASC);

