---------------------------------------------------------------------------------------------------------------------
--
--	Create [UCSF.] Schema
--
---------------------------------------------------------------------------------------------------------------------

CREATE SCHEMA [UCSF.]
GO

---------------------------------------------------------------------------------------------------------------------
--
--	Create Tables and Indexes
--
---------------------------------------------------------------------------------------------------------------------
/****** Object:  Table [UCSF.].[NameAdditions]    Script Date: 10/11/2013 10:50:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [UCSF.].[NameAdditions] (
	[InternalUserName] [nvarchar](50) NOT NULL,
	[CleanFirst] [nvarchar](50) NULL,
	[CleanMiddle] [nvarchar](50) NULL,
	[CleanLast] [nvarchar](50) NULL,
	[CleanSuffix] [nvarchar](50) NULL,
	[GivenName] [nvarchar](50) NULL,  
	[CleanGivenName] [nvarchar](50) NULL,  
	[PrettyURL] [nvarchar](255) NULL,
	[Strategy] [nvarchar](50) NULL,
	[PublishingFirst] [nvarchar](50) NULL,
 CONSTRAINT [PK_uniqueNames] PRIMARY KEY CLUSTERED 
(
	[InternalUserName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]


CREATE UNIQUE INDEX prettyUrlUnique ON [UCSF.].[NameAdditions]([PrettyURL])
WHERE [PrettyURL] IS NOT NULL
GO

/****** Object:  Table [UCSF.].[Theme]    Script Date: 12/16/2015 10:51:55 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [UCSF.].[Theme](
	[Theme] [nvarchar](50) NOT NULL,
	[BasePath] [nvarchar](50) NOT NULL,
	[GATrackingId] [nvarchar](50) NULL,
	[Shared] bit NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Theme] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

/****** Object:  Table [UCSF.].[InstitutionAdditions]    Script Date: 12/16/2015 10:51:55 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [UCSF.].[InstitutionAdditions](
	[InstitutionAbbreviation] [nvarchar](50) NOT NULL,
	[Theme] [nvarchar](50) NOT NULL,
	[ShibbolethIdP] [nvarchar](255) NULL,
	[ShibbolethUserNameHeader] [nvarchar](255) NULL,
	[ShibbolethDisplayNameHeader] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[InstitutionAbbreviation] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [UCSF.].[InstitutionAdditions]  WITH CHECK ADD  CONSTRAINT [FK_institution_theme] FOREIGN KEY([Theme])
REFERENCES [UCSF.].[Theme] ([Theme])
GO

---------------------------------------------------------------------------------------------------------------------
--
--  Create Views
--
---------------------------------------------------------------------------------------------------------------------

/****** Object:  View [UCSF].[Person]    Script Date: 10/11/2013 11:16:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE view [UCSF.].[vwPerson]
as
SELECT p.[PersonID]
      ,p.[UserID]
      ,n.nodeid
      ,na.PrettyURL
      ,p.[FirstName]
      ,isnull(na.[PublishingFirst], isnull(na.[GivenName], p.[FirstName])) [PublishingFirst]
      ,p.[LastName]
      ,p.[MiddleName]
      ,p.[DisplayName]
      ,p.[Suffix]
      ,p.[IsActive]
      ,p.[EmailAddr]
      ,p.[Phone]
      ,p.[Fax]
      ,p.[AddressLine1]
      ,p.[AddressLine2]
      ,p.[AddressLine3]
      ,p.[AddressLine4]
      ,p.[City]
      ,p.[State]
      ,p.[Zip]
      ,p.[Building]
      ,p.[Floor]
      ,p.[Room]
      ,p.[AddressString]
      ,p.[Latitude]
      ,p.[Longitude]
      ,p.[GeoScore]
      ,p.[FacultyRankID]
      ,p.[InternalUsername]
      ,p.[Visible]
	  ,i.InstitutionAbbreviation
	  ,t.Theme  
  FROM [Profile.Data].[Person] p 
	JOIN [Profile.Data].[Person.Affiliation] a on p.PersonID = a.PersonID and a.IsPrimary = 1
	JOIN [Profile.Data].[Organization.Institution] i on a.InstitutionID = i.InstitutionID
	JOIN [UCSF.].[InstitutionAdditions] t on i.InstitutionAbbreviation = t.InstitutionAbbreviation --this is where and how we assign a theme to a profile.
	JOIN [UCSF.].[NameAdditions] na on na.internalusername = p.internalusername
	JOIN [RDF.Stage].internalnodemap n on n.internalid = p.personId AND n.[class] = 'http://xmlns.com/foaf/0.1/Person' 

GO

/****** Object:  View [UCSF.].[vwPublication.MyPub.General]    Script Date: 10/13/2016 12:52:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [UCSF.].[vwPublication.MyPub.General] AS
SELECT ir.EntityID, g.* FROM [Profile.Data].[Publication.Entity.InformationResource] ir JOIN [Profile.Data].[Publication.MyPub.General] g ON
ir.MPID = g.MPID WHERE ir.MPID IS NOT NULL;

GO

/****** Object:  View [UCSF.].[vwBrand]    Script Date: 10/13/2016 12:52:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [UCSF.].[vwBrand] AS  
SELECT DISTINCT t.Theme,
	   t.BasePath,
	   t.GATrackingID,
	   CASE WHEN t.Shared = 1 THEN NULL ELSE a.InstitutionAbbreviation END AS InstitutionAbbreviation,
	   CASE WHEN t.Theme = 'UC' THEN 'UC Health' ELSE NULL END AS PersonFilter -- note that this is hacked to do what we need it to do. For a view, that is sort of OK
FROM [UCSF.].[Theme] t
	LEFT OUTER JOIN [UCSF.].[InstitutionAdditions] a on a.Theme = t.Theme

GO
---------------------------------------------------------------------------------------------------------------------
--
--	Create Functions
--
---------------------------------------------------------------------------------------------------------------------


/****** Object:  UserDefinedFunction [UCSF.].[fn_UrlCleanName]    Script Date: 10/11/2013 10:59:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [UCSF.].[fn_UrlCleanName]
(
	@s varchar(255)
)
RETURNS varchar(255)
AS
BEGIN

	SET @s = lower(ltrim(rtrim(@s)))

	DECLARE @str varchar(255)
	SET @str = ''
	DECLARE @i int
	DECLARE @c char(1)

	SET @i = 1

	WHILE @i <= len(@s)
	BEGIN
		SET @c = substring(@s,@i,1)											------------------------------------------- ' . - _ all are valid for URL's
		IF (ascii(@c) between 65 and 90 or ascii(@c) between 97 and 122 or ascii(@c) between 48 and 57 or ascii(@c) in (45, 46, 95))
			SET @str = @str + @c
        ELSE IF (ASCII(@c) = 32 AND @str != '' AND (ascii(right(@str,1)) between 65 and 90 or ascii(right(@str,1)) between 48 and 57)) 
			SET @str = @str + '-'
						
		SET @i = @i + 1
	END

	IF len(@str) < 1
		SET @str = null
		
	-- remove any trailing dots or dashes
	WHILE (ascii(RIGHT(@str,1)) in (45, 46, 95))
		SET @str = LEFT(@str, len(@str) -1)
			
	RETURN @str

END

GO

/****** Object:  UserDefinedFunction [UCSF.].[fn_UrlCleanName]    Script Date: 4/26/2017 3:12:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [UCSF.].[fn_ApplicationNameFromPrettyUrl]
(
	@CompleteURL varchar(255)
)
RETURNS varchar(255)
AS
BEGIN

	RETURN REVERSE(RTRIM(SUBSTRING(REVERSE (@CompleteURL), 
					(CHARINDEX('?', REVERSE (@CompleteURL), 1)+1), 
					((CHARINDEX('/', REVERSE (@CompleteURL), 1)) - (CHARINDEX('?', REVERSE (@CompleteURL), 1))- 1)))) 
END


GO

/****** Object:  UserDefinedFunction [UCSF.].[fn_LegacyInternalusername2EPPN]    Script Date: 4/26/2017 3:12:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [UCSF.].fn_LegacyInternalusername2EPPN
(
	@legacyinternalusername nvarchar(50),
	@institutionabbreviation nvarchar(50)	
)
RETURNS nvarchar(50)
AS
BEGIN
	IF (@institutionabbreviation = 'ucsf') 
		RETURN SUBSTRING(@legacyinternalusername, 3, 6) + '@ucsf.edu'
	ELSE IF (@institutionabbreviation = 'ucsd')
		RETURN cast(@legacyinternalusername as varchar) + '@ucsd.edu'
	ELSE IF (@institutionabbreviation = 'uci')
		RETURN cast(@legacyinternalusername as varchar) + '@uci.edu'
	ELSE IF (@institutionabbreviation = 'usc')
		RETURN cast(@legacyinternalusername as varchar) + '@usc.edu'
	ELSE IF (@institutionabbreviation = 'ucla')
		RETURN cast(@legacyinternalusername as varchar) + '@ucla.edu'
	ELSE IF (@institutionabbreviation = 'lbnl')
		RETURN cast(@legacyinternalusername as varchar) + '@lbl.gov'
	RETURN 'Unrecognized institution :' + @institutionabbreviation
END


GO

/****** Object:  UserDefinedFunction [UCSF.].[fn_InternalUserName2UserName]    Script Date: 3/16/2018 3:12:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [UCSF.].fn_InternalUserName2UserName
(
	@internalusername nvarchar(50)
)
RETURNS nvarchar(50)
AS
BEGIN
	IF (@internalusername LIKE '%@usc.edu') 
		RETURN REPLACE(@internalusername, '@usc.edu', '')
	ELSE IF (@internalusername LIKE '%@ucsd.edu')
		RETURN cast(cast(REPLACE(@internalusername, '@ucsd.edu', '') as Int) as varchar) + '@ucsd.edu'
	ELSE IF (@internalusername LIKE '%@lbl.gov')
		RETURN REPLACE(@internalusername, '@lbl.gov', '')
	RETURN @internalusername
END


GO

/****** Object:  UserDefinedFunction [UCSF.].[[fn_CleanResearcherType]]    Script Date: 2/22/2018 2:35:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [UCSF.].[fn_CleanResearcherType]
(
	@ResearcherType varchar(255), @ReturnOrder bit
)
RETURNS varchar(255)
AS
BEGIN
	DECLARE @tab TABLE(RankOrder int, ResearcherType  varchar(255))
	DECLARE @RankOrder int
	DECLARE @CleanResearcherType varchar(255)
	INSERT INTO @tab VALUES (1, 'Professor'),(2, 'Assistant Professor'),(3, 'Associate Professor'),(4, 'Instructor'),(5, 'Lecturer'),
							(6, 'Resident/Fellow'),(7, 'Postdoctoral Scholar'),(8, 'Clinical Research Coordinator'),(9, 'Other Academic/Other')

	SELECT @RankOrder = RankOrder, @CleanResearcherType = ResearcherType FROM @tab WHERE ResearcherType = LTRIM(RTRIM(@ResearcherType))
	RETURN CASE WHEN @ReturnOrder = 1 THEN CAST(ISNULL(@RankOrder,9) as varchar(255)) ELSE ISNULL(@CleanResearcherType, 'Other Academic/Other') END
END


GO
---------------------------------------------------------------------------------------------------------------------
--
--	Create Stored Procedures
--
---------------------------------------------------------------------------------------------------------------------

/****** Object:  StoredProcedure [UCSF.].[[CreateNewLogins]]    Script Date: 10/11/2013 10:52:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [UCSF.].[CreateNewLogins] 
AS
BEGIN
	UPDATE [User.Account].[User] set UserName = [UCSF.].fn_InternalUserName2UserName(InternalUserName) where UserName is null and InternalUserName is not null
END

GO

/****** Object:  StoredProcedure [UCSF.].[CreatePrettyURLs]    Script Date: 10/11/2013 10:52:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [UCSF.].[CreatePrettyURLs] 
AS
BEGIN
		
	DECLARE @id nvarchar(50)
	DECLARE @CleanFirst nvarchar(255)
	DECLARE @CleanMiddle nvarchar(255)
	DECLARE @CleanLast nvarchar(255)
	DECLARE @CleanSuffix nvarchar(255)
	DECLARE @CleanGivenName nvarchar(255)
	DECLARE @PrettyURL nvarchar(255)
	DECLARE @Strategy nvarchar(50)
	DECLARE @i int
	DECLARE @BaseDomain nvarchar(255)
	DECLARE @Domain nvarchar(255)

	SELECT @BaseDomain=Value FROM [Framework.].[Parameter] WHERE ParameterID='basePath'
		
	WHILE exists (SELECT *
		FROM [UCSF.].[NameAdditions] WHERE PrettyURL is null)
	BEGIN
		SELECT TOP 1 @id=n.internalusername,
					 @Domain=ISNULL(t.BasePath, @BaseDomain) + '/',
					 @CleanFirst=n.CleanFirst, 
					 @CleanMiddle=n.CleanMiddle,
					 @CleanLast=n.CleanLast,
					 @CleanSuffix=n.CleanSuffix,
 					 @CleanGivenName=n.CleanGivenName
		FROM [UCSF.].[NameAdditions] n JOIN [Profile.Import].[PersonAffiliation] a on n.internalusername=a.internalusername and a.primaryaffiliation=1
			LEFT OUTER JOIN [UCSF.].[InstitutionAdditions] it on it.InstitutionAbbreviation=a.institutionabbreviation -- associate theme to person by instutition 
			LEFT OUTER JOIN [UCSF.].[Theme] t on t.Theme=it.Theme 
			WHERE n.PrettyURL is null ORDER BY len(n.CleanMiddle) + len(n.CleanSuffix)					 

		-- try different strategies
		-- P = preferred first name
		-- I = middle initial
		-- M = middle name
		-- L = last name
		-- S = suffix
		-- G = given first name
		-- N = number
		
		-- for folks who go by their middle name as their preferred name, remove middle name from the strategy.
		-- also do this if it we only have middle initial and it looks like that's what they did
		IF (@CleanFirst = @CleanMiddle) OR 
			(
				(len(@CleanMiddle) = 1 OR (len(@CleanMiddle) = 2 AND charindex('.', @CleanMiddle) = 2)) 
				AND (@CleanFirst <> @CleanGivenName) 
				AND (substring(@CleanMiddle, 1, 1) = substring(@CleanFirst, 1, 1))
			)
			SET @CleanMiddle = ''

		SET @strategy = 'P.L'
		SET @PrettyURL = @Domain + @CleanFirst + '.' + @CleanLast -- first and last
		
		IF exists (SELECT * from [UCSF.].[NameAdditions] WHERE PrettyURL = @PrettyURL) AND len(@CleanMiddle) > 0
		BEGIN
			SET @strategy = 'P.I.L'
			SET @PrettyURL = @Domain + @CleanFirst + '.' + substring(@CleanMiddle,1,1) + '.' + @CleanLast -- middle initial
		END
		IF exists (SELECT * from [UCSF.].[NameAdditions] WHERE PrettyURL = @PrettyURL) AND len(@CleanMiddle) > 0
		BEGIN
			SET @strategy = 'P.M.L'
			SET @PrettyURL = @Domain + @CleanFirst + '.' + @CleanMiddle + '.' + @CleanLast -- middle name
		END
		IF exists (SELECT * from [UCSF.].[NameAdditions] WHERE PrettyURL = @PrettyURL) AND len(@CleanSuffix) > 0
		BEGIN
			SET @strategy = 'P.L.S'
			SET @PrettyURL = @Domain + @CleanFirst + '.' + @CleanLast + '.' + @CleanSuffix -- suffix
		END
		IF exists (SELECT * from [UCSF.].[NameAdditions] WHERE PrettyURL = @PrettyURL) AND len(@CleanMiddle) > 0 AND len(@CleanSuffix) > 0
		BEGIN
			SET @strategy = 'P.I.L.S'
			SET @PrettyURL = @Domain + @CleanFirst + '.' + substring(@CleanMiddle,1,1) + '.' + @CleanLast + '.' + @CleanSuffix-- middle initial and suffix
		END
		IF exists (SELECT * from [UCSF.].[NameAdditions] WHERE PrettyURL = @PrettyURL) AND len(@CleanMiddle) > 0 AND len(@CleanSuffix) > 0
		BEGIN
			SET @strategy = 'P.M.L.S'
			SET @PrettyURL = @Domain + @CleanFirst + '.' + @CleanMiddle + '.' + @CleanLast + '.' + @CleanSuffix -- middle name and suffix
		END
		-- if all else fails, add numbers
		SET @i = 2
		WHILE exists (SELECT * from [UCSF.].[NameAdditions] WHERE PrettyURL = @PrettyURL)
		BEGIN
			SET @strategy = 'P.L.N'
			SET @PrettyURL = @Domain + @CleanFirst + '.' + @CleanLast + '.' + CAST(@i as varchar)			
			SET @i = @i + 1
		END				
		-- it should be unique at this point
		UPDATE [UCSF.].[NameAdditions] SET PrettyURL = @PrettyURL, [Strategy] = @strategy WHERE internalusername = @id
		IF @@Error != 0 
            RETURN
	END

END

GO


/****** Object:  StoredProcedure [UCSF.].[AddProxyByInternalUsername]    Script Date: 10/13/2016 12:34:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [UCSF.].[AddProxyByInternalUsername]
	@proxy varchar(255),
	@user varchar(255)
AS
BEGIN
	DECLARE @UserID int
	DECLARE @ProxyForUserID int
	
	SELECT @UserID = UserID FROM [User.Account].[User] WHERE InternalUserName = @proxy
	SELECT @ProxyForUserID = UserID FROM [User.Account].[User] WHERE InternalUserName = @user

	INSERT INTO [User.Account].DesignatedProxy values (@UserID, @ProxyForUserID)
		
END
GO

/*********** ReadActivityLog from new tables **************************************/
-- Used by SecureAPI
CREATE PROCEDURE [UCSF.].[ReadActivityLog] @methodName nvarchar(255), @afterDT datetime
AS   

