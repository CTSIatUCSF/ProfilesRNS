USE [profilesRNS]
GO
/****** Object:  StoredProcedure [Profile.Data].[Publication.Pubmed.ParseALLPubMedXML]    Script Date: 5/20/2021 8:13:53 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Moisey Gruzman>
-- Create date: <03/31/2021>
-- Description:	<Parsing not parsed records from AllXML with reporting errors>
-- =============================================
ALTER PROCEDURE [Profile.Data].[Publication.Pubmed.ParseALLPubMedXML]

AS
BEGIN
	
	declare @parsingType varchar(100)
	declare @messageString varchar(max)

	set @parsingType='general'

	print '****************** starting '+@parsingType+' ************************'
	if exists	(SELECT * FROM sys.Tables where [name] ='Publication.PubMed.General.fromXML')
		drop table [Profile.Data].[Publication.PubMed.General.fromXML]
	
	if exists	(SELECT * FROM sys.Tables where [name] ='Publication.PubMed.General.Stage')
		drop table [Profile.Data].[Publication.PubMed.General.Stage]
	select top 0 *
		into [Profile.Data].[Publication.PubMed.General.Stage]
		from [Profile.Data].[Publication.PubMed.General];

	BEGIN TRY
		select pmid, 
			nref.value('@Owner[1]','varchar(max)') Owner,
			nref.value('@Status[1]','varchar(max)') Status,
			nref.value('Article[1]/@PubModel','varchar(max)') PubModel,
			nref.value('Article[1]/Journal[1]/JournalIssue[1]/Volume[1]','varchar(max)') Volume,
			nref.value('Article[1]/Journal[1]/JournalIssue[1]/Issue[1]','varchar(max)') Issue,
			nref.value('Article[1]/Journal[1]/JournalIssue[1]/PubDate[1]/MedlineDate[1]','varchar(max)') MedlineDate,
			nref.value('Article[1]/Journal[1]/JournalIssue[1]/PubDate[1]/Year[1]','varchar(max)') JournalYear,
			nref.value('Article[1]/Journal[1]/JournalIssue[1]/PubDate[1]/Month[1]','varchar(max)') JournalMonth,
			nref.value('Article[1]/Journal[1]/JournalIssue[1]/PubDate[1]/Day[1]','varchar(max)') JournalDay,
			nref.value('Article[1]/Journal[1]/Title[1]','varchar(max)') JournalTitle,
			nref.value('Article[1]/Journal[1]/ISOAbbreviation[1]','varchar(max)') ISOAbbreviation,
			nref.value('MedlineJournalInfo[1]/MedlineTA[1]','varchar(max)') MedlineTA,
			nref.value('Article[1]/ArticleTitle[1]','nvarchar(max)') ArticleTitle,
			nref.value('Article[1]/Pagination[1]/MedlinePgn[1]','varchar(max)') MedlinePgn,
			nref.value('Article[1]/Abstract[1]/AbstractText[1]','varchar(max)') AbstractText,
			nref.value('Article[1]/ArticleDate[1]/@DateType[1]','varchar(max)') ArticleDateType,
			NULLIF(nref.value('Article[1]/ArticleDate[1]/Year[1]','varchar(max)'),'') ArticleYear,
			NULLIF(nref.value('Article[1]/ArticleDate[1]/Month[1]','varchar(max)'),'') ArticleMonth,
			NULLIF(nref.value('Article[1]/ArticleDate[1]/Day[1]','varchar(max)'),'') ArticleDay,
			COALESCE(nref.value('Article[1]/AuthorList[1]/Author[1]/AffiliationInfo[1]/Affiliation[1]','varchar(max)'),
				nref.value('Article[1]/AuthorList[1]/Author[1]/Affiliation[1]','varchar(max)'),
				nref.value('Article[1]/Affiliation[1]','varchar(max)')) Affiliation,
			nref.value('Article[1]/AuthorList[1]/@CompleteYN[1]','varchar(1)') AuthorListCompleteYN,
			nref.value('Article[1]/GrantList[1]/@CompleteYN[1]','varchar(1)') GrantListCompleteYN,
			COALESCE(nref.value('(OtherID[@Source="NLM" and text()[contains(.,"PMC")]])[1]', 'varchar(max)'), 
				nref.value('(OtherID[@Source="NLM"][1])','varchar(max)')) PMCID
			into [Profile.Data].[Publication.PubMed.General.fromXML]
		from [Profile.Data].[Publication.PubMed.AllXML] cross apply x.nodes('//MedlineCitation[1]') as R(nref)
		where ParseDT is null and x is not null
		--where pmid in (select pmid from PubmedXMLListForDisambiguation)

		--select * from [Profile.Data].[Publication.PubMed.General.fromXML]
		exec [Profile.Data].[Publication.Pubmed.InsertIntoTableFromParseXML] '[Profile.Data].[Publication.PubMed.General.fromXML]',
			'[Profile.Data].[Publication.PubMed.General.Stage]'
	END TRY
	BEGIN CATCH
	print 'gotfailure processing '+@parsingType+' in those pmids'
	print ERROR_MESSAGE()
	END CATCH

/*
	delete from [Profile.Data].[Publication.PubMed.General.Stage]
	where pmid in ( select top 1 pmid from  PubmedXMLListForDisambiguation)
*/
	set  @messageString=''
	select @messageString= @messageString+' '+err 
	from 
	(
		select  distinct  ' PMID='+cast(fromXML.pmid as varchar) err
		from [Profile.Data].[Publication.PubMed.General.fromXML] fromXML
		left outer join 
		(
			select distinct pmid
			from [Profile.Data].[Publication.PubMed.General.Stage]
		)stage on stage.pmid =fromXML.pmid
		where stage.pmid is NULL
	)a
	if LEN(@messageString) >0
	BEGIN
		set @messageString='WARNING: failed processing '+@parsingType+@messageString
		RAISERROR(@messageString,0,0) WITH NOWAIT
	END



	
	--------------------- end of general --------------

	set @parsingType='authors';
	print '****************** starting '+@parsingType+' ************************'
	if exists	(SELECT * FROM sys.Tables where [name] ='Publication.PubMed.Author.fromXML')
		drop table [Profile.Data].[Publication.PubMed.Author.fromXML]
	
	if exists	(SELECT * FROM sys.Tables where [name] ='Publication.PubMed.Author.Stage')
		drop table [Profile.Data].[Publication.PubMed.Author.Stage]
	select top 0 *
	into [Profile.Data].[Publication.PubMed.Author.Stage]
	from [Profile.Data].[Publication.PubMed.Author];
	
	BEGIN TRY
		select * 
		into [Profile.Data].[Publication.PubMed.Author.fromXML]
		from (
			select pmid, 
				nref.value('@ValidYN','varchar(max)') ValidYN, 
				case 
					when nref.value('CollectiveName[1]','varchar(max)') is not NULL then nref.value('CollectiveName[1]','varchar(max)') 
					when nref.value('LastName[1]','varchar(max)') is not NULL then nref.value('LastName[1]','varchar(max)')
				end	LastName, 
				COALESCE(nref.value('FirstName[1]','varchar(max)'),'') FirstName,
				COALESCE(nref.value('ForeName[1]','varchar(max)'),'') ForeName,
				COALESCE(nref.value('Suffix[1]','varchar(max)'),'') Suffix,
				COALESCE(nref.value('Initials[1]','varchar(max)'),'') Initials,
				COALESCE(nref.value('AffiliationInfo[1]/Affiliation[1]','varchar(max)'),
					nref.value('Affiliation[1]','varchar(max)')) Affiliation
			from [Profile.Data].[Publication.PubMed.AllXML] cross apply x.nodes('//AuthorList/Author') as R(nref)
			where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
		)a
		where lastname is not NULL

		--select * from [Profile.Data].[Publication.PubMed.Author.fromXML]

		exec [Profile.Data].[Publication.Pubmed.InsertIntoTableFromParseXML] 
			'[Profile.Data].[Publication.PubMed.Author.fromXML]','[Profile.Data].[Publication.PubMed.Author.Stage]'
				
	IF OBJECT_ID('tempdb..#a') IS NOT NULL drop table #a
	create table #a (pmid int primary key, authors varchar(4000))
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
					select ', '+lastname+' '+initials
					from [Profile.Data].[Publication.PubMed.Author.Stage] q
					where q.pmid = p.pmid
					order by PmPubsAuthorID
					for xml path(''), type
				) as nvarchar(max)),'') s
				from [Profile.Data].[Publication.PubMed.General.Stage] p
			) t
		) t




	END TRY
	BEGIN CATCH
	print 'got failure processing '+@parsingType+' in those pmids'
	print ERROR_MESSAGE()
	END CATCH

		--[10132 in 00:00:01]
	update g
		set g.authors = isnull(a.authors,'')
		from [Profile.Data].[Publication.PubMed.General.Stage] g, #a a
		where g.pmid = a.pmid
	update [Profile.Data].[Publication.PubMed.General.Stage]
		set authors = ''
		where authors is null

	set  @messageString=''
	select @messageString= @messageString+' '+err 
	from 
	(
		select  distinct  ' PMID='+cast(fromXML.pmid as varchar) err
		from [Profile.Data].[Publication.PubMed.Author.fromXML] fromXML
		left outer join 
		(
			select distinct pmid
			from [Profile.Data].[Publication.PubMed.Author.Stage]
		)stage on stage.pmid =fromXML.pmid
		where stage.pmid is NULL
	)a
	if LEN(@messageString) >0
	BEGIN
		set @messageString='WARNING: failed processing '+@parsingType+@messageString
		RAISERROR(@messageString,0,0) WITH NOWAIT
	END


