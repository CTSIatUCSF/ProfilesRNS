/*********** bigger picture
Remove gadgets from ontology (or just fix? try that first)
Swap person to ageng in:
  -- import owl
  -- import triple
  -- classProperty
  -- PropertyGroupProperty 
  -- Node


***************************/
-- Massage old data 
UPDATE [Ontology.Import].[OWL] SET [Name] = 'ORNG_1.1', [Data] = REPLACE(cast([Data] as varchar(max)), 'Person', 'Agent') WHERE [Name] = 'ORNG_1.0'; 
UPDATE [Ontology.Import].[Triple] SET [Owl] = 'ORNG_1.1', [Subject] = REPLACE([Subject], 'Person', 'Agent'), 
									[Object] = REPLACE([Object], 'Person', 'Agent') WHERE [Owl] = 'ORNG_1.0'; 
UPDATE [Ontology.].[ClassProperty] SET Property = 'http://orng.info/ontology/orng#applicationInstanceForAgent' WHERE Property = 'http://orng.info/ontology/orng#applicationInstanceForPerson';									
UPDATE [Ontology.].[ClassProperty] SET Class = 'http://xmlns.com/foaf/0.1/Agent' WHERE Property LIKE 'http://orng.info/ontology/orng#%' AND Class = 'http://xmlns.com/foaf/0.1/Person';									
-- DELETE THE GROUP ONLY ONES
DELETE [Ontology.].[ClassProperty] WHERE Class = 'http://xmlns.com/foaf/0.1/Group' AND Property LIKE 'http://orng.info/ontology/orng#%';									

UPDATE [Ontology.].[PropertyGroupProperty] SET PropertyURI = 'http://orng.info/ontology/orng#applicationInstanceForAgent',
	_TagName = REPLACE(_TagName, 'Person', 'Agent'), _PropertyLabel = REPLACE(_PropertyLabel, 'Person', 'Agent') WHERE PropertyURI = 'http://orng.info/ontology/orng#applicationInstanceForPerson';

EXEC [Ontology.].UpdateDerivedFields;

UPDATE [RDF.].[Node] SET ValueHash = [RDF.].fnValueHash(NULL, NULL, 'http://orng.info/ontology/orng#applicationInstanceForAgent'), [Value] = 'http://orng.info/ontology/orng#applicationInstanceForAgent'
	WHERE ValueHash = [RDF.].fnValueHash(NULL, NULL, 'http://orng.info/ontology/orng#applicationInstanceForPerson')
UPDATE [RDF.].[Node] SET ValueHash = [RDF.].fnValueHash(NULL, NULL, 'ORNG Application Instance for Agent'), [Value] = 'ORNG Application Instance for Agent'
	WHERE ValueHash = [RDF.].fnValueHash(NULL, NULL, 'ORNG Application Instance for Person')

--DROP PROCEDURE [ORNG.].[AddAppToPerson];
--DROP PROCEDURE [ORNG.].[RemoveAppFromPerson];

/****** Object:  StoredProcedure [ORNG.].[AddAppToPerson]    Script Date: 10/31/2018 12:39:57 PM ******/


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [ORNG.].[AddAppToAgent]
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
	-- Determine if this app has already been added to this Agent
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
			WHERE c.Class = 'http://xmlns.com/foaf/0.1/Agent'
				AND c.Property = @PredicateURI
				AND c.NetworkProperty IS NULL

		-- Change the security group of the triple
		EXEC [RDF.].[GetStoreTriple] @SubjectID = @SubjectID, -- bigint
									 @ObjectID = @AppInstanceID, -- bigint
									 @PredicateURI = @PredicateURI, -- varchar(400)
									 @ViewSecurityGroup = @ViewSecurityGroup, -- bigint
									 @SessionID = NULL, -- uniqueidentifier
									 @Error = NULL -- bit

		IF (@PersonID IS NOT NULL)
		BEGIN
			print 'We are ready to add person to filter, if this is for a person'

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
		END
		-- Exit the proc
		RETURN;
	END

	----------------------------------------------------------------
	-- Add the app to the Agent for the first time
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
		-- Link the ApplicationInstance to the Agent
		EXEC [RDF.].GetStoreTriple	@SubjectID = @NodeID,
									@PredicateURI = 'http://orng.info/ontology/orng#applicationInstanceForAgent',
									@ObjectID = @SubjectID,
									@SessionID = @SessionID,
									@Error = @Error OUTPUT								
		-- Link the Agent to the ApplicationInstance
		EXEC [RDF.].GetStoreTriple	@SubjectID = @SubjectID,
									@PredicateURI = @PredicateURI,
									@ObjectID = @NodeID,
									@SessionID = @SessionID,
									@Error = @Error OUTPUT
		
		if (@PersonID IS NOT NULL)
		BEGIN
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
		END
	COMMIT	
END
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [ORNG.].[RemoveAppFromAgent]
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
	
	-- Lookup the Group or PersonID
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
		
	-- there is only ONE link from the Agent to the application object, so grab it	
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