IF @methodName is not null
	SELECT p.personid, p.displayname, p.prettyurl, p.emailaddr, l.createdDT, l.methodName, l.param1, l.param2
	  FROM [Framework.].[Log.Activity] l  join [UCSF.].[vwPerson] p on l.personId = p.PersonID
	  where l.methodName = @methodName and l.createdDT >= isnull(@afterDT, '01/01/1970') 
	   order by activityLogId desc;
ELSE
	SELECT p.personid, p.displayname, p.prettyurl, p.emailaddr, l.createdDT, l.methodName, l.param1, l.param2
	  FROM [Framework.].[Log.Activity] l  join [UCSF.].[vwPerson] p on l.personId = p.PersonID
	  where l.createdDT >= isnull(@afterDT, '01/01/1970') 
	   order by activityLogId desc;
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

-- note that for this you also need to alter some existing profiles SPs!
-- look in the VersionUpgrade_2.9.0_2.10.0 folder for details
CREATE VIEW [UCSF.].[vwPublication.Entity.Claimed] AS
  SELECT a.EntityID, a.PersonID, CAST (CASE WHEN p.PubID is not null THEN 1 ELSE 0 END AS BIT) Claimed FROM [Profile.Data].[vwPublication.Entity.Authorship] a 
  JOIN [Profile.Data].[vwPublication.Entity.InformationResource] i ON
  a.InformationResourceID = i.ENtityID left outer join [Profile.Data].[Publication.Person.Add] p ON p.personid = a.personid and p.PMID = i.PMID WHERE i.PMID IS NOT NULL;

GO

---------------------------------------------------------------------------------------------------------------------
--
--	Create [UCSF.CTSASearch] Schema
--
---------------------------------------------------------------------------------------------------------------------
CREATE SCHEMA [UCSF.CTSASearch]
GO

/****** Object:  Table [UCSF.CTSASearch].[Publication.PubMed.Author]    Script Date: 12/16/2015 10:51:55 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [UCSF.CTSASearch].[Publication.PubMed.Author](
	[PmPubsAuthorID] [int] NOT NULL,
	[URI] [varchar](2000) NULL,
	[URL] [varchar](2000) NULL,
PRIMARY KEY CLUSTERED 
(
	[PmPubsAuthorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [UCSF.CTSASearch].[Publication.PubMed.Author]  WITH CHECK ADD FOREIGN KEY([PmPubsAuthorID])
REFERENCES [Profile.Data].[Publication.PubMed.Author] ([PmPubsAuthorID])
ON DELETE CASCADE
GO

/****** Object:  Table [UCSF.CTSASearch].[Publication.PubMed.CoAuthorXML]    Script Date: 12/16/2015 10:52:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [UCSF.CTSASearch].[Publication.PubMed.CoAuthorXML](
	[PMID] [int] NOT NULL,
	[X] [xml] NULL,
	[ParseDT] [datetime] NULL,
	[AuthorXML] [xml] NULL,
PRIMARY KEY CLUSTERED 
(
	[PMID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

/****** Object:  StoredProcedure [UCSF.CTSASearch].[Publication.Pubmed.AddCoAuthorXML]    Script Date: 12/16/2015 10:52:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/****** Object:  StoredProcedure [UCSF.CTSASearch].[Publication.Pubmed.ParseCoAuthorXML]    Script Date: 12/16/2015 10:53:01 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [UCSF.CTSASearch].[Publication.Pubmed.ParseCoAuthorXML]
	@pmid int
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @FirstName VARCHAR(100)
	DECLARE @LastName VARCHAR(100)
	DECLARE @URI VARCHAR(2000)
	DECLARE @PmPubsAuthorID  int
	DECLARE @baseURI varchar(200)
	DECLARE @RowsToProcess   int
	DECLARE @CurrentRow      int
	DECLARE @SelectCol1      int

	SELECT @baseURI = Value FROM [Framework.].[Parameter] WHERE ParameterID = 'baseURI'

	--*** coauthor  links from CTSASearch***
	declare @c as table (
		RowID int not null primary key identity(1,1),
		firstname varchar(100),
		lastname varchar(100),
		uri nvarchar(2000)
	)

	insert into @c (firstName, lastName, uri)
		select 
			nref.value('firstName[1]','varchar(max)') FirstName, 
			nref.value('lastName[1]','varchar(max)') LastName,
			nref.value('uri[1]','varchar(max)') URI
		from [UCSF.CTSASearch].[Publication.PubMed.CoAuthorXML] cross apply x.nodes('//publicationList/publication/authorList/author') as R(nref)
		where pmid = @pmid and X is not null

	SET @RowsToProcess=@@ROWCOUNT

	SET @CurrentRow=0
	WHILE @CurrentRow<@RowsToProcess
	BEGIN
		SET @CurrentRow=@CurrentRow+1
		SELECT 
			@FirstName=firstName, @LastName = lastName, @URI=LTRIM(RTRIM(uri))
			FROM @c
			WHERE RowID=@CurrentRow

		--do your thing here--
		SET @PmPubsAuthorID  = NULL

		-- tight match
		SELECT @PmPubsAuthorID = PmPubsAuthorID FROM [Profile.Data].[Publication.PubMed.Author] 
			WHERE PMID = @pmid AND LastName = @LastName and ForeName = @FirstName 

		-- last name only
		IF (@PmPubsAuthorID IS NULL) 
			SELECT @PmPubsAuthorID = PmPubsAuthorID FROM [Profile.Data].[Publication.PubMed.Author] 
				WHERE PMID = @pmid AND LastName = @LastName 
 
		-- mangled but matching
		IF (@PmPubsAuthorID IS NULL) 
			SELECT @PmPubsAuthorID = PmPubsAuthorID FROM [Profile.Data].[Publication.PubMed.Author] 
				WHERE PMID = @pmid AND (CHARINDEX(LastName, @FirstName + ' ' + @LastName) > 0 OR  CHARINDEX(FirstName, @FirstName + ' ' + @LastName) > 0) 

		-- do not clobber authors that are in our own system, those have been accuratley set by [Profile.Cache].[Publication.PubMed.UpdateAuthorPosition]
		IF (@PmPubsAuthorID IS NOT NULL AND NOT EXISTS (SELECT * FROM [UCSF.CTSASearch].[Publication.PubMed.Author] WHERE 
			PmPubsAuthorID = @PmPubsAuthorID AND URI LIKE @baseURI + '%') ) 
		BEGIN
			DELETE [UCSF.CTSASearch].[Publication.PubMed.Author] WHERE PmPubsAuthorID = @PmPubsAuthorID
			INSERT [UCSF.CTSASearch].[Publication.PubMed.Author] (PmPubsAuthorID, URI, URL) VALUES
				(@PmPubsAuthorID, @URI, [UCSF.CTSASearch].[fn_UrlFromURI](@URI))
		END
	END

	-- authors, both local and those from CTSASearch
	declare @a as table (
		i int identity(0,1) primary key,
		lastname varchar(100),
		initials varchar(20),
		url varchar(2000)
	)

	insert into @a (lastname, initials, url)
		select a.lastname, a.initials, c.url
		from [Profile.Data].[Publication.PubMed.Author] a left outer join [UCSF.CTSASearch].[Publication.PubMed.Author] c on a.PmPubsAuthorID = c.PmPubsAuthorID
		where a.pmid = @pmid
		order by a.PmPubsAuthorID

	--coauthor links, set display xml and build legacy authors list in PubMed general
	DECLARE @CurrentAuthor varchar(200)
	DECLARE @CurrentURL varchar(200)
	DECLARE @VisibleAuthorLen int
	DECLARE @VisibleAuthorXML varchar(max)
	DECLARE @AllAuthorsVisible bit

	SELECT @CurrentRow = min(i) FROM @a
	SELECT @RowsToProcess = max(i) FROM @a
	SET @VisibleAuthorLen = 0
	SET @VisibleAuthorXML = '<authors>'
	SET @AllAuthorsVisible = 1

	WHILE @CurrentRow<=@RowsToProcess
	BEGIN
		SELECT @CurrentAuthor = lastname+' '+initials, @CurrentURL = url 
			FROM @a	WHERE i=@CurrentRow

		SET @CurrentRow=@CurrentRow+1

		-- check size of visible authors, this is based on logic in [Profile.Data].[Publication.Pubmed.ParsePubMedXML]
		IF (coalesce(@CurrentAuthor, '') = '')
			BEGIN
				CONTINUE
			END
		ELSE IF (@VisibleAuthorLen + 2 + len(@CurrentAuthor) < 3990) 
			BEGIN
				SET @VisibleAuthorLen = @VisibleAuthorLen + 2 + len(@CurrentAuthor)
				SET @VisibleAuthorXML = @VisibleAuthorXML + '<author><display>'+@CurrentAuthor+'</display>' + 
						coalesce('<url>'+@CurrentURL+'</url>', '') + '</author>'
			END
		ELSE
			BEGIN
				SET @AllAuthorsVisible = 0
				BREAK
			END
	END
	
	IF (@AllAuthorsVisible = 1) 
		SELECT @AllAuthorsVisible = CASE WHEN AuthorListCompleteYN = 'Y' THEN 1 ELSE 0 END FROM 
			[Profile.Data].[Publication.PubMed.General] WHERE PMID = @pmid

	IF (@AllAuthorsVisible = 1) 
		SET @VisibleAuthorXML = @VisibleAuthorXML + '</authors>'
	ELSE
		SET @VisibleAuthorXML = @VisibleAuthorXML + '<author><display>et al</display></author></authors>'

	-- now set the authorXML
	IF EXISTS (SELECT * FROM [UCSF.CTSASearch].[Publication.PubMed.CoAuthorXML] WHERE pmid = @pmid)
		UPDATE [UCSF.CTSASearch].[Publication.PubMed.CoAuthorXML] set ParseDT = GetDate(), AuthorXML=@VisibleAuthorXML where pmid = @pmid
	ELSE
		INSERT [UCSF.CTSASearch].[Publication.PubMed.CoAuthorXML] (PMID, ParseDT, AuthorXML) VALUES (@pmid, GetDate(),@VisibleAuthorXML)


END

/**************************************
*
*
*
*
*
*
**************************************/

GO



CREATE procedure  [UCSF.CTSASearch].[Publication.Pubmed.AddCoAuthorXML] ( 					 @pmid INT,
																			   @coauthorxml XML)
AS
BEGIN
	SET NOCOUNT ON;	
	 
	-- Parse Load Publication XML
	BEGIN TRY 	 
	
		BEGIN TRAN
			-- Remove existing pmid record
			DELETE FROM [UCSF.CTSASearch].[Publication.PubMed.CoAuthorXML] WHERE pmid = @pmid
		
			-- Add CoAuthor XML	
			INSERT INTO [UCSF.CTSASearch].[Publication.PubMed.CoAuthorXML](pmid,X) VALUES(@pmid,CAST(@coauthorxml AS XML))		
			
			-- Parse CoAuthor XML
			EXEC  [UCSF.CTSASearch].[Publication.Pubmed.ParseCoAuthorXML] 	 @pmid		
		 
		COMMIT
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
		--Check success
		IF @@TRANCOUNT > 0  ROLLBACK
 
		-- Raise an error with the details of the exception
		SELECT @ErrMsg = '[UCSF.CTSASearch].[Publication.Pubmed.AddCoAuthorXML] FAILED WITH : ' + ERROR_MESSAGE() + ' for PMID=' + cast(@pmid as varchar),
					 @ErrSeverity = ERROR_SEVERITY()
 
		RAISERROR(@ErrMsg, @ErrSeverity, 1)
			 
	END CATCH				
END




GO

