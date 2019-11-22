--- NOTE!!! 
-- Make sure the logic for finding filters in [UCSF.ORNG].[AlignCollaborationInterestsFilters]  will match for this value  and no others!!
-- ALSO MODIFY THE NIGHTLY IMPORT SO THAT Collaboration Filters are not destroyed!  SEE BOTTOM OF THIS

-- If category changes, you need to update the match logic a few places below to make sure it is compatible!
DECLARE @Category VARCHAR(50) = 'Find people interested in:';

DELETE FROM [Profile.Data].[Person.Filter] WHERE PersonFilterCategory = @Category;

DECLARE @filterSort INT = 12

DECLARE @FilterNames TABLE (PersonFilter VARCHAR(50) NOT NULL)

INSERT @FilterNames VALUES ('Clinical Research');
INSERT @FilterNames VALUES ('Community And Stakeholder Organizations');
INSERT @FilterNames VALUES ('Academic Senate Committee Service');
INSERT @FilterNames VALUES ('Academic Collaboration');
INSERT @FilterNames VALUES ('Prospective Donors');
INSERT @FilterNames VALUES ('Press');
INSERT @FilterNames VALUES ('Companies And Entrepreneurs');

DECLARE @FilterName VARCHAR(50)

SELECT TOP 1 @FilterName = PersonFilter FROM @FilterNames
WHILE (@FilterName IS NOT NULL)
BEGIN 
	INSERT INTO [Profile.Data].[Person.Filter] (PersonFilter, PersonFilterCategory, PersonFilterSort)
		VALUES (@FilterName, @Category, @filterSort);
	SELECT @filterSort = @filterSort + 1;
	DELETE FROM @FilterNames WHERE PersonFilter = @FilterName
	SET @FilterName = NULL
	SELECT TOP 1 @FilterName = PersonFilter FROM @FilterNames
END

