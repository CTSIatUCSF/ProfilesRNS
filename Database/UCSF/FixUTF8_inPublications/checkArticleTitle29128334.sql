/****** Script for SelectTopNRows command from SSMS  ******/
/*
delete FROM [ProfilesRNS_Dev].[Profile.Data].[Publication.Entity.InformationResource]
  where pmid in (29128334,32904559,32950879);
delete[ProfilesRNS_Dev].[Profile.Data].[Publication.Person.Include]
where pmid in (29128334,32904559,32950879);
delete[ProfilesRNS_Dev].[Profile.Data].[Publication.Person.Add]
where pmid in (29128334,32904559,32950879);
delete FROM [ProfilesRNS_Dev].[Profile.Data].[Publication.PubMed.PubType]
  where pmid in (29128334,32904559,32950879)
DELETE FROM [ProfilesRNS_Dev].[Profile.Data].[Publication.PubMed.Author]
  where pmid in (29128334,32904559,32950879)
delete FROM [ProfilesRNS_Dev].[Profile.Data].[Publication.PubMed.General]
  where pmid in (29128334,32904559,32950879);
update [ProfilesRNS_Dev].[Profile.Data].[Publication.PubMed.AllXML] 
set ParseDT=NULL
where pmid in (29128334,32904559,32950879)
*/
SELECT TOP (1000) [PMID]
      ,[X]
      ,[ParseDT]
  FROM [ProfilesRNS_Dev].[Profile.Data].[Publication.PubMed.AllXML]
  where pmid in (29128334,32904559,32950879);
select * from [ProfilesRNS_Dev].[Profile.Data].[Publication.Person.Include]
where pmid in (29128334,32904559,32950879);
SELECT 'General',[PMID],
	case
		when LEN(ArticleTitle) >100 then substring([ArticleTitle],90,50)
		else ArticleTitle
	end 
	as ArticleTitle
  FROM [ProfilesRNS_Dev].[Profile.Data].[Publication.PubMed.General]
  where pmid in (29128334,32904559,32950879);
select entityID,substring(Reference,90,50) FROM [ProfilesRNS_Dev].[Profile.Data].[Publication.Entity.InformationResource]
  where pmid in (29128334,32904559,32950879);
SELECT lastName FROM [ProfilesRNS_Dev].[Profile.Data].[Publication.PubMed.Author]
  where pmid=32950879;