--------------- end of authors  --------------------

	--update General Stage and save into General
	update [Profile.Data].[Publication.PubMed.General.Stage]
		set MedlineDate = (
			case when right(MedlineDate,4) like '20__' then ltrim(rtrim(right(MedlineDate,4)+' '+left(MedlineDate,len(MedlineDate)-4))) 
				else null 
			end
		)
	where MedlineDate is not null and MedlineDate not like '[0-9][0-9][0-9][0-9]%'

		
	update [Profile.Data].[Publication.PubMed.General.Stage]
	set PubDate = [Profile.Data].[fnPublication.Pubmed.GetPubDate](medlinedate,journalyear,journalmonth,journalday,articleyear,articlemonth,articleday)

	update g
		set 
			g.pmid=a.pmid,
			g.pmcid=a.pmcid,
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
				
		insert into [Profile.Data].[Publication.PubMed.General] 
			(
				pmid, pmcid, Owner, Status, PubModel, Volume, Issue, MedlineDate, JournalYear, JournalMonth, JournalDay, JournalTitle,
				ISOAbbreviation, MedlineTA, ArticleTitle, MedlinePgn, AbstractText, ArticleDateType, ArticleYear, ArticleMonth, ArticleDay,
				Affiliation, AuthorListCompleteYN, GrantListCompleteYN, PubDate, Authors
			 )

		select pmid, pmcid, Owner, Status, PubModel, Volume, Issue, MedlineDate, JournalYear, JournalMonth, JournalDay, JournalTitle,
			 ISOAbbreviation, MedlineTA, ArticleTitle, MedlinePgn, AbstractText, ArticleDateType, ArticleYear, ArticleMonth, ArticleDay,
			 Affiliation, AuthorListCompleteYN, GrantListCompleteYN, PubDate, Authors
		from [Profile.Data].[Publication.PubMed.General.Stage]
		where pmid not in (select pmid from [Profile.Data].[Publication.PubMed.General])

		---------------- finished with General

