USE [profilesRNS]
GO
/****** Object:  StoredProcedure [Profile.Data].[Publication.Pubmed.ParseALLPubMedXML]    Script Date: 5/24/2022 10:38:35 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [Profile.Data].[Publication.Pubmed.ParseALLPubMedXML]
AS
BEGIN
	SET NOCOUNT ON;

	--*** general ***
	truncate table [Profile.Data].[Publication.PubMed.General.Stage]
	insert into [Profile.Data].[Publication.PubMed.General.Stage] (pmid, Owner, Status, PubModel, Volume, Issue, MedlineDate, JournalYear, JournalMonth, JournalDay, JournalTitle, ISOAbbreviation, MedlineTA, ArticleTitle, MedlinePgn, AbstractText, ArticleDateType, ArticleYear, ArticleMonth, ArticleDay, Affiliation, AuthorListCompleteYN, GrantListCompleteYN,PMCID, DOI)
		select pmid, 
			nref.value('MedlineCitation[1]/@Owner[1]','varchar(50)') Owner,
			nref.value('MedlineCitation[1]/@Status[1]','varchar(50)') Status,
			nref.value('MedlineCitation[1]/Article[1]/@PubModel','varchar(50)') PubModel,
			nref.value('MedlineCitation[1]/Article[1]/Journal[1]/JournalIssue[1]/Volume[1]','varchar(255)') Volume,
			nref.value('MedlineCitation[1]/Article[1]/Journal[1]/JournalIssue[1]/Issue[1]','varchar(255)') Issue,
			nref.value('MedlineCitation[1]/Article[1]/Journal[1]/JournalIssue[1]/PubDate[1]/MedlineDate[1]','varchar(255)') MedlineDate,
			nref.value('MedlineCitation[1]/Article[1]/Journal[1]/JournalIssue[1]/PubDate[1]/Year[1]','varchar(50)') JournalYear,
			nref.value('MedlineCitation[1]/Article[1]/Journal[1]/JournalIssue[1]/PubDate[1]/Month[1]','varchar(50)') JournalMonth,
			nref.value('MedlineCitation[1]/Article[1]/Journal[1]/JournalIssue[1]/PubDate[1]/Day[1]','varchar(50)') JournalDay,
			nref.value('MedlineCitation[1]/Article[1]/Journal[1]/Title[1]','varchar(1000)') JournalTitle,
			nref.value('MedlineCitation[1]/Article[1]/Journal[1]/ISOAbbreviation[1]','varchar(100)') ISOAbbreviation,
			nref.value('MedlineCitation[1]/MedlineJournalInfo[1]/MedlineTA[1]','varchar(1000)') MedlineTA,
			nref.value('MedlineCitation[1]/Article[1]/ArticleTitle[1]','nvarchar(4000)') ArticleTitle,
			nref.value('MedlineCitation[1]/Article[1]/Pagination[1]/MedlinePgn[1]','varchar(255)') MedlinePgn,
			nref.value('MedlineCitation[1]/Article[1]/Abstract[1]/AbstractText[1]','varchar(max)') AbstractText,
			nref.value('MedlineCitation[1]/Article[1]/ArticleDate[1]/@DateType[1]','varchar(50)') ArticleDateType,
			NULLIF(nref.value('MedlineCitation[1]/Article[1]/ArticleDate[1]/Year[1]','varchar(10)'),'') ArticleYear,
			NULLIF(nref.value('MedlineCitation[1]/Article[1]/ArticleDate[1]/Month[1]','varchar(10)'),'') ArticleMonth,
			NULLIF(nref.value('MedlineCitation[1]/Article[1]/ArticleDate[1]/Day[1]','varchar(10)'),'') ArticleDay,
			Affiliation = COALESCE(nref.value('MedlineCitation[1]/Article[1]/AuthorList[1]/Author[1]/AffiliationInfo[1]/Affiliation[1]','varchar(8000)'),
				nref.value('MedlineCitation[1]/Article[1]/AuthorList[1]/Author[1]/Affiliation[1]','varchar(8000)'),
				nref.value('MedlineCitation[1]/Article[1]/Affiliation[1]','varchar(8000)')) ,
			nref.value('MedlineCitation[1]/Article[1]/AuthorList[1]/@CompleteYN[1]','varchar(1)') AuthorListCompleteYN,
			nref.value('MedlineCitation[1]/Article[1]/GrantList[1]/@CompleteYN[1]','varchar(1)') GrantListCompleteYN,
			--PMCID=COALESCE(nref.value('(OtherID[@Source="NLM" and text()[contains(.,"PMC")]])[1]', 'varchar(55)'), nref.value('(OtherID[@Source="NLM"][1])','varchar(55)'))
			nref.value('PubmedData[1]/ArticleIdList[1]/ArticleId[@IdType="pmc"][1]', 'varchar(100)') pmcid,
			nref.value('PubmedData[1]/ArticleIdList[1]/ArticleId[@IdType="doi"][1]', 'varchar(100)') doi
		from [Profile.Data].[Publication.PubMed.AllXML] cross apply x.nodes('//PubmedArticle[1]') as R(nref)
		where ParseDT is null and x is not null

		update [Profile.Data].[Publication.PubMed.General.Stage]
		set MedlineDate = (case when right(MedlineDate,4) like '20__' then ltrim(rtrim(right(MedlineDate,4)+' '+left(MedlineDate,len(MedlineDate)-4))) else null end)
		where MedlineDate is not null and MedlineDate not like '[0-9][0-9][0-9][0-9]%'

		
		update [Profile.Data].[Publication.PubMed.General.Stage]
		set PubDate = [Profile.Data].[fnPublication.Pubmed.GetPubDate](medlinedate,journalyear,journalmonth,journalday,articleyear,articlemonth,articleday)


	--*** authors ***
	truncate table [Profile.Data].[Publication.PubMed.Author.Stage]
	insert into [Profile.Data].[Publication.PubMed.Author.Stage] (pmid, ValidYN, LastName, FirstName, ForeName, CollectiveName, Suffix, Initials, ORCID, Affiliation)
		select pmid, 
			nref.value('@ValidYN','varchar(1)') ValidYN, 
			nref.value('LastName[1]','nvarchar(100)') LastName, 
			nref.value('FirstName[1]','nvarchar(100)') FirstName,
			nref.value('ForeName[1]','nvarchar(100)') ForeName,
			nref.value('CollectiveName[1]', 'nvarchar(100)') CollectiveName,
			nref.value('Suffix[1]','nvarchar(20)') Suffix,
			nref.value('Initials[1]','nvarchar(20)') Initials,
			nref.value('Identifier[@Source="ORCID"][1]', 'varchar(50)') ORCID,
			COALESCE(nref.value('AffiliationInfo[1]/Affiliation[1]','varchar(1000)'),
				nref.value('Affiliation[1]','varchar(max)')) Affiliation

		from [Profile.Data].[Publication.PubMed.AllXML] cross apply x.nodes('//AuthorList/Author') as R(nref)
		where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
		

	
		update [Profile.Data].[Publication.PubMed.Author.Stage] set orcid = replace(ORCID, 'http://orcid.org/', '')
		update [Profile.Data].[Publication.PubMed.Author.Stage] set orcid = replace(ORCID, 'https://orcid.org/', '')
		update [Profile.Data].[Publication.PubMed.Author.Stage] SET ORCID =  SUBSTRING(ORCID, 1, 4) + '-' + SUBSTRING(ORCID, 5, 4) + '-' + SUBSTRING(ORCID, 9, 4) + '-' + SUBSTRING(ORCID, 13, 4) where ORCID is not null and len(ORCID) = 16
		update [Profile.Data].[Publication.PubMed.Author.Stage] SET ORCID = LTRIM(RTRIM(ORCID))

		update [Profile.Data].[Publication.PubMed.Author.Stage] set valueHash = HASHBYTES('SHA1', cast(pmid as varchar(100)) + '|||' + isnull(LastName, '') + '|||' + isnull(ValidYN, '') + '|||' + isnull(FirstName, '') + '|||' + isnull(ForeName, '') + '|||' + isnull(Suffix, '') + '|||' + isnull(Initials, '') + '|||' + isnull(CollectiveName, '') + '|||' + isnull(ORCID, '') + '|||' + isnull(Affiliation, ''))

	--*** general (authors) ***

	create table #a (pmid int primary key, authors nvarchar(4000))
	insert into #a(pmid,authors)
		select pmid,
			(case	when len(s) < 3990 then s
					when charindex(',',reverse(left(s,3990)))>0 then
						left(s,3990-charindex(',',reverse(left(s,3990))))+', et al'
					else left(s,3990)
					end) authors
		from (
			select pmid, substring(s,3,len(s)) s
			from (
				select pmid, isnull(cast((
					select isnull(', '+lastname+' '+initials, ', '+CollectiveName)
					from [Profile.Data].[Publication.PubMed.Author.Stage] q
					where q.pmid = p.pmid
					order by PmPubsAuthorID
					for xml path(''), type
				) as nvarchar(max)),'') s
				from [Profile.Data].[Publication.PubMed.General.Stage] p
			) t
		) t

	--[10132 in 00:00:01]
	update g
		set g.authors = isnull(a.authors,'')
		from [Profile.Data].[Publication.PubMed.General.Stage] g, #a a
		where g.pmid = a.pmid
	update [Profile.Data].[Publication.PubMed.General.Stage]
		set authors = ''
		where authors is null
		
		
		
	--*** mesh ***
	truncate table [Profile.Data].[Publication.PubMed.Mesh.Stage]
	insert into [Profile.Data].[Publication.PubMed.Mesh.Stage] (pmid, DescriptorName, QualifierName, MajorTopicYN)
		select pmid, DescriptorName, IsNull(QualifierName,''), max(MajorTopicYN)
		from (
			select pmid, 
				nref.value('@MajorTopicYN[1]','varchar(1)') MajorTopicYN, 
				nref.value('.','varchar(255)') DescriptorName,
				null QualifierName
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//MeshHeadingList/MeshHeading/DescriptorName') as R(nref)
			where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
			union all
			select pmid, 
				nref.value('@MajorTopicYN[1]','varchar(1)') MajorTopicYN, 
				nref.value('../DescriptorName[1]','varchar(255)') DescriptorName,
				nref.value('.','varchar(255)') QualifierName
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//MeshHeadingList/MeshHeading/QualifierName') as R(nref)
			where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
		) t where DescriptorName is not null
		group by pmid, DescriptorName, QualifierName

		
	--******************************************************************
	--******************************************************************
	--*** Update General
	--******************************************************************
	--******************************************************************

	update g
		set 
			g.pmid=a.pmid,
			g.pmcid=a.pmcid,
			g.doi = a.doi,
			g.Owner=a.Owner,
			g.Status=a.Status,
			g.PubModel=a.PubModel,
			g.Volume=a.Volume,
			g.Issue=a.Issue,
			g.MedlineDate=a.MedlineDate,
			g.JournalYear=a.JournalYear,
			g.JournalMonth=a.JournalMonth,
			g.JournalDay=a.JournalDay,
			g.JournalTitle=a.JournalTitle,
			g.ISOAbbreviation=a.ISOAbbreviation,
			g.MedlineTA=a.MedlineTA,
			g.ArticleTitle=a.ArticleTitle,
			g.MedlinePgn=a.MedlinePgn,
			g.AbstractText=a.AbstractText,
			g.ArticleDateType=a.ArticleDateType,
			g.ArticleYear=a.ArticleYear,
			g.ArticleMonth=a.ArticleMonth,
			g.ArticleDay=a.ArticleDay,
			g.Affiliation=a.Affiliation,
			g.AuthorListCompleteYN=a.AuthorListCompleteYN,
			g.GrantListCompleteYN=a.GrantListCompleteYN,
			g.PubDate = a.PubDate,
			g.Authors = a.Authors
		from [Profile.Data].[Publication.PubMed.General] (nolock) g
			inner join [Profile.Data].[Publication.PubMed.General.Stage] a
				on g.pmid = a.pmid
				
	insert into [Profile.Data].[Publication.PubMed.General] (pmid, pmcid, Owner, Status, PubModel, Volume, Issue, MedlineDate, JournalYear, JournalMonth, JournalDay, JournalTitle, ISOAbbreviation, MedlineTA, ArticleTitle, MedlinePgn, AbstractText, ArticleDateType, ArticleYear, ArticleMonth, ArticleDay, Affiliation, AuthorListCompleteYN, GrantListCompleteYN, PubDate, Authors, doi)
		select pmid, pmcid, Owner, Status, PubModel, Volume, Issue, MedlineDate, JournalYear, JournalMonth, JournalDay, JournalTitle, ISOAbbreviation, MedlineTA, ArticleTitle, MedlinePgn, AbstractText, ArticleDateType, ArticleYear, ArticleMonth, ArticleDay, Affiliation, AuthorListCompleteYN, GrantListCompleteYN, PubDate, Authors, doi
			from [Profile.Data].[Publication.PubMed.General.Stage]
			where pmid not in (select pmid from [Profile.Data].[Publication.PubMed.General])
	
	
	--******************************************************************
	--******************************************************************
	--*** Update Authors
	--******************************************************************
	--******************************************************************
	update a set a.ExistingPmPubsAuthorID = b.PmPubsAuthorID 
		from [Profile.Data].[Publication.PubMed.Author.Stage] a 
			join [Profile.Data].[Publication.PubMed.Author] b
			on a.ValueHash = b.ValueHash 

IF OBJECT_ID('tempdb..#rewritePmids') IS NULL
begin
CREATE TABLE #rewritePmids(
	[pmid] [int] NULL
) ON [PRIMARY]
end
truncate table #rewritePmids

insert into #rewritePmids
select pmid from   [Profile.Data].[Publication.PubMed.Author.Stage]
where ExistingPmPubsAuthorID is NULL

insert into #rewritePmids 
select a.pmid from ( 
(
	select pmid, count(*) countXMLID
	from [Profile.Data].[Publication.PubMed.Author.Stage]
	where PMID in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
	group by pmid
	) a
join
(
	select pmid,count(*) countOldID
	from [Profile.Data].[Publication.PubMed.Author]
	where PMID in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
	group by pmid
	) stage on a.pmid=stage.pmid
)
where countXMLID !=countOldID

select 'rewritePmids before checking order of authors',* from #rewritePmids
/*
declare @curPmid int=-1
declare @wrongOrder int=0

DECLARE author_cursor CURSOR FOR
	SELECT distinct pmid
	from [Profile.Data].[Publication.PubMed.Author.Stage]
	where PMID in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
	and pmid not in (select pmid from #rewritePmids)
	OPEN author_cursor;
	FETCH NEXT FROM author_cursor INTO @curPmid
	WHILE (@@FETCH_STATUS <> -1 )
		BEGIN
	
			IF OBJECT_ID('tempdb..#pmid_authors') IS NULL
			begin
			 print 'creating pmid_authors'
				create table #pmid_authors
					([PMID] int, [ExistingPMPubsAuthorID] int);
			end
			truncate table #pmid_authors

			print @curPmid
			insert into #pmid_authors
			select pmid,ExistingPMPubsAuthorID  from [Profile.Data].[Publication.PubMed.Author.Stage]
			where pmid=@curPmid
			order by PMPubsAuthorID

	--		select * from #pmid_authors


			select @wrongOrder=count(*) from (
				select t.pmid, t.ExistingPmPubsAuthorID
				from (
					select *,
					row_number() over (order by pmid desc) rn1,
					row_number() over (order by ISNull(ExistingPmPubsAuthorID,0)) rn2
					from #pmid_authors
				) t
				where rn1 > rn2
			) a

print '@wrongorder='+cast(@wrongOrder as varchar)

		if @wrongOrder>0 insert  into #rewritePmids	values ( @curPmid)
			FETCH NEXT FROM author_cursor INTO @curPmid
		END
	CLOSE author_cursor;
	DEALLOCATE author_cursor;

select 'rewritePmids afterchecking order', * from #rewritePmids
*/
	select PmPubsAuthorID into #DeletedAuthors from [Profile.Data].[Publication.PubMed.Author]
	 where PMID in (select pmid from #rewritePmids)
select * from #DeletedAuthors



	delete from [Profile.Data].[Publication.PubMed.Author2Person] where PmPubsAuthorID in (select PmPubsAuthorID from #DeletedAuthors)
	delete from [Profile.Data].[Publication.PubMed.Author] where PmPubsAuthorID in (select PmPubsAuthorID from #DeletedAuthors)

select * from [Profile.Data].[Publication.PubMed.Author] where pmid in (select pmid from #rewritePmids)
		insert into [Profile.Data].[Publication.PubMed.Author] (pmid, ValidYN, LastName, FirstName, ForeName, CollectiveName, Suffix, Initials, ORCID, Affiliation, ValueHash)
		select pmid, ValidYN, LastName, FirstName, ForeName, CollectiveName, Suffix, Initials, ORCID, Affiliation, ValueHash
		from [Profile.Data].[Publication.PubMed.Author.Stage] where pmid in (select distinct pmid from #rewritePmids)
		order by PmPubsAuthorID


/*

	select PmPubsAuthorID into #DeletedAuthors from [Profile.Data].[Publication.PubMed.Author] where PMID in (select PMID from [Profile.Data].[Publication.PubMed.General.Stage])
		and PmPubsAuthorID not in (select ExistingPmPubsAuthorID from [Profile.Data].[Publication.PubMed.Author.Stage])

	delete from [Profile.Data].[Publication.PubMed.Author2Person] where PmPubsAuthorID in (select PmPubsAuthorID from #DeletedAuthors)

	delete from [Profile.Data].[Publication.PubMed.Author] where PmPubsAuthorID in (select PmPubsAuthorID from #DeletedAuthors)
	insert into [Profile.Data].[Publication.PubMed.Author] (pmid, ValidYN, LastName, FirstName, ForeName, CollectiveName, Suffix, Initials, ORCID, Affiliation, ValueHash)
		select pmid, ValidYN, LastName, FirstName, ForeName, CollectiveName, Suffix, Initials, ORCID, Affiliation, ValueHash
		from [Profile.Data].[Publication.PubMed.Author.Stage] where ExistingPmPubsAuthorID is null
		order by PmPubsAuthorID
*/
	exec [Profile.Data].[Publication.Pubmed.UpdateAuthor2Person] @UseStagePMIDs = 1

	--******************************************************************
	--******************************************************************
	--*** Update MeSH
	--******************************************************************
	--******************************************************************


	--*** mesh ***
	delete from [Profile.Data].[Publication.PubMed.Mesh] where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
	--[16593 in 00:00:11]
	insert into [Profile.Data].[Publication.PubMed.Mesh]
		select * from [Profile.Data].[Publication.PubMed.Mesh.Stage]
	--[86375 in 00:00:17]

		
		
		
	--*** investigators ***
	delete from [Profile.Data].[Publication.PubMed.Investigator] where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
	insert into [Profile.Data].[Publication.PubMed.Investigator] (pmid, LastName, FirstName, ForeName, Suffix, Initials, Affiliation)
		select pmid, 
			nref.value('LastName[1]','varchar(100)') LastName, 
			nref.value('FirstName[1]','varchar(100)') FirstName,
			nref.value('ForeName[1]','varchar(100)') ForeName,
			nref.value('Suffix[1]','varchar(20)') Suffix,
			nref.value('Initials[1]','varchar(20)') Initials,
			COALESCE(nref.value('AffiliationInfo[1]/Affiliation[1]','varchar(1000)'),
				nref.value('Affiliation[1]','varchar(1000)')) Affiliation
		from [Profile.Data].[Publication.PubMed.AllXML] cross apply x.nodes('//InvestigatorList/Investigator') as R(nref)
		where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
		

	--*** pubtype ***
	delete from [Profile.Data].[Publication.PubMed.PubType] where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
	insert into [Profile.Data].[Publication.PubMed.PubType] (pmid, PublicationType)
		select * from (
			select distinct pmid, nref.value('.','varchar(100)') PublicationType
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//PublicationTypeList/PublicationType') as R(nref)
			where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
		) t where PublicationType is not null


	--*** chemicals
	delete from [Profile.Data].[Publication.PubMed.Chemical] where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
	insert into [Profile.Data].[Publication.PubMed.Chemical] (pmid, NameOfSubstance)
		select * from (
			select distinct pmid, nref.value('.','varchar(255)') NameOfSubstance
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//ChemicalList/Chemical/NameOfSubstance') as R(nref)
			where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
		) t where NameOfSubstance is not null


	--*** databanks ***
	delete from [Profile.Data].[Publication.PubMed.Databank] where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
	insert into [Profile.Data].[Publication.PubMed.Databank] (pmid, DataBankName)
		select * from (
			select distinct pmid, 
				nref.value('.','varchar(100)') DataBankName
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//DataBankList/DataBank/DataBankName') as R(nref)
			where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
		) t where DataBankName is not null


	--*** accessions ***
	delete from [Profile.Data].[Publication.PubMed.Accession] where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
	insert into [Profile.Data].[Publication.PubMed.Accession] (pmid, DataBankName, AccessionNumber)
		select * from (
			select distinct pmid, 
				nref.value('../../DataBankName[1]','varchar(100)') DataBankName,
				nref.value('.','varchar(50)') AccessionNumber
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//DataBankList/DataBank/AccessionNumberList/AccessionNumber') as R(nref)
			where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
		) t where DataBankName is not null and AccessionNumber is not null


	--*** keywords ***
	delete from [Profile.Data].[Publication.PubMed.Keyword] where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
	insert into [Profile.Data].[Publication.PubMed.Keyword] (pmid, Keyword, MajorTopicYN)
		select pmid, Keyword, max(MajorTopicYN)
		from (
			select pmid, 
				nref.value('.','varchar(895)') Keyword,
				nref.value('@MajorTopicYN','varchar(1)') MajorTopicYN
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//KeywordList/Keyword') as R(nref)
			where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
		) t where Keyword is not null
		group by pmid, Keyword


	--*** grants ***
	delete from [Profile.Data].[Publication.PubMed.Grant] where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
	insert into [Profile.Data].[Publication.PubMed.Grant] (pmid, GrantID, Acronym, Agency)
		select pmid, GrantID, max(Acronym), max(Agency)
		from (
			select pmid, 
				nref.value('GrantID[1]','varchar(100)') GrantID, 
				nref.value('Acronym[1]','varchar(50)') Acronym,
				nref.value('Agency[1]','varchar(1000)') Agency
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//GrantList/Grant') as R(nref)
			where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
		) t where GrantID is not null
		group by pmid, GrantID


	--******************************************************************
	--******************************************************************
	--*** Update parse date
	--******************************************************************
	--******************************************************************

	update [Profile.Data].[Publication.PubMed.AllXML] set ParseDT = GetDate() where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
END
