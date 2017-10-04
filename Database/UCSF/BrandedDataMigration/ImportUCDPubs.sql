DECLARE @personID INT
DECLARE @PMIDS XML
DECLARE @SQL NVARCHAR(MAX)

-- load up people to migrate
SELECT @SQL = N'
SELECT distinct personid INTO tmpPeopleMap FROM [Profile.Data].[Person] d join [import_ucd].[dbo].[vw_pubmed] s on d.internalusername = s.internalusername'
EXEC dbo.sp_executesql @SQL


WHILE EXISTS (SELECT TOP 1 * FROM tmpPeopleMap)
BEGIN 
	SELECT TOP 1 @personID = personid FROM tmpPeopleMap
--select @personID  --20963
SELECT @SQL = N'SELECT @retvalOUT = (SELECT pmid as PMID from [Profile.Data].[Person] d join [import_ucd].[dbo].[vw_pubmed] s on d.internalusername = s.internalusername
		where personid = ' + cast(@personID as varchar) + ' and pmid is not null for xml path, ROOT (''PMIDS''), elements)'
	EXEC dbo.sp_executesql @SQL, N'@retvalOUT xml OUTPUT', @retvalOUT=@PMIDS OUTPUT
--select @PersonID, @PMIDS
	EXEC [Profile.Data].[Publication.Pubmed.AddPMIDs] @personid = @personID,	@PMIDxml =  @PMIDS


	DELETE FROM tmpPeopleMap WHERE personID = @personID
END
DROP TABLE tmpPeopleMap

EXEC [Profile.Data].[Publication.Pubmed.LoadDisambiguationResults]
