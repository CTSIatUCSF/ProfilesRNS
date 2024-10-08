/****** Object:  StoredProcedure [UCSF.].[LoadDimensionsIntoProfiles]    Script Date: 11/8/2019 8:15:50 AM ******/
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
	delete from [UCSF.].[Publication.URL]
	where pmid<0
  end


----------
-- altered by Eric to only add in articles
SELECT g.ImportPubID, p.PersonID
		INTO #MyPubGeneral
		FROM [Profile.Data].[Publication.Import.General] g
			INNER JOIN [Profile.Data].[Publication.Import.Pub2Person] p
				ON g.ImportPubID = p.ImportPubID and g.ItemType = 'article'
		where personid is not null
		and p.ImportPubID<0

		--select * from [Profile.Data].[Publication.Import.General]
		select 'myPubGeneral',* from #MyPubGeneral
--------
DELETE g
		FROM #MyPubGeneral g
		WHERE EXISTS (
			SELECT *
				FROM [Profile.Data].[Publication.Person.Include] i
				WHERE g.ImportPubID=i.PMID AND g.PersonID=i.PersonID
				and g.ImportPubID<0
		)

		select 'myPubGeneral_1',* from #MyPubGeneral

	DELETE g
		FROM #MyPubGeneral g
		WHERE EXISTS (
			SELECT *
			FROM [Profile.Data].[Publication.Person.Exclude] e
			WHERE g.ImportPubID=e.PMID AND g.PersonID=e.PersonID
			and g.ImportPubID<0
		)

			select 'myPubGeneral_2',* from #MyPubGeneral

IF OBJECT_ID('tempdb..#NewPMID') IS NOT NULL DROP TABLE #NewPMID;

SELECT DISTINCT ImportPubID
		INTO #NewPMID
		FROM #MyPubGeneral
		WHERE ImportPubID NOT IN (SELECT PMID FROM [Profile.Data].[Publication.PubMed.General])

	ALTER TABLE #NewPMID ADD PRIMARY KEY (ImportPubID)
select 'NewPMID',* from #NewPMID

	INSERT INTO [Profile.Data].[Publication.PubMed.General] (PMID, Owner, Status, Volume, Issue, JournalYear, JournalMonth, JournalDay, JournalTitle, MedlineTA, ArticleTitle, MedlinePgn, AuthorListCompleteYN, PubDate, Authors)
		SELECT ImportPubID, ActualIDType, 'PRNS', Volume, Issue, Year(PubDate),
			 (case when Day(PubDate)>0 then left(DateName(month,PubDate),3) else null end),
			 (case when Day(PubDate) > 0 then Day(PubDate) else null end), 
			 SourceTitle, SourceAbbr, case when RIGHT(ItemTitle, 1) = '.' then ItemTitle else ItemTitle + '.' end, Pagination, 'Y', PubDate, Authors
		FROM [Profile.Data].[Publication.Import.General]
		WHERE ImportPubID IN (SELECT ImportPubID FROM #NewPMID) 
	

	insert into [UCSF.].[Publication.URL] (pmid,DBType,issn,doi,url)
	select   pmid,[ActualIDType],ISSN,DOI,[URL]
	FROM [Profile.Data].[Publication.Import.General]
		WHERE ImportPubID IN (SELECT ImportPubID FROM #NewPMID)


		select '[UCSF.].[Publication.URL]',* from [UCSF.].[Publication.URL] 

	select '[Profile.Data].[Publication.PubMed.General]',* from [Profile.Data].[Publication.PubMed.General]
	where PMID<0

	INSERT INTO [Profile.Data].[Publication.PubMed.Author] (PMID, ValidYN, LastName, FirstName, ForeName, Suffix, Initials, Affiliation)
		SELECT ImportPubID, 'Y', LastName, FirstName, IsNull(ForeName,FirstName), SuffixName, 
			Left(LastName,1)+Coalesce(Left(FirstName,1),Left(ForeName,1),''), NULL
			FROM [Profile.Data].[Publication.Import.Author]
			WHERE ImportPubID IN (SELECT ImportPubID FROM #NewPMID)
			ORDER BY ImportPubID, AuthorRank, AuthorID

	select '[Profile.Data].[Publication.PubMed.Author]',* from [Profile.Data].[Publication.PubMed.Author]
	where PMID<0
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
	--ELSE
	BEGIN
		INSERT INTO [Profile.Data].[Publication.Person.Include] (PubID, PersonID, PMID, MPID)
			SELECT NewID(), g.PersonID, ImportPubID, NULL MPID
				FROM #MyPubGeneral g
	END

	select '[Profile.Data].[Publication.Person.Include]',* from [Profile.Data].[Publication.Person.Include]
	where pmid <0

	-- Popluate [Publication.Entity.Authorship] and [Publication.Entity.InformationResource] tables
	EXEC [Profile.Data].[Publication.Entity.UpdateEntity]


END







