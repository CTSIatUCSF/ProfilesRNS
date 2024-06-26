---------------------------------------------------------------------------------------------------------------------
--
--	Create Schema
--
---------------------------------------------------------------------------------------------------------------------

CREATE SCHEMA [ORNG.]
GO

---------------------------------------------------------------------------------------------------------------------
--
--	Create Tables and Indexes
--
---------------------------------------------------------------------------------------------------------------------
/****** Object:  Table [ORNG.].[Apps]    Script Date: 05/17/2013 13:22:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ORNG.].[Apps](
	[AppID] [int] NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Url] [nvarchar](255) NULL,
	[PersonFilterID] [int] NULL,
	[OAuthSecret] [nvarchar](255) NULL,
	[Enabled] [bit] NOT NULL,
 CONSTRAINT [PK__app] PRIMARY KEY CLUSTERED 
(
	[AppID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [ORNG.].[Apps] ADD  CONSTRAINT [DF_orng_apps_enabled]  DEFAULT ((1)) FOR [Enabled]
GO

/****** Object:  Table [ORNG.].[AppViews]    Script Date: 05/17/2013 13:23:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ORNG.].[AppViews](
	[AppID] [int] NOT NULL,
	[Page] [nvarchar](50) NULL,
	[View] [nvarchar](50) NULL,
	[ChromeID] [nvarchar](50) NULL,
	[Visibility] [nvarchar](50) NULL,
	[DisplayOrder] [int] NULL,
	[OptParams] [nvarchar](255) NULL
) ON [PRIMARY]

GO

ALTER TABLE [ORNG.].[AppViews]  WITH CHECK ADD  CONSTRAINT [FK_orng_app_views_apps] FOREIGN KEY([AppID])
REFERENCES [ORNG.].[Apps] ([AppID])
GO

ALTER TABLE [ORNG.].[AppViews] CHECK CONSTRAINT [FK_orng_app_views_apps]
GO

/****** Object:  Table [ORNG.].[AppData]    Script Date: 05/17/2013 13:24:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ORNG.].[AppData](
	[NodeID] [bigint] NOT NULL,
	[AppID] [int] NOT NULL,
	[Keyname] [nvarchar](255) NOT NULL,
	[Value] [nvarchar](4000) NULL,
	[CreatedDT] [datetime] NULL,
	[UpdatedDT] [datetime] NULL
) ON [PRIMARY]

GO

ALTER TABLE [ORNG.].[AppData] ADD  CONSTRAINT [DF_orng_appdata_createdDT]  DEFAULT (getdate()) FOR [CreatedDT]
GO

ALTER TABLE [ORNG.].[AppData] ADD  CONSTRAINT [DF_orng_appdata_updatedDT]  DEFAULT (getdate()) FOR [UpdatedDT]
GO

/****** Object:  Index [IDX_PersonApp]    Script Date: 05/17/2013 13:27:31 ******/
CREATE NONCLUSTERED INDEX [IDX_PersonApp] ON [ORNG.].[AppData] 
(
	[NodeID] ASC,
	[AppID] ASC
)
INCLUDE ( [Keyname],
[Value]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Table [ORNG.].[Activity]    Script Date: 05/17/2013 13:24:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ORNG.].[Activity](
	[ActivityID] [int] IDENTITY(1,1) NOT NULL,
	[NodeID] [bigint] NULL,
	[AppID] [int] NULL,
	[CreatedDT] [datetime] NULL,
	[Activity] [xml] NULL,
 CONSTRAINT [PK__activity] PRIMARY KEY CLUSTERED 
(
	[ActivityID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [ORNG.].[Activity] ADD  CONSTRAINT [DF_orng_activity_createdDT]  DEFAULT (getdate()) FOR [CreatedDT]
GO

/****** Object:  Table [ORNG.].[Messages]    Script Date: 05/17/2013 13:25:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [ORNG.].[Messages](
	[MsgID] [nvarchar](255) NOT NULL,
	[SenderNodeID] [bigint] NULL,
	[RecipientNodeID] [bigint] NULL,
	[Coll] [nvarchar](255) NULL,
	[Title] [nvarchar](255) NULL,
	[Body] [nvarchar](4000) NULL,
	[CreatedDT] [datetime] NULL
) ON [PRIMARY]

GO

ALTER TABLE [ORNG.].[Messages] ADD  CONSTRAINT [DF_orng_messages_createdDT]  DEFAULT (getdate()) FOR [CreatedDT]
GO

---------------------------------------------------------------------------------------------------------------------
--
--  Create Views
--
---------------------------------------------------------------------------------------------------------------------
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [ORNG.].[vwAppPersonData] as
	SELECT m.InternalID + '-' + CAST(a.AppID as varchar) + '-' + d.Keyname PrimaryId, 
	 m.InternalID + '-' + CAST(a.AppID as varchar)PersonIdAppId,
	 m.InternalID PersonId, a.AppID,
	 a.Name AppName, d.Keyname, d.Value FROM [ORNG.].[Apps] a 
	 join [ORNG.].AppData d on a.AppID = d.AppID 
	 join [RDF.Stage].InternalNodeMap m on d.NodeID = m.NodeID
GO

---------------------------------------------------------------------------------------------------------------------
--
--	Create Stored Procedures
--
---------------------------------------------------------------------------------------------------------------------
/****** Object:  StoredProcedure [ORNG.].[ReadAppData]    Script Date: 06/25/2013 13:38:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [ORNG.].[ReadAppData](@Uri nvarchar(255),@AppID INT, @Keyname nvarchar(255))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @NodeID bigint
	
	SELECT @NodeID = [RDF.].[fnURI2NodeID](@Uri);

	SELECT Value from [ORNG.].AppData where AppID=@AppID AND NodeID = @NodeID AND Keyname = @Keyname
END
GO
/****** Object:  StoredProcedure [ORNG.].[DeleteAppData]    Script Date: 06/25/2013 13:39:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [ORNG.].[DeleteAppData](@Uri nvarchar(255),@AppID INT, @Keyname nvarchar(255))
As
BEGIN
	SET NOCOUNT ON
	DECLARE @NodeID bigint
	
	SELECT @NodeID = [RDF.].[fnURI2NodeID](@Uri);
	DELETE [ORNG.].[AppData] WHERE NodeID = @NodeID AND AppID = @AppID and Keyname = @Keyname
END		

GO
/****** Object:  StoredProcedure [ORNG.].[UpsertAppData]    Script Date: 06/25/2013 13:40:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [ORNG.].[UpsertAppData](@Uri nvarchar(255),@AppID INT, @Keyname nvarchar(255),@Value nvarchar(4000))
As
BEGIN
	SET NOCOUNT ON
	DECLARE @NodeID bigint
	
	SELECT @NodeID = [RDF.].[fnURI2NodeID](@Uri);
	IF (SELECT COUNT(*) FROM AppData WHERE NodeID = @NodeID AND AppID = @AppID and Keyname = @Keyname) > 0
		UPDATE [ORNG.].[AppData] set [Value] = @Value, updatedDT = GETDATE() WHERE NodeID = @nodeId AND AppID = @AppID and Keyname = @Keyname
	ELSE
		INSERT [ORNG.].[AppData] (NodeID, AppID, Keyname, [Value]) values (@NodeID, @AppID, @Keyname, @Value)
END		
GO
/****** Object:  StoredProcedure [ORNG.].[ReadActivity]    Script Date: 06/25/2013 13:42:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [ORNG.].[ReadActivity](@Uri nvarchar(255),@AppID INT, @ActivityID INT)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @NodeID bigint
	
	select @NodeID = [RDF.].[fnURI2NodeID](@Uri);

	select Activity from [ORNG.].Activity where NodeID = @NodeID AND AppID=@AppID AND ActivityID =@ActivityID
END
GO
/****** Object:  StoredProcedure [ORNG.].[ReadAllActivities]    Script Date: 06/25/2013 13:42:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [ORNG.].[ReadAllActivities](@Uri nvarchar(255),@AppID INT)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @NodeID bigint
	
	select @NodeID = [RDF.].[fnURI2NodeID](@Uri);

	IF (@AppID IS NULL)
		select Activity from [ORNG.].Activity where NodeID = @NodeID
	ELSE		
		select Activity from [ORNG.].Activity where NodeID = @NodeID AND AppID=@AppID 
END
GO
/****** Object:  StoredProcedure [ORNG.].[DeleteActivity]    Script Date: 06/25/2013 13:43:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [ORNG.].[DeleteActivity](@Uri nvarchar(255),@AppID INT, @ActivityID int)
As
BEGIN
	SET NOCOUNT ON
	DECLARE @NodeID bigint
	
	select @NodeID = [RDF.].[fnURI2NodeID](@Uri);	
	DELETE [ORNG.].[Activity] WHERE NodeID = @NodeID AND AppID = @AppID and ActivityID = @ActivityID
END		
GO
/****** Object:  StoredProcedure [ORNG.].[InsertActivity]    Script Date: 06/25/2013 13:43:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [ORNG.].[InsertActivity](@Uri nvarchar(255),@AppID INT, @ActivityID int, @Activity XML)
As
BEGIN
	SET NOCOUNT ON
	DECLARE @NodeID bigint
	
	select @NodeID = [RDF.].[fnURI2NodeID](@Uri);	
	IF (@ActivityID IS NULL OR @ActivityID < 0)
		INSERT [ORNG.].[Activity] (NodeID, AppID, Activity) values (@NodeID, @AppID, @Activity)
	ELSE 		
		INSERT [ORNG.].[Activity] (ActivityID, NodeID, AppID, Activity) values (@ActivityID, @NodeID, @AppID, @Activity)
END		
GO
/****** Object:  StoredProcedure [ORNG.].[ReadMessages]    Script Date: 06/25/2013 13:44:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [ORNG.].[ReadMessages](@RecipientUri nvarchar(255),@Coll nvarchar(255), @MsgIDs nvarchar(max))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @RecipientNodeID bigint
	DECLARE @baseURI nvarchar(255)
	DECLARE @sql nvarchar(255)
	
	select @RecipientNodeID = [RDF.].[fnURI2NodeID](@RecipientUri)
	select @baseURI = [Value] FROM [Framework.].[Parameter] WHERE ParameterID = 'baseURI';
	
	SET @sql = 'SELECT MsgID, Coll, Body, Title, ''' + @baseURI  + '''+ SenderNodeID , ''' + @baseURI + '''+ RecipientNodeID ' +
		'FROM [ORNG.].[Messages] WHERE RecipientNodeID = ' + @RecipientNodeID
	IF (@Coll IS NOT NULL)
		SET @sql = @sql + ' AND Coll = ''' + @Coll + '''';
	IF (@MsgIDs IS NOT NULL)
		SET @sql = @sql + ' AND MsgID IN ' + @MsgIDs
		
	EXEC @sql;
END
GO
/****** Object:  StoredProcedure [ORNG.].[ReadMessageCollections]    Script Date: 06/25/2013 13:44:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE  [ORNG.].[ReadMessageCollections](@RecipientUri nvarchar(255))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @RecipientNodeID bigint
	
	select @RecipientNodeID = [RDF.].[fnURI2NodeID](@RecipientUri)

	SELECT DISTINCT Coll	FROM [ORNG.].[Messages] WHERE RecipientNodeID =  @RecipientNodeID
END
GO
/****** Object:  StoredProcedure [ORNG.].[InsertMessage]    Script Date: 06/25/2013 13:45:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [ORNG.].[InsertMessage](@MsgID nvarchar(255),@Coll nvarchar(255), @Title nvarchar(255), @Body nvarchar(255),
										@senderUri nvarchar(255), @RecipientUri nvarchar(255))
As
BEGIN
	SET NOCOUNT ON
	DECLARE @SenderNodeID bigint
	DECLARE @RecipientNodeID bigint
	
	select @SenderNodeID = [RDF.].[fnURI2NodeID](@senderUri)
	select @RecipientNodeID = [RDF.].[fnURI2NodeID](@RecipientUri)
	
	INSERT [ORNG.].[Messages]  (MsgID, Coll, Title, Body, SenderNodeID, RecipientNodeID) 
			VALUES (@MsgID, @Coll, @Title, @Body, @SenderNodeID, @RecipientNodeID)
END		
GO

---------------------------------------------------------------------------------------------------------------------
--
--	To Integrate into the Ontoloty
--
---------------------------------------------------------------------------------------------------------------------
/****** Object:  StoredProcedure [ORNG.].[AddAppToOntology]    Script Date: 10/11/2013 09:42:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [ORNG.].[AddAppToOntology](@AppID INT, 
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
		
		SELECT @InternalType = n.value FROM [rdf.].[Triple] t JOIN [rdf.].Node n ON t.[Object] = n.NodeID 
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
										@ClassURI = 'http://xmlns.com/foaf/0.1/Person',
										@IsDetail = 0,
										@IncludeDescription = 0								
		UPDATE [Ontology.].[ClassProperty] set EditExistingSecurityGroup = -20, IsDetail = 0, IncludeDescription = 0,
				CustomEdit = 1, CustomEditModule = @CustomEditModule,
				CustomDisplay = 1, CustomDisplayModule = @CustomDisplayModule,
				EditSecurityGroup = -20, EditPermissionsSecurityGroup = -20, -- was -20's
				EditAddNewSecurityGroup = -20, EditAddExistingSecurityGroup = -20, EditDeleteSecurityGroup = -20 
			WHERE property = @ClassPropertyName;
END

/****** Object:  StoredProcedure [ORNG.].[RemoveAppFromOntology]    Script Date: 10/11/2013 09:44:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [ORNG.].[RemoveAppFromOntology](@appId INT, @SessionID UNIQUEIDENTIFIER=NULL, @Error BIT=NULL OUTPUT, @NodeID BIGINT=NULL OUTPUT)
AS
BEGIN
	SET NOCOUNT ON
		DECLARE @Name NVARCHAR(255)
		DECLARE @PropertyURI NVARCHAR(255)
		DECLARE @SubjectNode BIGINT
		DECLARE @ObjectNode BIGINT
		
		SELECT @Name = REPLACE(RTRIM(RIGHT(url, CHARINDEX('/', REVERSE(url)) - 1)), '.xml', '')
			FROM [ORNG.].[Apps] WHERE appId = @appId 
		SET @PropertyURI = 'http://orng.info/ontology/orng#has' + @Name				
			
		IF (@PropertyURI IS NOT NULL)
		BEGIN	
			DELETE FROM [Ontology.].[ClassProperty]	WHERE Property = @PropertyURI
			DELETE FROM [Ontology.].[PropertyGroupProperty] WHERE PropertyURI = @PropertyURI
			-- get this data from the Import table
			SELECT @SubjectNode = _SubjectNode, @ObjectNode = _ObjectNode FROM [Ontology.Import].[Triple]
				WHERE Subject = @PropertyURI AND Predicate = 'http://www.w3.org/2000/01/rdf-schema#label'
			-- now remove items from the Import table
			DELETE FROM [Ontology.Import].[Triple] WHERE Subject = @PropertyURI
			-- and remove from stage
			DELETE FROM [RDF.Stage].[Triple] WHERE sURI = @PropertyURI
		END

		DECLARE @PropertyNode BIGINT
		SELECT @PropertyNode = _PropertyNode FROM [Ontology.].[ClassProperty] WHERE
			Class = 'http://orng.info/ontology/orng#Application' AND 
			Property = 'http://orng.info/ontology/orng#applicationId' --_PropertyNode
		SELECT @NodeID = t.[Subject] FROM [RDF.].Triple t JOIN
			[RDF.].Node n ON t.[Object] = n.nodeid 
			WHERE t.Predicate = @PropertyNode AND n.[Value] = CAST(@appId AS VARCHAR)
		
		IF (@NodeID IS NOT NULL)
		BEGIN
			EXEC [RDF.].DeleteNode @NodeID = @NodeID, @DeleteType = 0								   
		END	

		IF (@SubjectNode IS NOT NULL)
		BEGIN
			EXEC [RDF.].DeleteNode @NodeID = @SubjectNode, @DeleteType = 0								   
		END	

		IF (@ObjectNode IS NOT NULL)
		BEGIN
			EXEC [RDF.].DeleteNode @NodeID = @ObjectNode, @DeleteType = 0								   
		END	
		-- 
END


/****** Object:  StoredProcedure [ORNG.].[AddAppToPerson]    Script Date: 10/11/2013 09:47:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [ORNG.].[AddAppToPerson]
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

		print 'Weare ready to add the person to the filter'
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
		print 'We are ready to add the person to the filter'
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

/****** Object:  StoredProcedure [ORNG.].[GetAppInstance]    Script Date: 06/19/2014 09:37:50 ******/
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

/****** Object:  StoredProcedure [ORNG.].[RemoveAppFromPerson]    Script Date: 10/11/2013 09:48:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [ORNG.].[RemoveAppFromPerson]
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

/****** Object:  StoredProcedure [ORNG.].[HasApp]    Script Date: 06/25/2014 11:36:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [ORNG.].[HasApp]
@AppID INT, @SessionID UNIQUEIDENTIFIER=NULL, @Error BIT=NULL OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @Name nvarchar(255)
	DECLARE @Predicate BIGINT

	-- this must match the logic in AddAppToOntology!!!!
	SELECT @Name = REPLACE(RTRIM(RIGHT(url, CHARINDEX('/', REVERSE(url)) - 1)), '.xml', '')
		FROM [ORNG.].[Apps] WHERE appId = @appId 
  
	SELECT @Predicate = _PropertyNode FROM [Ontology.].ClassProperty 
		WHERE Property = 'http://orng.info/ontology/orng#has' + @Name
		
	SELECT [Subject] FROM [RDF.].Triple where Predicate = @Predicate
END


GO

/****** Object:  View [ORNG.].[vwPerson]    Script Date: 04/27/2014 08:09:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE view [ORNG.].[vwPerson]
as
SELECT n.nodeId
      ,par.[Value] + '/' + na.[UrlName] profileURL, p.IsActive, p.internalusername
  FROM [Framework.].Parameter par JOIN
  [Profile.Data].[Person] p ON  par.[ParameterID] = 'basePath'
	LEFT JOIN [UCSF.].[NameAdditions] na on na.internalusername = p.internalusername
	LEFT JOIN [RDF.Stage].internalnodemap n on n.internalid = p.personId
	and n.[class] = 'http://xmlns.com/foaf/0.1/Person' 

GO

/****** Object:  StoredProcedure [ORNG.].[ReadAppData]    Script Date: 02/18/2014 16:15:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE  [ORNG.].[ReadPerson](@uri nvarchar(255))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @nodeid bigint
	
	SELECT @nodeid = [RDF.].[fnURI2NodeID](@uri);

	SELECT * from [ORNG.].[vwPerson] WHERE nodeId = @nodeid
END

GO