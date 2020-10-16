USE [ProfilesRNS_Dev]
GO
drop table [Profile.Data].[Publication.Entity.InformationResourceNew]
/****** Object:  Table [Profile.Data].[Publication.Entity.InformationResource]    Script Date: 10/15/2020 4:26:20 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Profile.Data].[Publication.Entity.InformationResourceNew](
	[EntityID] [int] IDENTITY(1,1) NOT NULL,
	[PMID] [int] NULL,
	[PMCID] [nvarchar](55) NULL,
	[MPID] [nvarchar](50) NULL,
	[EntityName] [varchar](4000) NULL,
	[EntityDate] [datetime] NULL,
	[Reference] [nvarchar](max) NULL,
	[Source] [varchar](25) NULL,
	[URL] [varchar](2000) NULL,
	[PubYear] [int] NULL,
	[YearWeight] [float] NULL,
	[SummaryXML] [xml] NULL,
	[IsActive] [bit] NULL,
	[Authors] [varchar](4000) NULL,
 CONSTRAINT [PK__Publication.EntityNew__6892926B] PRIMARY KEY CLUSTERED 
(
	[EntityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

insert into [Profile.Data].[Publication.Entity.InformationResourceNew]
(
[PMID]
      ,[PMCID]
      ,[MPID]
      ,[EntityName]
      ,[EntityDate]
      ,[Reference]
      ,[Source]
      ,[URL]
      ,[PubYear]
      ,[YearWeight]
      ,[SummaryXML]
      ,[IsActive]
      ,[Authors]
	  )
select [PMID]
      ,[PMCID]
      ,[MPID]
      ,[EntityName]
      ,[EntityDate]
      ,[Reference]
      ,[Source]
      ,[URL]
      ,[PubYear]
      ,[YearWeight]
      ,[SummaryXML]
      ,[IsActive]
      ,[Authors]
	  from [ProfilesRNS_Dev].[Profile.Data].[Publication.Entity.InformationResource] 