/****** Object:  StoredProcedure [ORNG.].[AddAppToAgent]    Script Date: 7/9/2019 11:36:46 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [UCSF.ORNG].[AlignCollaborationInterestsFilters] @SubjectID BIGINT=NULL, @AppID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @Name nvarchar(255)
	DECLARE @Predicate BIGINT
	DECLARE @HasApp BIT = 0

	-- this must match the logic in AddAppToOntology!!!!
	SELECT @Name = [ORNG.].[fn_AppNameFromAppID](@AppID)
  
	-- This is sloppy but oh well, first check that this is even the correct app!
	IF ('CollaborationInterests' != @Name)
		RETURN
		
	SELECT @Predicate = _PropertyNode FROM [Ontology.].ClassProperty 
		WHERE Property = 'http://orng.info/ontology/orng#has' + @Name
		

	SELECT @HasApp = 1 FROM [RDF.].Triple where Predicate = @Predicate AND [Subject] = @SubjectID

	DECLARE @PersonID INT
	DECLARE @InternalUsername nvarchar(50)
	SELECT @PersonID = cast(InternalID as INT) FROM [RDF.Stage].[InternalNodeMap] WHERE Class = 'http://xmlns.com/foaf/0.1/Person' AND NodeID = @SubjectID
	SELECT @InternalUsername = InternalUsername FROM [Profile.Data].[Person] where PersonID = @PersonID

	-- now go through all the filters and see what they have
	DECLARE @Filters TABLE (PersonFilterID INT NOT NULL, PersonFilter VARCHAR(200) NOT NULL)
	INSERT INTO @Filters 
		SELECT PersonFilterID, PersonFilter FROM [Profile.Data].[Person.Filter] WHERE PersonFilterCategory like '%interested%';

	DECLARE @PersonFilterID INT
	DECLARE @PersonFilter varchar(50)
	SELECT TOP 1 @PersonFilterID = PersonFilterID FROM @Filters
	WHILE (@PersonFilterID IS NOT NULL)
	BEGIN 
		SELECT @PersonFilter = PersonFilter FROM @Filters WHERE PersonFilterID = @PersonFilterID
		IF ('true' = (SELECT [Value] FROM [ORNG.].[AppData] WHERE @HasApp = 1 AND NodeID = @SubjectID AND AppID = @AppID AND Keyname = REPLACE(@PersonFilter, ' ', '')))
			BEGIN
					IF NOT EXISTS (SELECT * FROM [Profile.Import].[PersonFilterFlag] WHERE internalusername = @InternalUsername AND personfilter = @PersonFilter)					
						INSERT [Profile.Import].[PersonFilterFlag] 
							VALUES (@InternalUserName, @PersonFilter)
					IF NOT EXISTS (SELECT * FROM [Profile.Data].[Person.FilterRelationship] WHERE PersonID = @PersonID AND personFilterId = @PersonFilterID)					
						INSERT [Profile.Data].[Person.FilterRelationship](PersonID, personFilterId) 
							VALUES (@PersonID, @PersonFilterID)				 
			END
		ELSE
			BEGIN
				DELETE FROM [Profile.Import].[PersonFilterFlag] 
					WHERE InternalUsername = @InternalUsername AND PersonFilter = @PersonFilter
				DELETE FROM [Profile.Data].[Person.FilterRelationship] 
					WHERE PersonID = @PersonID AND PersonFilterID = @PersonFilterID
			END

		DELETE FROM @Filters WHERE PersonFilterID = @PersonFilterID
		SET @PersonFilterID = NULL
		SELECT TOP 1 @PersonFilterID = PersonFilterID FROM @Filters
	END

END


GRANT EXECUTE ON [UCSF.ORNG].[AlignCollaborationInterestsFilters] TO App_Profiles10
GO

/****** Object:  StoredProcedure [ORNG.].[AddAppToAgent]    Script Date: 7/9/2019 2:31:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [ORNG.].[AddAppToAgent]
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
	SELECT @AppName = [ORNG.].[fn_AppNameFromAppID](@AppID)

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

		-- Change the security group of the Node
		EXEC [RDF.].[GetStoreNode]   @ExistingNodeID = @AppInstanceID, -- bigint
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
	-- CollaborationInterests HACK
	EXEC [UCSF.ORNG].[AlignCollaborationInterestsFilters] @SubjectID=@SubjectID, @AppID=@AppID
END

GO

/****** Object:  StoredProcedure [ORNG.].[RemoveAppFromAgent]    Script Date: 7/9/2019 2:34:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [ORNG.].[RemoveAppFromAgent]
@SubjectID BIGINT=NULL, @SubjectURI NVARCHAR(255)=NULL, @AppID INT, @UserEdit tinyint = 0, @SessionID UNIQUEIDENTIFIER=NULL, @Error BIT=NULL OUTPUT
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
				IF (@PersonID IS NOT NULL)
					BEGIN
						SELECT @InternalUserName = InternalUserName FROM [Profile.Data].[Person] WHERE PersonID = @PersonID
						SELECT @PersonFilter = PersonFilter FROM [Profile.Data].[Person.Filter] WHERE PersonFilterID = @PERSON_FILTER_ID

						DELETE FROM [Profile.Import].[PersonFilterFlag] WHERE InternalUserName = @InternalUserName AND personfilter = @PersonFilter
						DELETE FROM [Profile.Data].[Person.FilterRelationship] WHERE PersonID = @PersonID AND personFilterId = @PERSON_FILTER_ID
					END
			END
	COMMIT
	-- CollaborationInterests HACK
	EXEC [UCSF.ORNG].[AlignCollaborationInterestsFilters] @SubjectID=@SubjectID, @AppID=@AppID
END
GO

/****** Object:  StoredProcedure [ORNG.].[UpsertAppData]    Script Date: 7/9/2019 2:34:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [ORNG.].[UpsertAppData](@Uri nvarchar(255),@AppID INT, @Keyname nvarchar(255),@Value nvarchar(4000))
As
BEGIN
	SET NOCOUNT ON
	DECLARE @NodeID bigint
	
	SELECT @NodeID = [RDF.].[fnURI2NodeID](@Uri);
	IF (SELECT COUNT(*) FROM AppData WHERE NodeID = @NodeID AND AppID = @AppID and Keyname = @Keyname) > 0
		UPDATE [ORNG.].[AppData] set [Value] = @Value, updatedDT = GETDATE() WHERE NodeID = @nodeId AND AppID = @AppID and Keyname = @Keyname
	ELSE
		INSERT [ORNG.].[AppData] (NodeID, AppID, Keyname, [Value]) values (@NodeID, @AppID, @Keyname, @Value)

	-- CollaborationInterests HACK
	EXEC [UCSF.ORNG].[AlignCollaborationInterestsFilters] @SubjectID=@NodeID, @AppID=@AppID
END		

GO

USE [import_profiles]
GO

/****** Object:  StoredProcedure [UCSF.Export].[ExportHRData]    Script Date: 7/10/2019 8:51:59 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [UCSF.Export].[ExportHRData] 
	@DestinationDB VARCHAR(50)
AS
BEGIN 
	DECLARE @SQL NVARCHAR(MAX)
	SELECT @SQL = N'
		BEGIN TRANSACTION 
		delete from [' + @DestinationDB + '].[Profile.Import].[Person]
		delete from [' + @DestinationDB + '].[Profile.Import].[PersonAffiliation]
		-- do not remove ORNG based filters unless person is gone
		-- also allow for Collaboration Interests hack!
		delete from [' + @DestinationDB + '].[Profile.Import].[PersonFilterFlag] where PersonFilter NOT IN (select Name from [' + @DestinationDB + '].[ORNG.].Apps UNION select PersonFilter from [' + @DestinationDB + '].[Profile.Data].[Person.Filter] WHERE PersonFilterCategory like ''%interested%'')
		delete from [' + @DestinationDB + '].[Profile.Import].[PersonFilterFlag] where internalusername not in (select internalusername from [UCSF.Export].vwPerson)

		delete from [' + @DestinationDB + '].[Profile.Import].[User]

		insert  [' + @DestinationDB + '].[Profile.Import].[Person] select * from [UCSF.Export].vwPerson
		insert  [' + @DestinationDB + '].[Profile.Import].[PersonAffiliation] select * from [UCSF.Export].vwPersonAffiliation
		insert  [' + @DestinationDB + '].[Profile.Import].[PersonFilterFlag] select * from [UCSF.Export].vwPersonFilterFlag
		insert  [' + @DestinationDB + '].[Profile.Import].[User] select * from [UCSF.Export].vwUser
		COMMIT'
	EXEC dbo.sp_executesql @SQL
END


GRANT EXECUTE ON [UCSF.Export].[ExportHRData] TO profilesjobrunner



GO

-- 11-5-2019 UPDATE
UPDATE [Profile.Data].[Person.Filter] Set PersonFilter = 'Multicenter Clinical Research' WHERE PersonFilter = 'Clinical Research' 
UPDATE [Profile.Import].[PersonFilterFlag] Set personfilter = 'Multicenter Clinical Research' WHERE personfilter = 'Clinical Research' 
DECLARE @AppID INT
SELECT @AppID = AppID FROM [ORNG.].[Apps] WHERE [Name] = 'Collaboration Interests'
UPDATE [ORNG.].[AppData] SET Keyname = 'MulticenterClinicalResearch' WHERE Keyname = 'ClinicalResearch' AND AppID = @AppID