--- now move authors from stage
	delete from [Profile.Data].[Publication.PubMed.Author] 
	where pmid in (select pmid from [Profile.Data].[Publication.PubMed.Author.Stage])
	insert into [Profile.Data].[Publication.PubMed.Author] (pmid, ValidYN, LastName, FirstName, ForeName, Suffix, Initials, Affiliation)
		select pmid, ValidYN, LastName, FirstName, ForeName, Suffix, Initials, Affiliation
		from [Profile.Data].[Publication.PubMed.Author.Stage]
		order by PmPubsAuthorID

	-------------------------------------------


-----------------------------------------------------------------
	set @parsingType='mesh';
		print '****************** starting '+@parsingType+' ************************'
	if exists	(SELECT * FROM sys.Tables where [name] ='Publication.PubMed.Mesh.fromXML')
		drop table [Profile.Data].[Publication.PubMed.Mesh.fromXML]
	
	if exists	(SELECT * FROM sys.Tables where [name] ='Publication.PubMed.Mesh.Stage')
		drop table [Profile.Data].[Publication.PubMed.Mesh.Stage]
	select top 0 *
	into [Profile.Data].[Publication.PubMed.Mesh.Stage]
	from [Profile.Data].[Publication.PubMed.Mesh];
	
	BEGIN TRY
		select * 
		into [Profile.Data].[Publication.PubMed.Mesh.fromXML]
		from (
				select pmid, DescriptorName, IsNull(QualifierName,'') QualifierName, max(MajorTopicYN) MajorTopicYN
				from (
					select pmid, 
						nref.value('@MajorTopicYN[1]','varchar(1)') MajorTopicYN, 
						nref.value('.','varchar(max)') DescriptorName,
						null QualifierName
					from [Profile.Data].[Publication.PubMed.AllXML]
						cross apply x.nodes('//MeshHeadingList/MeshHeading/DescriptorName') as R(nref)
					where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
					union all
					select pmid, 
						nref.value('@MajorTopicYN[1]','varchar(1)') MajorTopicYN, 
						nref.value('../DescriptorName[1]','varchar(max)') DescriptorName,
						nref.value('.','varchar(max)') QualifierName
					from [Profile.Data].[Publication.PubMed.AllXML]
						cross apply x.nodes('//MeshHeadingList/MeshHeading/QualifierName') as R(nref)
					where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
				) t where DescriptorName is not null
				group by pmid, DescriptorName, QualifierName
			)a
  
		exec [Profile.Data].[Publication.Pubmed.InsertIntoTableFromParseXML] 
			'[Profile.Data].[Publication.PubMed.Mesh.fromXML]','[Profile.Data].[Publication.PubMed.Mesh.Stage]'
				

	END TRY
	BEGIN CATCH
	print 'got failure processing '+@parsingType+' in those pmids'
	print ERROR_MESSAGE()
	END CATCH

	set  @messageString=''
	select @messageString= @messageString+' '+err 
	from 
	(
		select  distinct  ' PMID='+cast(fromXML.pmid as varchar) err
		from [Profile.Data].[Publication.PubMed.Mesh.fromXML] fromXML
		left outer join 
		(
			select distinct pmid
			from [Profile.Data].[Publication.PubMed.Mesh.Stage]
		)stage on stage.pmid =fromXML.pmid
		where stage.pmid is NULL
	)a
	if LEN(@messageString) >0
	BEGIN
		set @messageString='WARNING: failed processing '+@parsingType+@messageString
		RAISERROR(@messageString,0,0) WITH NOWAIT
	END
	
	delete from [Profile.Data].[Publication.PubMed.Mesh] 
	where pmid in (
		select pmid from [Profile.Data].[Publication.PubMed.Mesh.Stage]
	)
	--[16593 in 00:00:11]
	insert into [Profile.Data].[Publication.PubMed.Mesh]
		select * from [Profile.Data].[Publication.PubMed.Mesh.Stage]

	--------------- end of mesh  --------------------

set @parsingType='Investigator';
print '****************** starting '+@parsingType+' ************************'
	if exists	(SELECT * FROM sys.Tables where [name] ='Publication.PubMed.Investigator.fromXML')
		drop table [Profile.Data].[Publication.PubMed.Investigator.fromXML]
	
	if exists	(SELECT * FROM sys.Tables where [name] ='Publication.PubMed.Investigator.Stage')
		drop table [Profile.Data].[Publication.PubMed.Investigator.Stage]
	select top 0 *
	into [Profile.Data].[Publication.PubMed.Investigator.Stage]
	from [Profile.Data].[Publication.PubMed.Investigator];
	
	BEGIN TRY
		select * 
		into [Profile.Data].[Publication.PubMed.Investigator.fromXML]
		from (
			select pmid, 
				nref.value('LastName[1]','varchar(max)') LastName, 
				nref.value('FirstName[1]','varchar(max)') FirstName,
				nref.value('ForeName[1]','varchar(max)') ForeName,
				nref.value('Suffix[1]','varchar(max)') Suffix,
				nref.value('Initials[1]','varchar(max)') Initials,
				COALESCE(nref.value('AffiliationInfo[1]/Affiliation[1]','varchar(max)'),
					nref.value('Affiliation[1]','varchar(max)')) Affiliation
			from [Profile.Data].[Publication.PubMed.AllXML] cross apply x.nodes('//InvestigatorList/Investigator') as R(nref)
			where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
		)a
  
  		exec [Profile.Data].[Publication.Pubmed.InsertIntoTableFromParseXML] 
			'[Profile.Data].[Publication.PubMed.Investigator.fromXML]','[Profile.Data].[Publication.PubMed.Investigator.Stage]'
				

	END TRY
	BEGIN CATCH
	print 'got failure processing '+@parsingType+' in those pmids'
	print ERROR_MESSAGE()
	END CATCH

	set  @messageString=''
	select @messageString= @messageString+' '+err 
	from 
	(
		select  distinct  ' PMID='+cast(fromXML.pmid as varchar) err
		from [Profile.Data].[Publication.PubMed.Investigator.fromXML] fromXML
		left outer join 
		(
			select distinct pmid
			from [Profile.Data].[Publication.PubMed.Investigator.Stage]
		)stage on stage.pmid =fromXML.pmid
		where stage.pmid is NULL
	)a
	if LEN(@messageString) >0
	BEGIN
		set @messageString='WARNING: failed processing '+@parsingType+@messageString
		RAISERROR(@messageString,0,0) WITH NOWAIT
	END

delete  from [Profile.Data].[Publication.PubMed.Investigator]
	where pmid in (select distinct pmid from [Profile.Data].[Publication.PubMed.Investigator.Stage])
	insert into [Profile.Data].[Publication.PubMed.Investigator] (PMID,LastName,FirstName,ForeName,Suffix,Initials,Affiliation)
		select PMID,LastName,FirstName,ForeName,Suffix,Initials,Affiliation
	   from [Profile.Data].[Publication.PubMed.Investigator.Stage]

--------------- end of investigator  --------------------

	set @parsingType='Pubtype';
		print '****************** starting '+@parsingType+' ************************'
	if exists	(SELECT * FROM sys.Tables where [name] ='Publication.PubMed.PubType.fromXML')
		drop table [Profile.Data].[Publication.PubMed.PubType.fromXML]
	
	if exists	(SELECT * FROM sys.Tables where [name] ='Publication.PubMed.PubType.Stage')
		drop table [Profile.Data].[Publication.PubMed.PubType.Stage]
	select top 0 *
	into [Profile.Data].[Publication.PubMed.PubType.Stage]
	from [Profile.Data].[Publication.PubMed.PubType];
	
	BEGIN TRY
		select * 
		into [Profile.Data].[Publication.PubMed.PubType.fromXML]
		from (
			select distinct pmid, nref.value('.','varchar(max)') PublicationType
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//PublicationTypeList/PublicationType') as R(nref)
			where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
		) t where PublicationType is not null

  		exec [Profile.Data].[Publication.Pubmed.InsertIntoTableFromParseXML] 
			'[Profile.Data].[Publication.PubMed.PubType.fromXML]','[Profile.Data].[Publication.PubMed.PubType.Stage]'
	END TRY
	BEGIN CATCH
	print 'got failure processing '+@parsingType+' in those pmids'
	print ERROR_MESSAGE()
	END CATCH

	set  @messageString=''
	select @messageString= @messageString+' '+err 
	from 
	(
		select  distinct  ' PMID='+cast(fromXML.pmid as varchar) err
		from [Profile.Data].[Publication.PubMed.PubType.fromXML] fromXML
		left outer join 
		(
			select distinct pmid
			from [Profile.Data].[Publication.PubMed.PubType.Stage]
		)stage on stage.pmid =fromXML.pmid
		where stage.pmid is NULL
	)a
	if LEN(@messageString) >0
	BEGIN
		set @messageString='WARNING: failed processing '+@parsingType+@messageString
		RAISERROR(@messageString,0,0) WITH NOWAIT
	END

	delete from [Profile.Data].[Publication.PubMed.PubType] 
	where pmid in (select pmid from [Profile.Data].[Publication.PubMed.PubType.Stage])
	insert into [Profile.Data].[Publication.PubMed.PubType]
		select * from [Profile.Data].[Publication.PubMed.PubType.Stage]

--------------- end of pubtype  --------------------
	set @parsingType='chemical';
		print '****************** starting '+@parsingType+' ************************'
	if exists	(SELECT * FROM sys.Tables where [name] ='Publication.PubMed.Chemical.fromXML')
		drop table [Profile.Data].[Publication.PubMed.Chemical.fromXML]
	
	if exists	(SELECT * FROM sys.Tables where [name] ='Publication.PubMed.Chemical.Stage')
		drop table [Profile.Data].[Publication.PubMed.Chemical.Stage]
	select top 0 *
	into [Profile.Data].[Publication.PubMed.Chemical.Stage]
	from [Profile.Data].[Publication.PubMed.Chemical];
	
	BEGIN TRY
		select * 
		into [Profile.Data].[Publication.PubMed.Chemical.fromXML]
		from (
			select * from (
				select distinct pmid, nref.value('.','varchar(max)') NameOfSubstance
				from [Profile.Data].[Publication.PubMed.AllXML]
					cross apply x.nodes('//ChemicalList/Chemical/NameOfSubstance') as R(nref)
				where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
			) t where NameOfSubstance is not null
		)a

  		exec [Profile.Data].[Publication.Pubmed.InsertIntoTableFromParseXML] 
			'[Profile.Data].[Publication.PubMed.Chemical.fromXML]','[Profile.Data].[Publication.PubMed.Chemical.Stage]'
	END TRY
	BEGIN CATCH
	print 'got failure processing '+@parsingType+' in those pmids'
	print ERROR_MESSAGE()
	END CATCH

	set  @messageString=''
	select @messageString= @messageString+' '+err 
	from 
	(
		select  distinct  ' PMID='+cast(fromXML.pmid as varchar) err
		from [Profile.Data].[Publication.PubMed.Chemical.fromXML] fromXML
		left outer join 
		(
			select distinct pmid
			from [Profile.Data].[Publication.PubMed.Chemical.Stage]
		)stage on stage.pmid =fromXML.pmid
		where stage.pmid is NULL
	)a
	if LEN(@messageString) >0
	BEGIN
		set @messageString='WARNING: failed processing '+@parsingType+@messageString
		RAISERROR(@messageString,0,0) WITH NOWAIT
	END

	delete from [Profile.Data].[Publication.PubMed.Chemical] 
	where pmid in (select pmid from [Profile.Data].[Publication.PubMed.Chemical.Stage])
	insert into [Profile.Data].[Publication.PubMed.Chemical]
		select * from [Profile.Data].[Publication.PubMed.Chemical.Stage]



--------------- end of chemical  --------------------
	set @parsingType='databanks';
	print '****************** starting '+@parsingType+' ************************'
	if exists	(SELECT * FROM sys.Tables where [name] ='Publication.PubMed.Databank.fromXML')
		drop table [Profile.Data].[Publication.PubMed.Databank.fromXML]
	
	if exists	(SELECT * FROM sys.Tables where [name] ='Publication.PubMed.Databank.Stage')
		drop table [Profile.Data].[Publication.PubMed.Databank.Stage]
	select top 0 *
	into [Profile.Data].[Publication.PubMed.Databank.Stage]
	from [Profile.Data].[Publication.PubMed.Databank];
	
	BEGIN TRY

		
		select * 
		into [Profile.Data].[Publication.PubMed.Databank.fromXML]
		from (
			select distinct pmid, 
				nref.value('.','varchar(max)') DataBankName
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//DataBankList/DataBank/DataBankName') as R(nref)
			where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
			) t where DataBankName is not null

  		exec [Profile.Data].[Publication.Pubmed.InsertIntoTableFromParseXML] 
			'[Profile.Data].[Publication.PubMed.Databank.fromXML]','[Profile.Data].[Publication.PubMed.Databank.Stage]'
	END TRY
	BEGIN CATCH
	print 'got failure processing '+@parsingType+' in those pmids'
	print ERROR_MESSAGE()
	END CATCH

	set  @messageString=''
	select @messageString= @messageString+' '+err 
	from 
	(
		select  distinct  ' PMID='+cast(fromXML.pmid as varchar) err
		from [Profile.Data].[Publication.PubMed.DataBank.fromXML] fromXML
		left outer join 
		(
			select distinct pmid
			from [Profile.Data].[Publication.PubMed.DataBank.Stage]
		)stage on stage.pmid =fromXML.pmid
		where stage.pmid is NULL
	)a
	if LEN(@messageString) >0
	BEGIN
		set @messageString='WARNING: failed processing '+@parsingType+@messageString
		RAISERROR(@messageString,0,0) WITH NOWAIT
	END

	delete from [Profile.Data].[Publication.PubMed.Databank] 
	where pmid in (select pmid from [Profile.Data].[Publication.PubMed.Databank.Stage])
	insert into [Profile.Data].[Publication.PubMed.Databank]
		select * from [Profile.Data].[Publication.PubMed.Databank.Stage]
	
	--------------- end of databanks  --------------------
	set @parsingType='accessions';
		print '****************** starting '+@parsingType+' ************************'
	if exists	(SELECT * FROM sys.Tables where [name] ='Publication.PubMed.Accession.fromXML')
		drop table [Profile.Data].[Publication.PubMed.Accession.fromXML]
	
	if exists	(SELECT * FROM sys.Tables where [name] ='Publication.PubMed.Accession.Stage')
		drop table [Profile.Data].[Publication.PubMed.Accession.Stage]
	select top 0 *
	into [Profile.Data].[Publication.PubMed.Accession.Stage]
	from [Profile.Data].[Publication.PubMed.Accession];
	
	BEGIN TRY

		
		select * 
		into [Profile.Data].[Publication.PubMed.Accession.fromXML]
		from (
			select distinct pmid, 
				nref.value('../../DataBankName[1]','varchar(max)') DataBankName,
				nref.value('.','varchar(max)') AccessionNumber
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//DataBankList/DataBank/AccessionNumberList/AccessionNumber') as R(nref)
			where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
		) t where DataBankName is not null and AccessionNumber is not null


  		exec [Profile.Data].[Publication.Pubmed.InsertIntoTableFromParseXML] 
			'[Profile.Data].[Publication.PubMed.Accession.fromXML]','[Profile.Data].[Publication.PubMed.Accession.Stage]'
	END TRY
	BEGIN CATCH
	print 'got failure processing '+@parsingType+' in those pmids'
	print ERROR_MESSAGE()
	END CATCH

	set  @messageString=''
	select @messageString= @messageString+' '+err 
	from 
	(
		select  distinct  ' PMID='+cast(fromXML.pmid as varchar) err
		from [Profile.Data].[Publication.PubMed.Accession.fromXML] fromXML
		left outer join 
		(
			select distinct pmid
			from [Profile.Data].[Publication.PubMed.Accession.Stage]
		)stage on stage.pmid =fromXML.pmid
		where stage.pmid is NULL
	)a
	if LEN(@messageString) >0
	BEGIN
		set @messageString='WARNING: failed processing '+@parsingType+@messageString
		RAISERROR(@messageString,0,0) WITH NOWAIT
	END
	
	delete from [Profile.Data].[Publication.PubMed.Accession] 
	where pmid in (select pmid from [Profile.Data].[Publication.PubMed.Accession.Stage])
	insert into [Profile.Data].[Publication.PubMed.Accession]
		select * from [Profile.Data].[Publication.PubMed.Accession.Stage]

	--------------- end of accessions  --------------------
	set @parsingType='keywords';
		print '****************** starting '+@parsingType+' ************************'
	if exists	(SELECT * FROM sys.Tables where [name] ='Publication.PubMed.Keyword.fromXML')
		drop table [Profile.Data].[Publication.PubMed.Keyword.fromXML]
	
	if exists	(SELECT * FROM sys.Tables where [name] ='Publication.PubMed.Keyword.Stage')
		drop table [Profile.Data].[Publication.PubMed.Keyword.Stage]
	select top 0 *
	into [Profile.Data].[Publication.PubMed.Keyword.Stage]
	from [Profile.Data].[Publication.PubMed.Keyword];
	
	BEGIN TRY

		
		select pmid, Keyword, max(MajorTopicYN) MajorTopicYN
		into [Profile.Data].[Publication.PubMed.Keyword.fromXML]
		from (
			select pmid, 
				nref.value('.','varchar(max)') Keyword,
				nref.value('@MajorTopicYN','varchar(1)') MajorTopicYN
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//KeywordList/Keyword') as R(nref)
			where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
		) t where Keyword is not null
		group by pmid, Keyword

  		exec [Profile.Data].[Publication.Pubmed.InsertIntoTableFromParseXML] 
			'[Profile.Data].[Publication.PubMed.Keyword.fromXML]','[Profile.Data].[Publication.PubMed.Keyword.Stage]'
	END TRY
	BEGIN CATCH
	print 'got failure processing '+@parsingType+' in those pmids'
	print ERROR_MESSAGE()
	END CATCH

	set  @messageString=''
	select @messageString= @messageString+' '+err 
	from 
	(
		select  distinct  ' PMID='+cast(fromXML.pmid as varchar) err
		from [Profile.Data].[Publication.PubMed.Keyword.fromXML] fromXML
		left outer join 
		(
			select distinct pmid
			from [Profile.Data].[Publication.PubMed.Keyword.Stage]
		)stage on stage.pmid =fromXML.pmid
		where stage.pmid is NULL
	)a
	if LEN(@messageString) >0
	BEGIN
		set @messageString='WARNING: failed processing '+@parsingType+@messageString
		RAISERROR(@messageString,0,0) WITH NOWAIT
	END

	delete from [Profile.Data].[Publication.PubMed.Keyword] 
	where pmid in (select pmid from [Profile.Data].[Publication.PubMed.Keyword.Stage])
	insert into [Profile.Data].[Publication.PubMed.Keyword]
		select * from [Profile.Data].[Publication.PubMed.Keyword.Stage]

--------------- end of Keyword  --------------------
	set @parsingType='grants';
		print '****************** starting '+@parsingType+' ************************'
	if exists	(SELECT * FROM sys.Tables where [name] ='Publication.PubMed.Grant.fromXML')
		drop table [Profile.Data].[Publication.PubMed.Grant.fromXML]
	
	if exists	(SELECT * FROM sys.Tables where [name] ='Publication.PubMed.Grant.Stage')
		drop table [Profile.Data].[Publication.PubMed.Grant.Stage]
	select top 0 *
	into [Profile.Data].[Publication.PubMed.Grant.Stage]
	from [Profile.Data].[Publication.PubMed.Grant];
	
	BEGIN TRY

		
		select pmid, GrantID, max(Acronym) Acronim, max(Agency) Agency
		into [Profile.Data].[Publication.PubMed.Grant.fromXML]
		from (
			select pmid, 
				nref.value('GrantID[1]','varchar(max)') GrantID, 
				nref.value('Acronym[1]','varchar(max)') Acronym,
				nref.value('Agency[1]','varchar(max)') Agency
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//GrantList/Grant') as R(nref)
			where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
		) t where GrantID is not null
		group by pmid, GrantID

  		exec [Profile.Data].[Publication.Pubmed.InsertIntoTableFromParseXML] 
			'[Profile.Data].[Publication.PubMed.Grant.fromXML]','[Profile.Data].[Publication.PubMed.Grant.Stage]'
	END TRY
	BEGIN CATCH
	print 'got failure processing '+@parsingType+' in those pmids'
	print ERROR_MESSAGE()
	END CATCH

	set  @messageString=''
	select @messageString= @messageString+' '+err 
	from 
	(
		select  distinct  ' PMID='+cast(fromXML.pmid as varchar) err
		from [Profile.Data].[Publication.PubMed.Grant.fromXML] fromXML
		left outer join 
		(
			select distinct pmid
			from [Profile.Data].[Publication.PubMed.Grant.Stage]
		)stage on stage.pmid =fromXML.pmid
		where stage.pmid is NULL
	)a
	if LEN(@messageString) >0
	BEGIN
		set @messageString='WARNING: failed processing '+@parsingType+@messageString
		RAISERROR(@messageString,0,0) WITH NOWAIT
	END
	
	delete from [Profile.Data].[Publication.PubMed.Grant] 
	where pmid in (select pmid from [Profile.Data].[Publication.PubMed.Grant.Stage])
	insert into [Profile.Data].[Publication.PubMed.Grant]
		select * from [Profile.Data].[Publication.PubMed.Grant.Stage]

	--------------- end of Grant  --------------------
	
		--******************************************************************
	--******************************************************************
	--*** Update parse date
	--******************************************************************
	--******************************************************************

	update [Profile.Data].[Publication.PubMed.AllXML] set ParseDT = GetDate() where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
		

END