/****** Object:  StoredProcedure [UCSF.CTSASearch].[Publication.PubMed.GetAllPMIDs]    Script Date: 12/16/2015 10:52:41 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- Stored Procedure

CREATE PROCEDURE [UCSF.CTSASearch].[Publication.PubMed.GetAllPMIDs] (@GetOnlyNewXML BIT=0 )
AS
BEGIN
	SET NOCOUNT ON;	


	BEGIN TRY
		IF @GetOnlyNewXML = 1 
		-- ONLY GET XML FOR NEW Publications
			BEGIN
				--SELECT DISTINCT pmid
				--  FROM  [Profile.Data].[Publication.PubMed.General]
				-- WHERE pmid NOT IN(SELECT PMID FROM [UCSF.CTSASearch].[Publication.PubMed.CoAuthorXML])
				--   AND pmid IS NOT NULL 
				SELECT DISTINCT pmid
				  FROM  [Profile.Data].[Publication.PubMed.General]
				 WHERE pmid IS NOT NULL AND PMID NOT IN (SELECT PMID FROM [UCSF.CTSASearch].[Publication.PubMed.CoAuthorXML] WHERE AuthorXML IS NOT NULL)
			END
		ELSE 
			BEGIN
				SELECT DISTINCT pmid
				  FROM  [Profile.Data].[Publication.PubMed.General]
				 WHERE pmid IS NOT NULL 
			END 
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT
		--Check success
		IF @@TRANCOUNT > 0  ROLLBACK

		-- Raise an error with the details of the exception
		SELECT @ErrMsg = 'FAILED WITH : ' + ERROR_MESSAGE(),
					 @ErrSeverity = ERROR_SEVERITY()

		RAISERROR(@ErrMsg, @ErrSeverity, 1)

	END CATCH				
END


GO


/****** Object:  UserDefinedFunction [UCSF.CTSASearch].[fn_UrlFromURI]    Script Date: 12/16/2015 10:53:32 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [UCSF.CTSASearch].[fn_UrlFromURI]
(
	@s varchar(255)
)
RETURNS varchar(255)
AS
BEGIN
	-- go from  http://vivo.experts.scival.com/indiana/individual/n955 to http://www.experts.scival.com/indiana/expert.asp?u_id=955
	-- and from http://vivo.scholars.northwestern.edu/individual/n4023 to http://www.scholars.northwestern.edu/expert.asp?u_id=4023
	DECLARE @str varchar(255)
	DECLARE @localBaseURI varchar(255)
	SET @str = @s
	SELECT @localBaseURI = Value FROM [Framework.].[Parameter] WHERE ParameterID = 'BaseURI'

 	IF CHARINDEX('vivo.experts.scival.com', @s) > 0 
		SET @str = REPLACE(REPLACE(@s, 'vivo.experts.scival.com', 'www.experts.scival.com'), 'individual/n', 'expert.asp?u_id=')
 	ELSE IF CHARINDEX('vivo.scholars.northwestern.edu', @s) > 0 
		SET @str = REPLACE(REPLACE(@s, 'vivo.scholars.northwestern.edu', 'www.scholars.northwestern.edu'), 'individual/n', 'expert.asp?u_id=')
	ELSE IF CHARINDEX(@localBaseURI, @s) = 1
	BEGIN
		-- Nick, you'll need to add your own logic here!
		SELECT @str = na.prettyurl FROM [UCSF.].[NameAdditions] na JOIN [Profile.Data].[Person] p on 
			na.InternalUserName = p.InternalUserName JOIN [RDF.Stage].[InternalNodeMap] n on n.internalid = p.personId
			and n.[class] = 'http://xmlns.com/foaf/0.1/Person' 
			WHERE n.nodeid = CAST(SUBSTRING(@s, LEN(@localBaseURI) + 1, LEN(@s) - LEN(@localBaseURI)) as bigint)
	END
	RETURN @str

END

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE function [UCSF.CTSASearch].[fnPublication.Pubmed.General2Reference]	(
	@pmid int,
	@ArticleDay varchar(10),
	@ArticleMonth varchar(10),
	@ArticleYear varchar(10),
	@ArticleTitle varchar(4000),
	@Issue varchar(255),
	@JournalDay varchar(50),
	@JournalMonth varchar(50),
	@JournalYear varchar(50),
	@MedlineDate varchar(255),
	@MedlinePgn varchar(255),
	@MedlineTA varchar(1000),
	@Volume varchar(255),
	@encode_html bit=0
)

RETURNS NVARCHAR(MAX) 
AS 
BEGIN

	DECLARE @Reference NVARCHAR(MAX)

	SET @Reference = --(case when right(@Authors,5) = 'et al' then @Authors+'. '
					 --			when @AuthorListCompleteYN = 'N' then @Authors+', et al. '
					 --			when @Authors <> '' then @Authors+'. '
					 --			else '' end) +
					 CASE WHEN @encode_html=1 THEN '<a href="'+'http'+'://www.ncbi.nlm.nih.gov/pubmed/'+cast(@pmid as varchar(50))+'" target="_blank">'+coalesce(@ArticleTitle,'')+'</a>' + ' '
								 ELSE coalesce(@ArticleTitle,'') + ' '
						END
					+ coalesce(@MedlineTA,'') + '. '
					+ (case when @JournalYear is not null then rtrim(@JournalYear + ' ' + coalesce(@JournalMonth,'') + ' ' + coalesce(@JournalDay,''))
							when @MedlineDate is not null then @MedlineDate
							when @ArticleYear is not null then rtrim(@ArticleYear + ' ' + coalesce(@ArticleMonth,'') + ' ' + coalesce(@ArticleDay,''))
						else '' end)
					+ (case when coalesce(@JournalYear,@MedlineDate,@ArticleYear) is not null
								and (coalesce(@Volume,'')+coalesce(@Issue,'')+coalesce(@MedlinePgn,'') <> '')
							then '; ' else '' end)
					+ coalesce(@Volume,'')
					+ (case when coalesce(@Issue,'') <> '' then '('+@Issue+')' else '' end)
					+ (case when (coalesce(@MedlinePgn,'') <> '') and (coalesce(@Volume,'')+coalesce(@Issue,'') <> '') then ':' else '' end)
					+ coalesce(@MedlinePgn,'')
					+ '.'

	RETURN @Reference

END

GO


---------------------------------------------------------------------------------------------------------------------
--
--	[ORNG.] sp's that are good for 
--
---------------------------------------------------------------------------------------------------------------------

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER TABLE [ORNG.].[Apps]	ADD  InstitutionID int NULL
GO

ALTER TABLE [ORNG.].[Apps]  WITH CHECK ADD  CONSTRAINT [FK_orng_apps_institution] FOREIGN KEY([InstitutionID])
REFERENCES [Profile.Data].[Organization.Institution] ([InstitutionID])
GO

ALTER TABLE [ORNG.].[Apps] CHECK CONSTRAINT [FK_orng_apps_institution]
GO

---------------------------------------------------------------------------------------------------------------------
--
--	Alter and create ProfilesRNS Schema objects
--
---------------------------------------------------------------------------------------------------------------------
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER TABLE [Profile.Data].[Publication.Entity.InformationResource]	ADD  Authors varchar(4000) NULL
GO

ALTER TABLE [Profile.Data].[Publication.PubMed.DisambiguationAffiliation] ADD InstitutionID int NULL
GO

ALTER TABLE [Profile.Data].[Publication.PubMed.DisambiguationAffiliation]  WITH CHECK ADD  CONSTRAINT [FK_pubmed_disambiguation_affiliation_institution] FOREIGN KEY([InstitutionID])
REFERENCES [Profile.Data].[Organization.Institution] ([InstitutionID])
GO


ALTER TABLE [User.Session].[Session] ADD DisplayName varchar(255) NULL
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER procedure [Profile.Cache].[Publication.PubMed.UpdateAuthorPosition]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
 
	  /* 
		drop table cache_pm_author_position
		create table dbo.cache_pm_author_position (
			PersonID int not null,
			pmid int not null,
			AuthorPosition char(1),
			AuthorWeight float,
			PubDate datetime,
			PubYear int,
			YearWeight float
		)
		alter table cache_pm_author_position add primary key (PersonID, pmid)
	*/
 
	DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int,@proc VARCHAR(200),@date DATETIME,@auditid UNIQUEIDENTIFIER,@rows BIGINT 
	SELECT @proc = OBJECT_NAME(@@PROCID),@date=GETDATE() 	
	EXEC [Profile.Cache].[Process.AddAuditUpdate] @auditid=@auditid OUTPUT,@ProcessName =@proc,@ProcessStartDate=@date,@insert_new_record=1
 
	select distinct i.pmid, p.personid, p.lastname, p.firstname, '' middlename,
			left(p.lastname,1) ln, left(p.firstname,1) fn, left('',1) mn
		into #pmid_person_name
		from [Profile.Data].[Publication.Person.Include] i, [Profile.Cache].Person p
		where i.personid = p.personid and i.pmid is not null
	create unique clustered index idx_pu on #pmid_person_name(pmid,personid)
 
	select distinct pmid, personid, pmpubsauthorid
		into #authorid_personid
		from (
			select a.pmid, a.PmPubsAuthorID, p.personid, dense_rank() over (partition by a.pmid, p.personid order by 
				(case when a.lastname = p.lastname and (a.forename like p.firstname + left(p.middlename,1) + '%') then 1
					when a.lastname = p.lastname and (a.forename like p.firstname + '%') and len(p.firstname) > 1 then 2
					when a.lastname = p.lastname and a.initials = p.fn+p.mn then 3
					when a.lastname = p.lastname and left(a.initials,1) = p.fn then 4
					when a.lastname = p.lastname then 5
					else 6 end) ) k
			from [Profile.Data].[Publication.PubMed.Author] a inner join #pmid_person_name p 
				on a.pmid = p.pmid and a.validyn = 'Y' and left(a.lastname,1) = p.ln
		) t
		where k = 1
	create unique clustered index idx_ap on #authorid_personid(pmid, personid, pmpubsauthorid)

	DECLARE @baseURI varchar(200)
	SELECT @baseURI = Value FROM [Framework.].[Parameter] WHERE ParameterID = 'baseURI'
 
	-- set coauthor links for local authors
	-- add new ones first
	INSERT [UCSF.CTSASearch].[Publication.PubMed.Author] (PmPubsAuthorID) 
		SELECT DISTINCT pmpubsauthorid FROM #authorid_personid WHERE PmPubsAuthorID NOT IN (SELECT PmPubsAuthorID FROM [UCSF.CTSASearch].[Publication.PubMed.Author] )

	-- this is currenlty specific to UCSF "pretty names". To make generic, just set the URL to the same value as the URI, or for those 
	-- that use URL's of the form ../profile/name something else can be done 
	UPDATE a set a.URI = @baseURI + cast(n.nodeid as varchar), a.URL = na.PrettyURL 
		from [UCSF.CTSASearch].[Publication.PubMed.Author] a join #authorid_personid p on a.PmPubsAuthorID = p.pmpubsauthorid
			join [RDF.Stage].internalnodemap n on n.internalid = p.personId
			and n.[class] = 'http://xmlns.com/foaf/0.1/Person' join
			[Profile.Data].[Person] per on per.personID = p.personID join [UCSF.].[NameAdditions] na on
			na.INternalUserName = per.InternalUserName;

	select pmid, min(pmpubsauthorid) a, max(pmpubsauthorid) b, count(*) numberOfAuthors
		into #pmid_authorid_range
		from [Profile.Data].[Publication.PubMed.Author]
		group by pmid
	create unique clustered index idx_p on #pmid_authorid_range(pmid)
 
	select PersonID, pmid, a AuthorPosition, 
			(case when a in ('F','L','S') then 1.00
				when a in ('M') then 0.25
				else 0.50 end) AuthorWeight,
			pmpubsauthorid,
			cast(null as int) authorRank,
			cast(null as int) numberOfAuthors,
			cast(null as varchar(255)) authorNameAsListed
		into #cache_author_position
		from (
			select pmid, personid, a, pmpubsauthorid, row_number() over (partition by pmid, personid order by k, pmpubsauthorid) k
			from (
				select a.pmid, a.personid,
						(case when a.pmpubsauthorid = r.a then 'F'
							when a.pmpubsauthorid = r.b then 'L'
							else 'M'
							end) a,
						(case when a.pmpubsauthorid = r.a then 1
							when a.pmpubsauthorid = r.b then 2
							else 3
							end) k,
						a.pmpubsauthorid
					from #authorid_personid a, #pmid_authorid_range r
					where a.pmid = r.pmid and r.b <> r.a
				union all
				select p.pmid, p.personid, 'S' a, 0 k, r.a pmpubsauthorid
					from #pmid_person_name p, #pmid_authorid_range r
					where p.pmid = r.pmid and r.a = r.b
				union all
				select pmid, personid, 'U' a, 9 k, null pmpubsauthorid
					from #pmid_person_name
			) t
		) t
		where k = 1
	create clustered index idx_pmid on #cache_author_position(pmid)
	create nonclustered index idx_pmpubsauthorid on #cache_author_position(pmpubsauthorid)
 
	update a
		set a.numberOfAuthors = r.numberOfAuthors
		from #cache_author_position a, #pmid_authorid_range r
		where a.pmid = r.pmid
 
	select pmpubsauthorid, 
			isnull(LastName,'') 
			+ (case when isnull(LastName,'')<>'' and (isnull(ForeName,'')+isnull(Suffix,''))<>'' then ', ' else '' end)
			+ isnull(ForeName,'')
			+ (case when isnull(ForeName,'')<>'' and isnull(Suffix,'')<>'' then ' ' else '' end)
			+ isnull(Suffix,'') authorNameAsListed,
			row_number() over (partition by pmid order by pmpubsauthorid) authorRank
		into #pmpubsauthorid_authorRank
		from [Profile.Data].[Publication.PubMed.Author]
	create unique clustered index idx_p on #pmpubsauthorid_authorRank(pmpubsauthorid)
 
	update a
		set a.authorRank = r.authorRank, a.authorNameAsListed = r.authorNameAsListed
		from #cache_author_position a, #pmpubsauthorid_authorRank r
		where a.pmpubsauthorid = r.pmpubsauthorid
 
	select PersonID, a.pmid, AuthorPosition, AuthorWeight, g.PubDate, year(g.PubDate) PubYear,
			(case when g.PubDate = '1900-01-01 00:00:00.000' then 0.5
				else power(cast(0.5 as float),cast(datediff(d,g.PubDate,GetDate()) as float)/365.25/10)
				end) YearWeight,
			authorRank, numberOfAuthors, authorNameAsListed
		into #cache_pm_author_position
		from #cache_author_position a, [Profile.Data].[Publication.PubMed.General] g
		where a.pmid = g.pmid
	update #cache_pm_author_position
		set PubYear = Year(GetDate()), YearWeight = 1
		where YearWeight > 1
 
	BEGIN TRY
		BEGIN TRAN
			TRUNCATE TABLE [Profile.Cache].[Publication.PubMed.AuthorPosition]
			INSERT INTO [Profile.Cache].[Publication.PubMed.AuthorPosition] (PersonID, pmid, AuthorPosition, AuthorWeight, PubDate, PubYear, YearWeight, authorRank, numberOfAuthors, authorNameAsListed)
				SELECT PersonID, pmid, AuthorPosition, AuthorWeight, PubDate, PubYear, YearWeight, authorRank, numberOfAuthors, authorNameAsListed
				FROM #cache_pm_author_position
			SELECT @rows = @@ROWCOUNT
		COMMIT
	END TRY
	BEGIN CATCH
		--Check success
		IF @@TRANCOUNT > 0  ROLLBACK
		SELECT @date=GETDATE()
		EXEC [Profile.Cache].[Process.AddAuditUpdate] @auditid=@auditid OUTPUT,@ProcessName =@proc,@ProcessEndDate =@date,@error = 1,@insert_new_record=0
		--Raise an error with the details of the exception
		SELECT @ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY()
		RAISERROR(@ErrMsg, @ErrSeverity, 1)
	END CATCH
 
	SELECT @date=GETDATE()
	EXEC [Profile.Cache].[Process.AddAuditUpdate] @auditid=@auditid OUTPUT,@ProcessName =@proc,@ProcessEndDate =@date,@ProcessedRows = @rows,@insert_new_record=0
 
END





GO



