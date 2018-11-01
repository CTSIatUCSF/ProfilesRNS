/****** Object:  StoredProcedure [ORNG.].[AddAppToPerson]    Script Date: 10/31/2018 12:39:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [ORNG.].[AddAppToPerson]
@SubjectID BIGINT=NULL, @SubjectURI nvarchar(255)=NULL, @AppID INT, @SessionID UNIQUEIDENTIFIER=NULL, @Error BIT=NULL OUTPUT, @NodeID BIGINT=NULL OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	-- Cat2
	DECLARE @InternalType nvarchar(100) -- lookup from import.twitter
	DECLARE @InternalID nvarchar(100) -- lookpup personid and add appID
	DECLARE @PersonID INT
	DECLARE @PersonName nvarchar(255)
	DECLARE @Label nvarchar(255)
	DECLARE @LabelID BIGINT
	DECLARE @AppName NVARCHAR(100)
	DECLARE @ApplicationNodeID BIGINT
	DECLARE @PredicateURI nvarchar(255) -- this could be passed in for some situations
	DECLARE @PERSON_FILTER_ID INT
	
	IF (@SubjectID IS NULL)
		SET @SubjectID = [RDF.].fnURI2NodeID(@SubjectURI)
	
	SELECT @InternalType = REPLACE([Object], ' ', '') FROM [Ontology.Import].[Triple] 
		WHERE [Subject] = 'http://orng.info/ontology/orng#ApplicationInstance' AND [Predicate] = 'http://www.w3.org/2000/01/rdf-schema#label'
	
	SELECT @PersonID = cast(InternalID as INT), @InternalID = InternalID + '-' + CAST(@AppID as varchar) FROM [RDF.Stage].[InternalNodeMap]
		WHERE [NodeID] = @SubjectID AND Class = 'http://xmlns.com/foaf/0.1/Person'

	IF (@InternalID is null)
	BEGIN
		SELECT @InternalID = InternalID + '-GROUP-' + CAST(@AppID as varchar) FROM [RDF.Stage].[InternalNodeMap]
			WHERE [NodeID] = @SubjectID AND Class = 'http://xmlns.com/foaf/0.1/Group'
	END
		
	SELECT @PersonName = DisplayName from [Profile.Data].Person WHERE PersonID = @PersonID
										
	-- Convert the AppID to an AppName based on its URL
	SELECT @AppName = REPLACE(RTRIM(RIGHT(url, CHARINDEX('/', REVERSE(url)) - 1)), '.xml', '')
		FROM [ORNG.].[Apps] 
		WHERE AppID = @AppID

	-- STOP, should we test that the PredicateURI is consistent with the AppID?
	SELECT @PredicateURI = 'http://orng.info/ontology/orng#has'+@AppName
				
	SELECT @ApplicationNodeID  = NodeID
		FROM [RDF.Stage].[InternalNodeMap]
		WHERE Class = 'http://orng.info/ontology/orng#Application' AND InternalType = 'ORNGApplication'
			AND InternalID = @AppName

		
	----------------------------------------------------------------
	-- Determine if this app has already been added to this person
	----------------------------------------------------------------
	DECLARE @AppInstanceID BIGINT
	SELECT @AppInstanceID = NodeID
		FROM [RDF.Stage].[InternalNodeMap]

		WHERE Class = 'http://orng.info/ontology/orng#ApplicationInstance' 
			AND InternalType = 'ORNGApplicationInstance'
			AND InternalID = @InternalID
	IF @AppInstanceID IS NOT NULL
	BEGIN
		-- Determine the ViewSecurityGroup
		DECLARE @ViewSecurityGroup BIGINT
		SELECT @ViewSecurityGroup = IsNull(p.ViewSecurityGroup,c.ViewSecurityGroup)
			FROM [Ontology.].ClassProperty c
				LEFT OUTER JOIN [RDF.Security].NodeProperty p
					ON p.Property = c._PropertyNode AND p.NodeID = @SubjectID
			WHERE c.Class = 'http://xmlns.com/foaf/0.1/Person'
				AND c.Property = @PredicateURI
				AND c.NetworkProperty IS NULL

		-- Change the security group of the triple
		EXEC [RDF.].[GetStoreTriple] @SubjectID = @SubjectID, -- bigint
									 @ObjectID = @AppInstanceID, -- bigint
									 @PredicateURI = @PredicateURI, -- varchar(400)
									 @ViewSecurityGroup = @ViewSecurityGroup, -- bigint
									 @SessionID = NULL, -- uniqueidentifier
									 @Error = NULL -- bit

		print 'Weare ready to add person to filter'
		SELECT @PERSON_FILTER_ID = (SELECT PersonFilterID FROM [ORNG.].[Apps]  
			WHERE AppID = @AppID AND PersonFilterID NOT IN (
				SELECT personFilterId FROM [Profile.Data].[Person.FilterRelationship] 
					WHERE PersonID = @PersonID))
		IF (@PERSON_FILTER_ID IS NOT NULL) 
			BEGIN
				INSERT [Profile.Import].[PersonFilterFlag]
					SELECT InternalUserName, PersonFilter FROM [Profile.Data].[Person], [Profile.Data].[Person.Filter]
						WHERE PersonID = @PersonID AND PersonFilterID = @PERSON_FILTER_ID
				INSERT [Profile.Data].[Person.FilterRelationship](PersonID, personFilterId) 
					values (@PersonID, @PERSON_FILTER_ID)
			END

		-- Exit the proc
		RETURN;
	END


	----------------------------------------------------------------
	-- Add the app to the person for the first time
	----------------------------------------------------------------
	SELECT @Error = 0
	BEGIN TRAN
		-- We want Type 2.  Lookup internal type from import.triple, pass in AppID
		EXEC [RDF.].GetStoreNode	@Class = 'http://orng.info/ontology/orng#ApplicationInstance',
									@InternalType = @InternalType,
									@InternalID = @InternalID,
									@SessionID = @SessionID, 
									@Error = @Error OUTPUT, 
									@NodeID = @NodeID OUTPUT
		SELECT @Label = 'ORNGApplicationInstance ' + cast(@NodeID as varchar)

		-- for some reason, this Status in [RDF.Stage].InternalNodeMap is set to 0, not 3.  This causes issues so
		-- we fix
		--UPDATE [RDF.Stage].[InternalNodeMap] SET [Status] = 3 WHERE NodeID = @NodeID						
			
		EXEC [RDF.].GetStoreNode @Value = @Label, @Language = NULL, @DataType = NULL,
			@SessionID = @SessionID, @Error = @Error OUTPUT, @NodeID = @LabelID OUTPUT	

		-- Add the Type
		EXEC [RDF.].GetStoreTriple	@SubjectID = @NodeID,
									@PredicateURI = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type',
									@ObjectURI = 'http://orng.info/ontology/orng#ApplicationInstance',
									@SessionID = @SessionID,
									@Error = @Error OUTPUT
		-- Add the Label
		EXEC [RDF.].GetStoreTriple	@SubjectID = @NodeID,
									@PredicateURI = 'http://www.w3.org/2000/01/rdf-schema#label',
									@ObjectID = @LabelID,
									@SessionID = @SessionID,
									@Error = @Error OUTPUT
		-- Link the ApplicationInstance to the Application
		EXEC [RDF.].GetStoreTriple	@SubjectID = @NodeID,
									@PredicateURI = 'http://orng.info/ontology/orng#applicationInstanceOfApplication',
									@ObjectID = @ApplicationNodeID,
									@SessionID = @SessionID,
									@Error = @Error OUTPUT		
		-- Link the ApplicationInstance to the person
		EXEC [RDF.].GetStoreTriple	@SubjectID = @NodeID,
									@PredicateURI = 'http://orng.info/ontology/orng#applicationInstanceForPerson',
									@ObjectID = @SubjectID,
									@SessionID = @SessionID,
									@Error = @Error OUTPUT								
		-- Link the person to the ApplicationInstance
		EXEC [RDF.].GetStoreTriple	@SubjectID = @SubjectID,
									@PredicateURI = @PredicateURI,
									@ObjectID = @NodeID,
									@SessionID = @SessionID,
									@Error = @Error OUTPUT
		
		-- wire in the filter to both the import and live tables
		print 'We are ready to add person to filter'
		SELECT @PERSON_FILTER_ID = (SELECT PersonFilterID FROM [ORNG.].[Apps]  

			WHERE AppID = @AppID AND PersonFilterID NOT IN (
				SELECT personFilterId FROM [Profile.Data].[Person.FilterRelationship] 
					WHERE PersonID = @PersonID))
		IF (@PERSON_FILTER_ID IS NOT NULL) 
			BEGIN
				INSERT [Profile.Import].[PersonFilterFlag]
					SELECT InternalUserName, PersonFilter FROM [Profile.Data].[Person], [Profile.Data].[Person.Filter]
						WHERE PersonID = @PersonID AND PersonFilterID = @PERSON_FILTER_ID

				INSERT [Profile.Data].[Person.FilterRelationship](PersonID, personFilterId) 
					values (@PersonID, @PERSON_FILTER_ID)
			END
	COMMIT	
END
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [ORNG.].[RemoveAppFromPerson]
@SubjectID BIGINT=NULL, @SubjectURI NVARCHAR(255)=NULL, @AppID INT, @DeleteType tinyint = 1, @SessionID UNIQUEIDENTIFIER=NULL, @Error BIT=NULL OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @ApplicationInstanceNodeID  BIGINT
	DECLARE @TripleID BIGINT
	DECLARE @PersonID INT
	DECLARE @InternalID nvarchar(100)	
	DECLARE @InternalType nvarchar(300)
	DECLARE @PERSON_FILTER_ID INT
	DECLARE @InternalUserName NVARCHAR(50)
	DECLARE @PersonFilter NVARCHAR(50)

	IF (@SubjectID IS NULL)
		SET @SubjectID = [RDF.].fnURI2NodeID(@SubjectURI)
	
	-- Lookup the PersonID
	SELECT @InternalID = InternalID, @InternalType = InternalType
		FROM [RDF.Stage].[InternalNodeMap]
		WHERE NodeID = @SubjectID
	
	IF @InternalType = 'Person'
	BEGIN
		-- Lookup the App Instance's NodeID
		SELECT @ApplicationInstanceNodeID  = NodeID
			FROM [RDF.Stage].[InternalNodeMap]
			WHERE Class = 'http://orng.info/ontology/orng#ApplicationInstance' AND InternalType = 'ORNGApplicationInstance'
				AND InternalID = @InternalID + '-' + CAST(@AppID AS VARCHAR(50))
	END
	ELSE IF @InternalType = 'Group'
	BEGIN
		-- Lookup the App Instance's NodeID
		SELECT @ApplicationInstanceNodeID  = NodeID
			FROM [RDF.Stage].[InternalNodeMap]
			WHERE Class = 'http://orng.info/ontology/orng#ApplicationInstance' AND InternalType = 'ORNGApplicationInstance'
				AND InternalID = @InternalID + '-GROUP-' + CAST(@AppID AS VARCHAR(50))
	END
		
	-- there is only ONE link from the person to the application object, so grab it	
	SELECT @TripleID = [TripleID] FROM [RDF.].Triple 
		WHERE [Subject] = @SubjectID
		AND [Object] = @ApplicationInstanceNodeID

	-- now delete it
	BEGIN TRAN

		EXEC [RDF.].DeleteTriple @TripleID = @TripleID, 
								 @SessionID = @SessionID, 
								 @Error = @Error

		IF (@DeleteType = 0) -- true delete, remove the now orphaned application instance
		BEGIN
			EXEC [RDF.].DeleteNode @NodeID = @ApplicationInstanceNodeID, 
							   @DeleteType = @DeleteType,
							   @SessionID = @SessionID, 
							   @Error = @Error OUTPUT
		END							   

		-- remove any filters
		SELECT @PERSON_FILTER_ID = (SELECT PersonFilterID FROM Apps WHERE AppID = @AppID)
		IF (@PERSON_FILTER_ID IS NOT NULL) 
			BEGIN
				SELECT @PersonID = CAST(InternalID AS INT) FROM [RDF.Stage].[InternalNodeMap]
					WHERE [NodeID] = @SubjectID AND Class = 'http://xmlns.com/foaf/0.1/Person'
				IF (@PersonID IS NOT NULL)
					BEGIN
						SELECT @InternalUserName = InternalUserName FROM [Profile.Data].[Person] WHERE PersonID = @PersonID
						SELECT @PersonFilter = PersonFilter FROM [Profile.Data].[Person.Filter] WHERE PersonFilterID = @PERSON_FILTER_ID

						DELETE FROM [Profile.Import].[PersonFilterFlag] WHERE InternalUserName = @InternalUserName AND personfilter = @PersonFilter
						DELETE FROM [Profile.Data].[Person.FilterRelationship] WHERE PersonID = @PersonID AND personFilterId = @PERSON_FILTER_ID
					END
			END
	COMMIT
END
GO

-- fix old bad data
SELECT * FROM [RDF.Stage].[InternalNodeMap] WHERE InternalType like 'ORNG %';
SELECT * FROM [RDF.Stage].[InternalNodeMap] b JOIN [RDF.Stage].[InternalNodeMap] a on a.Class = b.Class and a.InternalID = b.InternalID
and a.InternalType <> b.InternalType WHERE b.InternalType like 'ORNG %';
-- maybe delete those first? 
UPDATE [RDF.Stage].[InternalNodeMap] SET InternalType = REPLACE(InternalType, ' ', '') WHERE  InternalType like 'ORNG %';

SELECT * FROM [RDF.].Node where Value like 'http://orng.info/ontology/orng#%^^%';
UPDATE n SET n.Value = p.Value + cast (n.NodeID as varchar), n.ValueHash = [RDF.].fnValueHash(null, null, p.Value + cast (n.NodeID as varchar))
FROM [RDF.].Node n JOIN [Framework.].[Parameter] p ON 1 = 1 WHERE n.Value LIKE 'http://orng.info/ontology/orng#%^^%' AND p.ParameterID = 'baseURI'

