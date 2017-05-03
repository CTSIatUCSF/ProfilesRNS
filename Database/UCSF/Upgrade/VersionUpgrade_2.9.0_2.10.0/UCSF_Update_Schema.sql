/****** Object:  StoredProcedure [User.Session].[UpdateSession]    Script Date: 3/30/2017 2:11:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [User.Session].[UpdateSession]
	@SessionID UNIQUEIDENTIFIER, 
	@UserID INT=NULL, 
	@LastUsedDate DATETIME=NULL, 
	@LogoutDate DATETIME=NULL,
	@SessionPersonNodeID BIGINT = NULL OUTPUT,
	@SessionPersonURI VARCHAR(400) = NULL OUTPUT,
	@UserURI VARCHAR(400) = NULL OUTPUT,
	@SecurityGroupID BIGINT = NULL OUTPUT
	,@ShortDisplayName VARCHAR(400) = NULL OUTPUT  -- Added by UCSF
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	-- See if there is a PersonID associated with this session	
	DECLARE @PersonID INT
	SELECT @PersonID = PersonID
		FROM [User.Session].[Session]
		WHERE SessionID = @SessionID
	IF @PersonID IS NULL AND @UserID IS NOT NULL
		SELECT @PersonID = PersonID
			FROM [User.Account].[User]
			WHERE UserID = @UserID

	-- Get the NodeID and URI of the PersonID
	IF @PersonID IS NOT NULL
	BEGIN
		SELECT @SessionPersonNodeID = m.NodeID, @SessionPersonURI = p.Value + CAST(m.NodeID AS VARCHAR(50))
			FROM [RDF.Stage].InternalNodeMap m, [Framework.].[Parameter] p
			WHERE m.InternalID = @PersonID
				AND m.InternalType = 'person'
				AND m.Class = 'http://xmlns.com/foaf/0.1/Person'
				AND p.ParameterID = 'baseURI'
	END

	-- Update the session data
    IF EXISTS (SELECT * FROM [User.Session].[Session] WHERE SessionID = @SessionID)
		UPDATE [User.Session].[Session]
			SET	UserID = IsNull(@UserID,UserID),
				UserNode = IsNull((SELECT NodeID FROM [User.Account].[User] WHERE UserID = @UserID AND @UserID IS NOT NULL),UserNode),
				PersonID = IsNull(@PersonID,PersonID),
				LastUsedDate = IsNull(@LastUsedDate,LastUsedDate),
				LogoutDate = IsNull(@LogoutDate,LogoutDate)
			WHERE SessionID = @SessionID

	IF @UserID IS NOT NULL
	BEGIN
		SELECT @UserURI = p.Value + CAST(m.NodeID AS VARCHAR(50))
			FROM [RDF.Stage].InternalNodeMap m, [Framework.].[Parameter] p
			WHERE m.InternalID = @UserID
				AND m.InternalType = 'User'
				AND m.Class = 'http://profiles.catalyst.harvard.edu/ontology/prns#User'
				AND p.ParameterID = 'baseURI'
	END

	-- Get the security group of the session
	EXEC [RDF.Security].[GetSessionSecurityGroup] @SessionID = @SessionID, @SecurityGroupID = @SecurityGroupID OUTPUT
	-- UCSF
	IF @UserID IS NOT NULL
	BEGIN
		SELECT @UserURI = p.Value + CAST(m.NodeID AS VARCHAR(50))
			FROM [RDF.Stage].InternalNodeMap m, [Framework.].[Parameter] p
			WHERE m.InternalID = @UserID
				AND m.InternalType = 'User'
				AND m.Class = 'http://profiles.catalyst.harvard.edu/ontology/prns#User'
				AND p.ParameterID = 'baseURI'
	END
	-- UCSF
	SELECT @ShortDisplayName = FirstName + ' ' + LastName FROM [User.Account].[User] WHERE UserID = @UserID AND @UserID IS NOT NULL
END

GO


/****** Object:  StoredProcedure [Edit.Module].[CustomEditAuthorInAuthorship.GetList]    Script Date: 2/1/2017 10:45:57 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Edit.Module].[CustomEditAuthorInAuthorship.GetList]
@NodeID BIGINT=NULL, @SessionID UNIQUEIDENTIFIER=NULL
AS
BEGIN

	DECLARE @PersonID INT
 
	SELECT @PersonID = CAST(m.InternalID AS INT)
		FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n
		WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @NodeID
 
	SELECT r.Reference, (CASE WHEN r.PMID IS NOT NULL THEN 1 ELSE 0 END) FromPubMed, i.PubID, r.PMID, r.MPID, NULL Category, r.URL, r.EntityDate PubDate, r.EntityID, r.Source, r.IsActive, i.PersonID, 
			(CASE WHEN a.PubID IS NOT NULL THEN 1 ELSE 0 END) Claimed
		FROM [Profile.Data].[Publication.Person.Include] i
			INNER JOIN [Profile.Data].[Publication.Entity.InformationResource] r
				ON i.PMID = r.PMID AND i.PMID IS NOT NULL
				AND i.PersonID = @PersonID
			LEFT OUTER JOIN [Profile.Data].[Publication.Person.Add] a on i.PMID = a.PMID and i.PMID IS NOT NULL 
				AND a.PersonID = @PersonID
	UNION ALL
	SELECT r.Reference, (CASE WHEN r.PMID IS NOT NULL THEN 1 ELSE 0 END) FromPubMed, i.PubID, r.PMID, r.MPID, g.HmsPubCategory Category, r.URL, r.EntityDate PubDate, r.EntityID, r.Source, r.IsActive, i.PersonID, 1 Claimed
		FROM [Profile.Data].[Publication.Person.Include] i
			INNER JOIN [Profile.Data].[Publication.Entity.InformationResource] r
				ON i.MPID = r.MPID AND i.PMID IS NULL AND i.MPID IS NOT NULL
				AND i.PersonID = @PersonID
			INNER JOIN [Profile.Data].[Publication.MyPub.General] g
				ON i.MPID = g.MPID
	ORDER BY EntityDate DESC, EntityID

END



GO


/****** Object:  StoredProcedure [Profile.Data].[Publication.ClaimOnePublication]    Script Date: 2/1/2017 11:24:36 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Profile.Data].[Publication.ClaimOnePublication]
	@PersonID INT,
	@PubID varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
BEGIN TRY 	 
	BEGIN TRANSACTION

		if exists (select * from [Profile.Data].[Publication.Person.Include]  where pubid = @PubID and PersonID = @PersonID)
		begin

			declare @pmid int
			declare @mpid varchar(50)

			set @pmid = (select pmid from [Profile.Data].[Publication.Person.Include] where pubid = @PubID)
			set @mpid = (select mpid from [Profile.Data].[Publication.Person.Include] where pubid = @PubID)

			--delete from [Profile.Data].[Publication.Person.Exclude] where pubid = @PubID
			insert into [Profile.Data].[Publication.Person.Add] 
				values (@pubid,@PersonID,@pmid,@mpid)

		end

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
		--Check success
		IF @@TRANCOUNT > 0  ROLLBACK
 
		-- Raise an error with the details of the exception
		SELECT @ErrMsg =  ERROR_MESSAGE(),
					 @ErrSeverity = ERROR_SEVERITY()
 
		RAISERROR(@ErrMsg, @ErrSeverity, 1)
			 
	END CATCH		

END

GO

/****** Object:  View [UCSF.].[vwPublication.Entitity.Claimed]    Script Date: 5/2/2017 10:33:18 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [UCSF.].[vwPublication.Entitity.Claimed] AS
  SELECT a.EntityID, a.PersonID, CAST (CASE WHEN p.PubID is not null THEN 1 ELSE 0 END AS BIT) Claimed FROM [Profile.Data].[vwPublication.Entity.Authorship] a 
  JOIN [Profile.Data].[vwPublication.Entity.InformationResource] i ON
  a.InformationResourceID = i.ENtityID left outer join [Profile.Data].[Publication.Person.Add] p ON p.personid = a.personid and p.PMID = i.PMID WHERE i.PMID IS NOT NULL;


GO

-- ORNG bug fix for people re-adding a gadget with filters
/****** Object:  StoredProcedure [ORNG.].[AddAppToPerson]    Script Date: 4/4/2017 1:31:23 PM ******/
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