/****** Object:  StoredProcedure [Profile.Data].[Publication.Entity.UpdateEntity]    Script Date: 12/16/2015 10:46:54 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [Profile.Data].[Publication.Entity.UpdateEntity]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 
	-- *******************************************************************
	-- *******************************************************************
	-- Update InformationResource entities
	-- *******************************************************************
	-- *******************************************************************
 
 
	----------------------------------------------------------------------
	-- Get a list of current publications
	----------------------------------------------------------------------

	CREATE TABLE #Publications
	(
		PMID INT NULL ,
		MPID NVARCHAR(50) NULL ,
		PMCID NVARCHAR(55) NULL,
		EntityDate DATETIME NULL ,
		Reference VARCHAR(MAX) NULL ,
		Source VARCHAR(25) NULL ,
		URL VARCHAR(1000) NULL ,
		Title VARCHAR(4000) NULL ,
		Authors VARCHAR(4000) NULL,
		EntityID INT NULL
	)
 
	-- Add PMIDs to the publications temp table
	INSERT  INTO #Publications
            ( PMID ,
			  PMCID,
              EntityDate ,
              Reference ,
              Source ,
              URL ,
              Title,
			  Authors
            )
            SELECT -- Get Pub Med pubs
                    PG.PMID ,
					PG.PMCID,
                    EntityDate = PG.PubDate,
                    Reference = REPLACE([UCSF.CTSASearch].[fnPublication.Pubmed.General2Reference](PG.PMID,
                                                              PG.ArticleDay,
                                                              PG.ArticleMonth,
                                                              PG.ArticleYear,
                                                              PG.ArticleTitle,
                                                              PG.Issue,
                                                              PG.JournalDay,
                                                              PG.JournalMonth,
                                                              PG.JournalYear,
                                                              PG.MedlineDate,
                                                              PG.MedlinePgn,
                                                              PG.MedlineTA,
                                                              PG.Volume, 0),
                                        CHAR(11), '') ,
                    Source = 'PubMed',
                    URL = 'http://www.ncbi.nlm.nih.gov/pubmed/' + CAST(ISNULL(PG.pmid, '') AS VARCHAR(20)),
                    Title = left((case when IsNull(PG.ArticleTitle,'') <> '' then PG.ArticleTitle else 'Untitled Publication' end),4000),
					Authors = PG.Authors
            FROM    [Profile.Data].[Publication.PubMed.General] PG
			WHERE	PG.PMID IN (
						SELECT PMID 
						FROM [Profile.Data].[Publication.Person.Include]
						WHERE PMID IS NOT NULL )
 
	-- Add MPIDs to the publications temp table
	INSERT  INTO #Publications
            ( MPID ,
              EntityDate ,
			  Reference ,
			  Source ,
              URL ,
              Title ,
			  Authors
            )
            SELECT  MPID ,
                    EntityDate ,
                    Reference = REPLACE((CASE WHEN IsNull(article,'') <> '' THEN article + '. ' ELSE '' END)
										+ (CASE WHEN IsNull(pub,'') <> '' THEN pub + '. ' ELSE '' END)
										+ y
                                        + CASE WHEN y <> ''
                                                    AND vip <> '' THEN '; '
                                               ELSE ''
                                          END + vip
                                        + CASE WHEN y <> ''
                                                    OR vip <> '' THEN '.'
                                               ELSE ''
                                          END, CHAR(11), '') ,
                    Source = 'Custom' ,
                    URL = url,
                    Title = left((case when IsNull(article,'')<>'' then article when IsNull(pub,'')<>'' then pub else 'Untitled Publication' end),4000),
					Authors = authors
            FROM    ( SELECT    MPID ,
                                EntityDate ,
                                url ,
                                authors = CASE WHEN authors = '' THEN ''
                                               WHEN RIGHT(authors, 1) = '.'
                                               THEN LEFT(authors,
                                                         LEN(authors) - 1)
                                               ELSE authors
                                          END ,
                                article = CASE WHEN article = '' THEN ''
                                               WHEN RIGHT(article, 1) = '.'
                                               THEN LEFT(article,
                                                         LEN(article) - 1)
                                               ELSE article
                                          END ,
                                pub = CASE WHEN pub = '' THEN ''
                                           WHEN RIGHT(pub, 1) = '.'
                                           THEN LEFT(pub, LEN(pub) - 1)
                                           ELSE pub
                                      END ,
                                y ,
                                vip
                      FROM      ( SELECT    MPG.mpid ,
                                            EntityDate = MPG.publicationdt ,
                                            authors = CASE WHEN RTRIM(LTRIM(COALESCE(MPG.authors,
                                                              ''))) = ''
                                                           THEN ''
                                                           WHEN RIGHT(COALESCE(MPG.authors,
                                                              ''), 1) = '.'
                                                            THEN  COALESCE(MPG.authors,
                                                              '') + ' '
                                                           ELSE COALESCE(MPG.authors,
                                                              '') + '. '
                                                      END ,
                                            url = CASE WHEN COALESCE(MPG.url,
                                                              '') <> ''
                                                            AND LEFT(COALESCE(MPG.url,
                                                              ''), 4) = 'http'
                                                       THEN MPG.url
                                                       WHEN COALESCE(MPG.url,
                                                              '') <> ''
                                                       THEN 'http://' + MPG.url
                                                       ELSE ''
                                                  END ,
                                            article = LTRIM(RTRIM(COALESCE(MPG.articletitle,
                                                              ''))) ,
                                            pub = LTRIM(RTRIM(COALESCE(MPG.pubtitle,
                                                              ''))) ,
                                            y = CASE WHEN MPG.publicationdt > '1/1/1901'
                                                     THEN CONVERT(VARCHAR(50), YEAR(MPG.publicationdt))
                                                     ELSE ''
                                                END ,
                                            vip = COALESCE(MPG.volnum, '')
                                            + CASE WHEN COALESCE(MPG.issuepub,
                                                              '') <> ''
                                                   THEN '(' + MPG.issuepub
                                                        + ')'
                                                   ELSE ''
                                              END
                                            + CASE WHEN ( COALESCE(MPG.paginationpub,
                                                              '') <> '' )
                                                        AND ( COALESCE(MPG.volnum,
                                                              '')
                                                              + COALESCE(MPG.issuepub,
                                                              '') <> '' )
                                                   THEN ':'
                                                   ELSE ''
                                              END + COALESCE(MPG.paginationpub,
                                                             '')
                                  FROM      [Profile.Data].[Publication.MyPub.General] MPG
                                  INNER JOIN [Profile.Data].[Publication.Person.Include] PL ON MPG.mpid = PL.mpid
                                                           AND PL.mpid NOT LIKE 'DASH%'
                                                           AND PL.mpid NOT LIKE 'ISI%'
                                                           AND PL.pmid IS NULL
                                ) T0
                    ) T0
 
	CREATE NONCLUSTERED INDEX idx_pmid on #publications(pmid)
	CREATE NONCLUSTERED INDEX idx_mpid on #publications(mpid)

	----------------------------------------------------------------------
	-- Update the Publication.Entity.InformationResource table
	----------------------------------------------------------------------

	-- Determine which publications already exist
	UPDATE p
		SET p.EntityID = e.EntityID
		FROM #publications p, [Profile.Data].[Publication.Entity.InformationResource] e
		WHERE p.PMID = e.PMID and p.PMID is not null
	UPDATE p
		SET p.EntityID = e.EntityID
		FROM #publications p, [Profile.Data].[Publication.Entity.InformationResource] e
		WHERE p.MPID = e.MPID and p.MPID is not null
	CREATE NONCLUSTERED INDEX idx_entityid on #publications(EntityID)

	-- Deactivate old publications
	UPDATE e
		SET e.IsActive = 0
		FROM [Profile.Data].[Publication.Entity.InformationResource] e
		WHERE e.EntityID NOT IN (SELECT EntityID FROM #publications)

	-- Update the data for existing publications
	UPDATE e
		SET e.EntityDate = p.EntityDate,
			e.pmcid = p.pmcid,
			e.Reference = p.Reference,
			e.Source = p.Source,
			e.URL = p.URL,
			e.EntityName = p.Title,
			e.IsActive = 1,
			e.PubYear = year(p.EntityDate),
            e.YearWeight = (case when p.EntityDate is null then 0.5
                when year(p.EntityDate) <= 1901 then 0.5
                else power(cast(0.5 as float),cast(datediff(d,p.EntityDate,GetDate()) as float)/365.25/10)
                end),
			e.Authors = p.Authors
		FROM #publications p, [Profile.Data].[Publication.Entity.InformationResource] e
		WHERE p.EntityID = e.EntityID and p.EntityID is not null

	-- Insert new publications
	INSERT INTO [Profile.Data].[Publication.Entity.InformationResource] (
			PMID,
			PMCID,
			MPID,
			EntityName,
			EntityDate,
			Reference,
			Source,
			URL,
			IsActive,
			PubYear,
			YearWeight,
			Authors
		)
		SELECT 	PMID,
				PMCID,
				MPID,
				Title,
				EntityDate,
				Reference,
				Source,
				URL,
				1 IsActive,
				PubYear = year(EntityDate),
				YearWeight = (case when EntityDate is null then 0.5
								when year(EntityDate) <= 1901 then 0.5
								else power(cast(0.5 as float),cast(datediff(d,EntityDate,GetDate()) as float)/365.25/10)
								end),
				Authors
		FROM #publications
		WHERE EntityID IS NULL

 
	-- *******************************************************************
	-- *******************************************************************
	-- Update Authorship entities
	-- *******************************************************************
	-- *******************************************************************
 
 	----------------------------------------------------------------------
	-- Get a list of current Authorship records
	----------------------------------------------------------------------

	CREATE TABLE #Authorship
	(
		EntityDate DATETIME NULL ,
		authorRank INT NULL,
		numberOfAuthors INT NULL,
		authorNameAsListed VARCHAR(255) NULL,
		AuthorWeight FLOAT NULL,
		AuthorPosition VARCHAR(1) NULL,
		PubYear INT NULL ,
		YearWeight FLOAT NULL ,
		PersonID INT NULL ,
		InformationResourceID INT NULL,
		PMID INT NULL,
		IsActive BIT,
		EntityID INT
	)
 
	INSERT INTO #Authorship (EntityDate, PersonID, InformationResourceID, PMID, IsActive)
		SELECT e.EntityDate, i.PersonID, e.EntityID, e.PMID, 1 IsActive
			FROM [Profile.Data].[Publication.Entity.InformationResource] e,
				[Profile.Data].[Publication.Person.Include] i
			WHERE e.PMID = i.PMID and e.PMID is not null
	INSERT INTO #Authorship (EntityDate, PersonID, InformationResourceID, PMID, IsActive)
		SELECT e.EntityDate, i.PersonID, e.EntityID, null PMID, 1 IsActive
			FROM [Profile.Data].[Publication.Entity.InformationResource] e,
				[Profile.Data].[Publication.Person.Include] i
			WHERE (e.MPID = i.MPID) and (e.MPID is not null) and (e.PMID is null)
	CREATE NONCLUSTERED INDEX idx_person_pmid ON #Authorship(PersonID, PMID)
	CREATE NONCLUSTERED INDEX idx_person_pub ON #Authorship(PersonID, InformationResourceID)

	UPDATE a
		SET	a.authorRank=p.authorRank,
			a.numberOfAuthors=p.numberOfAuthors,
			a.authorNameAsListed=p.authorNameAsListed, 
			a.AuthorWeight=p.AuthorWeight, 
			a.AuthorPosition=p.AuthorPosition,
			a.PubYear=p.PubYear,
			a.YearWeight=p.YearWeight
		FROM #Authorship a, [Profile.Cache].[Publication.PubMed.AuthorPosition]  p
		WHERE a.PersonID = p.PersonID and a.PMID = p.PMID and a.PMID is not null
	UPDATE #authorship
		SET authorWeight = 0.5
		WHERE authorWeight IS NULL
	UPDATE #authorship
		SET authorPosition = 'U'
		WHERE authorPosition IS NULL
	UPDATE #authorship
		SET PubYear = year(EntityDate)
		WHERE PubYear IS NULL
	UPDATE #authorship
		SET	YearWeight = (case when EntityDate is null then 0.5
							when year(EntityDate) <= 1901 then 0.5
							else power(cast(0.5 as float),cast(datediff(d,EntityDate,GetDate()) as float)/365.25/10)
							end)
		WHERE YearWeight IS NULL

	----------------------------------------------------------------------
	-- Update the Publication.Authorship table
	----------------------------------------------------------------------

	-- Determine which authorships already exist
	UPDATE a
		SET a.EntityID = e.EntityID
		FROM #authorship a, [Profile.Data].[Publication.Entity.Authorship] e
		WHERE a.PersonID = e.PersonID and a.InformationResourceID = e.InformationResourceID
 	CREATE NONCLUSTERED INDEX idx_entityid on #authorship(EntityID)

	-- Deactivate old authorships
	UPDATE a
		SET a.IsActive = 0
		FROM [Profile.Data].[Publication.Entity.Authorship] a
		WHERE a.EntityID NOT IN (SELECT EntityID FROM #authorship)

	-- Update the data for existing authorships
	UPDATE e
		SET e.EntityDate = a.EntityDate,
			e.authorRank = a.authorRank,
			e.numberOfAuthors = a.numberOfAuthors,
			e.authorNameAsListed = a.authorNameAsListed,
			e.authorWeight = a.authorWeight,
			e.authorPosition = a.authorPosition,
			e.PubYear = a.PubYear,
			e.YearWeight = a.YearWeight,
			e.IsActive = 1
		FROM #authorship a, [Profile.Data].[Publication.Entity.Authorship] e
		WHERE a.EntityID = e.EntityID and a.EntityID is not null

	-- Insert new Authorships
	INSERT INTO [Profile.Data].[Publication.Entity.Authorship] (
			EntityDate,
			authorRank,
			numberOfAuthors,
			authorNameAsListed,
			authorWeight,
			authorPosition,
			PubYear,
			YearWeight,
			PersonID,
			InformationResourceID,
			IsActive
		)
		SELECT 	EntityDate,
				authorRank,
				numberOfAuthors,
				authorNameAsListed,
				authorWeight,
				authorPosition,
				PubYear,
				YearWeight,
				PersonID,
				InformationResourceID,
				IsActive
		FROM #authorship a
		WHERE EntityID IS NULL

	-- Assign an EntityName
	UPDATE [Profile.Data].[Publication.Entity.Authorship]
		SET EntityName = 'Authorship ' + CAST(EntityID as VARCHAR(50))
		WHERE EntityName is null
 
END





GO


/****** Object:  StoredProcedure [Profile.Data].[Publication.Entity.UpdateEntityOnePerson]    Script Date: 12/16/2015 10:47:19 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [Profile.Data].[Publication.Entity.UpdateEntityOnePerson]
	@PersonID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 
	-- *******************************************************************
	-- *******************************************************************
	-- Update InformationResource entities
	-- *******************************************************************
	-- *******************************************************************
 
 
	----------------------------------------------------------------------
	-- Get a list of current publications
	----------------------------------------------------------------------
 
	CREATE TABLE #Publications
	(
		PMID INT NULL ,
		MPID NVARCHAR(50) NULL ,
		PMCID NVARCHAR(55) NULL,
		EntityDate DATETIME NULL ,
		Reference VARCHAR(MAX) NULL ,
		Source VARCHAR(25) NULL ,
		URL VARCHAR(1000) NULL ,
		Title VARCHAR(4000) NULL ,
		Authors VARCHAR(4000) NULL
	)
 
	-- Add PMIDs to the publications temp table
	INSERT  INTO #Publications
            ( PMID ,
			  PMCID,
              EntityDate ,
              Reference ,
              Source ,
              URL ,
              Title ,
			  Authors
            )
            SELECT -- Get Pub Med pubs
                    PG.PMID ,
					PG.PMCID,
                    EntityDate = PG.PubDate,
                    Reference = REPLACE([UCSF.CTSASearch].[fnPublication.Pubmed.General2Reference](PG.PMID,
                                                              PG.ArticleDay,
                                                              PG.ArticleMonth,
                                                              PG.ArticleYear,
                                                              PG.ArticleTitle,
                                                              PG.Issue,
                                                              PG.JournalDay,
                                                              PG.JournalMonth,
                                                              PG.JournalYear,
                                                              PG.MedlineDate,
                                                              PG.MedlinePgn,
                                                              PG.MedlineTA,
                                                              PG.Volume, 0),
                                        CHAR(11), '') ,
                    Source = 'PubMed',
                    URL = 'http://www.ncbi.nlm.nih.gov/pubmed/' + CAST(ISNULL(PG.pmid, '') AS VARCHAR(20)),
                    Title = left((case when IsNull(PG.ArticleTitle,'') <> '' then PG.ArticleTitle else 'Untitled Publication' end),4000),
					Authors = PG.Authors
            FROM    [Profile.Data].[Publication.PubMed.General] PG
			WHERE	PG.PMID IN (
						SELECT PMID 
						FROM [Profile.Data].[Publication.Person.Include]
						WHERE PMID IS NOT NULL AND PersonID = @PersonID
					)
					AND PG.PMID NOT IN (
						SELECT PMID
						FROM [Profile.Data].[Publication.Entity.InformationResource]
						WHERE PMID IS NOT NULL
					)
 
	-- Add MPIDs to the publications temp table
	INSERT  INTO #Publications
            ( MPID ,
              EntityDate ,
			  Reference ,
			  Source ,
              URL ,
              Title ,
			  Authors
            )
            SELECT  MPID ,
                    EntityDate ,
 
 
                     Reference = REPLACE((CASE WHEN IsNull(article,'') <> '' THEN article + '. ' ELSE '' END)
										+ (CASE WHEN IsNull(pub,'') <> '' THEN pub + '. ' ELSE '' END)
										+ y
                                        + CASE WHEN y <> ''
                                                    AND vip <> '' THEN '; '
                                               ELSE ''
                                          END + vip
                                        + CASE WHEN y <> ''
                                                    OR vip <> '' THEN '.'
                                               ELSE ''
                                          END, CHAR(11), '') ,
                    Source = 'Custom' ,
                    URL = url,
                    Title = left((case when IsNull(article,'')<>'' then article when IsNull(pub,'')<>'' then pub else 'Untitled Publication' end),4000),
					Authors = authors 
            FROM    ( SELECT    MPID ,
                                EntityDate ,
                                url ,
                                authors = CASE WHEN authors = '' THEN ''
                                               WHEN RIGHT(authors, 1) = '.'
                                               THEN LEFT(authors,
                                                         LEN(authors) - 1)
                                               ELSE authors
                                          END ,
                                article = CASE WHEN article = '' THEN ''
                                               WHEN RIGHT(article, 1) = '.'
                                               THEN LEFT(article,
                                                         LEN(article) - 1)
                                               ELSE article
                                          END ,
                                pub = CASE WHEN pub = '' THEN ''
                                           WHEN RIGHT(pub, 1) = '.'
                                           THEN LEFT(pub, LEN(pub) - 1)
                                           ELSE pub
                                      END ,
                                y ,
                                vip
                      FROM      ( SELECT    MPG.mpid ,
                                            EntityDate = MPG.publicationdt ,
                                            authors = CASE WHEN RTRIM(LTRIM(COALESCE(MPG.authors,
                                                              ''))) = ''
                                                           THEN ''
                                                           WHEN RIGHT(COALESCE(MPG.authors,
                                                              ''), 1) = '.'
                                                            THEN  COALESCE(MPG.authors,
                                                              '') + ' '
                                                           ELSE COALESCE(MPG.authors,
                                                              '') + '. '
                                                      END ,
                                            url = CASE WHEN COALESCE(MPG.url,
                                                              '') <> ''
                                                            AND LEFT(COALESCE(MPG.url,
                                                              ''), 4) = 'http'
                                                       THEN MPG.url
                                                       WHEN COALESCE(MPG.url,
                                                              '') <> ''
                                                       THEN 'http://' + MPG.url
                                                       ELSE ''
                                                  END ,
                                            article = LTRIM(RTRIM(COALESCE(MPG.articletitle,
                                                              ''))) ,
                                            pub = LTRIM(RTRIM(COALESCE(MPG.pubtitle,
                                                              ''))) ,
                                            y = CASE WHEN MPG.publicationdt > '1/1/1901'
                                                     THEN CONVERT(VARCHAR(50), YEAR(MPG.publicationdt))
                                                     ELSE ''
                                                END ,
                                            vip = COALESCE(MPG.volnum, '')
                                            + CASE WHEN COALESCE(MPG.issuepub,
                                                              '') <> ''
                                                   THEN '(' + MPG.issuepub
                                                        + ')'
                                                   ELSE ''
                                              END
                                            + CASE WHEN ( COALESCE(MPG.paginationpub,
                                                              '') <> '' )
                                                        AND ( COALESCE(MPG.volnum,
                                                              '')
                                                              + COALESCE(MPG.issuepub,
                                                              '') <> '' )
                                                   THEN ':'
                                                   ELSE ''
                                              END + COALESCE(MPG.paginationpub,
                                                             '')
                                  FROM      [Profile.Data].[Publication.MyPub.General] MPG
                                  INNER JOIN [Profile.Data].[Publication.Person.Include] PL ON MPG.mpid = PL.mpid
                                                           AND PL.mpid NOT LIKE 'DASH%'
                                                           AND PL.mpid NOT LIKE 'ISI%'
                                                           AND PL.pmid IS NULL
                                                           AND PL.PersonID = @PersonID
									WHERE MPG.MPID NOT IN (
										SELECT MPID
										FROM [Profile.Data].[Publication.Entity.InformationResource]
										WHERE (MPID IS NOT NULL)
									)
                                ) T0
                    ) T0
 
	CREATE NONCLUSTERED INDEX idx_pmid on #publications(pmid)
	CREATE NONCLUSTERED INDEX idx_mpid on #publications(mpid)

	----------------------------------------------------------------------
	-- Update the Publication.Entity.InformationResource table
	----------------------------------------------------------------------
 
	-- Insert new publications
	INSERT INTO [Profile.Data].[Publication.Entity.InformationResource] (
			PMID,
			PMCID,
			MPID,
			EntityName,
			EntityDate,
			Reference,
			Source,
			URL,
			IsActive, 
			Authors
		)
		SELECT 	PMID,
				PMCID,
				MPID,
				Title,
				EntityDate,
				Reference,
				Source,
				URL,
				1 IsActive,
				Authors
		FROM #publications
	-- Assign an EntityName, PubYear, and YearWeight
	UPDATE e
		SET --e.EntityName = 'Publication ' + CAST(e.EntityID as VARCHAR(50)),
			e.PubYear = year(e.EntityDate),
			e.YearWeight = (case when e.EntityDate is null then 0.5
							when year(e.EntityDate) <= 1901 then 0.5
							else power(cast(0.5 as float),cast(datediff(d,e.EntityDate,GetDate()) as float)/365.25/10)
							end),
			e.Reference = p.Reference,
			e.Authors = p.Authors
		FROM [Profile.Data].[Publication.Entity.InformationResource] e,
			#publications p
		WHERE ((e.PMID = p.PMID) OR (e.MPID = p.MPID))
 
	-- *******************************************************************
	-- *******************************************************************
	-- Update Authorship entities
	-- *******************************************************************
	-- *******************************************************************
 
 	----------------------------------------------------------------------
	-- Get a list of current Authorship records
	----------------------------------------------------------------------

	CREATE TABLE #Authorship
	(
		EntityDate DATETIME NULL ,
		authorRank INT NULL,
		numberOfAuthors INT NULL,
		authorNameAsListed VARCHAR(255) NULL,
		AuthorWeight FLOAT NULL,
		AuthorPosition VARCHAR(1) NULL,
		PubYear INT NULL ,
		YearWeight FLOAT NULL ,
		PersonID INT NULL ,
		InformationResourceID INT NULL,
		PMID INT NULL,
		IsActive BIT
	)
 
	INSERT INTO #Authorship (EntityDate, PersonID, InformationResourceID, PMID, IsActive)
		SELECT e.EntityDate, i.PersonID, e.EntityID, e.PMID, 1 IsActive
			FROM [Profile.Data].[Publication.Entity.InformationResource] e,
				[Profile.Data].[Publication.Person.Include] i
			WHERE (e.PMID = i.PMID) and (e.PMID is not null) and (i.PersonID = @PersonID)
	INSERT INTO #Authorship (EntityDate, PersonID, InformationResourceID, PMID, IsActive)
		SELECT e.EntityDate, i.PersonID, e.EntityID, null PMID, 1 IsActive
			FROM [Profile.Data].[Publication.Entity.InformationResource] e,
				[Profile.Data].[Publication.Person.Include] i
			WHERE (e.MPID = i.MPID) and (e.MPID is not null) and (e.PMID is null) and (i.PersonID = @PersonID)
	CREATE NONCLUSTERED INDEX idx_person_pmid ON #Authorship(PersonID, PMID)
	CREATE NONCLUSTERED INDEX idx_person_pub ON #Authorship(PersonID, InformationResourceID)
 
	UPDATE a
		SET	a.authorRank=p.authorRank,
			a.numberOfAuthors=p.numberOfAuthors,
			a.authorNameAsListed=p.authorNameAsListed, 
			a.AuthorWeight=p.AuthorWeight, 
			a.AuthorPosition=p.AuthorPosition,
			a.PubYear=p.PubYear,
			a.YearWeight=p.YearWeight
		FROM #Authorship a, [Profile.Cache].[Publication.PubMed.AuthorPosition]  p
		WHERE a.PersonID = p.PersonID and a.PMID = p.PMID and a.PMID is not null
	UPDATE #authorship
		SET authorWeight = 0.5
		WHERE authorWeight IS NULL
	UPDATE #authorship
		SET authorPosition = 'U'
		WHERE authorPosition IS NULL
	UPDATE #authorship
		SET PubYear = year(EntityDate)
		WHERE PubYear IS NULL
	UPDATE #authorship
		SET	YearWeight = (case when EntityDate is null then 0.5
							when year(EntityDate) <= 1901 then 0.5
							else power(cast(0.5 as float),cast(datediff(d,EntityDate,GetDate()) as float)/365.25/10)
							end)
		WHERE YearWeight IS NULL

	----------------------------------------------------------------------
	-- Update the Publication.Authorship table
	----------------------------------------------------------------------
 
	-- Set IsActive = 0 for Authorships that no longer exist
	UPDATE [Profile.Data].[Publication.Entity.Authorship]
		SET IsActive = 0
		WHERE PersonID = @PersonID
			AND InformationResourceID NOT IN (SELECT InformationResourceID FROM #authorship)
	-- Set IsActive = 1 for current Authorships and update data
	UPDATE e
		SET e.EntityDate = a.EntityDate,
			e.authorRank = a.authorRank,
			e.numberOfAuthors = a.numberOfAuthors,
			e.authorNameAsListed = a.authorNameAsListed,
			e.authorWeight = a.authorWeight,
			e.authorPosition = a.authorPosition,
			e.PubYear = a.PubYear,
			e.YearWeight = a.YearWeight,
			e.IsActive = 1
		FROM #authorship a, [Profile.Data].[Publication.Entity.Authorship] e
		WHERE a.PersonID = e.PersonID and a.InformationResourceID = e.InformationResourceID
	-- Insert new Authorships
	INSERT INTO [Profile.Data].[Publication.Entity.Authorship] (
			EntityDate,
			authorRank,
			numberOfAuthors,
			authorNameAsListed,
			authorWeight,
			authorPosition,
			PubYear,
			YearWeight,
			PersonID,
			InformationResourceID,
			IsActive
		)
		SELECT 	EntityDate,
				authorRank,
				numberOfAuthors,
				authorNameAsListed,
				authorWeight,
				authorPosition,
				PubYear,
				YearWeight,
				PersonID,
				InformationResourceID,
				IsActive
		FROM #authorship a
		WHERE NOT EXISTS (
			SELECT *
			FROM [Profile.Data].[Publication.Entity.Authorship] e
			WHERE a.PersonID = e.PersonID and a.InformationResourceID = e.InformationResourceID
		)
	-- Assign an EntityName
	UPDATE [Profile.Data].[Publication.Entity.Authorship]
		SET EntityName = 'Authorship ' + CAST(EntityID as VARCHAR(50))
		WHERE PersonID = @PersonID AND EntityName is null


	-- *******************************************************************
	-- *******************************************************************
	-- Update RDF
	-- *******************************************************************
	-- *******************************************************************



	--------------------------------------------------------------
	-- Version 3 : Create stub RDF
	--------------------------------------------------------------

	CREATE TABLE #sql (
		i INT IDENTITY(0,1) PRIMARY KEY,
		s NVARCHAR(MAX)
	)
	INSERT INTO #sql (s)
		SELECT	'EXEC [RDF.Stage].ProcessDataMap '
					+'  @DataMapID = '+CAST(DataMapID AS VARCHAR(50))
					+', @InternalIdIn = '+InternalIdIn
					+', @TurnOffIndexing=0, @SaveLog=0; '
		FROM (
			SELECT *, '''SELECT CAST(EntityID AS VARCHAR(50)) FROM [Profile.Data].[Publication.Entity.Authorship] WHERE PersonID = '+CAST(@PersonID AS VARCHAR(50))+'''' InternalIdIn
				FROM [Ontology.].DataMap
				WHERE class = 'http://vivoweb.org/ontology/core#Authorship'
					AND NetworkProperty IS NULL
					AND Property IS NULL
			UNION ALL
			SELECT *, '''' + CAST(@PersonID AS VARCHAR(50)) + '''' InternalIdIn
				FROM [Ontology.].DataMap
				WHERE class = 'http://xmlns.com/foaf/0.1/Person' 
					AND property = 'http://vivoweb.org/ontology/core#authorInAuthorship'
					AND NetworkProperty IS NULL
		) t
		ORDER BY DataMapID

	DECLARE @s NVARCHAR(MAX)
	WHILE EXISTS (SELECT * FROM #sql)
	BEGIN
		SELECT @s = s
			FROM #sql
			WHERE i = (SELECT MIN(i) FROM #sql)
		print @s
		EXEC sp_executesql @s
		DELETE
			FROM #sql
			WHERE i = (SELECT MIN(i) FROM #sql)
	END

	--select * from [Ontology.].DataMap


/*

	--------------------------------------------------------------
	-- Version 1 : Create all RDF using ProcessDataMap
	--------------------------------------------------------------

	CREATE TABLE #sql (
		i INT IDENTITY(0,1) PRIMARY KEY,
		s NVARCHAR(MAX)
	)
	INSERT INTO #sql (s)
		SELECT	'EXEC [RDF.Stage].ProcessDataMap '
					+'  @DataMapID = '+CAST(DataMapID AS VARCHAR(50))
					+', @InternalIdIn = '+InternalIdIn
					+', @TurnOffIndexing=0, @SaveLog=0; '
		FROM (
			SELECT *, '''SELECT CAST(InformationResourceID AS VARCHAR(50)) FROM [Profile.Data].[Publication.Entity.Authorship] WHERE PersonID = '+CAST(@PersonID AS VARCHAR(50))+'''' InternalIdIn
				FROM [Ontology.].DataMap
				WHERE class = 'http://vivoweb.org/ontology/core#InformationResource' 
					AND IsNull(property,'') <> 'http://vivoweb.org/ontology/core#informationResourceInAuthorship'
					AND NetworkProperty IS NULL
			UNION ALL
			SELECT *, '''SELECT CAST(EntityID AS VARCHAR(50)) FROM [Profile.Data].[Publication.Entity.Authorship] WHERE PersonID = '+CAST(@PersonID AS VARCHAR(50))+'''' InternalIdIn
				FROM [Ontology.].DataMap
				WHERE class = 'http://vivoweb.org/ontology/core#Authorship'
					AND IsNull(property,'') NOT IN ('http://vivoweb.org/ontology/core#linkedAuthor','http://vivoweb.org/ontology/core#linkedInformationResource')
					AND NetworkProperty IS NULL
			UNION ALL
			SELECT *, '''SELECT CAST(InformationResourceID AS VARCHAR(50)) FROM [Profile.Data].[Publication.Entity.Authorship] WHERE PersonID = '+CAST(@PersonID AS VARCHAR(50))+'''' InternalIdIn
				FROM [Ontology.].DataMap
				WHERE class = 'http://vivoweb.org/ontology/core#InformationResource' 
					AND property = 'http://vivoweb.org/ontology/core#informationResourceInAuthorship'
					AND NetworkProperty IS NULL
			UNION ALL
			SELECT *, '''' + CAST(@PersonID AS VARCHAR(50)) + '''' InternalIdIn
				FROM [Ontology.].DataMap
				WHERE class = 'http://xmlns.com/foaf/0.1/Person' 
					AND property = 'http://vivoweb.org/ontology/core#authorInAuthorship'
					AND NetworkProperty IS NULL
		) t
		ORDER BY DataMapID

	DECLARE @s NVARCHAR(MAX)
	WHILE EXISTS (SELECT * FROM #sql)
	BEGIN
		SELECT @s = s
			FROM #sql
			WHERE i = (SELECT MIN(i) FROM #sql)
		--print @s
		EXEC sp_executesql @s
		DELETE
			FROM #sql
			WHERE i = (SELECT MIN(i) FROM #sql)
	END

*/


