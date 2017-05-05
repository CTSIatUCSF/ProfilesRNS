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

-- add claimed
-- add custom

-- UCSD
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