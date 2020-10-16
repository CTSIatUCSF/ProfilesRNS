
CREATE TABLE [Profile.Data].[Publication.PubMed.GeneralNew](
	[PMID] [int] NOT NULL,
	[PMCID] [nvarchar](55) NULL,
	[Owner] [varchar](50) NULL,
	[Status] [varchar](50) NULL,
	[PubModel] [varchar](50) NULL,
	[Volume] [varchar](255) NULL,
	[Issue] [varchar](255) NULL,
	[MedlineDate] [varchar](255) NULL,
	[JournalYear] [varchar](50) NULL,
	[JournalMonth] [varchar](50) NULL,
	[JournalDay] [varchar](50) NULL,
	[JournalTitle] [varchar](1000) NULL,
	[ISOAbbreviation] [varchar](100) NULL,
	[MedlineTA] [varchar](1000) NULL,
	[ArticleTitle] [nvarchar](4000) NULL,
	[MedlinePgn] [varchar](255) NULL,
	[AbstractText] [text] NULL,
	[ArticleDateType] [varchar](50) NULL,
	[ArticleYear] [varchar](10) NULL,
	[ArticleMonth] [varchar](10) NULL,
	[ArticleDay] [varchar](10) NULL,
	[Affiliation] [varchar](8000) NULL,
	[AuthorListCompleteYN] [varchar](1) NULL,
	[GrantListCompleteYN] [varchar](1) NULL,
	[PubDate] [datetime] NULL,
	[Authors] [nvarchar](4000) NULL,
PRIMARY KEY CLUSTERED 
(
	[PMID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

insert into [Profile.Data].[Publication.PubMed.GeneralNew]
SELECT  [PMID]
      ,[PMCID]
      ,[Owner]
      ,[Status]
      ,[PubModel]
      ,[Volume]
      ,[Issue]
      ,[MedlineDate]
      ,[JournalYear]
      ,[JournalMonth]
      ,[JournalDay]
      ,[JournalTitle]
      ,[ISOAbbreviation]
      ,[MedlineTA]
      ,[ArticleTitle]
      ,[MedlinePgn]
      ,[AbstractText]
      ,[ArticleDateType]
      ,[ArticleYear]
      ,[ArticleMonth]
      ,[ArticleDay]
      ,[Affiliation]
      ,[AuthorListCompleteYN]
      ,[GrantListCompleteYN]
      ,[PubDate]
      ,[Authors]
  FROM [ProfilesRNS_Dev].[Profile.Data].[Publication.PubMed.General]

ALTER TABLE [Profile.Data].[Publication.PubMed.PubType] drop FK_pm_pubs_pubtypes_pm_pubs_general
ALTER TABLE [Profile.Data].[Publication.PubMed.PubType]  WITH NOCHECK ADD  CONSTRAINT [FK_pm_pubs_pubtypes_pm_pubs_general] FOREIGN KEY([PMID])
REFERENCES [Profile.Data].[Publication.PubMed.General] ([PMID])
GO

ALTER TABLE [Profile.Data].[Publication.PubMed.PubType] CHECK CONSTRAINT [FK_pm_pubs_pubtypes_pm_pubs_general]
GO

ALTER TABLE [Profile.Data].[Publication.PubMed.Author] DROP FK_pm_pubs_authors_pm_pubs_general
ALTER TABLE [Profile.Data].[Publication.PubMed.Author]  WITH NOCHECK ADD  CONSTRAINT [FK_pm_pubs_authors_pm_pubs_general] FOREIGN KEY([PMID])
REFERENCES [Profile.Data].[Publication.PubMed.General] ([PMID])
GO

ALTER TABLE [Profile.Data].[Publication.PubMed.Author] CHECK CONSTRAINT [FK_pm_pubs_authors_pm_pubs_general]
GO

ALTER TABLE [Profile.Data].[Publication.PubMed.Keyword] DROP [FK_pm_pubs_keywords_pm_pubs_general]
ALTER TABLE [Profile.Data].[Publication.PubMed.Keyword]  WITH CHECK ADD  CONSTRAINT [FK_pm_pubs_keywords_pm_pubs_general] FOREIGN KEY([PMID])
REFERENCES [Profile.Data].[Publication.PubMed.General] ([PMID])
GO

ALTER TABLE [Profile.Data].[Publication.PubMed.Keyword] CHECK CONSTRAINT [FK_pm_pubs_keywords_pm_pubs_general]
GO

ALTER TABLE [Profile.Data].[Publication.Person.Include] DROP [FK_publications_include_pm_pubs_general]
ALTER TABLE [Profile.Data].[Publication.Person.Include]  WITH NOCHECK ADD  CONSTRAINT [FK_publications_include_pm_pubs_general] FOREIGN KEY([PMID])
REFERENCES [Profile.Data].[Publication.PubMed.General] ([PMID])
GO

ALTER TABLE [Profile.Data].[Publication.Person.Include] CHECK CONSTRAINT [FK_publications_include_pm_pubs_general]
GO