/*

	---------------------------------------------------------------------------------
	-- Version 2 : Create new entities using ProcessDataMap, and triples manually
	---------------------------------------------------------------------------------

	CREATE TABLE #sql (
		i INT IDENTITY(0,1) PRIMARY KEY,
		s NVARCHAR(MAX)
	)
	INSERT INTO #sql (s)
		SELECT	'EXEC [RDF.Stage].ProcessDataMap '
					+'  @DataMapID = '+CAST(DataMapID AS VARCHAR(50))
					+', @InternalIdIn = '+InternalIdIn
					+', @TurnOffIndexing=0, @SaveLog=0; '
		FROM (
			SELECT *, '''SELECT CAST(InformationResourceID AS VARCHAR(50)) FROM [Profile.Data].[Publication.Entity.Authorship] WHERE PersonID = '+CAST(@PersonID AS VARCHAR(50))+'''' InternalIdIn
				FROM [Ontology.].DataMap
				WHERE class = 'http://vivoweb.org/ontology/core#InformationResource' 
					AND IsNull(property,'') <> 'http://vivoweb.org/ontology/core#informationResourceInAuthorship'
					AND NetworkProperty IS NULL
			UNION ALL
			SELECT *, '''SELECT CAST(EntityID AS VARCHAR(50)) FROM [Profile.Data].[Publication.Entity.Authorship] WHERE PersonID = '+CAST(@PersonID AS VARCHAR(50))+'''' InternalIdIn
				FROM [Ontology.].DataMap
				WHERE class = 'http://vivoweb.org/ontology/core#Authorship'
					AND IsNull(property,'') NOT IN ('http://vivoweb.org/ontology/core#linkedAuthor','http://vivoweb.org/ontology/core#linkedInformationResource')
					AND NetworkProperty IS NULL
		) t
		ORDER BY DataMapID

	--select * from #sql
	--return

	DECLARE @s NVARCHAR(MAX)
	WHILE EXISTS (SELECT * FROM #sql)
	BEGIN
		SELECT @s = s
			FROM #sql
			WHERE i = (SELECT MIN(i) FROM #sql)
		--print @s
		EXEC sp_executesql @s
		DELETE
			FROM #sql
			WHERE i = (SELECT MIN(i) FROM #sql)
	END


	CREATE TABLE #a (
		PersonID INT,
		AuthorshipID INT,
		InformationResourceID INT,
		IsActive BIT,
		PersonNodeID BIGINT,
		AuthorshipNodeID BIGINT,
		InformationResourceNodeID BIGINT,
		AuthorInAuthorshipTripleID BIGINT,
		LinkedAuthorTripleID BIGINT,
		LinkedInformationResourceTripleID BIGINT,
		InformationResourceInAuthorshipTripleID BIGINT,
		AuthorRank INT,
		EntityDate DATETIME,
		TripleWeight FLOAT,
		AuthorRecord INT
	)
	-- Get authorship records
	INSERT INTO #a (PersonID, AuthorshipID, InformationResourceID, IsActive, AuthorRank, EntityDate, TripleWeight, AuthorRecord)
		SELECT PersonID, EntityID, InformationResourceID, IsActive, 
				AuthorRank, EntityDate, IsNull(authorweight * yearweight,0),
				0
			FROM [Profile.Data].[Publication.Entity.Authorship]
			WHERE PersonID = @PersonID
		UNION ALL
		SELECT PersonID, EntityID, InformationResourceID, IsActive, 
				AuthorRank, EntityDate, IsNull(authorweight * yearweight,0),
				1
			FROM [Profile.Data].[Publication.Entity.Authorship]
			WHERE PersonID <> @PersonID 
				AND IsActive = 1
				AND InformationResourceID IN (
					SELECT InformationResourceID
					FROM [Profile.Data].[Publication.Entity.Authorship]
					WHERE PersonID = @PersonID
				)
	-- Get entity IDs
	UPDATE a
		SET a.PersonNodeID = m.NodeID
		FROM #a a, [RDF.Stage].InternalNodeMap m
		WHERE m.Class = 'http://xmlns.com/foaf/0.1/Person'
			AND m.InternalType = 'Person'
			AND m.InternalID = CAST(a.PersonID AS VARCHAR(50))
	UPDATE a
		SET a.AuthorshipNodeID = m.NodeID
		FROM #a a, [RDF.Stage].InternalNodeMap m
		WHERE m.Class = 'http://vivoweb.org/ontology/core#Authorship'
			AND m.InternalType = 'Authorship'
			AND m.InternalID = CAST(a.AuthorshipID AS VARCHAR(50))
	UPDATE a
		SET a.InformationResourceNodeID = m.NodeID
		FROM #a a, [RDF.Stage].InternalNodeMap m
		WHERE m.Class = 'http://vivoweb.org/ontology/core#InformationResource'
			AND m.InternalType = 'InformationResource'
			AND m.InternalID = CAST(a.InformationResourceID AS VARCHAR(50))
	-- Get triple IDs
	UPDATE a
		SET a.AuthorInAuthorshipTripleID = t.TripleID
		FROM #a a, [RDF.].Triple t
		WHERE a.PersonNodeID IS NOT NULL AND a.AuthorshipNodeID IS NOT NULL
			AND t.subject = a.PersonNodeID
			AND t.predicate = [RDF.].fnURI2NodeID('http://vivoweb.org/ontology/core#authorInAuthorship')
			AND t.object = a.AuthorshipNodeID
	UPDATE a
		SET a.LinkedAuthorTripleID = t.TripleID
		FROM #a a, [RDF.].Triple t
		WHERE a.PersonNodeID IS NOT NULL AND a.AuthorshipNodeID IS NOT NULL
			AND t.subject = a.AuthorshipNodeID
			AND t.predicate = [RDF.].fnURI2NodeID('http://vivoweb.org/ontology/core#linkedAuthor')
			AND t.object = a.PersonNodeID
	UPDATE a
		SET a.LinkedInformationResourceTripleID = t.TripleID
		FROM #a a, [RDF.].Triple t
		WHERE a.AuthorshipNodeID IS NOT NULL AND a.InformationResourceID IS NOT NULL
			AND t.subject = a.AuthorshipNodeID
			AND t.predicate = [RDF.].fnURI2NodeID('http://vivoweb.org/ontology/core#linkedInformationResource')
			AND t.object = a.InformationResourceNodeID
	UPDATE a
		SET a.InformationResourceInAuthorshipTripleID = t.TripleID
		FROM #a a, [RDF.].Triple t
		WHERE a.AuthorshipNodeID IS NOT NULL AND a.InformationResourceID IS NOT NULL
			AND t.subject = a.InformationResourceNodeID
			AND t.predicate = [RDF.].fnURI2NodeID('http://vivoweb.org/ontology/core#informationResourceInAuthorship')
			AND t.object = a.AuthorshipNodeID
	
	--select * from #a
	--return
	--select * from [ontology.].datamap



	SELECT a.IsActive, a.subject, m._PropertyNode predicate, a.object, 
			a.TripleWeight, 0 ObjectType, a.SortOrder,
			IsNull(s.ViewSecurityGroup, m.ViewSecurityGroup) ViewSecurityGroup,
			a.TripleID, t.SortOrder ExistingSortOrder, X
		INTO #b
		FROM (
				SELECT AuthorshipNodeID subject, InformationResourceNodeID object, TripleWeight, 
						'http://vivoweb.org/ontology/core#Authorship' Class,
						'http://vivoweb.org/ontology/core#linkedInformationResource' Property,
						1 SortOrder,
						IsActive,
						LinkedInformationResourceTripleID TripleID,
						1 X
					FROM #a
					WHERE AuthorRecord = 0
					--WHERE IsActive = 1
				UNION ALL
				SELECT AuthorshipNodeID subject, PersonNodeID object, 1 TripleWeight,
						'http://vivoweb.org/ontology/core#Authorship' Class,
						'http://vivoweb.org/ontology/core#linkedAuthor' Property,
						1 SortOrder,
						IsActive,
						LinkedAuthorTripleID TripleID,
						2 X
					FROM #a
					WHERE AuthorRecord = 0
					--WHERE IsActive = 1
				UNION ALL
				SELECT InformationResourceNodeID subject, AuthorshipNodeID object, TripleWeight, 
						'http://vivoweb.org/ontology/core#InformationResource' Class,
						'http://vivoweb.org/ontology/core#informationResourceInAuthorship' Property,
						row_number() over (partition by InformationResourceNodeID, IsActive order by AuthorRank, t.SortOrder, AuthorshipNodeID) SortOrder,
						IsActive,
						InformationResourceInAuthorshipTripleID TripleID,
						3 X
					FROM #a a
						LEFT OUTER JOIN [RDF.].[Triple] t
						ON a.InformationResourceInAuthorshipTripleID = t.TripleID
					--WHERE IsActive = 1
				UNION ALL
				SELECT PersonNodeID subject, AuthorshipNodeID object, 1 TripleWeight, 
						'http://xmlns.com/foaf/0.1/Person' Class,
						'http://vivoweb.org/ontology/core#authorInAuthorship' Property,
						row_number() over (partition by PersonNodeID, IsActive order by EntityDate desc) SortOrder,
						IsActive,
						AuthorInAuthorshipTripleID TripleID,
						4 X
					FROM #a
					WHERE AuthorRecord = 0
					--WHERE IsActive = 1
			) a
			INNER JOIN [Ontology.].[DataMap] m
				ON m.Class = a.Class AND m.NetworkProperty IS NULL AND m.Property = a.Property
			LEFT OUTER JOIN [RDF.].[Triple] t
				ON a.TripleID = t.TripleID
			LEFT OUTER JOIN [RDF.Security].[NodeProperty] s
				ON s.NodeID = a.subject
					AND s.Property = m._PropertyNode

	--SELECT * FROM #b ORDER BY X, subject, property, IsActive, sortorder

	-- Delete
	DELETE
		FROM [RDF.].Triple
		WHERE TripleID IN (
			SELECT TripleID
			FROM #b
			WHERE IsActive = 0 AND TripleID IS NOT NULL
		)
	--select @@ROWCOUNT

	-- Update
	UPDATE t
		SET t.SortOrder = b.SortOrder
		FROM [RDF.].Triple t
			INNER JOIN #b b
			ON t.TripleID = b.TripleID
				AND b.IsActive = 1 
				AND b.TripleID IS NOT NULL
				AND b.SortOrder <> b.ExistingSortOrder
	--select @@ROWCOUNT

	-- Insert
	INSERT INTO [RDF.].Triple (Subject,Predicate,Object,TripleHash,Weight,Reitification,ObjectType,SortOrder,ViewSecurityGroup,Graph)
		SELECT Subject,Predicate,Object,
				[RDF.].fnTripleHash(Subject,Predicate,Object),
				TripleWeight,NULL,0,SortOrder,ViewSecurityGroup,1
			FROM #b
			WHERE IsActive = 1 AND TripleID IS NULL
	--select @@ROWCOUNT

*/


