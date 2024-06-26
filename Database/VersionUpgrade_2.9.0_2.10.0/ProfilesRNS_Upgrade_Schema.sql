/*
Run this script on:

        Profiles 2.9.0   -  This database will be modified

to synchronize it with:

        Profiles 2.10.0

You are recommended to back up your database before running this script

Details of which objects have changed can be found in the release notes.
If you have made changes to existing tables or stored procedures in profiles, you may need to merge changes individually. 

*/


/***
* 
* Modifications required to handle Funding Disambiguation
*
***/

CREATE TABLE [Profile.Data].[Funding.DisambiguationAudit] (
    [LogID]            BIGINT        IDENTITY (0, 1) NOT NULL,
    [ServiceCallStart] DATETIME      NULL,
    [ServiceCallEnd]   DATETIME      NULL,
    [ProcessEnd]       DATETIME      NULL,
    [Success]          BIT           NULL,
    [ErrorText]        VARCHAR (MAX) NULL
);


GO

CREATE TABLE [Profile.Data].[Funding.DisambiguationOrganizationMapping] (
    [InstitutionID] INT            NULL,
    [Organization]  VARCHAR (1000) NOT NULL
);


GO
CREATE TABLE [Profile.Data].[Funding.DisambiguationResults] (
    [PersonID]                  INT           NOT NULL,
    [FundingID]                 VARCHAR (50)  NOT NULL,
    [FundingID2]                VARCHAR (50)  NULL,
    [Source]                    VARCHAR (50)  NOT NULL,
    [GrantAwardedBy]            VARCHAR (50)  NULL,
    [StartDate]                 DATE          NULL,
    [EndDate]                   DATE          NULL,
    [PrincipalInvestigatorName] VARCHAR (100) NULL,
    [AgreementLabel]            VARCHAR (500) NULL,
    [Abstract]                  VARCHAR (MAX) NULL,
    [RoleLabel]                 VARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([PersonID] ASC, [FundingID] ASC, [Source] ASC)
);


GO
CREATE PROCEDURE  [Profile.Data].[Funding.AddDisambiguationLog] (@logID BIGINT, 
												@action VARCHAR(200),
												@actionText varchar(max) = null,
												@newLogID BIGINT OUTPUT )
AS
BEGIN
	IF @action='StartService'
		BEGIN
			DECLARE @logIDtable TABLE (logID BIGINT)
			INSERT INTO [Profile.Data].[Funding.DisambiguationAudit]  (ServiceCallStart)
			OUTPUT inserted.logID into @logIDtable
			VALUES (GETDATE())
			select @newLogID = logID from @logIDtable
		END
	IF @action='EndService'
		BEGIN
			UPDATE [Profile.Data].[Funding.DisambiguationAudit] 
			   SET ServiceCallEnd = GETDATE()
			 WHERE LogID=@LogID
			 select @newLogID = @logID
		END
	IF @action='Error'
		BEGIN
			UPDATE [Profile.Data].[Funding.DisambiguationAudit] 
			   SET ErrorText = @actionText,
				   ProcessEnd  = GETDATE(),
				   Success=0
			 WHERE LogID=@LogID
			 select @newLogID = @logID
		END
END

GO
CREATE procedure [Profile.Data].[Funding.GetPersonInfoForDisambiguation] 
	@startRow INT = 0,
	@nextRow INT OUTPUT