/****** Object:  StoredProcedure [ORNG.].[AddAppToOntology]    Script Date: 11/7/2018 2:31:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/****** Object:  StoredProcedure [ORNG.].[AddAppToOntology]    Script Date: 11/7/2018 2:30:23 PM ******/
ALTER PROCEDURE [ORNG.].[AddAppToOntology](@AppID INT, 
										   @EditView nvarchar(100) = 'home',
										   @EditOptParams nvarchar(255) = '{''hide_titlebar'':1}', --'{''gadget_class'':''ORNGToggleGadget'', ''start_closed'':0, ''hideShow'':1, ''closed_width'':700}',
										   @ProfileView nvarchar(100) = 'profile',
										   @ProfileOptParams nvarchar(255) = '{''hide_titlebar'':1}',
										   @SessionID UNIQUEIDENTIFIER=NULL, 
										   @Error BIT=NULL OUTPUT, 
										   @NodeID BIGINT=NULL OUTPUT)
As
BEGIN
	SET NOCOUNT ON
		-- Cat2
		DECLARE @InternalType nvarchar(100) -- lookup from import.twitter
		DECLARE @Name nvarchar(255)
		DECLARE @URL nvarchar(255)
		DECLARE @LabelNodeID BIGINT
		DECLARE @ApplicationIdNodeID BIGINT
		DECLARE @ApplicationURLNodeID BIGINT
		DECLARE @DataMapID int
		DECLARE @TableName nvarchar(255)
		DECLARE @ClassPropertyName nvarchar(255)
		DECLARE @ClassPropertyLabel nvarchar(255)
		DECLARE @CustomDisplayModule XML
		DECLARE @CustomEditModule XML
		DECLARE @Enabled bit
		
		SELECT @InternalType = n.value FROM [rdf.].[Triple] t JOIN [rdf.].Node n ON t.[Object] = n.NodeID 
			WHERE t.[Subject] = [RDF.].fnURI2NodeID('http://orng.info/ontology/orng#Application')
			and t.Predicate = [RDF.].fnURI2NodeID('http://www.w3.org/2000/01/rdf-schema#label')
		SELECT @Name = REPLACE(RTRIM(RIGHT(url, CHARINDEX('/', REVERSE(url)) - 1)), '.xml', '')
			FROM [ORNG.].[Apps] WHERE AppID = @AppID 
		SELECT @URL = url FROM [ORNG.].[Apps] WHERE AppID = @AppID
		SELECT @Enabled = Enabled FROM [ORNG.].[Apps] WHERE AppID = @AppID
			
		-- Add the Nodes for the application, its Id and URL
		EXEC [RDF.].GetStoreNode	@Class = 'http://orng.info/ontology/orng#Application',
									@InternalType = @InternalType,
									@InternalID = @Name,
									@SessionID = @SessionID, 
									@Error = @Error OUTPUT, 
									@NodeID = @NodeID OUTPUT		
		EXEC [RDF.].GetStoreNode @Value = @Name, @Language = NULL, @DataType = NULL,
			@SessionID = @SessionID, @Error = @Error OUTPUT, @NodeID = @LabelNodeID OUTPUT	
		EXEC [RDF.].GetStoreNode @Value = @AppID, @Language = NULL, @DataType = NULL,
			@SessionID = @SessionID, @Error = @Error OUTPUT, @NodeID = @ApplicationIdNodeID OUTPUT	
		EXEC [RDF.].GetStoreNode @Value = @URL, @Language = NULL, @DataType = NULL,
			@SessionID = @SessionID, @Error = @Error OUTPUT, @NodeID = @ApplicationURLNodeID OUTPUT	
		-- Add the Type
		EXEC [RDF.].GetStoreTriple	@SubjectID = @NodeID,
									@PredicateURI = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type',
									@ObjectURI = 'http://orng.info/ontology/orng#Application',
									@SessionID = @SessionID,
									@Error = @Error OUTPUT
		-- Add the Label
		EXEC [RDF.].GetStoreTriple	@SubjectID = @NodeID,
									@PredicateURI = 'http://www.w3.org/2000/01/rdf-schema#label',
									@ObjectID = @LabelNodeID,
									@SessionID = @SessionID,
									@Error = @Error OUTPUT
		-- Add the triples for the application, we assume label and class are already wired
		EXEC [RDF.].GetStoreTriple	@SubjectID = @NodeID,
									@PredicateURI = 'http://orng.info/ontology/orng#applicationId',
									@ObjectID = @ApplicationIdNodeID,
									@SessionID = @SessionID,
									@Error = @Error OUTPUT
		EXEC [RDF.].GetStoreTriple	@SubjectID = @NodeID,
									@PredicateURI = 'http://orng.info/ontology/orng#applicationURL',
									@ObjectID = @ApplicationURLNodeID,
									@SessionID = @SessionID,
									@Error = @Error OUTPUT																																
		
		-- create a custom property to associate an instance of this application to an agent
		SET @ClassPropertyName = 'http://orng.info/ontology/orng#has' + @Name
		SELECT @ClassPropertyLabel = Name
			FROM [ORNG.].[Apps] WHERE AppID = @AppID 
		SET @CustomEditModule = cast(N'<Module ID="EditPersonalGadget">
					<ParamList>
					  <Param Name="AppId">' + cast(@AppID as varchar) + '</Param>
					  <Param Name="Label">' + @ClassPropertyLabel + '</Param>
					  <Param Name="View">' + @EditView + '</Param>
					  <Param Name="OptParams">' + @EditOptParams + '</Param>
					</ParamList>
				  </Module>' as XML)
		SET @CustomDisplayModule = cast(N'<Module ID="ViewPersonalGadget">
					<ParamList>
					  <Param Name="AppId">' + cast(@AppID as varchar) + '</Param>
					  <Param Name="Label">' + @ClassPropertyLabel + '</Param>
					  <Param Name="View">' + @ProfileView + '</Param>
					  <Param Name="OptParams">' + @ProfileOptParams + '</Param>
					</ParamList>
				  </Module>' as XML)				
		EXEC [Ontology.].[AddProperty]	@OWL = 'ORNG_1.0', 
										@PropertyURI = @ClassPropertyName,
										@PropertyName = @ClassPropertyLabel,
										@ObjectType = 0,
										@PropertyGroupURI = 'http://orng.info/ontology/orng#PropertyGroupORNGApplications', 
										@ClassURI = 'http://xmlns.com/foaf/0.1/Agent',
										@IsDetail = 0,
										@IncludeDescription = 0
		IF (@Enabled = 1)
		BEGIN								
			UPDATE [Ontology.].[ClassProperty] set EditExistingSecurityGroup = -20, IsDetail = 0, IncludeDescription = 0,
					CustomEdit = 1, CustomEditModule = @CustomEditModule,
					CustomDisplay = 1, CustomDisplayModule = @CustomDisplayModule,
					EditSecurityGroup = -20, EditPermissionsSecurityGroup = -20, -- was -20's
					EditAddNewSecurityGroup = -20, EditAddExistingSecurityGroup = -20, EditDeleteSecurityGroup = -20 
				WHERE property = @ClassPropertyName;
		END
		ELSE IF (@Enabled = 0)
		BEGIN								
			UPDATE [Ontology.].[ClassProperty] set EditExistingSecurityGroup = -50, IsDetail = 0, IncludeDescription = 0,
					CustomEdit = 1, CustomEditModule = @CustomEditModule,
					CustomDisplay = 1, CustomDisplayModule = @CustomDisplayModule,
					EditSecurityGroup = -50, EditPermissionsSecurityGroup = -50, -- was -20's
					EditAddNewSecurityGroup = -50, EditAddExistingSecurityGroup = -50, EditDeleteSecurityGroup = -50,
					ViewSecurityGroup = -50
				WHERE property = @ClassPropertyName;
		END
END
GO

/****** Object:  StoredProcedure [ORNG.].[RemoveAppFromOntology]    Script Date: 11/7/2018 2:31:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [ORNG.].[RemoveAppFromOntology](@AppID INT, @SessionID UNIQUEIDENTIFIER=NULL, @Error BIT=NULL OUTPUT, @NodeID BIGINT=NULL OUTPUT)
As
BEGIN
	SET NOCOUNT ON
		DECLARE @Name nvarchar(255)
		DECLARE @PropertyURI nvarchar(255)
		
		SELECT @Name = REPLACE(RTRIM(RIGHT(url, CHARINDEX('/', REVERSE(url)) - 1)), '.xml', '')
			FROM [ORNG.].[Apps] WHERE AppID = @AppID 
		SET @PropertyURI = 'http://orng.info/ontology/orng#has' + @Name				
			
		IF (@PropertyURI IS NOT NULL)
		BEGIN	
			DELETE FROM [Ontology.].[ClassProperty]	WHERE Property = @PropertyURI
			DELETE FROM [Ontology.].[PropertyGroupProperty] WHERE PropertyURI = @PropertyURI
		END

		DECLARE @PropertyNode BIGINT
		SELECT @PropertyNode = _PropertyNode FROM [Ontology.].[ClassProperty] WHERE
			Class = 'http://orng.info/ontology/orng#Application' and 
			Property = 'http://orng.info/ontology/orng#applicationId' --_PropertyNode
		SELECT @NodeID = t.[Subject] FROM [RDF.].Triple t JOIN
			[RDF.].Node n ON t.[Object] = n.nodeid 
			WHERE t.Predicate = @PropertyNode AND n.[Value] = CAST(@AppID as varchar)
		
		IF (@NodeID IS NOT NULL)
		BEGIN
			EXEC [RDF.].DeleteNode @NodeID = @NodeID, @DeleteType = 0								   
		END	
END
GO

GRANT EXECUTE ON [ORNG.].[AddAppToAgent] TO App_Profiles10
GO
GRANT EXECUTE ON [ORNG.].[RemoveAppFromAgent] TO App_Profiles10
GO