END




GO


/****** Object:  StoredProcedure [Profile.Module].[CustomViewAuthorInAuthorship.GetList]    Script Date: 12/16/2015 10:50:43 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






ALTER PROCEDURE  [Profile.Module].[CustomViewAuthorInAuthorship.GetList]
	@NodeID bigint = NULL,
	@SessionID uniqueidentifier = NULL
AS
BEGIN

	DECLARE @SecurityGroupID BIGINT, @HasSpecialViewAccess BIT
	EXEC [RDF.Security].GetSessionSecurityGroup @SessionID, @SecurityGroupID OUTPUT, @HasSpecialViewAccess OUTPUT
	CREATE TABLE #SecurityGroupNodes (SecurityGroupNode BIGINT PRIMARY KEY)
	INSERT INTO #SecurityGroupNodes (SecurityGroupNode) EXEC [RDF.Security].GetSessionSecurityGroupNodes @SessionID, @NodeID


	declare @AuthorInAuthorship bigint
	select @AuthorInAuthorship = [RDF.].fnURI2NodeID('http://vivoweb.org/ontology/core#authorInAuthorship') 
	declare @LinkedInformationResource bigint
	select @LinkedInformationResource = [RDF.].fnURI2NodeID('http://vivoweb.org/ontology/core#linkedInformationResource') 


	select i.NodeID, p.EntityID, i.Value rdf_about, p.EntityName rdfs_label, 
		p.Authors authors, p.Reference prns_informationResourceReference, p.EntityDate prns_publicationDate,
		year(p.EntityDate) prns_year, p.pmid bibo_pmid, p.pmcid vivo_pmcid, p.mpid prns_mpid, p.URL vivo_webpage, c.AuthorXML authorXML
	from [RDF.].[Triple] t
		inner join [RDF.].[Node] a
			on t.subject = @NodeID and t.predicate = @AuthorInAuthorship
				and t.object = a.NodeID
				and ((t.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (t.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (t.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
				and ((a.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (a.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (a.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
		inner join [RDF.].[Node] i
			on t.object = i.NodeID
				and ((i.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (i.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (i.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
		inner join [RDF.Stage].[InternalNodeMap] m
			on i.NodeID = m.NodeID
		inner join [Profile.Data].[Publication.Entity.Authorship] e
			on m.InternalID = e.EntityID
		inner join [Profile.Data].[Publication.Entity.InformationResource] p
			on e.InformationResourceID = p.EntityID
		left outer join [UCSF.CTSASearch].[Publication.PubMed.CoAuthorXML] c
			on p.pmid = c.PMID
	order by p.EntityDate desc

/*
	select i.NodeID, p.EntityID, i.Value rdf_about, p.EntityName rdfs_label, 
		p.Reference prns_informationResourceReference, p.EntityDate prns_publicationDate,
		year(p.EntityDate) prns_year, p.pmid bibo_pmid, p.mpid prns_mpid
	from [RDF.].[Triple] t
		inner join [RDF.].[Triple] v
			on t.subject = @NodeID and t.predicate = @AuthorInAuthorship
			and t.object = v.subject and v.predicate = @LinkedInformationResource
			and ((t.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (t.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (t.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
			and ((v.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (v.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (v.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
		inner join [RDF.].[Node] a
			on t.object = a.NodeID
			and ((a.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (a.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (a.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
		inner join [RDF.].[Node] i
			on v.object = i.NodeID
			and ((i.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (i.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (i.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
		inner join [RDF.Stage].[InternalNodeMap] m
			on i.NodeID = m.NodeID
		inner join [Profile.Data].[Publication.Entity.InformationResource] p
			on m.InternalID = p.EntityID
	order by p.EntityDate desc
*/

END

GO

