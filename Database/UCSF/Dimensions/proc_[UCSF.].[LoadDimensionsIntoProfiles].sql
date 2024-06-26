USE [profilesRNS]
GO
/****** Object:  StoredProcedure [UCSF.].[LoadDimensionsIntoProfiles]    Script Date: 11/16/2020 12:11:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [UCSF.].[LoadDimensionsIntoProfiles] 
	@reset int=0
	--, @PubThreshold int=NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  if @reset=1
  begin
-- clean existing CDL data in Profiles tables -----
	delete from [Profile.Data].[Publication.PubMed.Author]
	where pmid<0
	--ALTER TABLE [Profile.Data].[Publication.PubMed.Author]  NOCHECK CONSTRAINT [FK_pm_pubs_authors_pm_pubs_general];
	delete from [Profile.Data].[Publication.Person.Include]
	where pmid<0
	delete from [Profile.Data].[Publication.Person.Exclude]
	where pmid<0
	--delete from [Profile.Data].[Publication.PubMed.General]
	--where pmid<0
	delete from [Profile.Data].[Publication.Entity.InformationResource]
	where pmid<0;
	--ALTER TABLE [Profile.Data].[Publication.PubMed.Author]  CHECK CONSTRAINT [FK_pm_pubs_authors_pm_pubs_general];
	delete from [UCSF.].[PublicationAdditions]
	where pmid<0
  end

IF OBJECT_ID('tempdb..#MyPub2Person') IS NOT NULL     DROP TABLE #MyPub2Person;
IF OBJECT_ID('tempdb..#MyPubGeneral') IS NOT NULL     DROP TABLE #MyPubGeneral;
IF OBJECT_ID('tempdb..#NewPMID') IS NOT NULL DROP TABLE #NewPMID;
---------------
	Exec [UCSF.].[GetDoiFromPubmed]
-- Updating Include table for any publications, even already processed before into General table

	SELECT * 
	INTO #MyPub2Person
		FROM [Profile.Data].[Publication.Import.Pub2Person]

--select 'myPub2Person',* from #MyPub2Person

	DELETE g
		FROM #MyPub2Person g
		WHERE EXISTS (
			SELECT *
				FROM [Profile.Data].[Publication.Person.Include] i
				WHERE g.ImportPubID=i.PMID AND g.PersonID=i.PersonID
					and g.ImportPubID<0
		)

--select 'myPub2Person_1',* from #MyPub2Person

	DELETE g
	FROM #MyPub2Person g
	WHERE EXISTS (
		SELECT *
		FROM [Profile.Data].[Publication.Person.Exclude] e
		WHERE g.ImportPubID=e.PMID AND g.PersonID=e.PersonID
			and g.ImportPubID<0
	)

--select 'myPub2Person_2',* from #MyPub2Person
----------
	DELETE g
	FROM #MyPub2Person g
	WHERE ImportPubID  in (
		SELECT  p2p.importPubID 
		FROM #MyPub2Person p2p
		JOIN [Profile.Data].[Publication.Import.General] ig on ig.ImportPubID=p2p.ImportPubID
		JOIN [UCSF.].[PublicationAdditions] pa on pa.doi=ig.doi and pa.pmid != ig.ImportPubID and pa.pmid>0
	)
------------

SELECT g.ImportPubID, p.PersonID
		INTO #MyPubGeneral
		FROM [Profile.Data].[Publication.Import.General] g
			INNER JOIN #MyPub2Person p
				ON g.ImportPubID = p.ImportPubID
		where personid is not null
		and p.ImportPubID<0



	SELECT DISTINCT ImportPubID
		INTO #NewPMID
		FROM #MyPubGeneral
		WHERE ImportPubID NOT IN (SELECT PMID FROM [Profile.Data].[Publication.PubMed.General])

	ALTER TABLE #NewPMID ADD PRIMARY KEY (ImportPubID)

select 'NewPMID',* from #NewPMID

	-- altered by Eric to add a period to Item Title if it is missing
	INSERT INTO [Profile.Data].[Publication.PubMed.General] (PMID, Owner, Status, Volume, Issue, JournalYear, JournalMonth, JournalDay, JournalTitle, MedlineTA, ArticleTitle, MedlinePgn, AuthorListCompleteYN, PubDate, Authors)
		SELECT ImportPubID, ActualIDType, 'PRNS', Volume, Issue, Year(PubDate),
			 (case when Day(PubDate)>0 then left(DateName(month,PubDate),3) else null end),
			 (case when Day(PubDate) > 0 then Day(PubDate) else null end), 
			 SourceTitle, SourceAbbr, case when RIGHT(ItemTitle, 1) = '.' then ItemTitle else ItemTitle + '.' end, Pagination, 'Y', PubDate, Authors
			FROM [Profile.Data].[Publication.Import.General]
			WHERE ImportPubID IN (SELECT ImportPubID FROM #NewPMID) 
	
	
	INSERT INTO [Profile.Data].[Publication.Person.Include] (PubID, PersonID, PMID, MPID)
			SELECT NewID(), g.PersonID, ImportPubID, NULL MPID
				FROM #MyPub2Person  g
	JOIN [Profile.Data].[Publication.PubMed.General]  pubg on pubg.pmid=g.ImportPubID 


	INSERT INTO [UCSF.].[PublicationAdditions] (pmid,DBType,issn,doi,url)
		SELECT   pmid,[ActualIDType],substring(ISSN,1,20),DOI,[URL]
			FROM [Profile.Data].[Publication.Import.General]
			WHERE ImportPubID IN (SELECT ImportPubID FROM #NewPMID)
			and ImportPubID not in (select pmid from [UCSF.].[PublicationAdditions])


	--select '[UCSF.].[Publication.URL]',* from [UCSF.].[Publication.URL] 

	--select '[Profile.Data].[Publication.PubMed.General]',* from [Profile.Data].[Publication.PubMed.General]
	--where PMID<0

	INSERT INTO [Profile.Data].[Publication.PubMed.Author] (PMID, ValidYN, LastName, FirstName, ForeName, Suffix, Initials, Affiliation)
		SELECT ImportPubID, 'Y', LastName, FirstName, IsNull(ForeName,FirstName), SuffixName, 
			Left(LastName,1)+Coalesce(Left(FirstName,1),Left(ForeName,1),''), NULL
			FROM [Profile.Data].[Publication.Import.Author]
			WHERE ImportPubID IN (SELECT ImportPubID FROM #NewPMID)
			ORDER BY ImportPubID, AuthorRank, AuthorID

--------------------
	-- Added by Eric. For the first month or so, only add pubs that won't drastcially change the profile, aka
	-- if the number added for a particular person is below a threshold (probably 10) 
	--IF @PubThreshold IS NOT NULL
	--BEGIN
	--	SELECT PersonId, count(*) PubCount INTO #Threshold FROM #MyPubGeneral 
	--	GROUP BY PersonId HAVING count(*) <= @PubThreshold 

	--	INSERT INTO [Profile.Data].[Publication.Person.Include] (PubID, PersonID, PMID, MPID)
	--		SELECT NewID(), g.PersonID, ImportPubID, NULL MPID
	--			FROM #MyPubGeneral g JOIN #Threshold t ON g.PersonID = t.PersonID
	--END 

	-- Popluate [Publication.Entity.Authorship] and [Publication.Entity.InformationResource] tables
	EXEC [Profile.Data].[Publication.Entity.UpdateEntity]


END







