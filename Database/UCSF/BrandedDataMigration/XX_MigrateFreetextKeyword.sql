
/********** freetext keyword ****************************************************************************************/
DECLARE @Institution VARCHAR(50) = 'UCSF'
DECLARE @SourceDB VARCHAR(50) = 'profiles_ucsf' 

DECLARE @SQL NVARCHAR(MAX)
DECLARE @OldPropertyNode INT

SELECT @SQL = N'SELECT @retvalOUT = _PropertyNode FROM [' + @SourceDB + '].[Ontology.].[ClassProperty]
		WHERE Class = ''http://xmlns.com/foaf/0.1/Person'' AND Property = ''http://vivoweb.org/ontology/core#freetextKeyword'''
	EXEC dbo.sp_executesql @SQL, N'@retvalOUT int OUTPUT', @retvalOUT=@OldPropertyNode OUTPUT

--SELECT @OldPropertyNode

-- load up people to migrate
SELECT @SQL = N'
SELECT DISTINCT d.nodeid newNodeID, s.nodeid oldNodeID INTO tmpPeopleMap FROM [UCSF.].[vwPerson] d join [' + @SourceDB + '].[UCSF.].[vwPerson] s on d.internalusername = [UCSF.].fn_LegacyInternalusername2EPPN(s.InternalUserName, ''' + @Institution + ''')'
EXEC dbo.sp_executesql @SQL

DECLARE @newNodeID BIGINT
DECLARE @oldNodeID BIGINT
DECLARE @keyword NVARCHAR(MAX)
DECLARE @sortorder INT
DECLARE @keywordNodeID BIGINT

WHILE EXISTS (SELECT * FROM tmpPeopleMap)
BEGIN 
	SELECT TOP 1 @newNodeID = newNodeID, @oldNodeID = oldNodeID FROM tmpPeopleMap
	SELECT @sortorder = 1

	WHILE (@sortorder is not null)
	BEGIN
		SELECT @SQL = N'SELECT @retvalOUT = n.Value FROM [' + @SourceDB + '].[RDF.].Triple t join [' + @SourceDB + '].[RDF.].Node n on t.Object = n.NodeID where 
					t.subject = ' + cast(@oldNodeID as varchar) + ' AND t.predicate = ' + cast(@OldPropertyNode as varchar) + ' AND t.SortOrder = ' + cast(@sortorder as varchar)
		EXEC dbo.sp_executesql @SQL, N'@retvalOUT nvarchar(max) OUTPUT', @retvalOUT=@keyword OUTPUT

		IF (@keyword is not null)
		BEGIN
			--SELECT @oldNodeID, @keyword, @sortorder
			--DELETE FROM tmpPeopleMap
			--BREAK
			EXEC [RDF.].[GetStoreNode] @Value = @keyword, @NodeID = @keywordNodeID OUTPUT
			IF (@keywordNodeID IS NOT NULL)
				EXEC [RDF.].[GetStoreTriple]	@SubjectID = @newNodeID,
												@PredicateURI = 'http://vivoweb.org/ontology/core#freetextKeyword',
												@ObjectID = @keywordNodeID
			SELECT @keyword=null, @sortorder = @sortorder+1
		END
		ELSE 
		BEGIN
			SET @sortorder = null
		END
	END

	DELETE FROM tmpPeopleMap WHERE newNodeID = @newNodeID
END
DROP TABLE tmpPeopleMap

