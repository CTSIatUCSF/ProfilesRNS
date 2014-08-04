SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [RDF.Security].[Group](
	[SecurityGroupID] [bigint] NOT NULL,
	[Label] [varchar](255) NOT NULL,
	[HasSpecialViewAccess] [bit] NULL,
	[HasSpecialEditAccess] [bit] NULL,
	[Description] [varchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[SecurityGroupID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO