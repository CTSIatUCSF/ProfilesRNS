USE [profiles_ucsf]
GO

/****** Object:  StoredProcedure [UCSF.].[loadSymplecticIntoProfiles]    Script Date: 12/20/2017 10:33:57 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [UCSF.].[loadSymplecticIntoProfiles] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
IF OBJECT_ID('tempdb..#AuthorList') IS NOT NULL DROP TABLE #AuthorList;
		SELECT ImportPubID, 
			(
				SELECT IsNull((
					SELECT SUBSTRING(al,3,LEN(al))
					FROM (
						SELECT (
							SELECT IsNull(', '+a.AuthorName,'')
							FROM [Profile.Data].[Publication.Import.Author] a
							WHERE a.ImportPubID = p.ImportPubID
							ORDER BY a.AuthorRank
							FOR XML PATH(''), TYPE
						).value('(./text())[1]','varchar(max)') al
					) t
				), '')
			) AuthorList
		INTO #AuthorList
		FROM [Profile.Data].[Publication.Import.PubData] p
		GROUP BY p.ImportPubID
select "AuthorList",* from #AuthorList 

truncate table [Profile.Data].[Publication.Import.General] 
;WITH    XMLNAMESPACES ('http://www.w3.org/2005/Atom' as ns1,
	'http://www.symplectic.co.uk/publications/api' as api,default 'http://www.w3.org/2005/Atom')
	insert into [Profile.Data].[Publication.Import.General]
	SELECT pub.[ImportPubID]
		,R.nref.value('../@source-name','varchar(max)') as ActualIDType
		,R.nref.value('../@source-id','varchar(max)') as ActualID
		,SUBSTRING((R.nref.value('../../../@type','varchar(max)')),
			CHARINDEX('-',R.nref.value('../../../@type','varchar(max)'))+1,10
		) as 'ItemType'
	    ,SUBSTRING((R.nref.value('../../../@type','varchar(max)')),0,
			CHARINDEX('-',R.nref.value('../../../@type','varchar(max)'))
	    ) as 'SourceType'
		,R.nref.value('api:field[@name="title"][1]/api:text[1]','varchar(max)') as 'ItemTitle'
		,COALESCE (R.nref.value('api:field[@name="journal"][1]','varchar(max)'),
		 R.nref.value('../../../api:repository-items[1]/api:repository-item[1]/@repository-name','varchar(max)'),
		 R.nref.value('api:field[@name="parent-title"][1]/api:text[1]','varchar(max)')
		 ) 
		 as SourceTitle
		,NULL as SourceAbbr
		,R.nref.value('api:field[@name="volume"][1]/api:text[1]','varchar(max)') as Volume
		,R.nref.value('api:field[@name="issue"][1]/api:text[1]','varchar(max)') as 'issue'
		,R.nref.value('api:field[@name="pagination"][1]/api:pagination[1]/api:begin-page[1]','varchar(max)')+
			'-'+ R.nref.value('api:field[@name="pagination"][1]/api:pagination[1]/api:end-page[1]','varchar(max)')
		as 'pagination'
		,cast(IsNull(R.nref.value('api:field[@name="publication-date"][1]/api:date[1]/api:month[1]','varchar(max)'),'1') 
			+'/'+IsNULL(R.nref.value('api:field[@name="publication-date"][1]/api:date[1]/api:day[1]','varchar(max)'),'1') 
			+'/'+R.nref.value('api:field[@name="publication-date"][1]/api:date[1]/api:year[1]','varchar(max)') as DateTime) as 'Pubdate'
		,R.nref.value('api:field[@name="issn"][1]/api:text[1]','varchar(max)') as 'issn'
		,R.nref.value('api:field[@name="doi"][1]/api:text[1]','varchar(max)') as 'doi'
		,pub.[ImportPubID] as PMID
		,COALESCE(R.nref.value('api:field[@name="doi"][1]/api:links[1]/api:link[@type="doi"][1]/@href[1]','varchar(max)'),
		 R.nref.value('../../../api:repository-items[1]/api:repository-item[1]/api:public-url[1]','varchar(max)'),
		 R.nref.value('api:field[@name="author-url"][1]/api:text[1]','varchar(max)')
		 )
		 as 'url'
		,AuthorList as Authors
		,NULL as Reference
		,R.nref.value('../api:citation-count[1]','varchar(max)')
  FROM [Profile.Data].[Publication.Import.PubData] pub
  join #AuthorList authors on authors.ImportPubID=pub.ImportPubID
  CROSS APPLY  x.nodes('//feed[1]/entry[1]/api:object[1]/api:records[1]/api:record[@source-name][1]/api:native[1]') as R(nref)
  --where pub.importPubID=-478694;

select '[Profile.Data].[Publication.Import.General]',* from [Profile.Data].[Publication.Import.General]
---------------------
IF OBJECT_ID('tempdb..#myPubGeneral') IS NOT NULL DROP TABLE #myPubGeneral;


SELECT g.ImportPubID, p.PersonID
		INTO #MyPubGeneral
		FROM [Profile.Data].[Publication.Import.General] g
			INNER JOIN [Profile.Data].[Publication.Import.Author] p
				ON g.ImportPubID = p.ImportPubID
		where personid is not null
		and p.ImportPubID<0

		--select * from [Profile.Data].[Publication.Import.General]
		select 'myPubGeneral',* from #MyPubGeneral

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
	ALTER TABLE [Profile.Data].[Publication.PubMed.Author]  NOCHECK CONSTRAINT [FK_pm_pubs_authors_pm_pubs_general];
	delete from [Profile.Data].[Publication.PubMed.General]
	where pmid<-1
	delete from [Profile.Data].[Publication.Entity.InformationResource]
	where pmid<0;
	ALTER TABLE [Profile.Data].[Publication.PubMed.Author]  CHECK CONSTRAINT [FK_pm_pubs_authors_pm_pubs_general];

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
			 SourceTitle, SourceAbbr, ItemTitle, Pagination, 'Y', PubDate, Authors
		FROM [Profile.Data].[Publication.Import.General]
		WHERE ImportPubID IN (SELECT ImportPubID FROM #NewPMID) 
	
	delete from [UCSF.].[Publication.URL]
	where pmid<0
	insert into [UCSF.].[Publication.URL] (pmid,DBType,issn,doi,url)
	select   pmid,[ActualIDType],ISSN,DOI,[URL]
	FROM [Profile.Data].[Publication.Import.General]
		WHERE ImportPubID IN (SELECT ImportPubID FROM #NewPMID)


		select '[UCSF.].[Publication.URL]',* from [UCSF.].[Publication.URL] 

	select '[Profile.Data].[Publication.PubMed.General]',* from [Profile.Data].[Publication.PubMed.General]
	where PMID<0

	delete from [Profile.Data].[Publication.PubMed.Author]
	where pmid<-1
	INSERT INTO [Profile.Data].[Publication.PubMed.Author] (PMID, ValidYN, LastName, FirstName, ForeName, Suffix, Initials, Affiliation)
		SELECT ImportPubID, 'Y', LastName, FirstName, IsNull(ForeName,FirstName), SuffixName, 
			Left(LastName,1)+Coalesce(Left(FirstName,1),Left(ForeName,1),''), NULL
			FROM [Profile.Data].[Publication.Import.Author]
			WHERE ImportPubID IN (SELECT ImportPubID FROM #NewPMID)
			ORDER BY ImportPubID, AuthorRank, AuthorID

	select '[Profile.Data].[Publication.PubMed.Author]',* from [Profile.Data].[Publication.PubMed.Author]
	where PMID<0
--------------------
	delete from [Profile.Data].[Publication.Person.Include]
	where pmid<0

	INSERT INTO [Profile.Data].[Publication.Person.Include] (PubID, PersonID, PMID, MPID)
		SELECT NewID(), g.PersonID, ImportPubID, NULL MPID
			FROM #MyPubGeneral g

	select '[Profile.Data].[Publication.Person.Include]',* from [Profile.Data].[Publication.Person.Include]
	where pmid <0

END




GO