/****** Object:  StoredProcedure [User.Session].[UpdateSession]    Script Date: 3/30/2017 2:11:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [User.Session].[UpdateSession]
	@SessionID UNIQUEIDENTIFIER, 
	@UserID INT=NULL OUTPUT,  -- UCSF added as output for MultiShibbolethLogin
	@LastUsedDate DATETIME=NULL, 
	@LogoutDate DATETIME=NULL,
	@SessionPersonNodeID BIGINT = NULL OUTPUT,
	@SessionPersonURI VARCHAR(400) = NULL OUTPUT,
	@UserURI VARCHAR(400) = NULL OUTPUT,
	@SecurityGroupID BIGINT = NULL OUTPUT,
	@DisplayName VARCHAR(255) = NULL OUTPUT  -- Added by UCSF
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	-- See if there is a PersonID associated with this session	
	DECLARE @PersonID INT
	SELECT @PersonID = PersonID, 
		@UserID = ISNULL(@UserID, UserID) -- UCSF added this line
		FROM [User.Session].[Session]
		WHERE SessionID = @SessionID
	IF @UserID IS NOT NULL
		SELECT @PersonID = ISNULL(@PersonID, PersonID),
			@DisplayName = FirstName + ' ' + LastName  -- UCSF
			FROM [User.Account].[User]
			WHERE UserID = @UserID

	-- UCSF. Set the @UserID from the @SessionID

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
				DisplayName = IsNull(@DisplayName, DisplayName), -- UCSF
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
END

GO

/****** Object:  StoredProcedure [Profile.Module].[NetworkAuthorshipTimeline.Concept.GetData]    Script Date: 5/17/2017 12:16:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Profile.Module].[NetworkAuthorshipTimeline.Concept.GetData]
	@NodeID BIGINT,
	@PersonFilter VARCHAR(200)=NULL,
	@InstitutionAbbreviation VARCHAR(200)=NULL 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @DescriptorName NVARCHAR(255)
 	SELECT @DescriptorName = d.DescriptorName
		FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n,
			[Profile.Data].[Concept.Mesh.Descriptor] d
		WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @NodeID
			AND m.InternalID = d.DescriptorUI

    -- Insert statements for procedure here
	declare @gc varchar(max)

	declare @y table (
		y int,
		A int,
		B int
	)

	insert into @y (y,A,B)
		select n.n y, coalesce(t.A,0) A, coalesce(t.B,0) B
		from [Utility.Math].[N] left outer join (
			select (case when y < 1970 then 1970 else y end) y,
				sum(A) A,
				sum(B) B
			from (
				select pmid, pubyear y, (case when w = 1 then 1 else 0 end) A, (case when w < 1 then 1 else 0 end) B
				from (
					select distinct pmid, pubyear, topicweight w
					from [Profile.Cache].[Concept.Mesh.PersonPublication]
					where meshheader = @DescriptorName 
					-- UCSF Changes
					AND (@PersonFilter is null OR personid in 
						(select personid from [Profile.Data].[Person.Filter] f join [Profile.Data].[Person.FilterRelationship] r 
						on f.PersonFilterID = r.PersonFilterID AND f.PersonFilter = @PersonFilter)) 
					AND (@InstitutionAbbreviation is null OR personid in 
						(select personid from [Profile.Data].[vwPerson] WHERE InstitutionAbbreviation = @InstitutionAbbreviation)) 
				) t
			) t
			group by y
		) t on n.n = t.y
		where n.n between 1980 and year(getdate())

	declare @x int

	select @x = max(A+B)
		from @y

	if coalesce(@x,0) > 0
	begin
		declare @v varchar(1000)
		declare @z int
		declare @k int
		declare @i int

		set @z = power(10,floor(log(@x)/log(10)))
		set @k = floor(@x/@z)
		if @x > @z*@k
			select @k = @k + 1
		if @k > 5
			select @k = floor(@k/2.0+0.5), @z = @z*2

		set @v = ''
		set @i = 0
		while @i <= @k
		begin
			set @v = @v + '|' + cast(@z*@i as varchar(50))
			set @i = @i + 1
		end
		set @v = '|0|'+cast(@x as varchar(50))
		--set @v = '|0|50|100'

		declare @h varchar(1000)
		set @h = ''
		select @h = @h + '|' + (case when y % 2 = 1 then '' else ''''+right(cast(y as varchar(50)),2) end)
			from @y
			order by y 

		declare @w float
		--set @w = @k*@z
		set @w = @x

		declare @d varchar(max)
		set @d = ''
		select @d = @d + cast(floor(0.5 + 100*A/@w) as varchar(50)) + ','
			from @y
			order by y
		set @d = left(@d,len(@d)-1) + '|'
		select @d = @d + cast(floor(0.5 + 100*B/@w) as varchar(50)) + ','
			from @y
			order by y
		set @d = left(@d,len(@d)-1)

		declare @c varchar(50)
		set @c = 'b23f45,b4b9bF'
		--set @c = 'FB8072,80B1D3'
		--set @c = 'FB8072,B3DE69,80B1D3'
		--set @c = 'F96452,a8dc4f,68a4cc'
		--set @c = 'fea643,76cbbd,b56cb5'

		--select @v, @h, @d

		--set @gc = '//chart.googleapis.com/chart?chs=595x100&chf=bg,s,ffffff|c,s,ffffff&chxt=x,y&chxl=0:' + @h + '|1:' + @v + '&cht=bvs&chd=t:' + @d + '&chdl=First+Author|Middle or Unkown|Last+Author&chco='+@c+'&chbh=10'
		--set @gc = '//chart.googleapis.com/chart?chs=595x100&chf=bg,s,ffffff|c,s,ffffff&chxt=x,y&chxl=0:' + @h + '|1:' + @v + '&cht=bvs&chd=t:' + @d + '&chdl=Major+Topic|Minor+Topic&chco='+@c+'&chbh=10'
		set @gc = '//chart.googleapis.com/chart?chs=620x100&chf=bg,s,ffffff|c,s,ffffff&chxt=x,y&chxl=0:' + @h + '|1:' + @v + '&cht=bvs&chd=t:' + @d + '&chdl=Major+Topic|Minor+Topic&chco='+@c+'&chbh=9'


		declare @asText varchar(max)
		set @asText = '<table style="width:592px"><tr><th>Year</th><th>Major Topic</th><th>Minor Topic</th><th>Total</th></tr>'
		select @asText = @asText + '<tr><td>' + cast(y as varchar(50)) + '</td><td>' + cast(A as varchar(50)) + '</td><td>' + cast(B as varchar(50)) + '</td><td>' + cast(A + B as varchar(50)) + '</td></tr>'
			from @y
			where A + B > 0
			order by y 
		select @asText = @asText + '</table>'

		declare @alt varchar(max)
		select @alt = 'Bar chart showing ' + cast(sum(A + B) as varchar(50))+ ' publications over ' + cast(count(*) as varchar(50)) + ' distinct years, with a maximum of ' + cast(@x as varchar(50)) + ' publications in ' from @y where A + B > 0
		select @alt = @alt + cast(y as varchar(50)) + ' and '
			from @y
			where A + B = @x
			order by y 
		select @alt = left(@alt, len(@alt) - 4)

		select @gc gc, @alt alt, @asText asText --, @w w

		--select * from @y order by y

	end

END

GO

/****** Object:  StoredProcedure [Profile.Module].[NetworkAuthorshipTimeline.Person.GetData]    Script Date: 10/3/2017 11:15:48 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Profile.Module].[NetworkAuthorshipTimeline.Person.GetData]
	@NodeID BIGINT,
	@ShowAuthorPosition BIT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @PersonID INT
 	SELECT @PersonID = CAST(m.InternalID AS INT)
		FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n
		WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @NodeID
 
    -- Insert statements for procedure here
	declare @gc varchar(max)

	declare @y table (
		y int,
		A int,
		B int,
		C int,
		T int
	)

	insert into @y (y,A,B,C,T)
		select n.n y, coalesce(t.A,0) A, coalesce(t.B,0) B, coalesce(t.C,0) C, coalesce(t.T,0) T
		from [Utility.Math].[N] left outer join (
			select (case when y < 1970 then 1970 else y end) y,
				sum(case when r in ('F','S') then 1 else 0 end) A,
				sum(case when r not in ('F','S','L') then 1 else 0 end) B,
				sum(case when r in ('L') then 1 else 0 end) C,
				count(*) T
			from (
				select coalesce(p.AuthorPosition,'U') r, year(coalesce(p.pubdate,m.publicationdt,'1/1/1970')) y
				from [Profile.Data].[Publication.Person.Include] a
					left outer join [Profile.Cache].[Publication.PubMed.AuthorPosition] p on a.pmid = p.pmid and p.personid = a.personid
					left outer join [Profile.Data].[Publication.MyPub.General] m on a.mpid = m.mpid
				where a.personid = @PersonID
			) t
			group by y
		) t on n.n = t.y
		where n.n between 1980 and year(getdate())

	declare @x int

	--select @x = max(A+B+C)
	--	from @y

	select @x = max(T)
		from @y

	if coalesce(@x,0) > 0
	begin
		declare @v varchar(1000)
		declare @z int
		declare @k int
		declare @i int

		set @z = power(10,floor(log(@x)/log(10)))
		set @k = floor(@x/@z)
		if @x > @z*@k
			select @k = @k + 1
		if @k > 5
			select @k = floor(@k/2.0+0.5), @z = @z*2

		set @v = ''
		set @i = 0
		while @i <= @k
		begin
			set @v = @v + '|' + cast(@z*@i as varchar(50))
			set @i = @i + 1
		end
		set @v = '|0|'+cast(@x as varchar(50))
		--set @v = '|0|50|100'

		declare @h varchar(1000)
		set @h = ''
		select @h = @h + '|' + (case when y % 2 = 1 then '' else ''''+right(cast(y as varchar(50)),2) end)
			from @y
			order by y 

		declare @w float
		--set @w = @k*@z
		set @w = @x

		declare @c varchar(50)
		declare @d varchar(max)
		set @d = ''

		if @ShowAuthorPosition = 0
		begin
			select @d = @d + cast(floor(0.5 + 100*T/@w) as varchar(50)) + ','
				from @y
				order by y
			set @d = left(@d,len(@d)-1)

			--set @c = 'AC1B30'
			--set @c = '178CCB'
			set @c = '999999'
			set @gc = '//chart.googleapis.com/chart?chs=620x100&chf=bg,s,ffffff|c,s,ffffff&chxt=x,y&chxl=0:' + @h + '|1:' + @v + '&cht=bvs&chd=t:' + @d + '&chco='+@c+'&chbh=10'
		end
		else
		begin
			select @d = @d + cast(floor(0.5 + 100*A/@w) as varchar(50)) + ','
				from @y
				order by y
			set @d = left(@d,len(@d)-1) + '|'
			select @d = @d + cast(floor(0.5 + 100*B/@w) as varchar(50)) + ','
				from @y
				order by y
			set @d = left(@d,len(@d)-1) + '|'
			select @d = @d + cast(floor(0.5 + 100*C/@w) as varchar(50)) + ','
				from @y
				order by y
			set @d = left(@d,len(@d)-1)

			set @c = 'FB8072,B3DE69,80B1D3'
			set @gc = '//chart.googleapis.com/chart?chs=620x100&chf=bg,s,ffffff|c,s,ffffff&chxt=x,y&chxl=0:' + @h + '|1:' + @v + '&cht=bvs&chd=t:' + @d + '&chdl=First+Author|Middle or Unkown|Last+Author&chco='+@c+'&chbh=10'
		end
		
		declare @asText varchar(max)
		set @asText = '<table style="width:592px"><tr><th>Year</th><th>Publications</th></tr>'
		select @asText = @asText + '<tr><td>' + cast(y as varchar(50)) + '</td><td>' + cast(t as varchar(50)) + '</td></tr>'
			from @y
			where t > 0
			order by y 
		select @asText = @asText + '</table>'
		
			declare @alt varchar(max)
		select @alt = 'Bar chart showing ' + cast(sum(t) as varchar(50))+ ' publications over ' + cast(count(*) as varchar(50)) + ' distinct years, with a maximum of ' + cast(@x as varchar(50)) + ' publications in ' from @y where t > 0
		select @alt = @alt + cast(y as varchar(50)) + ' and '
			from @y
			where t = @x
			order by y 
		select @alt = left(@alt, len(@alt) - 4)


		select @gc gc, @alt alt, @asText asText --, @w w
	end

END

GO

/****** Object:  StoredProcedure [Profile.Data].[Concept.Mesh.GetPublications]    Script Date: 5/17/2017 12:28:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Profile.Data].[Concept.Mesh.GetPublications]
	@NodeID BIGINT,
	@ListType varchar(50) = NULL,
	@LastDate datetime = '1/1/1900',
	@PersonFilter VARCHAR(200)=NULL,
	@InstitutionAbbreviation VARCHAR(200)=NULL 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @DescriptorName NVARCHAR(255)
 	SELECT @DescriptorName = d.DescriptorName
		FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n,
			[Profile.Data].[Concept.Mesh.Descriptor] d
		WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @NodeID
			AND m.InternalID = d.DescriptorUI

	if @ListType = 'Newest' or @ListType IS NULL
	begin

		select *
		from (
			select top 10 g.pmid, g.pubdate, [Profile.Cache].[fnPublication.Pubmed.General2Reference](g.pmid, ArticleDay, ArticleMonth, ArticleYear, ArticleTitle, Authors, AuthorListCompleteYN, Issue, JournalDay, JournalMonth, JournalYear, MedlineDate, MedlinePgn, MedlineTA, Volume, 0) reference
			from [Profile.Data].[Publication.PubMed.General] g, (
				select m.pmid, max(MajorTopicYN) MajorTopicYN
				from [Profile.Data].[Publication.Person.Include] i, [Profile.Data].[Publication.PubMed.Mesh] m
				where i.pmid = m.pmid and i.pmid is not null and m.descriptorname = @DescriptorName
				-- UCSF changes
				AND (@PersonFilter is null OR i.personid in 
						(select personid from [Profile.Data].[Person.Filter] f join [Profile.Data].[Person.FilterRelationship] r 
						on f.PersonFilterID = r.PersonFilterID AND f.PersonFilter = @PersonFilter)) 
				AND (@InstitutionAbbreviation is null OR i.personid in 
						(select personid from [Profile.Data].[vwPerson] WHERE InstitutionAbbreviation = @InstitutionAbbreviation)) 
				group by m.pmid
			) m
			where g.pmid = m.pmid
			order by g.pubdate desc
		) t
		order by pubdate desc

	end

	if @ListType = 'Oldest' or @ListType IS NULL
	begin

		select *
		from (
			select top 10 g.pmid, g.pubdate, [Profile.Cache].[fnPublication.Pubmed.General2Reference](g.pmid, ArticleDay, ArticleMonth, ArticleYear, ArticleTitle, Authors, AuthorListCompleteYN, Issue, JournalDay, JournalMonth, JournalYear, MedlineDate, MedlinePgn, MedlineTA, Volume, 0) reference
			from [Profile.Data].[Publication.PubMed.General] g, (
				select m.pmid, max(MajorTopicYN) MajorTopicYN
				from [Profile.Data].[Publication.Person.Include] i, [Profile.Data].[Publication.PubMed.Mesh] m
				where i.pmid = m.pmid and i.pmid is not null and m.descriptorname = @DescriptorName
				-- UCSF changes
				AND (@PersonFilter is null OR i.personid in 
						(select personid from [Profile.Data].[Person.Filter] f join [Profile.Data].[Person.FilterRelationship] r 
						on f.PersonFilterID = r.PersonFilterID AND f.PersonFilter = @PersonFilter)) 
				AND (@InstitutionAbbreviation is null OR i.personid in 
						(select personid from [Profile.Data].[vwPerson] WHERE InstitutionAbbreviation = @InstitutionAbbreviation)) 
				group by m.pmid
			) m
			where g.pmid = m.pmid --and g.pubdate < @LastDate
			order by g.pubdate
		) t
		order by pubdate

	end


	if @ListType = 'Cited' or @ListType IS NULL
	begin

		;with pm_citation_count as (
			select pmid, 0 n
			from [Profile.Data].[Publication.PubMed.General]
		)
		select *
		from (
			select top 10 g.pmid, g.pubdate, c.n, [Profile.Cache].[fnPublication.Pubmed.General2Reference](g.pmid, ArticleDay, ArticleMonth, ArticleYear, ArticleTitle, Authors, AuthorListCompleteYN, Issue, JournalDay, JournalMonth, JournalYear, MedlineDate, MedlinePgn, MedlineTA, Volume, 0) reference
			from [Profile.Data].[Publication.PubMed.General] g, (
				select m.pmid, max(MajorTopicYN) MajorTopicYN
				from [Profile.Data].[Publication.Person.Include] i, [Profile.Data].[Publication.PubMed.Mesh] m
				where i.pmid = m.pmid and i.pmid is not null and m.descriptorname = @DescriptorName
				-- UCSF changes
				AND (@PersonFilter is null OR i.personid in 
						(select personid from [Profile.Data].[Person.Filter] f join [Profile.Data].[Person.FilterRelationship] r 
						on f.PersonFilterID = r.PersonFilterID AND f.PersonFilter = @PersonFilter)) 
				AND (@InstitutionAbbreviation is null OR i.personid in 
						(select personid from [Profile.Data].[vwPerson] WHERE InstitutionAbbreviation = @InstitutionAbbreviation)) 
				group by m.pmid
			) m, pm_citation_count c
			where g.pmid = m.pmid and m.pmid = c.pmid
			order by c.n desc, g.pubdate desc
		) t
		order by n desc, pubdate desc

	end

END

GO

/****** Object:  StoredProcedure [Profile.Module].[CustomViewPersonSameDepartment.GetList]    Script Date: 5/23/2017 12:57:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Profile.Module].[CustomViewPersonSameDepartment.GetList]
	@NodeID BIGINT,
	@baseURI nvarchar(400),
	@SessionID UNIQUEIDENTIFIER = NULL
AS
BEGIN
 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
 
	declare @labelID bigint
	select @labelID = [RDF.].fnURI2NodeID('http://www.w3.org/2000/01/rdf-schema#label')

	DECLARE @PersonID INT
 	SELECT @PersonID = CAST(m.InternalID AS INT)
		FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n
		WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @NodeID

	declare @i nvarchar(500)
	declare @d nvarchar(500)
	declare @v nvarchar(500)

	select @i = institutionname, @d = departmentname, @v = divisionfullname
		from [Profile.Cache].[Person]
		where personid = @personid

	declare @InstitutionURI varchar(400)
	declare @DepartmentURI varchar(400)

	select	@InstitutionURI = @baseURI + cast(j.NodeID as varchar(50)),
			@DepartmentURI = @baseURI + cast(e.NodeID as varchar(50))
		from [Profile.Data].[Organization.Institution] i,
			[Profile.Data].[Organization.Department] d,
			[RDF.Stage].[InternalNodeMap] j,
			[RDF.Stage].[InternalNodeMap] e
		where i.InstitutionName = @i and d.DepartmentName = @d
			and j.InternalType = 'Institution' and j.Class = 'http://xmlns.com/foaf/0.1/Organization' and j.InternalID = cast(i.InstitutionID as varchar(50))
			and e.InternalType = 'Department' and e.Class = 'http://xmlns.com/foaf/0.1/Organization' and e.InternalID = cast(d.DepartmentID as varchar(50))

	declare @x xml

	;with a as (
		select a.personid, 
			max(case when a.divisionname = @v then 1 else 0 end) v,
			max(case when s.numpublications > 0 then 1 else 0 end) p
			--row_number() over (order by newid()) k
		from [Profile.Cache].[Person.Affiliation] a, [Profile.Cache].[Person] s
		where a.personid <> @personid
			and a.instititutionname = @i and a.departmentname = @d
			and a.personid = s.personid
		group by a.personid
	), b as (
		select top(5) *
		from a
		order by v desc, p desc, newid()
	), c as (
		select m.NodeID, n.Value URI, l.Value Label
		from b
			inner join [RDF.Stage].[InternalNodeMap] m
				on m.InternalType = 'Person' and m.Class = 'http://xmlns.com/foaf/0.1/Person' and m.InternalID = cast(b.personid as varchar(50))
			inner join [RDF.].[Node] n
				on n.NodeID = m.NodeID and n.ViewSecurityGroup = -1
			inner join [RDF.].[Triple] t
				on t.subject = n.NodeID and t.predicate = @labelID and t.ViewSecurityGroup = -1
			inner join [RDF.].[Node] l
				on l.NodeID = t.object and l.ViewSecurityGroup = -1
	)
	select @x = (
			select	(select count(*) from a) "NumberOfConnections",
					@InstitutionURI "InstitutionURI",
					@DepartmentURI "DepartmentURI",
					(select	NodeID "Connection/@NodeID",
							URI "Connection/@URI",
							Label "Connection"
						from c
						order by Label
						for xml path(''), type
					)
			for xml path('Network'), type
		)

	select @x XML

END

GO

/****** Object:  StoredProcedure [Profile.Module].[NetworkCategory.Person.HasResearchArea.GetXML]    Script Date: 5/23/2017 12:39:45 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Stored Procedure

ALTER PROCEDURE [Profile.Module].[NetworkCategory.Person.HasResearchArea.GetXML]
	@NodeID BIGINT,
	@baseURI NVARCHAR(400)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @hasResearchAreaID BIGINT
	SELECT @hasResearchAreaID = [RDF.].fnURI2NodeID('http://vivoweb.org/ontology/core#hasResearchArea')	

	DECLARE @labelID BIGINT
	SELECT @labelID = [RDF.].fnURI2NodeID('http://www.w3.org/2000/01/rdf-schema#label')	

	DECLARE @meshSemanticGroupNameID BIGINT
	SELECT @meshSemanticGroupNameID = [RDF.].fnURI2NodeID('http://profiles.catalyst.harvard.edu/ontology/prns#meshSemanticGroupName')	

	SELECT *
		INTO #t
		FROM (
			SELECT t.SortOrder, t.Weight, @baseURI+CAST(t.Object AS VARCHAR(50)) URI, n.Value Concept, m.Value Category,
				ROW_NUMBER() OVER (PARTITION BY s.Object ORDER BY t.Weight DESC) CategoryRank
			FROM [RDF.].[Triple] t
				INNER JOIN [RDF.].[Triple] l
					ON t.Object = l.Subject AND l.Predicate = @labelID
				INNER JOIN [RDF.].[Node] n
					ON l.Object = n.NodeID
				INNER JOIN [RDF.].[Triple] s
					ON t.Object = s.Subject AND s.Predicate = @meshSemanticGroupNameID
				INNER JOIN [RDF.].[Node] m
					ON s.Object = m.NodeID
			WHERE t.Subject = @NodeID AND t.Predicate = @hasResearchAreaID
		) t
		WHERE CategoryRank <= 10

	SELECT (
		SELECT	'Concepts listed here are grouped according to their ''semantic'' categories. Within each category, up to ten concepts are shown, in decreasing order of relevance.' "@InfoCaption",
				(
					SELECT a.Category "DetailList/@Category",
						(SELECT	'' "Item/@ItemURLText",
								URI "Item/@URL",
								Concept "Item"
							FROM #t b
							WHERE b.Category = a.Category
							ORDER BY b.CategoryRank
							FOR XML PATH(''), TYPE
						) "DetailList"
					FROM (SELECT DISTINCT Category FROM #t) a
					ORDER BY a.Category
					FOR XML PATH(''), TYPE
				)
		FOR XML PATH('Items'), TYPE
	) ItemsXML

END

GO

/****** Object:  StoredProcedure [Profile.Module].[NetworkCloud.Person.HasResearchArea.GetXML]    Script Date: 5/23/2017 12:59:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- Stored Procedure

ALTER PROCEDURE [Profile.Module].[NetworkCloud.Person.HasResearchArea.GetXML]
	@NodeID BIGINT,
	@baseURI NVARCHAR(400)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @hasResearchAreaID BIGINT
	SELECT @hasResearchAreaID = [RDF.].fnURI2NodeID('http://vivoweb.org/ontology/core#hasResearchArea')	

	DECLARE @labelID BIGINT
	SELECT @labelID = [RDF.].fnURI2NodeID('http://www.w3.org/2000/01/rdf-schema#label')	

	SELECT (
		SELECT	'' "@Description",
				'In this concept ''cloud'', the sizes of the concepts are based not only on the number of corresponding publications, but also how relevant the concepts are to the overall topics of the publications, how long ago the publications were written, whether the person was the first or senior author, and how many other people have written about the same topic. The largest concepts are those that are most unique to this person.' "@InfoCaption",
				2 "@Columns",
				(
					SELECT	Value "@ItemURLText", 
							SortOrder "@sortOrder", 
							(CASE WHEN SortOrder <= 5 THEN 'big'
								WHEN Quintile = 1 THEN 'big'
								WHEN Quintile = 5 THEN 'small'
								ELSE 'med' END) "@Weight",
							URI "@ItemURL"
					FROM (
						SELECT t.SortOrder, t.Weight, @baseURI+CAST(t.Object AS VARCHAR(50)) URI, n.Value,
							NTILE(5) OVER (ORDER BY t.SortOrder) Quintile
						FROM [RDF.].[Triple] t
							INNER JOIN [RDF.].[Triple] l
								ON t.Object = l.Subject AND l.Predicate = @labelID
							INNER JOIN [RDF.].[Node] n
								ON l.Object = n.NodeID
						WHERE t.Subject = @NodeID AND t.Predicate = @hasResearchAreaID
					) t
					ORDER BY Value
					FOR XML PATH('Item'), TYPE
				)
		FOR XML PATH('ListView'), TYPE
	) ListViewXML

END

GO

/****** Object:  StoredProcedure [Profile.Module].[NetworkTimeline.Person.CoAuthorOf.GetData]    Script Date: 5/23/2017 1:08:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Profile.Module].[NetworkTimeline.Person.CoAuthorOf.GetData]
	@NodeID BIGINT,
	@baseURI NVARCHAR(400)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @PersonID INT
 	SELECT @PersonID = CAST(m.InternalID AS INT)
		FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n
		WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @NodeID
 
 	--DECLARE @baseURI NVARCHAR(400) Eric Meeks. Because we are getting URI's for people we just leave this as the base URI. The code will 
	-- always swap in the proper theme for a person URI.
	SELECT @baseURI = value FROM [Framework.].Parameter WHERE ParameterID = 'baseURI'

	;with e as (
		select top 20 s.PersonID1, s.PersonID2, s.n PublicationCount, 
			year(s.FirstPubDate) FirstPublicationYear, year(s.LastPubDate) LastPublicationYear, 
			p.DisplayName DisplayName2, ltrim(rtrim(p.FirstName+' '+p.LastName)) FirstLast2, s.w OverallWeight
		from [Profile.Cache].[SNA.Coauthor] s, [Profile.Cache].[Person] p
		where personid1 = @PersonID and personid2 = p.personid
		order by w desc, personid2
	), f as (
		select e.*, g.pubdate
		from [Profile.Data].[Publication.Person.Include] a, 
			[Profile.Data].[Publication.Person.Include] b, 
			[Profile.Data].[Publication.PubMed.General] g,
			e
		where a.personid = e.personid1 and b.personid = e.personid2 and a.pmid = b.pmid and a.pmid = g.pmid
			and g.pubdate > '1/1/1900'
	), g as (
		select min(year(pubdate))-1 a, max(year(pubdate))+1 b,
			cast(cast('1/1/'+cast(min(year(pubdate))-1 as varchar(10)) as datetime) as float) f,
			cast(cast('1/1/'+cast(max(year(pubdate))+1 as varchar(10)) as datetime) as float) g
		from f
	), h as (
		select f.*, (cast(pubdate as float)-f)/(g-f) x, a, b, f, g
		from f, g
	), i as (
		select personid2, min(x) MinX, max(x) MaxX, avg(x) AvgX
		from h
		group by personid2
	)
	select h.*, MinX, MaxX, AvgX, h.FirstLast2 label, (select count(distinct personid2) from i) n,
		@baseURI + cast(m.NodeID as varchar(50)) ObjectURI
	from h, i, [RDF.Stage].[InternalNodeMap] m
	where h.personid2 = i.personid2 and cast(i.personid2 as varchar(50)) = m.InternalID
		and m.Class = 'http://xmlns.com/foaf/0.1/Person' and m.InternalType = 'Person'
	order by AvgX, firstpublicationyear, lastpublicationyear, personid2, pubdate

END

GO

/****** Object:  StoredProcedure [Profile.Module].[NetworkTimeline.Person.HasResearchArea.GetData]    Script Date: 5/23/2017 1:04:11 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Profile.Module].[NetworkTimeline.Person.HasResearchArea.GetData]
	@NodeID BIGINT,
	@baseURI NVARCHAR(400)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @PersonID INT
 	SELECT @PersonID = CAST(m.InternalID AS INT)
		FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n
		WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @NodeID
 
	;with a as (
		select t.*, g.pubdate
		from (
			select top 20 *, 
				--numpubsthis/sqrt(numpubsall+100)/sqrt((LastPublicationYear+1 - FirstPublicationYear)*1.00000) w
				--numpubsthis/sqrt(numpubsall+100)/((LastPublicationYear+1 - FirstPublicationYear)*1.00000) w
				--WeightNTA/((LastPublicationYear+2 - FirstPublicationYear)*1.00000) w
				weight w
			from [Profile.Cache].[Concept.Mesh.Person]
			where personid = @PersonID
			order by w desc, meshheader
		) t, [Profile.Cache].[Concept.Mesh.PersonPublication] m, [Profile.Data].[Publication.PubMed.General] g
		where t.meshheader = m.meshheader and t.personid = m.personid and m.pmid = g.pmid and year(g.pubdate) > 1900
	), b as (
		select min(firstpublicationyear)-1 a, max(lastpublicationyear)+1 b,
			cast(cast('1/1/'+cast(min(firstpublicationyear)-1 as varchar(10)) as datetime) as float) f,
			cast(cast('1/1/'+cast(max(lastpublicationyear)+1 as varchar(10)) as datetime) as float) g
		from a
	), c as (
		select a.*, (cast(pubdate as float)-f)/(g-f) x, a, b, f, g
		from a, b
	), d as (
		select meshheader, min(x) MinX, max(x) MaxX, avg(x) AvgX
				--, (select avg(cast(g.pubdate as float))
				--from resnav_people_hmsopen.dbo.pm_pubs_general g, (
				--	select distinct pmid
				--	from resnav_people_hmsopen.dbo.cache_pub_mesh m
				--	where m.meshheader = c.meshheader
				--) t
				--where g.pmid = t.pmid) AvgAllX
		from c
		group by meshheader
	)
	select c.*, d.MinX, d.MaxX, d.AvgX,	c.meshheader label, (select count(distinct meshheader) from a) n, p.DescriptorUI
		into #t
		from c, d, [Profile.Data].[Concept.Mesh.Descriptor] p
		where c.meshheader = d.meshheader and d.meshheader = p.DescriptorName

	select t.*, @baseURI + cast(m.NodeID as varchar(50)) ObjectURI
		from #t t, [RDF.Stage].[InternalNodeMap] m
		where t.DescriptorUI = m.InternalID
			and m.Class = 'http://www.w3.org/2004/02/skos/core#Concept' and m.InternalType = 'MeshDescriptor'
		order by AvgX, firstpublicationyear, lastpublicationyear, meshheader, pubdate

END

GO

/****** Object:  StoredProcedure [Profile.Data].[Publication.PubMed.GetPersonInfoForDisambiguation]    Script Date: 10/5/2017 4:08:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [Profile.Data].[Publication.PubMed.GetPersonInfoForDisambiguation] 
AS
BEGIN
SET nocount  ON;
 
 
DECLARE  @search XML,
            @batchID UNIQUEIDENTIFIER,
            @batchcount INT,
            @threshold FLOAT,
            @baseURI NVARCHAR(max),
			@orcidNodeID NVARCHAR(max)

--SET Custom Threshold based on internal Institutional Logic, default is .98
SELECT @threshold = .98

SELECT @batchID=NEWID()

SELECT @baseURI = [Value] FROM [Framework.].[Parameter] WHERE [ParameterID] = 'baseURI'
SELECT @orcidNodeID = NodeID from [RDF.].Node where Value = 'http://vivoweb.org/ontology/core#orcidId'

SELECT personid, 
                   (SELECT ISNULL(RTRIM(firstname),'')  "Name/First",
                                          ISNULL(RTRIM(middlename),'') "Name/Middle",
                                          ISNULL(RTRIM(p.lastname),'') "Name/Last",
                                          ISNULL(RTRIM(suffix),'')     "Name/Suffix",
                                          CASE 
                                                 WHEN a.n IS NOT NULL OR b.n IS NOT NULL 
                                                          /*  Below is example of a custom piece of logic to alter the disambiguation by telling the disambiguation service
                                                            to Require First Name usage in the algorithm for faculty who are lower in rank */
                                                      OR facultyranksort > 4 
                                                      THEN 'true'
                                                ELSE 'false'
                                          END "RequireFirstName",
                                          d.cnt                                                                              "LocalDuplicateNames",
                                          @threshold                                                                   "MatchThreshold",
                                          (SELECT DISTINCT ISNULL(LTRIM(ISNULL(emailaddress,p.emailaddr)),'') Email
                                                      FROM [Profile.Data].[Person.Affiliation] pa
                                                WHERE pa.personid = p.personid
                                                FOR XML PATH(''),TYPE) AS "EmailList",
                                          (SELECT Affiliation
                                                      FROM [Profile.Data].[Person.Affiliation] pa 
													  JOIN [Profile.Data].[Publication.PubMed.DisambiguationAffiliation] d ON pa.InstitutionID = d.InstitutionID AND pa.IsPrimary = 1
                                                WHERE pa.personid = p.personid
                                                FOR XML PATH(''),TYPE) AS "AffiliationList",
                                          (SELECT PMID
                                             FROM [Profile.Data].[Publication.Person.Add]
                                            WHERE personid =p2.personid
                                        FOR XML PATH(''),ROOT('PMIDAddList'),TYPE),
                                          (SELECT PMID
                                             FROM [Profile.Data].[Publication.Person.Exclude]
                                            WHERE personid =p2.personid
                                        FOR XML PATH(''),ROOT('PMIDExcludeList'),TYPE),
                                          (SELECT @baseURI + CAST(i.NodeID AS VARCHAR) 
                                        FOR XML PATH(''),ROOT('URI'),TYPE),
										  (select n.Value as '*' from [RDF.].Node n join
											[RDF.].Triple t  on n.NodeID = t.Object
											and t.Subject = i.NodeID
											and t.Predicate = @orcidNodeID
										FOR XML PATH(''),ROOT('ORCID'),TYPE)
                              FROM [Profile.Data].Person p
                                       LEFT JOIN ( 
                                                
                                                         --case 1
                                                            SELECT LEFT(firstname,1)  f,
                                                                              LEFT(middlename,1) m,
                                                                              lastname,
                                                                              COUNT(* )          n
                                                              FROM [Profile.Data].Person
                                                            GROUP BY LEFT(firstname,1),
                                                                              LEFT(middlename,1),
                                                                              lastname
                                                            HAVING COUNT(* ) > 1
                                                      )A ON a.lastname = p.lastname
                                                        AND a.f=LEFT(firstname,1)
                                                        AND a.m = LEFT(middlename,1)
                              LEFT JOIN (               
 
                                                      --case 2
                                                      SELECT LEFT(firstname,1) f,
                                                                        lastname,
                                                                        COUNT(* )         n
                                                        FROM [Profile.Data].Person
                                                      GROUP BY LEFT(firstname,1),
                                                                        lastname
                                                      HAVING COUNT(* ) > 1
                                                                        AND SUM(CASE 
                                                                                                       WHEN middlename = '' THEN 1
                                                                                                      ELSE 0
                                                                                                END) > 0
                                                                                                
                                                )B ON b.f = LEFT(firstname,1)
                                                  AND b.lastname = p.lastname
                              LEFT JOIN ( SELECT [Utility.NLP].[fnNamePart1](firstname)F,
                                                                                          lastname,
                                                                                          COUNT(*)cnt
                                                                              FROM [Profile.Data].Person 
                                                                         GROUP BY [Utility.NLP].[fnNamePart1](firstname), 
                                                                                          lastname
                                                                  )d ON d.f = [Utility.NLP].[fnNamePart1](p2.firstname)
                                                                        AND d.lastname = p2.lastname

                              LEFT JOIN [RDF.Stage].[InternalNodeMap] i
								 ON [InternalType] = 'Person' AND [Class] = 'http://xmlns.com/foaf/0.1/Person' AND [InternalID] = CAST(p2.personid AS VARCHAR(50))                             
                         WHERE p.personid = p2.personid
                        
                        FOR XML PATH(''),ROOT('FindPMIDs')) XML--as xml)
  INTO #batch
  FROM [Profile.Data].vwperson  p2
  
   