AS
BEGIN
SET nocount  ON;
 
 
	DECLARE  @search XML,
				@batchcount INT,
				@baseURI NVARCHAR(max),
				@orcidNodeID NVARCHAR(max),
				@rows INT,
				@batchSize INT

				
	SELECT @batchSize = 1000

	SELECT @baseURI = [Value] FROM [Framework.].[Parameter] WHERE [ParameterID] = 'baseURI'
	SELECT @orcidNodeID = NodeID from [RDF.].Node where Value = 'http://vivoweb.org/ontology/core#orcidId'
	
	SELECT personID, ROW_NUMBER() OVER (ORDER BY personID) AS rownum INTO #personIDs FROM [Profile.Data].Person 
	WHERE IsActive = 1

	SELECT @rows = count(*) FROM #personIDs
	SELECT @nextRow = CASE WHEN @rows > @startRow + @batchSize THEN @startRow + @batchSize ELSE -1 END

	SELECT (
		select p2.personid as PersonID, 
		ISNULL(RTRIM(firstname),'')  "Name/First",
		ISNULL(RTRIM(middlename),'') "Name/Middle",
		ISNULL(RTRIM(p2.lastname),'') "Name/Last",
		ISNULL(RTRIM(suffix),'')     "Name/Suffix",
		d.cnt "LocalDuplicateNames",
		(SELECT DISTINCT ISNULL(LTRIM(ISNULL(emailaddress,p2.emailaddr)),'') Email
				FROM [Profile.Data].[Person.Affiliation] pa
				WHERE pa.personid = p2.personid
			FOR XML PATH(''),TYPE) AS "EmailList",
		(SELECT distinct Organization as Org FROM [Profile.Data].[Funding.DisambiguationOrganizationMapping] m
			JOIN [Profile.Data].[Person.Affiliation] pa
			on m.InstitutionID = pa.InstitutionID 
				or m.InstitutionID is null
			where pa.PersonID = p2.PersonID
			FOR XML PATH(''),ROOT('OrgList'),TYPE),
		(SELECT PMID
				FROM [Profile.Data].[Publication.Person.Add]
				WHERE personid =p2.personid
			FOR XML PATH(''),ROOT('PMIDAddList'),TYPE),
		(SELECT PMID
			FROM [Profile.Data].[Publication.Person.Include]
				WHERE personid =p2.personid
			FOR XML PATH(''),ROOT('PMIDIncludeList'),TYPE),
		(SELECT PMID
			FROM [Profile.Data].[Publication.Person.Exclude]
				WHERE personid =p2.personid
			FOR XML PATH(''),ROOT('PMIDExcludeList'),TYPE),
		(SELECT FundingID FROM [Profile.Data].[Funding.Add] ad
			join [Profile.Data].[Funding.Agreement] ag
				on ad.FundingAgreementID = ag.FundingAgreementID
				and ag.Source = 'NIH'
				WHERE ad.PersonID = p2.PersonID
			FOR XML PATH(''),ROOT('GrantsAddList'),TYPE),
		(SELECT FundingID FROM [Profile.Data].[Funding.Add] ad
			join [Profile.Data].[Funding.Agreement] ag
				on ad.FundingAgreementID = ag.FundingAgreementID
				and ag.Source = 'NIH'
				WHERE ad.PersonID = p2.PersonID
			FOR XML PATH(''),ROOT('GrantsAddList'),TYPE),
		(SELECT FundingID FROM [Profile.Data].[Funding.Delete]
				WHERE Source = 'NIH' and PersonID = p2.PersonID
			FOR XML PATH(''),ROOT('GrantsDeleteList'),TYPE),
		(SELECT @baseURI + CAST(i.NodeID AS VARCHAR) 
			FOR XML PATH(''),ROOT('URI'),TYPE),
				(select n.Value as '*' from [RDF.].Node n join
				[RDF.].Triple t  on n.NodeID = t.Object
				and t.Subject = i.NodeID
				and t.Predicate = @orcidNodeID
			FOR XML PATH(''),ROOT('ORCID'),TYPE)
	FROM [Profile.Data].Person p2 
	  LEFT JOIN ( SELECT [Utility.NLP].[fnNamePart1](firstname)F,
			lastname,
			COUNT(*)cnt
			FROM [Profile.Data].Person 
			GROUP BY [Utility.NLP].[fnNamePart1](firstname), 
				lastname
			)d ON d.f = [Utility.NLP].[fnNamePart1](p2.firstname)
				AND d.lastname = p2.lastname
				AND p2.IsActive = 1 
		LEFT JOIN [RDF.Stage].[InternalNodeMap] i
			ON [InternalType] = 'Person' AND [Class] = 'http://xmlns.com/foaf/0.1/Person' AND [InternalID] = CAST(p2.personid AS VARCHAR(50))
		-- below added by UCSF
		JOIN #personIDs p3 on p2.personID = p3.personID AND p3.rownum > @startRow and (@nextRow = -1 OR p3.rownum <= @nextRow)
	  for xml path('Person'), root('FindFunding'), type) as X
