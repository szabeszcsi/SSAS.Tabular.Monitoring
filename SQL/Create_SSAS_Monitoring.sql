GO

/****** Object:  Table [dbo].[SSAS_Monitoring]    Script Date: 2018. 05. 29. 9:50:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SSAS_Monitoring](
	[TimeStampUtc] [datetime2](7) NOT NULL,
	[EventType] [nvarchar](60) NOT NULL,
	[ServerName] [nvarchar](255) NULL,
	[DatabaseName] [nvarchar](255) NULL,
	[UserName] [nvarchar](255) NULL,
	[StartTime] [datetime] NULL,
	[Duration] [int] NULL,
	[CPUTime] [int] NULL,
	[QueryText] [nvarchar](max) NULL,
	[ObjectName] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


