CREATE TABLE [dbo].[QueryExecutions] (
    [QueryExecutionId] INT            IDENTITY (1, 1) NOT NULL,
    [QueryId]          INT            NOT NULL,
    [UserName]         NVARCHAR (255) NOT NULL,
    [ExecutionTime]    DATETIME       NOT NULL,
    [Duration]         INT            NOT NULL,
    [CPUTime]          INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([QueryExecutionId] ASC),
    CONSTRAINT [FK_QueryExecutions_Query] FOREIGN KEY ([QueryId]) REFERENCES [dbo].[Queries] ([QueryId])
);

