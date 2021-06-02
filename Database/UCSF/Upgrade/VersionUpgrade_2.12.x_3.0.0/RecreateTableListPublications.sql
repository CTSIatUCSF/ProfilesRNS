USE [profilesRNS]
GO

/****** Object:  Table [Profile.Cache].[List.Export.Publications]    Script Date: 6/2/2021 12:28:18 PM ******/
DROP TABLE [Profile.Cache].[List.Export.Publications]
GO

/****** Object:  Table [Profile.Cache].[List.Export.Publications]    Script Date: 6/2/2021 12:28:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Profile.Cache].[List.Export.Publications](
	[PersonID] [int] NOT NULL,
	[Data] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO


