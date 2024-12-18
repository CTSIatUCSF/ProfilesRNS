USE [profilesRNS]
GO
/****** Object:  StoredProcedure [Profile.Data].[Publication.Pubmed.ParsePubMedXML]    Script Date: 6/2/2021 12:58:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [Profile.Data].[Publication.Pubmed.ParsePubMedXML]
	@pmid int
AS
BEGIN
	SET NOCOUNT ON;

	declare @tableType varchar(100)

	UPDATE [Profile.Data].[Publication.PubMed.AllXML] set ParseDT = GetDate() where pmid = @pmid


	delete from [Profile.Data].[Publication.PubMed.Author] where pmid = @pmid
	delete from [Profile.Data].[Publication.PubMed.Investigator] where pmid = @pmid
	delete from [Profile.Data].[Publication.PubMed.PubType] where pmid = @pmid
	delete from [Profile.Data].[Publication.PubMed.Chemical] where pmid = @pmid
	delete from [Profile.Data].[Publication.PubMed.Databank] where pmid = @pmid
	delete from [Profile.Data].[Publication.PubMed.Accession] where pmid = @pmid
	delete from [Profile.Data].[Publication.PubMed.Keyword] where pmid = @pmid
	delete from [Profile.Data].[Publication.PubMed.Grant] where pmid = @pmid
	delete from [Profile.Data].[Publication.PubMed.Mesh] where pmid = @pmid

	
	BEGIN TRY
	set @tableType='General'
	-- Update pm_pubs_general if record exists, else insert new record
	IF EXISTS (SELECT 1 FROM [Profile.Data].[Publication.PubMed.General] WHERE pmid = @pmid) 
		BEGIN 
		
			UPDATE g
			   SET 	Owner= nref.value('@Owner[1]','varchar(max)') ,
							Status = nref.value('@Status[1]','varchar(max)') ,
							PubModel=nref.value('Article[1]/@PubModel','varchar(max)') ,
							Volume	 = nref.value('Article[1]/Journal[1]/JournalIssue[1]/Volume[1]','varchar(max)') ,
							Issue = nref.value('Article[1]/Journal[1]/JournalIssue[1]/Issue[1]','varchar(max)') ,
							MedlineDate = nref.value('Article[1]/Journal[1]/JournalIssue[1]/PubDate[1]/MedlineDate[1]','varchar(max)') ,
							JournalYear = nref.value('Article[1]/Journal[1]/JournalIssue[1]/PubDate[1]/Year[1]','varchar(max)') ,
							JournalMonth = nref.value('Article[1]/Journal[1]/JournalIssue[1]/PubDate[1]/Month[1]','varchar(max)') ,
							JournalDay=nref.value('Article[1]/Journal[1]/JournalIssue[1]/PubDate[1]/Day[1]','varchar(max)') ,
							JournalTitle = nref.value('Article[1]/Journal[1]/Title[1]','varchar(max)') ,
							ISOAbbreviation=nref.value('Article[1]/Journal[1]/ISOAbbreviation[1]','varchar(max)') ,
							MedlineTA = nref.value('MedlineJournalInfo[1]/MedlineTA[1]','varchar(max)') ,
							ArticleTitle = nref.value('Article[1]/ArticleTitle[1]','nvarchar(max)') ,
							MedlinePgn = nref.value('Article[1]/Pagination[1]/MedlinePgn[1]','varchar(max)') ,
							AbstractText = nref.value('Article[1]/Abstract[1]/AbstractText[1]','varchar(max)') ,
							ArticleDateType= nref.value('Article[1]/ArticleDate[1]/@DateType[1]','varchar(max)') ,
							-- Updated on 19 Dec 2016 to handle incorrectly formatted dates
							ArticleYear = NULLIF(nref.value('Article[1]/ArticleDate[1]/Year[1]','varchar(max)'),'') ,
							ArticleMonth = NULLIF(nref.value('Article[1]/ArticleDate[1]/Month[1]','varchar(max)'),'') ,
							ArticleDay = NULLIF(nref.value('Article[1]/ArticleDate[1]/Day[1]','varchar(max)'),'') ,
							Affiliation = COALESCE(nref.value('Article[1]/AuthorList[1]/Author[1]/AffiliationInfo[1]/Affiliation[1]','varchar(max)'),
								nref.value('Article[1]/AuthorList[1]/Author[1]/Affiliation[1]','varchar(max)'),
								nref.value('Article[1]/Affiliation[1]','varchar(max)')) ,
							AuthorListCompleteYN = nref.value('Article[1]/AuthorList[1]/@CompleteYN[1]','varchar(max)') ,
							GrantListCompleteYN=nref.value('Article[1]/GrantList[1]/@CompleteYN[1]','varchar(max)'),
							PMCID=COALESCE(nref.value('(OtherID[@Source="NLM" and text()[contains(.,"PMC")]])[1]', 'varchar(max)'), nref.value('(OtherID[@Source="NLM"][1])','varchar(max)'))
				FROM  [Profile.Data].[Publication.PubMed.General]  g
				JOIN  [Profile.Data].[Publication.PubMed.AllXML] a ON a.pmid = g.pmid
					 CROSS APPLY  x.nodes('//MedlineCitation[1]') as R(nref)
				WHERE a.pmid = @pmid
				
		END
	ELSE 
		BEGIN 
		
			--*** general ***
			insert into [Profile.Data].[Publication.PubMed.General] (pmid, Owner, Status, PubModel, Volume, Issue, MedlineDate, JournalYear, JournalMonth, JournalDay, JournalTitle, ISOAbbreviation, MedlineTA, ArticleTitle, MedlinePgn, AbstractText, ArticleDateType, ArticleYear, ArticleMonth, ArticleDay, Affiliation, AuthorListCompleteYN, GrantListCompleteYN,PMCID)
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
					-- Updated on 19 Dec 2016 to handle incorrectly formatted dates
					NULLIF(nref.value('Article[1]/ArticleDate[1]/Year[1]','varchar(max)'),'') ArticleYear,
					NULLIF(nref.value('Article[1]/ArticleDate[1]/Month[1]','varchar(max)'),'') ArticleMonth,
					NULLIF(nref.value('Article[1]/ArticleDate[1]/Day[1]','varchar(max)'),'') ArticleDay,
					Affiliation = COALESCE(nref.value('Article[1]/AuthorList[1]/Author[1]/AffiliationInfo[1]/Affiliation[1]','varchar(max)'),
						nref.value('Article[1]/AuthorList[1]/Author[1]/Affiliation[1]','varchar(max)'),
						nref.value('Article[1]/Affiliation[1]','varchar(max)')) ,
					nref.value('Article[1]/AuthorList[1]/@CompleteYN[1]','varchar(max)') AuthorListCompleteYN,
					nref.value('Article[1]/GrantList[1]/@CompleteYN[1]','varchar(max)') GrantListCompleteYN,
					PMCID=COALESCE(nref.value('(OtherID[@Source="NLM" and text()[contains(.,"PMC")]])[1]', 'varchar(max)'), nref.value('(OtherID[@Source="NLM"][1])','varchar(max)'))
				from [Profile.Data].[Publication.PubMed.AllXML] cross apply x.nodes('//MedlineCitation[1]') as R(nref)
				where pmid = @pmid
	END
	END TRY
	BEGIN CATCH
	print 'failed adding parsed pmid='+cast(@pmid as varchar(10))+'to '+@tableType
	END CATCH
	-- Updated on 19 Dec 2016 to handle incorrectly formatted dates
	update [Profile.Data].[Publication.PubMed.General]
	set MedlineDate = (case when right(MedlineDate,4) like '20__' then ltrim(rtrim(right(MedlineDate,4)+' '+left(MedlineDate,len(MedlineDate)-4))) else null end)
	where MedlineDate is not null and MedlineDate not like '[0-9][0-9][0-9][0-9]%'
	
	--fixed 2/14/2021 in order to process CollectiveName in authors list, but not in other related tables.

	--*** authors ***
	BEGIN TRY
	set @tableType='authors'
	insert into [Profile.Data].[Publication.PubMed.Author] (pmid, ValidYN, LastName, FirstName, ForeName, Suffix, Initials, Affiliation)

		select * 
		from (
			select pmid, 
				nref.value('@ValidYN','varchar(max)') ValidYN, 
				case 
					when nref.value('CollectiveName[1]','varchar(max)') is not NULL then SUBSTRING(nref.value('CollectiveName[1]','varchar(max)'),1,100) 
					when nref.value('LastName[1]','varchar(max)') is not NULL then nref.value('LastName[1]','varchar(max)')
				end	LastName, 
				COALESCE(nref.value('FirstName[1]','varchar(max)'),'') FirstName,
				COALESCE(nref.value('ForeName[1]','varchar(max)'),'') ForeName,
				COALESCE(nref.value('Suffix[1]','varchar(max)'),'') Suffix,
				COALESCE(nref.value('Initials[1]','varchar(max)'),'') Initials,
				COALESCE(nref.value('AffiliationInfo[1]/Affiliation[1]','varchar(max)'),
				nref.value('Affiliation[1]','varchar(max)')) Affiliation
			from [Profile.Data].[Publication.PubMed.AllXML] cross apply x.nodes('//AuthorList/Author') as R(nref)
			where pmid =@pmid
		)a
		where lastname is not NULL				
	END TRY
	BEGIN CATCH
	print 'failed adding parsed pmid='+cast(@pmid as varchar(10))+'to '+@tableType
	END CATCH

	--*** investigators ***
	BEGIN TRY
	set @tableType='investigators'
	insert into [Profile.Data].[Publication.PubMed.Investigator] (pmid, LastName, FirstName, ForeName, Suffix, Initials, Affiliation)
		select pmid, 
			nref.value('LastName[1]','varchar(max)') LastName, 
			nref.value('FirstName[1]','varchar(max)') FirstName,
			nref.value('ForeName[1]','varchar(max)') ForeName,
			nref.value('Suffix[1]','varchar(max)') Suffix,
			nref.value('Initials[1]','varchar(max)') Initials,
			COALESCE(nref.value('AffiliationInfo[1]/Affiliation[1]','varchar(max)'),
				nref.value('Affiliation[1]','varchar(max)')) Affiliation
		from [Profile.Data].[Publication.PubMed.AllXML] cross apply x.nodes('//InvestigatorList/Investigator') as R(nref)
		where pmid = @pmid
		 and nref.value('LastName[1]','varchar(max)') is not NULL
	END TRY
	BEGIN CATCH
	print 'failed adding parsed pmid='+cast(@pmid as varchar(10))+'to '+@tableType
	END CATCH

	--***  ***
	BEGIN TRY
	set @tableType='pubtype'


	--*** pubtype ***
	insert into [Profile.Data].[Publication.PubMed.PubType] (pmid, PublicationType)
		select * from (
			select distinct pmid, nref.value('.','varchar(max)') PublicationType
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//PublicationTypeList/PublicationType') as R(nref)
			where pmid = @pmid
		) t where PublicationType is not null
	END TRY
	BEGIN CATCH
	print 'failed adding parsed pmid='+cast(@pmid as varchar(10))+'to '+@tableType
	END CATCH

	--***  ***
	BEGIN TRY
	set @tableType='pubtype'


	--*** chemicals
	insert into [Profile.Data].[Publication.PubMed.Chemical] (pmid, NameOfSubstance)
		select * from (
			select distinct pmid, nref.value('.','varchar(max)') NameOfSubstance
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//ChemicalList/Chemical/NameOfSubstance') as R(nref)
			where pmid = @pmid
		) t where NameOfSubstance is not null

	END TRY
	BEGIN CATCH
	print 'failed adding parsed pmid='+cast(@pmid as varchar(10))+'to '+@tableType
	END CATCH

	--***  ***
	BEGIN TRY
	set @tableType='databanks'


	--*** databanks ***
	insert into [Profile.Data].[Publication.PubMed.Databank] (pmid, DataBankName)
		select * from (
			select distinct pmid, 
				nref.value('.','varchar(max)') DataBankName
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//DataBankList/DataBank/DataBankName') as R(nref)
			where pmid = @pmid
		) t where DataBankName is not null

	END TRY
	BEGIN CATCH
	print 'failed adding parsed pmid='+cast(@pmid as varchar(10))+'to '+@tableType
	END CATCH

	--***  ***
	BEGIN TRY
	set @tableType='accessions'


	--*** accessions ***
	insert into [Profile.Data].[Publication.PubMed.Accession] (pmid, DataBankName, AccessionNumber)
		select * from (
			select distinct pmid, 
				nref.value('../../DataBankName[1]','varchar(max)') DataBankName,
				nref.value('.','varchar(max)') AccessionNumber
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//DataBankList/DataBank/AccessionNumberList/AccessionNumber') as R(nref)
			where pmid = @pmid
		) t where DataBankName is not null and AccessionNumber is not null

	END TRY
	BEGIN CATCH
	print 'failed adding parsed pmid='+cast(@pmid as varchar(10))+'to '+@tableType
	END CATCH

	--***  ***
	BEGIN TRY
	set @tableType='keywords'



	--*** keywords ***
	insert into [Profile.Data].[Publication.PubMed.Keyword] (pmid, Keyword, MajorTopicYN)
		select pmid, Keyword, max(MajorTopicYN)
		from (
			select pmid, 
				nref.value('.','varchar(max)') Keyword,
				nref.value('@MajorTopicYN','varchar(max)') MajorTopicYN
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//KeywordList/Keyword') as R(nref)
			where pmid = @pmid
		) t where Keyword is not null
		group by pmid, Keyword

	END TRY
	BEGIN CATCH
	print 'failed adding parsed pmid='+cast(@pmid as varchar(10))+'to '+@tableType
	END CATCH

	--***  ***
	BEGIN TRY
	set @tableType='grants'

	--*** grants ***
	insert into [Profile.Data].[Publication.PubMed.Grant] (pmid, GrantID, Acronym, Agency)
		select pmid, GrantID, max(Acronym), max(Agency)
		from (
			select pmid, 
				nref.value('GrantID[1]','varchar(100)') GrantID, 
				nref.value('Acronym[1]','varchar(50)') Acronym,
				nref.value('Agency[1]','varchar(1000)') Agency
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//GrantList/Grant') as R(nref)
			where pmid = @pmid
		) t where GrantID is not null
		group by pmid, GrantID

	END TRY
	BEGIN CATCH
	print 'failed adding parsed pmid='+cast(@pmid as varchar(10))+'to '+@tableType
	END CATCH

	--***  ***
	BEGIN TRY
	set @tableType='mesh'


	--*** mesh ***
	insert into [Profile.Data].[Publication.PubMed.Mesh] (pmid, DescriptorName, QualifierName, MajorTopicYN)
		select pmid, DescriptorName, coalesce(QualifierName,''), max(MajorTopicYN)
		from (
			select pmid, 
				nref.value('@MajorTopicYN[1]','varchar(max)') MajorTopicYN, 
				nref.value('.','varchar(max)') DescriptorName,
				null QualifierName
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//MeshHeadingList/MeshHeading/DescriptorName') as R(nref)
			where pmid = @pmid
			union all
			select pmid, 
				nref.value('@MajorTopicYN[1]','varchar(max)') MajorTopicYN, 
				nref.value('../DescriptorName[1]','varchar(max)') DescriptorName,
				nref.value('.','varchar(max)') QualifierName
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//MeshHeadingList/MeshHeading/QualifierName') as R(nref)
			where pmid = @pmid
		) t where DescriptorName is not null
		group by pmid, DescriptorName, QualifierName

	END TRY
	BEGIN CATCH
	print 'failed adding parsed pmid='+cast(@pmid as varchar(10))+'to '+@tableType
	END CATCH

	--***  ***




	--*** general (authors) ***

	declare @a as table (
		i int identity(0,1) primary key,
		pmid int,
		lastname varchar(100),
		initials varchar(20),
		s varchar(max)
	)

	insert into @a (pmid, lastname, initials)
		select pmid, lastname, initials
		from [Profile.Data].[Publication.PubMed.Author]
		where pmid = @pmid
		and lastname is not NULL and lastname !=''
		order by pmid, PmPubsAuthorID

	declare @s varchar(max)
	declare @lastpmid int
	set @s = ''
	set @lastpmid = -1

	update @a
		set
			@s = s = case
					when @lastpmid <> pmid then lastname+' '+initials
					else @s + ', ' + lastname+' '+initials
				end,
			@lastpmid = pmid

	--create nonclustered index idx_p on @a (pmid)

	update g
		set g.authors = coalesce(a.authors,'')
		from [Profile.Data].[Publication.PubMed.General] g, (
				select pmid, (case when authors > authors_short then authors_short+', et al' else authors end) authors
				from (
					select pmid, max(s) authors,
							max(case when len(s)<3990 then s else '' end) authors_short
						from @a group by pmid
				) t
			) a
		where g.pmid = a.pmid





	--*** general (pubdate) ***

	declare @d as table (
		pmid int,
		PubDate datetime
	)

	insert into @d (pmid,PubDate)
		select pmid,[Profile.Data].[fnPublication.Pubmed.GetPubDate](MedlineDate,JournalYear,JournalMonth,JournalDay,ArticleYear,ArticleMonth,ArticleDay)
		from [Profile.Data].[Publication.PubMed.General]
		where pmid = @pmid



	/*

	insert into @d (pmid,PubDate)
		select pmid,
			case when JournalMonth is not null then JournalMonth
				when MedlineMonth is not null then MedlineMonth
				else coalesce(ArticleMonth,'1') end
			+'/'+
			case when JournalMonth is not null then coalesce(JournalDay,'1')
				when MedlineMonth is not null then '1'
				else coalesce(ArticleDay,'1') end
			+'/'+
			case when JournalYear is not null then coalesce(JournalYear,'1900')
				when MedlineMonth is not null then coalesce(MedlineYear,'1900')
				else coalesce(ArticleYear,'1900') end
			as PubDate
		from (
			select pmid, ArticleYear, ArticleDay, MedlineYear, JournalYear, JournalDay,
				(case MedlineMonth
					when 'Jan' then '1'
					when 'Feb' then '2'
					when 'Mar' then '3'
					when 'Arp' then '4'
					when 'May' then '5'
					when 'Jun' then '6'
					when 'Jul' then '7'
					when 'Aug' then '8'
					when 'Sep' then '9'
					when 'Oct' then '10'
					when 'Nov' then '11'
					when 'Dec' then '12'
					when 'Win' then '1'
					when 'Spr' then '4'
					when 'Sum' then '7'
					when 'Fal' then '10'
					else null end) MedlineMonth,
				(case JournalMonth
					when 'Jan' then '1'
					when 'Feb' then '2'
					when 'Mar' then '3'
					when 'Arp' then '4'
					when 'May' then '5'
					when 'Jun' then '6'
					when 'Jul' then '7'
					when 'Aug' then '8'
					when 'Sep' then '9'
					when 'Oct' then '10'
					when 'Nov' then '11'
					when 'Dec' then '12'
					when 'Win' then '1'
					when 'Spr' then '4'
					when 'Sum' then '7'
					when 'Fal' then '10'
					when '1' then '1'
					when '2' then '2'
					when '3' then '3'
					when '4' then '4'
					when '5' then '5'
					when '6' then '6'
					when '7' then '7'
					when '8' then '8'
					when '9' then '9'
					when '10' then '10'
					when '11' then '11'
					when '12' then '12'
					else null end) JournalMonth,
				(case ArticleMonth
					when 'Jan' then '1'
					when 'Feb' then '2'
					when 'Mar' then '3'
					when 'Arp' then '4'
					when 'May' then '5'
					when 'Jun' then '6'
					when 'Jul' then '7'
					when 'Aug' then '8'
					when 'Sep' then '9'
					when 'Oct' then '10'
					when 'Nov' then '11'
					when 'Dec' then '12'
					when 'Win' then '1'
					when 'Spr' then '4'
					when 'Sum' then '7'
					when 'Fal' then '10'
					when '1' then '1'
					when '2' then '2'
					when '3' then '3'
					when '4' then '4'
					when '5' then '5'
					when '6' then '6'
					when '7' then '7'
					when '8' then '8'
					when '9' then '9'
					when '10' then '10'
					when '11' then '11'
					when '12' then '12'
					else null end) ArticleMonth
			from (
				select pmid,
					left(medlinedate,4) as MedlineYear,
					substring(replace(medlinedate,' ',''),5,3) as MedlineMonth,
					JournalYear, left(journalMonth,3) as JournalMonth, JournalDay,
					ArticleYear, ArticleMonth, ArticleDay
				from pm_pubs_general
				where pmid = @pmid
			) t
		) t

	*/


	--create nonclustered index idx_p on @d (pmid)

	update g
		set g.PubDate = coalesce(d.PubDate,'1/1/1900')
		from [Profile.Data].[Publication.PubMed.General] g, @d d
		where g.pmid = d.pmid


END
