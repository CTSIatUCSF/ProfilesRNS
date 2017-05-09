/********** publications ****************************************************************************************/
 -- Pubmed first but only those that can be parsed! 
 --- add publication xml, then parse, then add to people, and remove those that are NOT claimed
-- UCSF
WHILE EXISTS (SELECT * FROM  [profiles_ucsf].[Profile.Data].[Publication.PubMed.AllXML] WHERE ParseDT IS NOT NULL
	AND PMID NOT IN (SELECT PMID FROM [Profile.Data].[Publication.PubMed.AllXML]))
BEGIN 
	INSERT [Profile.Data].[Publication.PubMed.AllXML] (PMID, X) SELECT TOP 1000 PMID, X FROM  [profiles_ucsf].[Profile.Data].[Publication.PubMed.AllXML]
	WHERE ParseDT IS NOT NULL AND PMID NOT IN (SELECT PMID FROM [Profile.Data].[Publication.PubMed.AllXML])
END 
-- now parse all of it

EXEC [Profile.Data].[Publication.Pubmed.ParseALLPubMedXML]

-- load up people to migrate
SELECT DISTINCT d.personid newPersonID, s.personid oldPersonID INTO #peopleMapUCSF FROM [Profile.Data].[Person] d join [profiles_ucsf].[Profile.Data].[Person] s on d.internalusername = [UCSF.].fn_LegacyInternalusername2EPPN(s.InternalUserName, 'ucsf')
JOIN [profiles_ucsf].[Profile.Data].[Publication.Person.Include] si on si.PersonID = s.PersonID WHERE si.PMID is not null AND si.PersonID is not null AND 
si.PMID NOT IN (select PMID FROM [Profile.Data].[Publication.PubMed.Disambiguation] WHERE PMID is not null AND PersonID = d.PersonID)

