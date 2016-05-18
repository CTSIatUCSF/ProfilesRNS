USE [profiles_ucsf]
GO

/****** Object:  StoredProcedure [Profile.Data].[Publication.Pubmed.ParsePubMedXML]    Script Date: 11/12/2015 2:19:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [Profile.Data].[Publication.Pubmed.ParsePubMedXML]
	@pmid int
AS
BEGIN
	SET NOCOUNT ON;


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
							ArticleTitle = nref.value('Article[1]/ArticleTitle[1]','varchar(max)') ,
							MedlinePgn = nref.value('Article[1]/Pagination[1]/MedlinePgn[1]','varchar(max)') ,
							AbstractText = nref.value('Article[1]/Abstract[1]/AbstractText[1]','varchar(max)') ,
							ArticleDateType= nref.value('Article[1]/ArticleDate[1]/@DateType[1]','varchar(max)') ,
							ArticleYear = nref.value('Article[1]/ArticleDate[1]/Year[1]','varchar(max)') ,
							ArticleMonth = nref.value('Article[1]/ArticleDate[1]/Month[1]','varchar(max)') ,
							ArticleDay = nref.value('Article[1]/ArticleDate[1]/Day[1]','varchar(max)') ,
							Affiliation=nref.value('Article[1]/Affiliation[1]','varchar(max)') ,
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
					nref.value('Article[1]/ArticleTitle[1]','varchar(max)') ArticleTitle,
					nref.value('Article[1]/Pagination[1]/MedlinePgn[1]','varchar(max)') MedlinePgn,
					nref.value('Article[1]/Abstract[1]/AbstractText[1]','varchar(max)') AbstractText,
					nref.value('Article[1]/ArticleDate[1]/@DateType[1]','varchar(max)') ArticleDateType,
					nref.value('Article[1]/ArticleDate[1]/Year[1]','varchar(max)') ArticleYear,
					nref.value('Article[1]/ArticleDate[1]/Month[1]','varchar(max)') ArticleMonth,
					nref.value('Article[1]/ArticleDate[1]/Day[1]','varchar(max)') ArticleDay,
					nref.value('Article[1]/Affiliation[1]','varchar(max)') Affiliation,
					nref.value('Article[1]/AuthorList[1]/@CompleteYN[1]','varchar(max)') AuthorListCompleteYN,
					nref.value('Article[1]/GrantList[1]/@CompleteYN[1]','varchar(max)') GrantListCompleteYN,
					COALESCE(nref.value('(OtherID[@Source="NLM" and text()[contains(.,"PMC")]])[1]', 'varchar(max)'), nref.value('(OtherID[@Source="NLM"][1])','varchar(max)'))
				from [Profile.Data].[Publication.PubMed.AllXML] cross apply x.nodes('//MedlineCitation[1]') as R(nref)
				where pmid = @pmid
	END


	--*** authors ***
	insert into [Profile.Data].[Publication.PubMed.Author] (pmid, ValidYN, LastName, FirstName, ForeName, Suffix, Initials, Affiliation)
		select pmid, 
			nref.value('@ValidYN','varchar(max)') ValidYN, 
			nref.value('LastName[1]','varchar(max)') LastName, 
			nref.value('FirstName[1]','varchar(max)') FirstName,
			nref.value('ForeName[1]','varchar(max)') ForeName,
			nref.value('Suffix[1]','varchar(max)') Suffix,
			nref.value('Initials[1]','varchar(max)') Initials,
			nref.value('Affiliation[1]','varchar(max)') Affiliation
		from [Profile.Data].[Publication.PubMed.AllXML] cross apply x.nodes('//AuthorList/Author') as R(nref)
		where pmid = @pmid
				

	--*** co-author links ***
	exec [UCSF.CTSASearch].[Publication.Pubmed.ParseCoAuthorXML] @pmid=@pmid


	--*** investigators ***
	insert into [Profile.Data].[Publication.PubMed.Investigator] (pmid, LastName, FirstName, ForeName, Suffix, Initials, Affiliation)
		select pmid, 
			nref.value('LastName[1]','varchar(max)') LastName, 
			nref.value('FirstName[1]','varchar(max)') FirstName,
			nref.value('ForeName[1]','varchar(max)') ForeName,
			nref.value('Suffix[1]','varchar(max)') Suffix,
			nref.value('Initials[1]','varchar(max)') Initials,
			nref.value('Affiliation[1]','varchar(max)') Affiliation
		from [Profile.Data].[Publication.PubMed.AllXML] cross apply x.nodes('//InvestigatorList/Investigator') as R(nref)
		where pmid = @pmid
		

	--*** pubtype ***
	insert into [Profile.Data].[Publication.PubMed.PubType] (pmid, PublicationType)
		select * from (
			select distinct pmid, nref.value('.','varchar(max)') PublicationType
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//PublicationTypeList/PublicationType') as R(nref)
			where pmid = @pmid
		) t where PublicationType is not null


	--*** chemicals
	insert into [Profile.Data].[Publication.PubMed.Chemical] (pmid, NameOfSubstance)
		select * from (
			select distinct pmid, nref.value('.','varchar(max)') NameOfSubstance
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//ChemicalList/Chemical/NameOfSubstance') as R(nref)
			where pmid = @pmid
		) t where NameOfSubstance is not null


	--*** databanks ***
	insert into [Profile.Data].[Publication.PubMed.Databank] (pmid, DataBankName)
		select * from (
			select distinct pmid, 
				nref.value('.','varchar(max)') DataBankName
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//DataBankList/DataBank/DataBankName') as R(nref)
			where pmid = @pmid
		) t where DataBankName is not null


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


	--*** grants ***
	insert into [Profile.Data].[Publication.PubMed.Grant] (pmid, GrantID, Acronym, Agency)
		select pmid, GrantID, max(Acronym), max(Agency)
		from (
			select pmid, 
				nref.value('GrantID[1]','varchar(max)') GrantID, 
				nref.value('Acronym[1]','varchar(max)') Acronym,
				nref.value('Agency[1]','varchar(max)') Agency
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//GrantList/Grant') as R(nref)
			where pmid = @pmid
		) t where GrantID is not null
		group by pmid, GrantID


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





	--*** general (authors) ***

	declare @a as table (
		i int identity(0,1) primary key,
		lastname varchar(100),
		initials varchar(20),
		url varchar(2000)
	)

	insert into @a (lastname, initials, url)
		select a.lastname, a.initials, c.url
		from [Profile.Data].[Publication.PubMed.Author] a join [UCSF.CTSASearch].[Publication.PubMed.Author] c on a.PmPubsAuthorID = c.PmPubsAuthorID
		where a.pmid = @pmid
		order by a.PmPubsAuthorID

	--coauthor links, set display xml and build legacy authors list in PubMed general
	DECLARE @CurrentRow int
	DECLARE @MaxRow	   int
	DECLARE @CurrentAuthor varchar(200)
	DECLARE @CurrentURL varchar(200)
	DECLARE @VisibleAuthorList varchar(max)
	DECLARE @VisibleAuthorXML varchar(max)

	SELECT @CurrentRow = min(i) FROM @a
	SELECT @MaxRow = max(i) FROM @a
	SET @VisibleAuthorList = ''
	SET @VisibleAuthorXML = '<coauthors>'

	WHILE @CurrentRow<=@MaxRow
	BEGIN
		SELECT @CurrentAuthor = lastname+' '+initials, @CurrentURL = url 
			FROM @a	WHERE i=@CurrentRow
		-- check size of visible authors
		IF (len(@VisibleAuthorList + ', ' + @CurrentAuthor) < 3990) 
			BEGIN
				SET @VisibleAuthorList = @VisibleAuthorList + ', ' + @CurrentAuthor
				SET @VisibleAuthorXML = @VisibleAuthorXML + '<coauthor><name>'+@CurrentAuthor+'</name>' + 
						coalesce('<url>'+@CurrentURL+'</url>', '') + '</coauthor>'
			END
		ELSE
			BEGIN
				SET @VisibleAuthorList = @VisibleAuthorList + ', et al'
				BREAK
			END
		SET @CurrentRow=@CurrentRow+1
	END
	SET @VisibleAuthorXML = @VisibleAuthorXML+'</coauthors>'
	
	BEGIN
		UPDATE [UCSF.CTSASearch].[Publication.PubMed.CoAuthorXML] SET Display = @VisibleAuthorXML WHERE PMID = @pmid
	END

	--*** general (pubdate) ***
	UPDATE [Profile.Data].[Publication.PubMed.General] SET Authors = @VisibleAuthorList, 
		PubDate = coalesce([Profile.Data].[fnPublication.Pubmed.GetPubDate](MedlineDate,JournalYear,JournalMonth,JournalDay,ArticleYear,ArticleMonth,ArticleDay),'1/1/1900')
		WHERE PMID = @pmid

END

/**************************************
*
*
*
*
*
*
**************************************/






GO


