USE [profilesRNS]
GO

/****** Object:  Table [UCSF.].[Publication.URL]    Script Date: 1/21/2020 10:57:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [UCSF.].[PublicationAdditions](
	[PMID] [int] NOT NULL,
	[DBType] [varchar](50) NULL,
	[ISSN] [varchar](20) NULL,
	[DOI] [varchar](1000) NULL,
	[URL] [varchar](1000) NULL
) ON [PRIMARY]

GO

insert into [UCSF.].[PublicationAdditions]
select * from [UCSF.].[Publication.URL];

insert into [UCSF.].[PublicationAdditions]
select pmid,'PubMedElectronic',NULL,
	nref.value('Article[1]/ELocationID[1]','varchar(max)') doi,
	'https://www.ncbi.nlm.nih.gov/pubmed/'+cast(pmid as varchar(10))
from [Profile.Data].[Publication.PubMed.AllXML] a
	 CROSS APPLY  x.nodes('//MedlineCitation[1]') as R(nref)
where nref.value('Article[1]/ELocationID[1]','varchar(max)') is not NULL
 and pmid not in (
 select pmid from [UCSF.].[PublicationAdditions]
 );

insert into [UCSF.].[PublicationAdditions]
select pmid,'PubMedPrint',NULL,
x.value('/PubmedArticle[1]/PubmedData[1]/ArticleIdList[1]/ArticleId[@IdType="doi"][1]','varchar(max)') as doi,
'https://www.ncbi.nlm.nih.gov/pubmed/'+cast(pmid as varchar(10))
 from [Profile.Data].[Publication.PubMed.AllXML]
 where x.exist('/PubmedArticle/PubmedData/ArticleIdList/ArticleId[@IdType[1] = "doi"]') = 1
	and x.value('/PubmedArticle[1]/PubmedData[1]/ArticleIdList[1]/ArticleId[@IdType="doi"][1]','varchar(max)') IS NOT NULL
 and pmid not in (
 select pmid from [UCSF.].[PublicationAdditions]
 ); 


 insert into [UCSF.].[PublicationAdditions]
select cast(PUB_MED as int),'PubMedFromDavis' DBType,NULL ISSN,doi,
'https://www.ncbi.nlm.nih.gov/pubmed/'+PUB_MED
from [ucdavis_pure_publications] where PUB_MED in (
	SELECT distinct cast([PUB_MED] as int) as pmid
	FROM [profilesRNS].[dbo].[ucdavis_pure_publications]
		 where pub_med !='' and doi !=''
		and PUB_MED not in (
			select cast(pmid as varchar) from [UCSF.].[PublicationAdditions]
		)
)


update [UCSF.].[PublicationAdditions]
set DBType='PubMed' where DBType like 'PubMed%'
select top 10 * from [UCSF.].[PublicationAdditions]