END

GO
CREATE procedure [Profile.Data].[Funding.LoadDisambiguationResults]
AS
BEGIN
	--------------------------------------------------------------
	-- Get existing and deleted NIH grants
	--------------------------------------------------------------

	SELECT DISTINCT ISNULL(r.PersonID,0) PersonID, ISNULL(a.FundingID2,'') CORE_PROJECT_NUM
		INTO #ExistingRoles
		FROM [Profile.Data].[Funding.Role] r
			INNER JOIN [Profile.Data].[Funding.Agreement] a
				ON r.FundingAgreementID = a.FundingAgreementID
		WHERE a.Source = 'NIH' AND a.FundingID2 <> ''

	ALTER TABLE #ExistingRoles ADD PRIMARY KEY (PersonID, CORE_PROJECT_NUM)


	SELECT DISTINCT ISNULL(PersonID,0) PersonID, ISNULL(FundingID2,'') CORE_PROJECT_NUM
		INTO #DeletedRoles
		FROM [Profile.Data].[Funding.Delete]
		WHERE Source = 'NIH' AND FundingID2 <> ''

	ALTER TABLE #DeletedRoles ADD PRIMARY KEY (PersonID, CORE_PROJECT_NUM)

	--------------------------------------------------------------
	-- Get a list of agreements
	--------------------------------------------------------------

	SELECT 
			ISNULL(NEWID(),'00000000-0000-0000-0000-000000000000') FundingAgreementID,
			ISNULL(FundingID,'') FundingID,
			AgreementLabel,
			GrantAwardedBy,
			StartDate,
			EndDate,
			PrincipalInvestigatorName,
			NULLIF(Abstract,'') Abstract,
			Source,
			FundingID2
		INTO #Agreement
		FROM (
			SELECT *, ROW_NUMBER() OVER (PARTITION BY FundingID ORDER BY PersonID) k
			FROM [Profile.Data].[Funding.DisambiguationResults] e
			WHERE NOT EXISTS (
				SELECT * 
				FROM #DeletedRoles d 
				WHERE d.PersonID=e.PersonID AND d.CORE_PROJECT_NUM=e.FundingID2
			)
		) t
		WHERE k = 1

	ALTER TABLE #Agreement ADD PRIMARY KEY (FundingAgreementID)
	CREATE UNIQUE NONCLUSTERED INDEX idx_FundingID ON #Agreement(FundingID)

	-- Use the current FundingAgreementID if one exists
	UPDATE a
		SET a.FundingAgreementID = h.FundingAgreementID
		FROM #Agreement a
			INNER JOIN [Profile.Data].[Funding.Agreement] h
				ON a.FundingID = h.FundingID
					AND a.FundingID = h.FundingID2
					AND h.Source = 'NIH'

	--------------------------------------------------------------
	-- Get a list of new roles
	--------------------------------------------------------------

	SELECT ISNULL(NEWID(),'00000000-0000-0000-0000-000000000000') FundingRoleID, 
			e.PersonID, a.FundingAgreementID, e.RoleLabel RoleLabel, NULL RoleDescription
		INTO #Role
		FROM [Profile.Data].[Funding.DisambiguationResults] e
			INNER JOIN #Agreement a ON e.FundingID = a.FundingID
		WHERE NOT EXISTS (
			SELECT * 
			FROM #DeletedRoles d 
			WHERE d.PersonID=e.PersonID AND d.CORE_PROJECT_NUM=e.FundingID
		) AND NOT EXISTS (
			SELECT * 
			FROM #ExistingRoles a 
			WHERE a.PersonID=e.PersonID AND a.CORE_PROJECT_NUM=e.FundingID
		)

	ALTER TABLE #Role ADD PRIMARY KEY (FundingRoleID)
	CREATE UNIQUE NONCLUSTERED INDEX idx_PersonAgreement ON #Role(PersonID,FundingAgreementID)


	--------------------------------------------------------------
	-- Update actual tables
	--------------------------------------------------------------

	-- Update agreement information
	UPDATE h
		SET h.AgreementLabel = a.AgreementLabel,
			h.GrantAwardedBy = a.GrantAwardedBy,
			h.StartDate = a.StartDate,
			h.EndDate = a.EndDate,
			h.PrincipalInvestigatorName = a.PrincipalInvestigatorName,
			h.Abstract = a.Abstract
		FROM [Profile.Data].[Funding.Agreement] h
			INNER JOIN #Agreement a 
				ON h.FundingAgreementID = a.FundingAgreementID
		WHERE h.AgreementLabel <> a.AgreementLabel
			OR h.GrantAwardedBy <> a.GrantAwardedBy
			OR h.StartDate <> a.StartDate
			OR h.EndDate <> a.EndDate
			OR h.PrincipalInvestigatorName <> a.PrincipalInvestigatorName
			OR h.Abstract <> a.Abstract

	-- Insert new agreements
	INSERT INTO [Profile.Data].[Funding.Agreement]
		SELECT FundingAgreementID, FundingID, AgreementLabel, GrantAwardedBy, StartDate, EndDate, PrincipalInvestigatorName, Abstract, Source, FundingID2
		FROM #Agreement a
		WHERE FundingAgreementID NOT IN (SELECT FundingAgreementID FROM [Profile.Data].[Funding.Agreement])

	-- Insert new roles
	INSERT INTO [Profile.Data].[Funding.Role]
		SELECT FundingRoleID, PersonID, FundingAgreementID, RoleLabel, RoleDescription
		FROM #Role

	-- Update the Activity log	
	INSERT INTO [Framework.].[Log.Activity] (userId, personId, methodName, property, privacyCode, param1, param2) 
		SELECT 0, PersonID, '[Profile.Data].[Funding.LoadDisambiguationResults]', 'http://vivoweb.org/ontology/core#ResearcherRole', null, FundingRoleID, null 
		FROM #Role
	

	--******************************************************************
	--******************************************************************
	--*** Update RDF
	--******************************************************************
	--******************************************************************


	CREATE TABLE #DataMapID (DataMapID INT PRIMARY KEY)

	INSERT INTO #DataMapID (DataMapID)
		SELECT DataMapID
			FROM [Ontology.].[DataMap]
			WHERE Class IN ('http://vivoweb.org/ontology/core#Grant','http://vivoweb.org/ontology/core#ResearcherRole')
				AND Property IS NULL
				AND NetworkProperty IS NULL 
		UNION ALL
		SELECT DataMapID
			FROM [Ontology.].[DataMap]
			WHERE Class = 'http://vivoweb.org/ontology/core#Grant'
				AND Property IS NOT NULL
				AND NetworkProperty IS NULL 
		UNION ALL
		SELECT DataMapID
			FROM [Ontology.].[DataMap]
			WHERE Class = 'http://vivoweb.org/ontology/core#ResearcherRole'
				AND Property IS NOT NULL
				AND NetworkProperty IS NULL 
		UNION ALL
		SELECT DataMapID
			FROM [Ontology.].[DataMap]
			WHERE Class = 'http://xmlns.com/foaf/0.1/Person'
				AND Property = 'http://vivoweb.org/ontology/core#hasResearcherRole'
				AND NetworkProperty IS NULL 

	DECLARE @DataMapID INT

	WHILE EXISTS (SELECT * FROM #DataMapID)
	BEGIN
		SELECT @DataMapID = (SELECT TOP 1 DataMapID FROM #DataMapID ORDER BY DataMapID)

		EXEC [RDF.Stage].[ProcessDataMap] @DataMapID = @DataMapID, @TurnOffIndexing = 0

		DELETE FROM #DataMapID WHERE DataMapID = @DataMapID
	END
END

GO
CREATE procedure [Profile.Data].[Funding.ParseDisambiguationXML]
	@xml XMl,
	@truncate INT = null
AS
BEGIN
	IF @truncate = 1
	BEGIN
		Truncate table [Profile.Data].[Funding.DisambiguationResults]
	END

	Insert into [Profile.Data].[Funding.DisambiguationResults]
	(PersonID, FundingID, GrantAwardedBy, StartDate, EndDate, PrincipalInvestigatorName,
		AgreementLabel, Abstract, Source, FundingID2, RoleLabel)
	select nref.value('@PersonID','varchar(max)') PersonID,
	sref.value('FundingID[1]','varchar(max)') FundingID,
	sref.value('GrantAwardedBy[1]','varchar(max)') GrantAwardedBy,
	sref.value('StartDate[1]','varchar(max)') StartDate,
	sref.value('EndDate[1]','varchar(max)') EndDate,
	sref.value('PrincipalInvestigatorName[1]','varchar(max)') PrincipalInvestigatorName,
	sref.value('AgreementLabel[1]','varchar(max)') AgreementLabel,
	sref.value('Abstract[1]','varchar(max)') Abstract,
	sref.value('Source[1]','varchar(max)') Source,
	sref.value('FundingID2[1]','varchar(max)') FundingID2,
	sref.value('RoleLabel[1]','varchar(max)') RoleLabel
	from @xml.nodes('//PersonList[1]/Person') as R(nref)
	cross apply R.nref.nodes('Funding') as S(sref)
END
GO




/***
* 
* Modifications required to handle batch processing of PubMed XML
*
***/


GO
CREATE TABLE [Profile.Data].[Publication.PubMed.Author.Stage] (
    [PmPubsAuthorID] INT            IDENTITY (1, 1) NOT NULL,
    [PMID]           INT            NOT NULL,
    [ValidYN]        VARCHAR (1)    NULL,
    [LastName]       VARCHAR (100)  NULL,
    [FirstName]      VARCHAR (100)  NULL,
    [ForeName]       VARCHAR (100)  NULL,
    [Suffix]         VARCHAR (20)   NULL,
    [Initials]       VARCHAR (20)   NULL,
    [Affiliation]    VARCHAR (4000) NULL,
    CONSTRAINT [PK__pm_pubs_authors_stage] PRIMARY KEY CLUSTERED ([PmPubsAuthorID] ASC)
);


GO
CREATE TABLE [Profile.Data].[Publication.PubMed.General.Stage] (
    [PMID]                 INT            NOT NULL,
    [PMCID]                NVARCHAR (55)  NULL,
    [Owner]                VARCHAR (50)   NULL,
    [Status]               VARCHAR (50)   NULL,
    [PubModel]             VARCHAR (50)   NULL,
    [Volume]               VARCHAR (255)  NULL,
    [Issue]                VARCHAR (255)  NULL,
    [MedlineDate]          VARCHAR (255)  NULL,
    [JournalYear]          VARCHAR (50)   NULL,
    [JournalMonth]         VARCHAR (50)   NULL,
    [JournalDay]           VARCHAR (50)   NULL,
    [JournalTitle]         VARCHAR (1000) NULL,
    [ISOAbbreviation]      VARCHAR (100)  NULL,
    [MedlineTA]            VARCHAR (1000) NULL,
    [ArticleTitle]         VARCHAR (4000) NULL,
    [MedlinePgn]           VARCHAR (255)  NULL,
    [AbstractText]         TEXT           NULL,
    [ArticleDateType]      VARCHAR (50)   NULL,
    [ArticleYear]          VARCHAR (10)   NULL,
    [ArticleMonth]         VARCHAR (10)   NULL,
    [ArticleDay]           VARCHAR (10)   NULL,
    [Affiliation]          VARCHAR (4000) NULL,
    [AuthorListCompleteYN] VARCHAR (1)    NULL,
    [GrantListCompleteYN]  VARCHAR (1)    NULL,
    [PubDate]              DATETIME       NULL,
    [Authors]              VARCHAR (4000) NULL,
    PRIMARY KEY CLUSTERED ([PMID] ASC)
);


GO

CREATE TABLE [Profile.Data].[Publication.PubMed.Mesh.Stage] (
    [PMID]           INT           NOT NULL,
    [DescriptorName] VARCHAR (255) NOT NULL,
    [QualifierName]  VARCHAR (255) NOT NULL,
    [MajorTopicYN]   CHAR (1)      NULL,
    CONSTRAINT [PK_pm_pubs_mesh_stage] PRIMARY KEY CLUSTERED ([PMID] ASC, [DescriptorName] ASC, [QualifierName] ASC)
);


GO

ALTER procedure  [Profile.Data].[Publication.Pubmed.AddPubMedXML] ( 					 @pmid INT,
																			   @pubmedxml XML)
AS
BEGIN
	SET NOCOUNT ON;	
	 
	-- Parse Load Publication XML
	BEGIN TRY 	 
	
	IF ISNULL(CAST(@pubmedxml AS NVARCHAR(MAX)),'')='' 
		BEGIN
			DELETE FROM [Profile.Data].[Publication.PubMed.Disambiguation] WHERE pmid = @pmid AND NOT EXISTS (SELECT 1 FROM [Profile.Data].[Publication.Person.Add]  pa WHERE pa.pmid = @pmid)
			RETURN
		END
 
		BEGIN TRAN
			-- Remove existing pmid record
			DELETE FROM [Profile.Data].[Publication.PubMed.AllXML] WHERE pmid = @pmid
		
			-- Add Pub Med XML	
			INSERT INTO [Profile.Data].[Publication.PubMed.AllXML](pmid,X) VALUES(@pmid,CAST(@pubmedxml AS XML))		
			
			-- Parse Pub Med XML
			--EXEC [Profile.Data].[Publication.Pubmed.ParsePubMedXML] 	 @pmid		
		 
		COMMIT
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
		--Check success
		IF @@TRANCOUNT > 0  ROLLBACK
 
		-- Raise an error with the details of the exception
		SELECT @ErrMsg = '[Profile.Data].[Publication.Pubmed.AddPubMedXML] FAILED WITH : ' + ERROR_MESSAGE(),
					 @ErrSeverity = ERROR_SEVERITY()
 
		RAISERROR(@ErrMsg, @ErrSeverity, 1)
			 
	END CATCH				
END
GO

ALTER procedure [Profile.Data].[Publication.Pubmed.ParsePubMedXML]
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
					nref.value('Article[1]/ArticleTitle[1]','varchar(max)') ArticleTitle,
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

	-- Updated on 19 Dec 2016 to handle incorrectly formatted dates
	update [Profile.Data].[Publication.PubMed.General]
	set MedlineDate = (case when right(MedlineDate,4) like '20__' then ltrim(rtrim(right(MedlineDate,4)+' '+left(MedlineDate,len(MedlineDate)-4))) else null end)
	where MedlineDate is not null and MedlineDate not like '[0-9][0-9][0-9][0-9]%'
	
	--*** authors ***
	insert into [Profile.Data].[Publication.PubMed.Author] (pmid, ValidYN, LastName, FirstName, ForeName, Suffix, Initials, Affiliation)
		select pmid, 
			nref.value('@ValidYN','varchar(max)') ValidYN, 
			nref.value('LastName[1]','varchar(max)') LastName, 
			nref.value('FirstName[1]','varchar(max)') FirstName,
			nref.value('ForeName[1]','varchar(max)') ForeName,
			nref.value('Suffix[1]','varchar(max)') Suffix,
			nref.value('Initials[1]','varchar(max)') Initials,
			COALESCE(nref.value('AffiliationInfo[1]/Affiliation[1]','varchar(max)'),
				nref.value('Affiliation[1]','varchar(max)')) Affiliation
		from [Profile.Data].[Publication.PubMed.AllXML] cross apply x.nodes('//AuthorList/Author') as R(nref)
		where pmid = @pmid
		

	--*** investigators ***
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
		pmid int,
		lastname varchar(100),
		initials varchar(20),
		s varchar(max)
	)

	insert into @a (pmid, lastname, initials)
		select pmid, lastname, initials
		from [Profile.Data].[Publication.PubMed.Author]
		where pmid = @pmid
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

GO
CREATE procedure [Profile.Data].[Publication.Pubmed.ParseALLPubMedXML]
AS
BEGIN
	SET NOCOUNT ON;

/*
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
	*/
	
	--*** general ***
	truncate table [Profile.Data].[Publication.PubMed.General.Stage]
	insert into [Profile.Data].[Publication.PubMed.General.Stage] (pmid, Owner, Status, PubModel, Volume, Issue, MedlineDate, JournalYear, JournalMonth, JournalDay, JournalTitle, ISOAbbreviation, MedlineTA, ArticleTitle, MedlinePgn, AbstractText, ArticleDateType, ArticleYear, ArticleMonth, ArticleDay, Affiliation, AuthorListCompleteYN, GrantListCompleteYN,PMCID)
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
		where ParseDT is null and x is not null

		update [Profile.Data].[Publication.PubMed.General.Stage]
		set MedlineDate = (case when right(MedlineDate,4) like '20__' then ltrim(rtrim(right(MedlineDate,4)+' '+left(MedlineDate,len(MedlineDate)-4))) else null end)
		where MedlineDate is not null and MedlineDate not like '[0-9][0-9][0-9][0-9]%'
		
		update [Profile.Data].[Publication.PubMed.General.Stage]
		set PubDate = [Profile.Data].[fnPublication.Pubmed.GetPubDate](medlinedate,journalyear,journalmonth,journalday,articleyear,articlemonth,articleday)


	--*** authors ***
	truncate table [Profile.Data].[Publication.PubMed.Author.Stage]
	insert into [Profile.Data].[Publication.PubMed.Author.Stage] (pmid, ValidYN, LastName, FirstName, ForeName, Suffix, Initials, Affiliation)
		select pmid, 
			nref.value('@ValidYN','varchar(1)') ValidYN, 
			nref.value('LastName[1]','varchar(100)') LastName, 
			nref.value('FirstName[1]','varchar(100)') FirstName,
			nref.value('ForeName[1]','varchar(100)') ForeName,
			nref.value('Suffix[1]','varchar(20)') Suffix,
			nref.value('Initials[1]','varchar(20)') Initials,
			COALESCE(nref.value('AffiliationInfo[1]/Affiliation[1]','varchar(1000)'),
				nref.value('Affiliation[1]','varchar(max)')) Affiliation
		from [Profile.Data].[Publication.PubMed.AllXML] cross apply x.nodes('//AuthorList/Author') as R(nref)
		where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
		


	--*** general (authors) ***

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
				nref.value('@MajorTopicYN[1]','varchar(max)') MajorTopicYN, 
				nref.value('.','varchar(max)') DescriptorName,
				null QualifierName
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//MeshHeadingList/MeshHeading/DescriptorName') as R(nref)
			where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
			union all
			select pmid, 
				nref.value('@MajorTopicYN[1]','varchar(max)') MajorTopicYN, 
				nref.value('../DescriptorName[1]','varchar(max)') DescriptorName,
				nref.value('.','varchar(max)') QualifierName
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
				
	insert into [Profile.Data].[Publication.PubMed.General] (pmid, pmcid, Owner, Status, PubModel, Volume, Issue, MedlineDate, JournalYear, JournalMonth, JournalDay, JournalTitle, ISOAbbreviation, MedlineTA, ArticleTitle, MedlinePgn, AbstractText, ArticleDateType, ArticleYear, ArticleMonth, ArticleDay, Affiliation, AuthorListCompleteYN, GrantListCompleteYN, PubDate, Authors)
		select pmid, pmcid, Owner, Status, PubModel, Volume, Issue, MedlineDate, JournalYear, JournalMonth, JournalDay, JournalTitle, ISOAbbreviation, MedlineTA, ArticleTitle, MedlinePgn, AbstractText, ArticleDateType, ArticleYear, ArticleMonth, ArticleDay, Affiliation, AuthorListCompleteYN, GrantListCompleteYN, PubDate, Authors
			from [Profile.Data].[Publication.PubMed.General.Stage]
			where pmid not in (select pmid from [Profile.Data].[Publication.PubMed.General])
	
	
	--******************************************************************
	--******************************************************************
	--*** Update Authors
	--******************************************************************
	--******************************************************************
	
	delete from [Profile.Data].[Publication.PubMed.Author] where pmid in (select pmid from [Profile.Data].[Publication.PubMed.Author.Stage])
	insert into [Profile.Data].[Publication.PubMed.Author] (pmid, ValidYN, LastName, FirstName, ForeName, Suffix, Initials, Affiliation)
		select pmid, ValidYN, LastName, FirstName, ForeName, Suffix, Initials, Affiliation
		from [Profile.Data].[Publication.PubMed.Author]
		order by PmPubsAuthorID

		
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
			nref.value('LastName[1]','varchar(max)') LastName, 
			nref.value('FirstName[1]','varchar(max)') FirstName,
			nref.value('ForeName[1]','varchar(max)') ForeName,
			nref.value('Suffix[1]','varchar(max)') Suffix,
			nref.value('Initials[1]','varchar(max)') Initials,
			COALESCE(nref.value('AffiliationInfo[1]/Affiliation[1]','varchar(max)'),
				nref.value('Affiliation[1]','varchar(max)')) Affiliation
		from [Profile.Data].[Publication.PubMed.AllXML] cross apply x.nodes('//InvestigatorList/Investigator') as R(nref)
		where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
		

	--*** pubtype ***
	delete from [Profile.Data].[Publication.PubMed.PubType] where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
	insert into [Profile.Data].[Publication.PubMed.PubType] (pmid, PublicationType)
		select * from (
			select distinct pmid, nref.value('.','varchar(max)') PublicationType
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//PublicationTypeList/PublicationType') as R(nref)
			where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
		) t where PublicationType is not null


	--*** chemicals
	delete from [Profile.Data].[Publication.PubMed.Chemical] where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
	insert into [Profile.Data].[Publication.PubMed.Chemical] (pmid, NameOfSubstance)
		select * from (
			select distinct pmid, nref.value('.','varchar(max)') NameOfSubstance
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//ChemicalList/Chemical/NameOfSubstance') as R(nref)
			where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
		) t where NameOfSubstance is not null


	--*** databanks ***
	delete from [Profile.Data].[Publication.PubMed.Databank] where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
	insert into [Profile.Data].[Publication.PubMed.Databank] (pmid, DataBankName)
		select * from (
			select distinct pmid, 
				nref.value('.','varchar(max)') DataBankName
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//DataBankList/DataBank/DataBankName') as R(nref)
			where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
		) t where DataBankName is not null


	--*** accessions ***
	delete from [Profile.Data].[Publication.PubMed.Accession] where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
	insert into [Profile.Data].[Publication.PubMed.Accession] (pmid, DataBankName, AccessionNumber)
		select * from (
			select distinct pmid, 
				nref.value('../../DataBankName[1]','varchar(max)') DataBankName,
				nref.value('.','varchar(max)') AccessionNumber
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
				nref.value('.','varchar(max)') Keyword,
				nref.value('@MajorTopicYN','varchar(max)') MajorTopicYN
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
				nref.value('GrantID[1]','varchar(max)') GrantID, 
				nref.value('Acronym[1]','varchar(max)') Acronym,
				nref.value('Agency[1]','varchar(max)') Agency
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
GO
