/****** Object:  StoredProcedure [ORNG.].[AddAppToOntology]    Script Date: 7/7/2017 4:53:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [ORNG.].[AddAppToOntology](@AppID INT, 
										   @EditView NVARCHAR(100) = 'home',
										   @EditOptParams NVARCHAR(255) = '{}', --'{''gadget_class'':''ORNGToggleGadget'', ''start_closed'':0, ''hideShow'':1, ''closed_width'':700}',
										   @ProfileView NVARCHAR(100) = 'profile',
										   @ProfileOptParams NVARCHAR(255) = '{}',
										   @SessionID UNIQUEIDENTIFIER=NULL, 
										   @Error BIT=NULL OUTPUT, 
										   @NodeID BIGINT=NULL OUTPUT)
AS
BEGIN
	SET NOCOUNT ON
		-- Cat2
		DECLARE @InternalType nvarchar(100) = null -- lookup from import.twitter
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
		
		SELECT @InternalType = REPLACE(n.value, ' ', '') FROM [rdf.].[Triple] t JOIN [rdf.].Node n ON t.[Object] = n.NodeID 
			WHERE t.[Subject] = [RDF.].fnURI2NodeID('http://orng.info/ontology/orng#Application')
			and t.Predicate = [RDF.].fnURI2NodeID('http://www.w3.org/2000/01/rdf-schema#label')
		SELECT @Name = REPLACE(RTRIM(RIGHT(url, CHARINDEX('/', REVERSE(url)) - 1)), '.xml', '')
			FROM [ORNG.].[Apps] WHERE AppID = @AppID 
		SELECT @URL = url FROM [ORNG.].[Apps] WHERE AppID = @AppID
			
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
		
		-- create a custom property to associate an instance of this application to a person
		SET @ClassPropertyName = 'http://orng.info/ontology/orng#has' + @Name
		SELECT @ClassPropertyLabel = Name
			FROM [ORNG.].[Apps] WHERE AppID = @AppID 
		SET @CustomEditModule = CAST(N'<Module ID="EditPersonalGadget">
					<ParamList>
					  <Param Name="AppId">' + CAST(@AppID AS VARCHAR) + '</Param>
					  <Param Name="Label">' + @ClassPropertyLabel + '</Param>
					  <Param Name="View">' + @EditView + '</Param>
					  <Param Name="OptParams">' + @EditOptParams + '</Param>
					</ParamList>
				  </Module>' AS XML)
		SET @CustomDisplayModule = CAST(N'<Module ID="ViewPersonalGadget">
					<ParamList>
					  <Param Name="AppId">' + CAST(@AppID AS VARCHAR) + '</Param>
					  <Param Name="Label">' + @ClassPropertyLabel + '</Param>
					  <Param Name="View">' + @ProfileView + '</Param>
					  <Param Name="OptParams">' + @ProfileOptParams + '</Param>
					</ParamList>
				  </Module>' AS XML)				

		-- add to the Import tables
		--INSERT INTO [Ontology.Import].[Triple] (OWL, Graph, Subject, Predicate, Object) 
		--	VALUES ('ORNG_1.0', 4, @ClassPropertyName, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type', 'http://www.w3.org/2002/07/owl#ObjectProperty')
		--INSERT INTO [Ontology.Import].[Triple] (OWL, Graph, Subject, Predicate, Object) 
		--	VALUES ('ORNG_1.0', 4, @ClassPropertyName, 'http://www.w3.org/2000/01/rdf-schema#label', @ClassPropertyLabel)

		EXEC [Ontology.].[AddProperty]	@OWL = 'ORNG_1.0', 
										@PropertyURI = @ClassPropertyName,
										@PropertyName = @ClassPropertyLabel,
										@ObjectType = 0,
										@PropertyGroupURI = 'http://orng.info/ontology/orng#PropertyGroupORNGApplications', 
										@ClassURI = 'http://xmlns.com/foaf/0.1/Person',
										@IsDetail = 0,
										@IncludeDescription = 0								
		UPDATE [Ontology.].[ClassProperty] SET EditExistingSecurityGroup = -20, IsDetail = 0, IncludeDescription = 0,
				CustomEdit = 1, CustomEditModule = @CustomEditModule,
				CustomDisplay = 1, CustomDisplayModule = @CustomDisplayModule,
				EditSecurityGroup = -20, EditPermissionsSecurityGroup = -20, -- was -20's
				EditAddNewSecurityGroup = -20, EditAddExistingSecurityGroup = -20, EditDeleteSecurityGroup = -20, 
				_Propertylabel = @ClassPropertyLabel
			WHERE property = @ClassPropertyName;
END

/****** Object:  StoredProcedure [ORNG.].[RemoveAppFromOntology]    Script Date: 10/11/2013 09:44:25 ******/
SET ANSI_NULLS ON



GO


/****** Object:  StoredProcedure [ORNG.].[AddAppToPerson]    Script Date: 7/7/2017 4:55:10 PM ******/
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
		
	SELECT @PersonName = DisplayName from [Profile.Data].Person WHERE PersonID = @PersonID
	--- this odd label format is required for the DataMap items to work properly!
	SELECT @Label = 'http://orng.info/ontology/orng#ApplicationInstance^^' +
					@InternalType + '^^' + @InternalID
					
					
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
		WHERE Class = 'http://orng.info/ontology/orng#ApplicationInstance' AND InternalType = 'ORNGApplicationInstance'
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
	END
	ELSE
	BEGIN
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
			-- for some reason, this Status in [RDF.Stage].InternalNodeMap is set to 0, not 3.  This causes issues so
			-- we fix
			UPDATE [RDF.Stage].[InternalNodeMap] SET [Status] = 3 WHERE NodeID = @NodeID						
			
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
		COMMIT	
	END
			
	-- wire in the filter to both the import and live tables
	SELECT @PERSON_FILTER_ID = (SELECT PersonFilterID FROM Apps WHERE AppID = @AppID AND PersonFilterID NOT IN (
			SELECT personFilterId FROM [Profile.Data].[Person.FilterRelationship] WHERE PersonID = @PersonID))
	IF (@PERSON_FILTER_ID IS NOT NULL) 
		BEGIN
			INSERT [Profile.Import].[PersonFilterFlag]
				SELECT InternalUserName, PersonFilter FROM [Profile.Data].[Person], [Profile.Data].[Person.Filter]
					WHERE PersonID = @PersonID AND PersonFilterID = @PERSON_FILTER_ID
			INSERT [Profile.Data].[Person.FilterRelationship](PersonID, personFilterId) values (@PersonID, @PERSON_FILTER_ID)
		END
END





GO

 -- now fix the data map
 UPDATE [Ontology.].[DataMap] SET oInternalType = REPLACE(oInternalType, ' ', '') WHERE oInternalType LIKE 'ORNG%'; --1
 UPDATE [Ontology.].[DataMap] SET sInternalType = REPLACE(sInternalType, ' ', '') WHERE sInternalType LIKE 'ORNG%'; --5

 --  now fix the InternalNodeMap
 UPDATE [RDF.Stage].[InternalNodeMap] set InternalType = REPLACE(InternalType, ' ', '') WHERE InternalType LIKE 'ORNG%'; --62180, 72808 prod

 -- should we fix the RDF Nodes? Sure
-- SELECT [RDF.].fnValueHash(null, null, VALUE), * FROM [RDF.].Node WHERE Value LIKE 'http://orng.info/ontology/orng#ApplicationInstance^^ORNG%' --9554, 12006
 UPDATE [RDF.].Node SET Value = REPLACE(VALUE, ' ', ''), ValueHash = [RDF.].fnValueHash(null, null, REPLACE(VALUE, ' ', ''))
	WHERE Value LIKE 'http://orng.info/ontology/orng#ApplicationInstance^^ORNG%';


-- to fix in base install, change InstallData.xml, ORNG_CreateSchema.sql and ORNG_DataLoad.sql

 