/****** Object:  StoredProcedure [ORNG.].[GetAppInstance]    Script Date: 4/19/2017 10:09:48 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [ORNG.].[GetAppInstance]
@SubjectID BIGINT=NULL, @SubjectURI nvarchar(255)=NULL, @AppID INT, @SessionID UNIQUEIDENTIFIER=NULL, @ApplicationInstanceNodeID BIGINT=NULL OUTPUT,
@Error BIT=NULL OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @ApplicationNodeID BIGINT
	DECLARE @PersonID INT	

	IF (@SubjectID IS NULL)
		SET @SubjectID = [RDF.].fnURI2NodeID(@SubjectURI)
	
	-- get the person id
	SELECT @PersonID = cast(InternalID as INT) FROM [RDF.Stage].[InternalNodeMap]
		WHERE [NodeID] = @SubjectID AND Class = 'http://xmlns.com/foaf/0.1/Person'
		
	--get the ApplicationInstance nodeid
	SELECT @ApplicationInstanceNodeID = [NodeID] FROM [RDF.STage].InternalNodeMap 
		WHERE Class = 'http://orng.info/ontology/orng#ApplicationInstance' AND 
		InternalID = CAST(@PersonID as varchar) + '-' + CAST(@AppID as varchar)
		
	IF (@ApplicationInstanceNodeID IS NOT NULL)
		SELECT [Value] + CAST(@ApplicationInstanceNodeID as VARCHAR) FROM [Framework.].[Parameter] WHERE ParameterID = 'baseURI'
	ELSE
		SELECT NULL		
END


GO


/****** Object:  StoredProcedure [ORNG.].[AddAppToPerson]    Script Date: 4/19/2017 10:21:15 AM ******/
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
	
	SELECT @InternalType = [Object] FROM [Ontology.Import].[Triple] 
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
		WHERE Class = 'http://orng.info/ontology/orng#Application' AND InternalType = 'ORNG Application'
			AND InternalID = @AppName

		
	----------------------------------------------------------------
	-- Determine if this app has already been added to this person
	----------------------------------------------------------------
	DECLARE @AppInstanceID BIGINT
	SELECT @AppInstanceID = NodeID
		FROM [RDF.Stage].[InternalNodeMap]
		WHERE Class = 'http://orng.info/ontology/orng#ApplicationInstance' AND InternalType = 'ORNG Application Instance'
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

