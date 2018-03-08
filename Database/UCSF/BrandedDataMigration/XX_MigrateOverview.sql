
/********** overview ****************************************************************************************/
DECLARE @Institution VARCHAR(50) = 'USC'
DECLARE @SourceDB VARCHAR(50) = 'profiles_usc' 

DECLARE @SQL NVARCHAR(MAX)
DECLARE @OldPropertyNode INT

SELECT @SQL = N'SELECT @retvalOUT = _PropertyNode FROM [' + @SourceDB + '].[Ontology.].[ClassProperty]
		WHERE Class = ''http://xmlns.com/foaf/0.1/Person'' AND Property = ''http://vivoweb.org/ontology/core#overview'''
	EXEC dbo.sp_executesql @SQL, N'@retvalOUT int OUTPUT', @retvalOUT=@OldPropertyNode OUTPUT

--SELECT @OldPropertyNode

-- load up people to migrate
SELECT @SQL = N'
SELECT DISTINCT d.nodeid newNodeID, s.nodeid oldNodeID INTO tmpPeopleMap FROM [UCSF.].[vwPerson] d join [' + @SourceDB + '].[UCSF.].[vwPerson] s on d.internalusername = [UCSF.].fn_LegacyInternalusername2EPPN(s.InternalUserName, ''' + @Institution + ''')'
EXEC dbo.sp_executesql @SQL

DECLARE @newNodeID BIGINT
DECLARE @oldNodeID BIGINT
DECLARE @overview NVARCHAR(MAX)
DECLARE @overviewNodeID BIGINT

WHILE EXISTS (SELECT * FROM tmpPeopleMap)
BEGIN 
	SELECT TOP 1 @newNodeID = newNodeID, @oldNodeID = oldNodeID FROM tmpPeopleMap

	SELECT @SQL = N'SELECT @retvalOUT = n.Value FROM [' + @SourceDB + '].[RDF.].Triple t join [' + @SourceDB + '].[RDF.].Node n on t.Object = n.NodeID where 
				t.subject = ' + cast(@oldNodeID as varchar) + ' AND t.predicate = ' + cast(@OldPropertyNode as varchar)
	EXEC dbo.sp_executesql @SQL, N'@retvalOUT nvarchar(max) OUTPUT', @retvalOUT=@overview OUTPUT

	IF (@overview is not null)
	BEGIN
		--SELECT @oldNodeID, @overview
		EXEC [RDF.].[GetStoreNode] @Value = @overview, @NodeID = @overviewNodeID OUTPUT
		IF (@overviewNodeID IS NOT NULL)
			EXEC [RDF.].[GetStoreTriple]	@SubjectID = @newNodeID,
											@PredicateURI = 'http://vivoweb.org/ontology/core#overview',
											@ObjectID = @overviewNodeID
	END

	DELETE FROM tmpPeopleMap WHERE newNodeID = @newNodeID
END
DROP TABLE tmpPeopleMap