SELECT @batchcount=@@ROWCOUNT

SELECT @BatchID,@batchcount,*
  FROM #batch 
END

GO

/****** Object:  StoredProcedure [Profile.Data].[Organization.GetInstitutions]    Script Date: 12/11/2017 10:49:18 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Profile.Data].[Organization.GetInstitutions]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT x.InstitutionID, x.InstitutionName, x.InstitutionAbbreviation, n.NodeID, n.Value URI, a.ShibbolethIdP, a.ShibbolethUserNameHeader, a.ShibbolethDisplayNameHeader
		FROM (
				SELECT CAST(MAX(InstitutionID) AS VARCHAR(50)) InstitutionID,
						LTRIM(RTRIM(InstitutionName)) InstitutionName, 
						MIN(institutionabbreviation) InstitutionAbbreviation
				FROM [Profile.Data].[Organization.Institution] WITH (NOLOCK)
				GROUP BY LTRIM(RTRIM(InstitutionName))
			) x 
			LEFT OUTER JOIN [RDF.Stage].InternalNodeMap m WITH (NOLOCK)
				ON m.class = 'http://xmlns.com/foaf/0.1/Organization'
					AND m.InternalType = 'Institution'
					AND m.InternalID = CAST(x.InstitutionID AS VARCHAR(50))
			LEFT OUTER JOIN [RDF.].Node n WITH (NOLOCK)
				ON m.NodeID = n.NodeID
					AND n.ViewSecurityGroup = -1
			LEFT OUTER JOIN [UCSF.].[InstitutionAdditions] a WITH (NOLOCK)
				ON x.InstitutionAbbreviation = a.InstitutionAbbreviation
		ORDER BY InstitutionName

END

GO


/****** Object:  StoredProcedure [Profile.Data].[Organization.GetDepartments]    Script Date: 3/5/2018 10:37:17 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Profile.Data].[Organization.GetDepartments] 
	@InstitutionAbbreviation varchar(50) 
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT x.DepartmentID, x.DepartmentName Department, n.NodeID, n.Value URI
		FROM (
				SELECT *
				FROM [Profile.Data].[Organization.Department] WITH (NOLOCK)
				WHERE Visible = 1 AND LTRIM(RTRIM(DepartmentName))<>'' AND DepartmentName IN (SELECT departmentname FROM [Profile.Import].[PersonAffiliation] WHERE institutionabbreviation = @InstitutionAbbreviation and departmentname IS NOT NULL)
			) x 
			LEFT OUTER JOIN [RDF.Stage].InternalNodeMap m WITH (NOLOCK)
				ON m.class = 'http://xmlns.com/foaf/0.1/Organization'
					AND m.InternalType = 'Department'
					AND m.InternalID = CAST(x.DepartmentID AS VARCHAR(50))
			LEFT OUTER JOIN [RDF.].Node n WITH (NOLOCK)
				ON m.NodeID = n.NodeID
					AND n.ViewSecurityGroup = -1
		ORDER BY Department

END

GO

/****** Object:  StoredProcedure [Profile.Data].[Organization.GetDivisions]    Script Date: 3/5/2018 11:12:17 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Profile.Data].[Organization.GetDivisions]
	@InstitutionAbbreviation varchar(50) 
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT x.DivisionID, x.DivisionName, n.NodeID, n.Value URI
		FROM (
				SELECT *
				FROM [Profile.Data].[Organization.Division] WITH (NOLOCK)
				WHERE LTRIM(RTRIM(DivisionName))<>'' AND DivisionName IN (SELECT [divisionname] FROM [Profile.Import].[PersonAffiliation] WHERE institutionabbreviation = @InstitutionAbbreviation and [divisionname] IS NOT NULL)
			) x 
			LEFT OUTER JOIN [RDF.Stage].InternalNodeMap m WITH (NOLOCK)
				ON m.class = 'http://xmlns.com/foaf/0.1/Organization'
					AND m.InternalType = 'Division'
					AND m.InternalID = CAST(x.DivisionID AS VARCHAR(50))
			LEFT OUTER JOIN [RDF.].Node n WITH (NOLOCK)
				ON m.NodeID = n.NodeID
					AND n.ViewSecurityGroup = -1
		ORDER BY DivisionName

END

GO

/****** Object:  StoredProcedure [Edit.Module].[CustomEditAuthorInAuthorship.GetList]    Script Date: 4/11/2018 10:50:10 AM ******/
-- needed for Claimed pubs
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


/****** Object:  StoredProcedure [Profile.Data].[Person.GetFacultyRanks]    Script Date: 4/16/2018 1:57:23 PM ******/
-- faculty rank sort bug
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [Profile.Data].[Person.GetFacultyRanks]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT x.FacultyRankID, x.FacultyRank,  n.NodeID, n.Value URI--, x.FacultyRankSort
		FROM (
				SELECT CAST(MAX(FacultyRankID) AS VARCHAR(50)) FacultyRankID,
						LTRIM(RTRIM(FacultyRank)) FacultyRank, FacultyRankSort				
				FROM [Profile.Data].[Person.FacultyRank] WITH (NOLOCK) where facultyrank <> ''				
				group by FacultyRank ,FacultyRankSort 
			) x 
			LEFT OUTER JOIN [RDF.Stage].InternalNodeMap m WITH (NOLOCK)
				ON m.class = 'http://profiles.catalyst.harvard.edu/ontology/prns#FacultyRank'
					AND m.InternalType = 'FacultyRank'
					AND m.InternalID = CAST(x.FacultyRankID AS VARCHAR(50))
			LEFT OUTER JOIN [RDF.].Node n WITH (NOLOCK)
				ON m.NodeID = n.NodeID
					AND n.ViewSecurityGroup = -1
		ORDER BY FacultyRankSort

END

GO
