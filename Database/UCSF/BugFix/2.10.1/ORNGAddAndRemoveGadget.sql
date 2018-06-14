USE [ProfilesRNS]
GO

/****** Object:  UserDefinedFunction [UCSF.].[fn_ApplicationNameFromPrettyUrl]    Script Date: 6/2/2018 10:18:48 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [ORNG.].[fn_AppNameFromAppID]
(
	@AppID INT
)
RETURNS varchar(255)
AS
BEGIN
	DECLARE @AppName varchar(255)
	SELECT @AppName = REPLACE(RTRIM(RIGHT(url, CHARINDEX('/', REVERSE(url)) - 1)), '.xml', '')
		FROM [ORNG.].[Apps] 
		WHERE AppID = @AppID
	RETURN @AppName
END


GO

/****** Object:  StoredProcedure [ORNG.].[AddAppToOntology]    Script Date: 6/2/2018 10:40:01 AM ******/
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
		SELECT @Name = [ORNG.].[fn_AppNameFromAppID](@AppID)
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

/****** Object:  StoredProcedure [ORNG.].[AddAppToOntology]    Script Date: 10/11/2013 09:44:25 ******/
SET ANSI_NULLS ON




GO

/****** Object:  StoredProcedure [ORNG.].[RemoveAppFromOntology]    Script Date: 6/2/2018 10:42:35 AM ******/
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
		
		SELECT @Name = [ORNG.].[fn_AppNameFromAppID](@AppID)
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

/****** Object:  StoredProcedure [ORNG.].[AddAppToPerson]    Script Date: 6/2/2018 9:05:13 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [ORNG.].[AddAppToPerson]
@SubjectID BIGINT=NULL, @SubjectURI nvarchar(255)=NULL, @AppID INT, @UserEdit tinyint=0, @SessionID UNIQUEIDENTIFIER=NULL, @Error BIT=NULL OUTPUT, @NodeID BIGINT=NULL OUTPUT
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
	DECLARE @AppName varchar(255)
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
	SELECT @AppName = [ORNG.].[fn_AppNameFromAppID](@AppID)

	-- STOP, should we test that the PredicateURI is consistent with the AppID?
	SELECT @PredicateURI = 'http://orng.info/ontology/orng#has' + @AppName
				
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

		-- If this is a UserEdit, then also change the security group of the node to make it visible
		IF @UserEdit = 1
		BEGIN
			EXEC [RDF.].[GetStoreNode] @ExistingNodeID = @AppInstanceID,
									   @ViewSecurityGroup = @ViewSecurityGroup
		END
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



/****** Object:  StoredProcedure [ORNG.].[RemoveAppFromPerson]    Script Date: 6/2/2018 10:33:24 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [ORNG.].[RemoveAppFromPerson]
@SubjectID BIGINT=NULL, @SubjectURI NVARCHAR(255)=NULL, @AppID INT, @UserEdit tinyint=0, @SessionID UNIQUEIDENTIFIER=NULL, @Error BIT=NULL OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @ApplicationInstanceNodeID  BIGINT
	DECLARE @TripleID BIGINT
	DECLARE @PersonID INT	
	DECLARE @PERSON_FILTER_ID INT
	DECLARE @InternalUserName NVARCHAR(50)
	DECLARE @PersonFilter NVARCHAR(50)

	IF (@SubjectID IS NULL)
		SET @SubjectID = [RDF.].fnURI2NodeID(@SubjectURI)
	
	-- Lookup the PersonID
	SELECT @PersonID = CAST(InternalID AS INT)
		FROM [RDF.Stage].[InternalNodeMap]
		WHERE Class = 'http://xmlns.com/foaf/0.1/Person' AND InternalType = 'Person' AND NodeID = @SubjectID

	-- Lookup the App Instance's NodeID
	SELECT @ApplicationInstanceNodeID  = NodeID
		FROM [RDF.Stage].[InternalNodeMap]
		WHERE Class = 'http://orng.info/ontology/orng#ApplicationInstance' AND InternalType = 'ORNGApplicationInstance'
			AND InternalID = CAST(@PersonID AS VARCHAR(50)) + '-' + CAST(@AppID AS VARCHAR(50))
	
		
	-- there is only ONE link from the person to the application object, so grab it	
	SELECT @TripleID = [TripleID] FROM [RDF.].Triple 
		WHERE [Subject] = @SubjectID
		AND [Object] = @ApplicationInstanceNodeID

	-- now delete it
	BEGIN TRAN

		EXEC [RDF.].DeleteTriple @TripleID = @TripleID, 
								 @SessionID = @SessionID, 
								 @Error = @Error

		-- If @UserEdit = 1, we just want to flip the security type to hide the node, that way the user can add it back
		-- If @UserEdit = 0, then use true delete because IF THE GADGET IS CODED CORRECTLY, it means that this user truly no longer has this data
		EXEC [RDF.].DeleteNode @NodeID = @ApplicationInstanceNodeID, 
							@DeleteType = @UserEdit,
							@SessionID = @SessionID, 
							@Error = @Error OUTPUT

		-- remove any filters
		SELECT @PERSON_FILTER_ID = (SELECT PersonFilterID FROM Apps WHERE AppID = @AppID)
		IF (@PERSON_FILTER_ID IS NOT NULL) 
			BEGIN
				SELECT @PersonID = CAST(InternalID AS INT) FROM [RDF.Stage].[InternalNodeMap]
					WHERE [NodeID] = @SubjectID AND Class = 'http://xmlns.com/foaf/0.1/Person'

				SELECT @InternalUserName = InternalUserName FROM [Profile.Data].[Person] WHERE PersonID = @PersonID
				SELECT @PersonFilter = PersonFilter FROM [Profile.Data].[Person.Filter] WHERE PersonFilterID = @PERSON_FILTER_ID

				DELETE FROM [Profile.Import].[PersonFilterFlag] 
					WHERE InternalUserName = @InternalUserName 
						AND personfilter = @PersonFilter
				DELETE FROM [Profile.Data].[Person.FilterRelationship] 
					WHERE PersonID = @PersonID 
						AND personFilterId = @PERSON_FILTER_ID
			END
	COMMIT
END



GO

/****** Object:  StoredProcedure [ORNG.].[HasApp]    Script Date: 6/2/2018 10:43:14 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [ORNG.].[HasApp]
@AppID INT, @SessionID UNIQUEIDENTIFIER=NULL, @Error BIT=NULL OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @Name nvarchar(255)
	DECLARE @Predicate BIGINT

	-- this must match the logic in AddAppToOntology!!!!
	SELECT @Name = [ORNG.].[fn_AppNameFromAppID](@AppID)
  
	SELECT @Predicate = _PropertyNode FROM [Ontology.].ClassProperty 
		WHERE Property = 'http://orng.info/ontology/orng#has' + @Name
		
	SELECT [Subject] FROM [RDF.].Triple where Predicate = @Predicate
END



GO