DECLARE @newPersonID INT
DECLARE @oldPersonID INT
DECLARE @PMIDS XML
WHILE EXISTS (SELECT * FROM #peopleMapUCSF)
BEGIN 
	SELECT TOP 1 @newPersonID = newPersonID, @oldPersonID = oldPersonID FROM #peopleMapUCSF

	SELECT @PMIDS = (SELECT pmid as PMID from [profiles_ucsf].[Profile.Data].[Publication.Person.Include] 
		where personid = @oldPersonID and pmid is not null for xml path, ROOT ('PMIDS'), elements)

	EXEC [Profile.Data].[Publication.Pubmed.AddPMIDs] @personid = @newPersonID,	@PMIDxml =  @PMIDS

	DELETE FROM #peopleMapUCSF WHERE newPersonID = @newPersonID
END

EXEC [Profile.Data].[Publication.Pubmed.LoadDisambiguationResults]
DROP TABLE #peopleMapUCSF

--DELETE FROM [Profile.Data].[Publication.Person.Add] 
--DELETE FROM [Profile.Data].[Publication.Person.Include]  WHERE MPID IS NOT NULL
--DELETE FROM [Profile.Data].[Publication.MyPub.General]
--select count(*) from [profiles_ucsf].[Profile.Data].[Publication.MyPub.General]
-- add custom
INSERT INTO [Profile.Data].[Publication.MyPub.General]
	SELECT mpid, d.personid, PMID, hmspubcategory,nlmpubcategory,PubTitle,ArticleTitle,ArticleType,ConfEditors,ConfLoc,EDITION,PlaceOfPub,VolNum,PartVolPub,IssuePub,PaginationPub,
			AdditionalInfo,Publisher,SecondaryAuthors,ConfNm,ConfDts,ReptNumber,ContractNum,DissUnivNM,NewspaperCol,NewspaperSect,PublicationDT,ABSTRACT,AUTHORS,URL,
			CreatedDT,d.personid,UpdatedDT,d.personid FROM [profiles_ucsf].[Profile.Data].[Publication.MyPub.General] g JOIN
		[profiles_ucsf].[Profile.Data].[Person] s on g.personid = s.personid JOIN [Profile.Data].[Person] d on d.internalusername = [UCSF.].fn_LegacyInternalusername2EPPN(s.InternalUserName, 'ucsf')
	WHERE mpid IS NOT NULL and mpid not in (SELECT mpid FROM [Profile.Data].[Publication.MyPub.General] where personid = d.personid and mpid is not null)

INSERT INTO [Profile.Data].[Publication.Person.Include] ( PubID, PersonID, MPID )
	SELECT si.PubID, dg.PersonID, dg.MPID FROM [profiles_ucsf].[Profile.Data].[Publication.Person.Include] si JOIN [Profile.Data].[Publication.MyPub.General] dg 
		ON si.mpid = dg.mpid JOIN [profiles_ucsf].[Profile.Data].[Person] s on si.personid = s.personid JOIN
		[Profile.Data].[Person] d on d.internalusername = [UCSF.].fn_LegacyInternalusername2EPPN(s.InternalUserName, 'ucsf') WHERE dg.MPID is NOT NULL 
		and dg.mpid not in (select mpid from [Profile.Data].[Publication.Person.Include] where mpid is not null) 
select * from  [Profile.Data].[Publication.MyPub.General] where mpid is not null and mpid not in (select mpid from [Profile.Data].[Publication.Person.Include] where mpid is not null)
select mpid, count(*) from [Profile.Data].[Publication.MyPub.General] group by mpid order by count(*) desc;
select mpid, count(*) from [Profile.Data].[Publication.Person.Include] where mpid is not null group by mpid order by count(*) desc;
select * from  [Profile.Data].[Publication.Person.Include] where mpid is not null and mpid not in (select mpid from [Profile.Data].[Publication.MyPub.General])
select count(distinct(mpid)) from [Profile.Data].[Publication.MyPub.General] where mpid is not null
select count(distinct(mpid)) from [Profile.Data].[Publication.Person.Include] where mpid is not null

INSERT INTO [Profile.Data].[Publication.Person.Add] ( PubID, PersonID, MPID )
	SELECT PubID, PersonID, MPID FROM [Profile.Data].[Publication.Person.Include] i WHERE mpid IS NOT NULL AND mpid NOT IN 
	(select MPID from [Profile.Data].[Publication.Person.Add] WHERE mpid is not null)

-- add claimed
INSERT INTO [Profile.Data].[Publication.Person.Add] ( PubID, PersonID, pmid )
	SELECT di.PubID, d.PersonID, di.pmid FROM [profiles_ucsf].[Profile.Data].[Publication.Person.Add] sa
		JOIN [profiles_ucsf].[Profile.Data].[Person] s on sa.personid = s.personid JOIN
		[Profile.Data].[Person] d on d.internalusername = [UCSF.].fn_LegacyInternalusername2EPPN(s.InternalUserName, 'ucsf') JOIN
		[Profile.Data].[Publication.Person.Include] di on di.personid = d.personid and di.pmid = sa.pmid 
		WHERE sa.pmid is not null and di.PubID not in (select PubID from [Profile.Data].[Publication.Person.Add])

-- UCSD -------------------------------------------------------------------------------
WHILE EXISTS (SELECT * FROM  [profiles_ucsd].[Profile.Data].[Publication.PubMed.AllXML] WHERE ParseDT IS NOT NULL
	AND PMID NOT IN (SELECT PMID FROM [Profile.Data].[Publication.PubMed.AllXML]))
BEGIN 
	INSERT [Profile.Data].[Publication.PubMed.AllXML] (PMID, X) SELECT TOP 1000 PMID, X FROM  [profiles_ucsd].[Profile.Data].[Publication.PubMed.AllXML]
	WHERE ParseDT IS NOT NULL AND PMID NOT IN (SELECT PMID FROM [Profile.Data].[Publication.PubMed.AllXML])
END 
-- now parse all of it

EXEC [Profile.Data].[Publication.Pubmed.ParseALLPubMedXML]

-- load up people to migrate
SELECT DISTINCT d.personid newPersonID, s.personid oldPersonID INTO #peopleMapUCSD FROM [Profile.Data].[Person] d join [profiles_ucsd].[Profile.Data].[Person] s on d.internalusername = [UCSF.].fn_LegacyInternalusername2EPPN(s.InternalUserName, 'ucsd')
JOIN [profiles_ucsd].[Profile.Data].[Publication.Person.Include] si on si.PersonID = s.PersonID WHERE si.PMID is not null AND si.PersonID is not null AND 
si.PMID NOT IN (select PMID FROM [Profile.Data].[Publication.PubMed.Disambiguation] WHERE PMID is not null AND PersonID = d.PersonID)

--DECLARE @newPersonID INT
--DECLARE @oldPersonID INT
--DECLARE @PMIDS XML
WHILE EXISTS (SELECT * FROM #peopleMapUCSD)
BEGIN 
	SELECT TOP 1 @newPersonID = newPersonID, @oldPersonID = oldPersonID FROM #peopleMapUCSD

	SELECT @PMIDS = (SELECT pmid as PMID from [profiles_ucsd].[Profile.Data].[Publication.Person.Include] 
		where personid = @oldPersonID and pmid is not null for xml path, ROOT ('PMIDS'), elements)

	EXEC [Profile.Data].[Publication.Pubmed.AddPMIDs] @personid = @newPersonID,	@PMIDxml =  @PMIDS

	DELETE FROM #peopleMapUCSD WHERE newPersonID = @newPersonID
END


EXEC [Profile.Data].[Publication.Pubmed.LoadDisambiguationResults]
DROP TABLE #peopleMapUCSD

-- add claimed
-- add custom

-- UCI
WHILE EXISTS (SELECT * FROM  [profiles_uci].[Profile.Data].[Publication.PubMed.AllXML] WHERE ParseDT IS NOT NULL
	AND PMID NOT IN (SELECT PMID FROM [Profile.Data].[Publication.PubMed.AllXML]))
BEGIN 
	INSERT [Profile.Data].[Publication.PubMed.AllXML] (PMID, X) SELECT TOP 1000 PMID, X FROM  [profiles_uci].[Profile.Data].[Publication.PubMed.AllXML]
	WHERE ParseDT IS NOT NULL AND PMID NOT IN (SELECT PMID FROM [Profile.Data].[Publication.PubMed.AllXML])
END 
-- now parse all of it

EXEC [Profile.Data].[Publication.Pubmed.ParseALLPubMedXML]

-- load up people to migrate
SELECT DISTINCT d.personid newPersonID, s.personid oldPersonID INTO #peopleMapUCI FROM [Profile.Data].[Person] d join [profiles_uci].[Profile.Data].[Person] s on d.internalusername = [UCSF.].fn_LegacyInternalusername2EPPN(s.InternalUserName, 'uci')
JOIN [profiles_uci].[Profile.Data].[Publication.Person.Include] si on si.PersonID = s.PersonID WHERE si.PMID is not null AND si.PersonID is not null AND 
si.PMID NOT IN (select PMID FROM [Profile.Data].[Publication.PubMed.Disambiguation] WHERE PMID is not null AND PersonID = d.PersonID)

--DECLARE @newPersonID INT
--DECLARE @oldPersonID INT
--DECLARE @PMIDS XML
WHILE EXISTS (SELECT * FROM #peopleMapUCI)
BEGIN 
	SELECT TOP 1 @newPersonID = newPersonID, @oldPersonID = oldPersonID FROM #peopleMapUCI

	SELECT @PMIDS = (SELECT pmid as PMID from [profiles_uci].[Profile.Data].[Publication.Person.Include] 
		where personid = @oldPersonID and pmid is not null for xml path, ROOT ('PMIDS'), elements)

	EXEC [Profile.Data].[Publication.Pubmed.AddPMIDs] @personid = @newPersonID,	@PMIDxml =  @PMIDS

	DELETE FROM #peopleMapUCI WHERE newPersonID = @newPersonID
END


EXEC [Profile.Data].[Publication.Pubmed.LoadDisambiguationResults]
DROP TABLE #peopleMapUCI

-- add claimed
-- add custom