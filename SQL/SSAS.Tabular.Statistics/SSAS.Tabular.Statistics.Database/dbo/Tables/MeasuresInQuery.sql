CREATE TABLE [dbo].[MeasuresInQuery] (
    [MeasuresInQueryId] INT IDENTITY (1, 1) NOT NULL,
    [MeasureId]         INT NOT NULL,
    [QueryId]           INT NOT NULL,
    PRIMARY KEY CLUSTERED ([MeasuresInQueryId] ASC),
    CONSTRAINT [FK_MeasuresInQuery_Measure] FOREIGN KEY ([MeasureId]) REFERENCES [dbo].[Measures] ([MeasureId]),
    CONSTRAINT [FK_MeasuresInQuery_Query] FOREIGN KEY ([QueryId]) REFERENCES [dbo].[Queries] ([QueryId])
);

