CREATE TABLE [dbo].[Measures] (
    [MeasureId]   INT            IDENTITY (1, 1) NOT NULL,
    [TableId]     INT            NOT NULL,
    [MeasureName] NVARCHAR (255) NOT NULL,
    [IsActive]    BIT            DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([MeasureId] ASC),
    CONSTRAINT [FK_Measure_Table] FOREIGN KEY ([TableId]) REFERENCES [dbo].[Tables] ([TableId])
);

