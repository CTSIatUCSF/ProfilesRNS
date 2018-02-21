
/********** freetext keyword ****************************************************************************************/
DECLARE @Institution VARCHAR(50) = 'UCSF'
DECLARE @SourceDB VARCHAR(50) = 'profiles_ucsf' 

DECLARE @Property VARCHAR(255) = 'http://vivoweb.org/ontology/core#awardOrHonor'

DECLARE @SQL NVARCHAR(MAX)
DECLARE @OldPropertyNode INT

SELECT @SQL = N'SELECT @retvalOUT = _PropertyNode FROM [' + @SourceDB + '].[Ontology.].[ClassProperty]
		WHERE Class = ''http://xmlns.com/foaf/0.1/Person'' AND Property = ''' + @Property + ''''
	EXEC dbo.sp_executesql @SQL, N'@retvalOUT int OUTPUT', @retvalOUT=@OldPropertyNode OUTPUT

--SELECT @OldPropertyNode

-- load up people to migrate
SELECT @SQL = N'
SELECT DISTINCT d.nodeid newNodeID, s.nodeid oldNodeID INTO tmpPeopleMap FROM [UCSF.].[vwPerson] d join [' + @SourceDB + '].[UCSF.].[vwPerson] s on d.internalusername = [UCSF.].fn_LegacyInternalusername2EPPN(s.InternalUserName, ''' + @Institution + ''')'
EXEC dbo.sp_executesql @SQL

DECLARE @label VARCHAR (MAX)=NULL
DECLARE @awardConferredBy VARCHAR (MAX)=NULL
DECLARE @startDate VARCHAR (MAX)=NULL
DECLARE @endDate VARCHAR (MAX)=NULL
DECLARE @ExistingAwardReceiptID BIGINT=NULL

DECLARE @newNodeID BIGINT
DECLARE @oldNodeID BIGINT
DECLARE @sortorder INT
DECLARE @objectNodeID BIGINT
DECLARE @predicateURI VARCHAR (255)

WHILE EXISTS (SELECT * FROM tmpPeopleMap)
BEGIN 
	SELECT TOP 1 @newNodeID = newNodeID, @oldNodeID = oldNodeID FROM tmpPeopleMap
	SELECT @sortorder = 1

	WHILE (@sortorder is not null)
	BEGIN
		SELECT @SQL = N'SELECT @retvalOUT = t.Object FROM [' + @SourceDB + '].[RDF.].Triple t where 
					t.subject = ' + cast(@oldNodeID as varchar) + ' AND t.predicate = ' + cast(@OldPropertyNode as varchar) + ' AND t.SortOrder = ' + cast(@sortorder as varchar)
		EXEC dbo.sp_executesql @SQL, N'@retvalOUT nvarchar(max) OUTPUT', @retvalOUT=@objectNodeID OUTPUT

		IF (@objectNodeID is not null)
		BEGIN
			SELECT @predicateURI = 'http://www.w3.org/2000/01/rdf-schema#label';
			SELECT @SQL = N'SELECT @retvalOUT = n.Value FROM [' + @SourceDB + '].[RDF.].Triple t join [' + @SourceDB + '].[RDF.].Node n on t.Object = n.NodeID where 
					t.subject = ' + cast(@objectNodeID as varchar) + ' AND t.predicate = [' + @SourceDB + '].[RDF.].fnURI2NodeID(''' + @predicateURI + ''') AND t.SortOrder = ' + cast(@sortorder as varchar)
			EXEC dbo.sp_executesql @SQL, N'@retvalOUT nvarchar(max) OUTPUT', @retvalOUT=@label OUTPUT

			SELECT @predicateURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#awardConferredBy';
			SELECT @SQL = N'SELECT @retvalOUT = n.Value FROM [' + @SourceDB + '].[RDF.].Triple t join [' + @SourceDB + '].[RDF.].Node n on t.Object = n.NodeID where 
					t.subject = ' + cast(@objectNodeID as varchar) + ' AND t.predicate = [' + @SourceDB + '].[RDF.].fnURI2NodeID(''' + @predicateURI + ''') AND t.SortOrder = ' + cast(@sortorder as varchar)
			EXEC dbo.sp_executesql @SQL, N'@retvalOUT nvarchar(max) OUTPUT', @retvalOUT=@awardConferredBy OUTPUT

			SELECT @predicateURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#startDate';
			SELECT @SQL = N'SELECT @retvalOUT = n.Value FROM [' + @SourceDB + '].[RDF.].Triple t join [' + @SourceDB + '].[RDF.].Node n on t.Object = n.NodeID where 
					t.subject = ' + cast(@objectNodeID as varchar) + ' AND t.predicate = [' + @SourceDB + '].[RDF.].fnURI2NodeID(''' + @predicateURI + ''') AND t.SortOrder = ' + cast(@sortorder as varchar)
			EXEC dbo.sp_executesql @SQL, N'@retvalOUT nvarchar(max) OUTPUT', @retvalOUT=@startDate OUTPUT

			SELECT @predicateURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#endDate';
			SELECT @SQL = N'SELECT @retvalOUT = n.Value FROM [' + @SourceDB + '].[RDF.].Triple t join [' + @SourceDB + '].[RDF.].Node n on t.Object = n.NodeID where 
					t.subject = ' + cast(@objectNodeID as varchar) + ' AND t.predicate = [' + @SourceDB + '].[RDF.].fnURI2NodeID(''' + @predicateURI + ''') AND t.SortOrder = ' + cast(@sortorder as varchar)
			EXEC dbo.sp_executesql @SQL, N'@retvalOUT nvarchar(max) OUTPUT', @retvalOUT=@endDate OUTPUT

			-- see if they already have one
			SELECT @SQL = N'SELECT @retvalOUT = t.Object FROM [RDF.].Triple t where 
						t.subject = ' + cast(@newNodeID as varchar) + ' AND t.predicate = [RDF.].fnURI2NodeID(''' + @Property + ''') AND t.SortOrder = ' + cast(@sortorder as varchar)
			EXEC dbo.sp_executesql @SQL, N'@retvalOUT nvarchar(max) OUTPUT', @retvalOUT=@ExistingAwardReceiptID OUTPUT

			if (@label is not null)
			BEGIN
				--SELECT @newNodeID, @sortorder, @objectNodeID, @label, @awardConferredBy,@startDate,@endDate,@ExistingAwardReceiptID
				exec [Edit.Module].[CustomEditAwardOrHonor.StoreItem] @ExistingAwardReceiptID=@ExistingAwardReceiptID, @awardOrHonorForID=@newNodeID, @label=@label, 
					@awardConferredBy=@awardConferredBy, @startDate=@startDate, @endDate=@endDate
				--DELETE FROM tmpPeopleMap
				--BREAK

			END
			SELECT @objectNodeID=null, @label=null, @awardConferredBy=null, @startDate=null, @endDate=null, @ExistingAwardReceiptID=null, @sortorder = @sortorder+1
		END
		ELSE 
		BEGIN
			SET @sortorder = null
		END
	END

	DELETE FROM tmpPeopleMap WHERE newNodeID = @newNodeID
END
DROP TABLE tmpPeopleMap

