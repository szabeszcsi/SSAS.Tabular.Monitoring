CREATE TABLE [dbo].[Queries] (
    [QueryId]   INT            IDENTITY (1, 1) NOT NULL,
    [QueryText] NVARCHAR (MAX) NOT NULL,
    [QueryHash] VARCHAR (40)   NOT NULL,
    PRIMARY KEY CLUSTERED ([QueryId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [Idx_Queries_QueryHash]
    ON [dbo].[Queries]([QueryHash] ASC);

