-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [UCSF.].[GetDoiFromPubmed]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
/* Updating PublicationAddition table with newly added PubMed publications */
insert into [UCSF.].[PublicationAdditions]
    select  pmid,'PubMed',NULL,
		case when nref.value('Article[1]/ELocationID[@EIdType="doi"][1]','varchar(max)') like 'https://doi.org%' then
				REPLACE(nref.value('Article[1]/ELocationID[@EIdType="doi"][1]','varchar(max)'),'https://doi.org','')
			else nref.value('Article[1]/ELocationID[@EIdType="doi"][1]','varchar(max)') 
		end doi,
		'https://www.ncbi.nlm.nih.gov/pubmed/'+cast(pmid as varchar(10))
	from [Profile.Data].[Publication.PubMed.AllXML] a
		CROSS APPLY  x.nodes('//MedlineCitation[1]') as R(nref)
	where pmid not in ( select pmid from [UCSF.].[PublicationAdditions])
		  and nref.value('Article[1]/ELocationID[@EIdType="doi"][1]','varchar(max)') is not NULL
		  and (nref.value('Article[1]/ELocationID[@EIdType="doi"][1]','varchar(max)') like 'https://doi.org/10.%' 
			or nref.value('Article[1]/ELocationID[@EIdType="doi"][1]','varchar(max)') like '10.%')
 ;

insert into [UCSF.].[PublicationAdditions]
    select pmid,'PubMed',NULL,
		case when x.value('/PubmedArticle[1]/PubmedData[1]/ArticleIdList[1]/ArticleId[@IdType="doi"][1]','varchar(max)') like 'https://doi.org%' then
			REPLACE(x.value('/PubmedArticle[1]/PubmedData[1]/ArticleIdList[1]/ArticleId[@IdType="doi"][1]','varchar(max)'),'https://doi.org/','')
			else x.value('/PubmedArticle[1]/PubmedData[1]/ArticleIdList[1]/ArticleId[@IdType="doi"][1]','varchar(max)')
		end doi,
		'https://www.ncbi.nlm.nih.gov/pubmed/'+cast(pmid as varchar(10))
	from [Profile.Data].[Publication.PubMed.AllXML]
	where pmid not in (select pmid from [UCSF.].[PublicationAdditions]) 
		and x.exist('/PubmedArticle/PubmedData/ArticleIdList/ArticleId[@IdType[1] = "doi"]') = 1
		and x.value('/PubmedArticle[1]/PubmedData[1]/ArticleIdList[1]/ArticleId[@IdType="doi"][1]','varchar(max)') IS NOT NULL
		and (x.value('/PubmedArticle[1]/PubmedData[1]/ArticleIdList[1]/ArticleId[@IdType="doi"][1]','varchar(max)') like 'https://doi.org/10.%'
			or x.value('/PubmedArticle[1]/PubmedData[1]/ArticleIdList[1]/ArticleId[@IdType="doi"][1]','varchar(max)') like '10.%')
 ; 


END
GO
