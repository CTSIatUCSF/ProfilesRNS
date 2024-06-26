USE [profilesRNS]
GO
/****** Object:  StoredProcedure [UCSF.].[FindWrongXML]    Script Date: 10/18/2021 4:02:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [UCSF.].[FindWrongXML]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	delete from [UCSF.].[PubmedXMLListForDisambiguation]
	insert into [UCSF.].[PubmedXMLListForDisambiguation]
	select pmid
			--,nref.value('PMID[1]','varchar(50)') XMLPMID
	from [Profile.Data].[Publication.PubMed.AllXML] cross apply x.nodes('//MedlineCitation[1]') as R(nref)
	where pmid>0
		and nref.value('PMID[1]','varchar(50)') !=cast(pmid as varchar(50));
	select ls.pmid, nref.value('PMID[1]','varchar(50)') XMLPMID,parseDT
	from [UCSF.].[PubmedXMLListForDisambiguation] ls 
	join [Profile.Data].[Publication.PubMed.AllXML]  xmls
		cross apply x.nodes('//MedlineCitation[1]') as R(nref) on ls.pmid=xmls.pmid 
END
