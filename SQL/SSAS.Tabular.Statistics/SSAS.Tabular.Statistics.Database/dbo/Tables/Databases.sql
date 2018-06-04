CREATE TABLE [dbo].[Databases] (
    [DatabaseId]   INT            IDENTITY (1, 1) NOT NULL,
    [DatabaseName] NVARCHAR (255) NOT NULL,
    PRIMARY KEY CLUSTERED ([DatabaseId] ASC)
);

