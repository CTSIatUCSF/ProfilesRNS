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

/****** Object:  Table [UCSF.].[Brand]    Script Date: 12/16/2015 10:51:55 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [UCSF.].[Brand](
	[BrandName] [nvarchar](50) NOT NULL,
	[Theme] [nvarchar](50) NULL,
	[BasePath] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[BrandName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

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
	  ,b.[BrandName]  --this is where and how we assign a brand to a profile, currently based on institutionabbreviation
  FROM [Profile.Data].[Person] p 
	JOIN [Profile.Data].[Person.Affiliation] a on p.PersonID = a.PersonID and a.IsPrimary = 1
	JOIN [Profile.Data].[Organization.Institution] i on a.InstitutionID = i.InstitutionID
	LEFT JOIN [UCSF.].[Brand] b on b.BrandName = i.InstitutionAbbreviation
	LEFT JOIN [UCSF.].[NameAdditions] na on na.internalusername = p.internalusername
	LEFT JOIN [RDF.Stage].internalnodemap n on n.internalid = p.personId
	where n.[class] = 'http://xmlns.com/foaf/0.1/Person' 


GO

/****** Object:  View [UCSF.].[vwPersonExport]    Script Date: 10/11/2013 11:32:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE view [UCSF.].[vwPersonExport]
as
		SELECT p.personid,
					 p.userid,
					 p.nodeid,
					 p.PrettyURL,
					 p.internalusername,
					 p.firstname,
					 p.publishingfirst,
					 p.MiddleName,
					 p.lastname,
					 p.displayname, 
					 pa.title,
					 CASE WHEN ISNULL(dp.ShowAddress,'Y')='Y' THEN p.addressline1 END addressline1,
					 CASE WHEN ISNULL(dp.ShowAddress,'Y')='Y' THEN p.addressline2 END addressline2,
					 CASE WHEN ISNULL(dp.ShowAddress,'Y')='Y' THEN p.addressline3 END addressline3,
					 CASE WHEN ISNULL(dp.ShowAddress,'Y')='Y' THEN p.addressline4 END addressline4,
					 CASE WHEN ISNULL(dp.ShowAddress,'Y')='Y' THEN p.addressstring END addressstring, 
					 CASE WHEN ISNULL(dp.ShowAddress,'Y')='Y' THEN  p.building END building,
					 CASE WHEN ISNULL(dp.ShowAddress,'Y')='Y' THEN  p.room END room,
					 CASE WHEN ISNULL(dp.ShowAddress,'Y')='Y' THEN  p.floor END floor, 
					 CASE WHEN ISNULL(dp.ShowAddress,'Y')='Y' THEN  p.latitude END latitude, 
					 CASE WHEN ISNULL(dp.ShowAddress,'Y')='Y' THEN  p.longitude END longitude,
					 CASE WHEN ISNULL(dp.ShowAddress,'Y')='Y' THEN p.phone END phone,
					 CASE WHEN ISNULL(dp.ShowAddress,'Y')='Y' THEN p.fax END fax,  
					 CASE WHEN ISNULL(dp.ShowEmail,'Y') = 'Y' THEN p.emailaddr END emailaddr,
					 i2.institutionname,
					 i2.institutionabbreviation, 
					 de.departmentname,
					 dv.divisionname,  
					 fr.facultyrank, 
					 fr.facultyranksort, 
					 p.isactive,
					 ISNULL(dp.ShowAddress,'Y')ShowAddress,
					 ISNULL(dp.ShowPhone,'Y')ShowPhone,
					 ISNULL(dp.Showfax,'Y')Showfax,
					 ISNULL(dp.ShowEmail,'Y')ShowEmail,
					 ISNULL(dp.ShowPhoto,'N')ShowPhoto,
					 ISNULL(dp.ShowAwards,'N')ShowAwards,
					 ISNULL(dp.ShowNarrative,'N')ShowNarrative,
					 ISNULL(dp.ShowPublications,'Y')ShowPublications, 
					 ISNULL(p.visible,1)visible,
					 0 numpublications
			FROM [UCSF.].vwPerson p
 --LEFT JOIN [Profile.Cache].Person ps				 ON ps.personid = p.personid
 LEFT JOIN [Profile.Data].[Person.Affiliation] pa				 ON pa.personid = p.personid
																				AND pa.isprimary=1 
 LEFT JOIN [Profile.Data].[Organization.Institution] i2				 ON pa.institutionid = i2.institutionid 
 LEFT JOIN [Profile.Data].[Organization.Department] de				 ON de.departmentid = pa.departmentid
 LEFT JOIN [Profile.Data].[Organization.Division] dv				 ON dv.divisionid = pa.divisionid
 LEFT OUTER JOIN [Profile.Data].[Person.FacultyRank] fr on fr.facultyrankid = pa.facultyrankid 
 LEFT OUTER JOIN [Profile.Import].[Beta.DisplayPreference] dp on dp.PersonID=p.PersonID 
 --OUTER APPLY(SELECT TOP 1 facultyrank ,facultyranksort from [Profile.Data].[Person.Affiliation] pa JOIN [Profile.Data].[Person.FacultyRank] fr on fr.facultyrankid = pa.facultyrankid  where personid = p.personid order by facultyranksort asc)a
 WHERE p.isactive = 1

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

---------------------------------------------------------------------------------------------------------------------
--
--	Create Stored Procedures
--
---------------------------------------------------------------------------------------------------------------------

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
					 @Domain=ISNULL(b.BasePath, @BaseDomain) + '/',
					 @CleanFirst=n.CleanFirst, 
					 @CleanMiddle=n.CleanMiddle,
					 @CleanLast=n.CleanLast,
					 @CleanSuffix=n.CleanSuffix,
 					 @CleanGivenName=n.CleanGivenName
		FROM [UCSF.].[NameAdditions] n JOIN [Profile.Import].[PersonAffiliation] a on n.internalusername=a.internalusername and a.primaryaffiliation=1
			LEFT OUTER JOIN [UCSF.].[Brand] b on b.BrandName=a.institutionabbreviation -- associate brand to person by instutition again
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
	@UserID INT=NULL, 
	@LastUsedDate DATETIME=NULL, 
	@LogoutDate DATETIME=NULL,
	@SessionPersonNodeID BIGINT = NULL OUTPUT,
	@SessionPersonURI VARCHAR(400) = NULL OUTPUT,
	@UserURI VARCHAR(400) = NULL OUTPUT,
	@SecurityGroupID BIGINT = NULL OUTPUT,
	@ShortDisplayName VARCHAR(400) = NULL OUTPUT  -- Added by UCSF
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

/***** UCSF for UC Wide Profiles: Add FullApplicationPath to ResolveURL objects  ********************/
ALTER TABLE [User.Session].[History.ResolveURL] ADD [FullApplicationPath] VARCHAR(255) NULL;  

/****** Object:  StoredProcedure [Framework.].[ResolveURL]    Script Date: 4/26/2017 11:09:33 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Framework.].[ResolveURL]
	@ApplicationName varchar(1000) = '',
    @param1 varchar(1000) = '',
	@param2 varchar(1000) = '',
	@param3 varchar(1000) = '',
	@param4 varchar(1000) = '',
	@param5 varchar(1000) = '',
	@param6 varchar(1000) = '',
	@param7 varchar(1000) = '',
	@param8 varchar(1000) = '',
	@param9 varchar(1000) = '',
	@SessionID uniqueidentifier = NULL,	 
	@RestURL varchar(MAX) = NULL,
	@UserAgent varchar(255) = NULL,
	@ContentType varchar(255) = NULL,
	@FullApplicationPath varchar(255) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Log request
	DECLARE @HistoryID INT
	INSERT INTO [User.Session].[History.ResolveURL]	(RequestDate, ApplicationName, param1, param2, param3, param4, param5, param6, param7, param8, param9, SessionID, RestURL, UserAgent, ContentType, FullApplicationPath)
		SELECT GetDate(), @ApplicationName, @param1, @param2, @param3, @param4, @param5, @param6, @param7, @param8, @param9, @SessionID, @RestURL, @UserAgent, @ContentType, @FullApplicationPath
	SELECT @HistoryID = @@IDENTITY		 

	-- For dynamic sql
	DECLARE @sql nvarchar(max)

	-- Define variables needed to construct the output XML
	DECLARE @Resolved bit
	DECLARE @ErrorDescription varchar(max)
	DECLARE @ResponseURL varchar(1000)
	DECLARE @ResponseContentType varchar(255)
	DECLARE @ResponseStatusCode int
	DECLARE @ResponseRedirect bit
	DECLARE @ResponseIncludePostData bit

	-- Determine if this application has a custom resolver
	DECLARE @CustomResolver varchar(1000)
	SELECT @CustomResolver = Resolver
		FROM [Framework.].RestPath
		WHERE ApplicationName = @ApplicationName

	-- Resolve the URL
	SELECT @Resolved = 0
	IF @CustomResolver IS NOT NULL
	BEGIN
		-- Use a custom resolver
		SELECT @sql = 'EXEC ' + @CustomResolver 
			+ ' @ApplicationName = ''' + replace(@ApplicationName,'''','''''') + ''', '
			+ ' @param1 = ''' + replace(@param1,'''','''''') + ''', '
			+ ' @param2 = ''' + replace(@param2,'''','''''') + ''', '
			+ ' @param3 = ''' + replace(@param3,'''','''''') + ''', '
			+ ' @param4 = ''' + replace(@param4,'''','''''') + ''', '
			+ ' @param5 = ''' + replace(@param5,'''','''''') + ''', '
			+ ' @param6 = ''' + replace(@param6,'''','''''') + ''', '
			+ ' @param7 = ''' + replace(@param7,'''','''''') + ''', '
			+ ' @param8 = ''' + replace(@param8,'''','''''') + ''', '
			+ ' @param9 = ''' + replace(@param9,'''','''''') + ''', '
			+ ' @SessionID = ' + IsNull('''' + replace(@SessionID,'''','''''') + '''','NULL') + ', '
			+ ' @ContentType = ' + IsNull('''' + replace(@ContentType,'''','''''') + '''','NULL') + ', '
			+ ' @FullApplicationPath = ''' + replace(@FullApplicationPath,'''','''''') + ''', '
			+ ' @Resolved = @Resolved_OUT OUTPUT, '
			+ ' @ErrorDescription = @ErrorDescription_OUT OUTPUT, '
			+ ' @ResponseURL = @ResponseURL_OUT OUTPUT, '
			+ ' @ResponseContentType = @ResponseContentType_OUT OUTPUT, '
			+ ' @ResponseStatusCode = @ResponseStatusCode_OUT OUTPUT, '
			+ ' @ResponseRedirect = @ResponseRedirect_OUT OUTPUT, '
			+ ' @ResponseIncludePostData = @ResponseIncludePostData_OUT OUTPUT '
		EXEC sp_executesql @sql, 
			N'
				@Resolved_OUT bit OUTPUT,
				@ErrorDescription_OUT varchar(max) OUTPUT,
				@ResponseURL_OUT varchar(1000) OUTPUT,
				@ResponseContentType_OUT varchar(255) OUTPUT,
				@ResponseStatusCode_OUT int OUTPUT,
				@ResponseRedirect_OUT bit OUTPUT,
				@ResponseIncludePostData_OUT bit OUTPUT',
			@Resolved_OUT = @Resolved OUTPUT,
			@ErrorDescription_OUT = @ErrorDescription OUTPUT,
			@ResponseURL_OUT = @ResponseURL OUTPUT,
			@ResponseContentType_OUT = @ResponseContentType OUTPUT,
			@ResponseStatusCode_OUT = @ResponseStatusCode OUTPUT,
			@ResponseRedirect_OUT = @ResponseRedirect OUTPUT,
			@ResponseIncludePostData_OUT = @ResponseIncludePostData OUTPUT
	END
	ELSE
	BEGIN
		-- Use the default resolver
		SELECT	@Resolved = 1,
				@ErrorDescription = '', 
				@ResponseURL = BaseURL,
				@ResponseContentType = @ContentType,
				@ResponseStatusCode = 200,
				@ResponseRedirect = 0,
				@ResponseIncludePostData = 0
		    FROM [Framework.Alias].ApplicationBaseURL
			WHERE ApplicationName = @ApplicationName
		SELECT @ResponseURL = @ResponseURL + (CASE WHEN CHARINDEX('?',@ResponseURL) > 0 THEN '' ELSE '?' END)
			+ '&param1=' + @param1
			+ '&param2=' + @param2
			+ '&param3=' + @param3
			+ '&param4=' + @param4
			+ '&param5=' + @param5
			+ '&param6=' + @param6
			+ '&param7=' + @param7
			+ '&param8=' + @param8
			+ '&param9=' + @param9
	END
	-- Add standard parameters
	IF (@Resolved = 1) AND (@ResponseRedirect = 0)
	BEGIN
		SELECT @ResponseURL = @ResponseURL + (CASE WHEN CHARINDEX('?',@ResponseURL) > 0 THEN '' ELSE '?' END)
		SELECT @ResponseURL = @ResponseURL + '&SessionID=' + IsNull(CAST(@SessionID AS varchar(50)),'')
	END
	SELECT @ErrorDescription = IsNull(@ErrorDescription,'URL could not be resolved.')

	-- Log results
	UPDATE [User.Session].[History.ResolveURL]
		SET CustomResolver = @CustomResolver,
			Resolved = @Resolved,
			ErrorDescription = @ErrorDescription,
			ResponseURL = @ResponseURL,
			ResponseContentType = @ResponseContentType,
			ResponseStatusCode = @ResponseStatusCode,
			ResponseRedirect = @ResponseRedirect,
			ResponseIncludePostData = @ResponseIncludePostData
		WHERE HistoryID = @HistoryID

	-- Return results 
	SELECT	@Resolved Resolved, 
			@ErrorDescription ErrorDescription, 
			@ResponseURL ResponseURL,
			@ResponseContentType ResponseContentType,
			@ResponseStatusCode ResponseStatusCode,
			@ResponseRedirect ResponseRedirect,
			@ResponseIncludePostData ResponseIncludePostData,
			@SessionID RedirectHeaderSessionID


	/*
		Examples:

		EXEC [Framework.].[ResolveURL] @ApplicationName='profile', @param1='12345', @ContentType='application/rdf+xml'
		EXEC [Framework.].[ResolveURL] @ApplicationName='profile', @param1='12345', @param2='12345.rdf'
		EXEC [Framework.].[ResolveURL] @ApplicationName='profile', @param1='12345'
		EXEC [Framework.].[ResolveURL] @ApplicationName='display', @param1='12345', @SessionID = '16A199ED-07C5-436F-AB7D-0214792630A6'
		EXEC [Framework.].[ResolveURL] @ApplicationName='profile', @param1='12345', @param2='12345.rdf', @SessionID = '16A199ED-07C5-436F-AB7D-0214792630A6'

	*/

END

GO

/****** Object:  StoredProcedure [Edit.Framework].[ResolveURL]    Script Date: 4/26/2017 1:12:32 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Edit.Framework].[ResolveURL]
	@ApplicationName varchar(1000) = '',
	@param1 varchar(1000) = '',
	@param2 varchar(1000) = '',
	@param3 varchar(1000) = '',
	@param4 varchar(1000) = '',
	@param5 varchar(1000) = '',
	@param6 varchar(1000) = '',
	@param7 varchar(1000) = '',
	@param8 varchar(1000) = '',
	@param9 varchar(1000) = '',
	@SessionID uniqueidentifier = null,
	@ContentType varchar(255) = null,
	@FullApplicationPath varchar(255) = null,
	@Resolved bit OUTPUT,
	@ErrorDescription varchar(max) OUTPUT,
	@ResponseURL varchar(1000) OUTPUT,
	@ResponseContentType varchar(255) OUTPUT,
	@ResponseStatusCode int OUTPUT,
	@ResponseRedirect bit OUTPUT,
	@ResponseIncludePostData bit OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
	-- By default we were not able to resolve the URL
	SELECT @Resolved = 0

	-- Load param values into a table
	DECLARE @params TABLE (id int, val varchar(1000))
	INSERT INTO @params (id, val) VALUES (1, @param1)
	INSERT INTO @params (id, val) VALUES (2, @param2)
	INSERT INTO @params (id, val) VALUES (3, @param3)
	INSERT INTO @params (id, val) VALUES (4, @param4)
	INSERT INTO @params (id, val) VALUES (5, @param5)
	INSERT INTO @params (id, val) VALUES (6, @param6)
	INSERT INTO @params (id, val) VALUES (7, @param7)
	INSERT INTO @params (id, val) VALUES (8, @param8)
	INSERT INTO @params (id, val) VALUES (9, @param9)

	DECLARE @MaxParam int
	SELECT @MaxParam = 0
	SELECT @MaxParam = MAX(id) FROM @params WHERE val > ''

	DECLARE @TabParam int
	SELECT @TabParam = 3

	DECLARE @REDIRECTPAGE VARCHAR(255)
	
	SELECT @REDIRECTPAGE = '~/edit/default.aspx'


--this is for the display of the people search results if a queryID exists.
		if(@Param1	<>	'' and IsNumeric(@Param1)=1)
		BEGIN

			SELECT @Resolved = 1,
				@ErrorDescription = '',
				@ResponseURL = @REDIRECTPAGE  + '?subject=' + @Param1							
				
					
		END		


set	@ResponseContentType =''
set	@ResponseStatusCode  =''
set	@ResponseRedirect =0
set	@ResponseIncludePostData =0

END

GO

/****** Object:  StoredProcedure [History.Framework].[ResolveURL]    Script Date: 4/26/2017 1:13:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [History.Framework].[ResolveURL]
@ApplicationName VARCHAR (1000)='', @param1 VARCHAR (1000)='', @param2 VARCHAR (1000)='', @param3 VARCHAR (1000)='', @param4 VARCHAR (1000)='', @param5 VARCHAR (1000)='', @param6 VARCHAR (1000)='', @param7 VARCHAR (1000)='', @param8 VARCHAR (1000)='', @param9 VARCHAR (1000)='', @SessionID UNIQUEIDENTIFIER=null, @ContentType VARCHAR (255)=null, @FullApplicationPath VARCHAR (255)=null, @Resolved BIT OUTPUT, @ErrorDescription VARCHAR (MAX) OUTPUT, @ResponseURL VARCHAR (1000) OUTPUT, @ResponseContentType VARCHAR (255) OUTPUT, @ResponseStatusCode INT OUTPUT, @ResponseRedirect BIT OUTPUT, @ResponseIncludePostData BIT OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
	-- By default we were not able to resolve the URL
	SELECT @Resolved = 0

	-- Load param values into a table
	DECLARE @params TABLE (id int, val varchar(1000))
	INSERT INTO @params (id, val) VALUES (1, @param1)
	INSERT INTO @params (id, val) VALUES (2, @param2)
	INSERT INTO @params (id, val) VALUES (3, @param3)
	INSERT INTO @params (id, val) VALUES (4, @param4)
	INSERT INTO @params (id, val) VALUES (5, @param5)
	INSERT INTO @params (id, val) VALUES (6, @param6)
	INSERT INTO @params (id, val) VALUES (7, @param7)
	INSERT INTO @params (id, val) VALUES (8, @param8)
	INSERT INTO @params (id, val) VALUES (9, @param9)

	DECLARE @MaxParam int
	SELECT @MaxParam = 0
	SELECT @MaxParam = MAX(id) FROM @params WHERE val > ''

	DECLARE @TabParam int
	SELECT @TabParam = 3

	DECLARE @REDIRECTPAGE VARCHAR(255)
	
	SELECT @REDIRECTPAGE = '~/history/default.aspx'

	-- Return results
	IF (@ErrorDescription IS NULL)
	BEGIN
	
		if(@Param1='list')
		BEGIN
			SELECT @Resolved = 1,
				@ErrorDescription = '',
				@ResponseURL = @REDIRECTPAGE + '?tab=list'
		END						

		if(@Param1='type')
		BEGIN
			SELECT @Resolved = 1,
				@ErrorDescription = '',
				@ResponseURL = @REDIRECTPAGE  + '?tab=type'									
		END		
	

set	@ResponseContentType =''
set	@ResponseStatusCode  =''
set	@ResponseRedirect =0
set	@ResponseIncludePostData =0



				
	END

END

GO

/****** Object:  StoredProcedure [Direct.Framework].[ResolveURL]    Script Date: 4/26/2017 1:14:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*
declare @resolved bit
declare @t uniqueidentifier
set @t = '719491AF-F4B2-48C0-B264-465D46730AB1';
	declare @ErrorDescription varchar(max) 
	declare @ResponseURL varchar(1000) 
	declare @ResponseContentType varchar(255) 
	declare @ResponseStatusCode int 
	declare @ResponseRedirect bit 
	declare @ResponseIncludePostData bit 



exec [Direct.Framework].[ResolveDirectURL] 'direct','directservice.aspx', 'asdf','','','','','','','',@t,'', @resolved output, 
	 @ErrorDescription output,
	 @ResponseURL output,
	 @ResponseContentType output,
	 @ResponseStatusCode output,
	 @ResponseRedirect output,
	 @ResponseIncludePostData output



select @ResponseURL

*/
ALTER PROCEDURE [Direct.Framework].[ResolveURL]
	@ApplicationName varchar(1000) = '',
	@param1 varchar(1000) = '',
	@param2 varchar(1000) = '',
	@param3 varchar(1000) = '',
	@param4 varchar(1000) = '',
	@param5 varchar(1000) = '',
	@param6 varchar(1000) = '',
	@param7 varchar(1000) = '',
	@param8 varchar(1000) = '',
	@param9 varchar(1000) = '',
	@SessionID uniqueidentifier = null,
	@ContentType varchar(255) = null,
	@FullApplicationPath varchar(255) = null,
	@Resolved bit OUTPUT,
	@ErrorDescription varchar(max) OUTPUT,
	@ResponseURL varchar(1000) OUTPUT,
	@ResponseContentType varchar(255) OUTPUT,
	@ResponseStatusCode int OUTPUT,
	@ResponseRedirect bit OUTPUT,
	@ResponseIncludePostData bit OUTPUT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
	-- By default we were not able to resolve the URL
	SELECT @Resolved = 0

	-- Load param values into a table
	DECLARE @params TABLE (id int, val varchar(1000))
	INSERT INTO @params (id, val) VALUES (1, @param1)
	INSERT INTO @params (id, val) VALUES (2, @param2)
	INSERT INTO @params (id, val) VALUES (3, @param3)
	INSERT INTO @params (id, val) VALUES (4, @param4)
	INSERT INTO @params (id, val) VALUES (5, @param5)
	INSERT INTO @params (id, val) VALUES (6, @param6)
	INSERT INTO @params (id, val) VALUES (7, @param7)
	INSERT INTO @params (id, val) VALUES (8, @param8)
	INSERT INTO @params (id, val) VALUES (9, @param9)

	DECLARE @MaxParam int
	SELECT @MaxParam = 0
	SELECT @MaxParam = MAX(id) FROM @params WHERE val > ''

	DECLARE @TabParam int
	SELECT @TabParam = 3

	DECLARE @REDIRECTPAGE VARCHAR(255)
	
	SELECT @REDIRECTPAGE = '~/direct/default.aspx'

	-- Return results
	IF (@ErrorDescription IS NULL)
	BEGIN

		if(@ApplicationName = 'direct' and @param1 <> '' and @param2 = '')
		BEGIN
			SELECT @Resolved = 1,
				@ErrorDescription = '',
				@ResponseURL = @REDIRECTPAGE + '?queryid=' + @param1
					
		END


		if(@ApplicationName = 'direct' and @param1 <> '' and @param2 <> '')
		BEGIN
			SELECT @Resolved = 1,
				@ErrorDescription = '',
				@ResponseURL = @REDIRECTPAGE + '?queryid=' + @param1 + '&stop=true'
					
		END
	
		set	@ResponseContentType =''
		set	@ResponseStatusCode  =''
		set	@ResponseRedirect =0
		set	@ResponseIncludePostData =0
				
	END

END

GO

/****** Object:  StoredProcedure [Search.Framework].[ResolveURL]    Script Date: 4/26/2017 1:15:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Search.Framework].[ResolveURL]
@ApplicationName VARCHAR (1000)='', @param1 VARCHAR (1000)='', @param2 VARCHAR (1000)='', @param3 VARCHAR (1000)='', @param4 VARCHAR (1000)='', @param5 VARCHAR (1000)='', @param6 VARCHAR (1000)='', @param7 VARCHAR (1000)='', @param8 VARCHAR (1000)='', @param9 VARCHAR (1000)='', @SessionID UNIQUEIDENTIFIER=null, @ContentType VARCHAR (255)=null, @FullApplicationPath VARCHAR (255)=null, @Resolved BIT OUTPUT, @ErrorDescription VARCHAR (MAX) OUTPUT, @ResponseURL VARCHAR (1000) OUTPUT, @ResponseContentType VARCHAR (255) OUTPUT, @ResponseStatusCode INT OUTPUT, @ResponseRedirect BIT OUTPUT, @ResponseIncludePostData BIT OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
	-- By default we were not able to resolve the URL
	SELECT @Resolved = 0

	-- Load param values into a table
	DECLARE @params TABLE (id int, val varchar(1000))
	INSERT INTO @params (id, val) VALUES (1, @param1)
	INSERT INTO @params (id, val) VALUES (2, @param2)
	INSERT INTO @params (id, val) VALUES (3, @param3)
	INSERT INTO @params (id, val) VALUES (4, @param4)
	INSERT INTO @params (id, val) VALUES (5, @param5)
	INSERT INTO @params (id, val) VALUES (6, @param6)
	INSERT INTO @params (id, val) VALUES (7, @param7)
	INSERT INTO @params (id, val) VALUES (8, @param8)
	INSERT INTO @params (id, val) VALUES (9, @param9)

	DECLARE @MaxParam int
	SELECT @MaxParam = 0
	SELECT @MaxParam = MAX(id) FROM @params WHERE val > ''

	DECLARE @TabParam int
	SELECT @TabParam = 3

	DECLARE @REDIRECTPAGE VARCHAR(255)
	
	SELECT @REDIRECTPAGE = '~/search/default.aspx'

	-- Return results
	IF (@ErrorDescription IS NULL)
	BEGIN


		if(@Param1='all' and @Param2='')
		BEGIN
			SELECT @Resolved = 1,
				@ErrorDescription = '',
				@ResponseURL = @REDIRECTPAGE + '?tab=all'
		END		


		if(@Param1='all' and @Param2='results')
		BEGIN          
		
			SELECT @Resolved = 1,
				@ErrorDescription = '',
				@ResponseURL = @REDIRECTPAGE + '?tab=all&action=results'
							
		END


		if(@Param1='people' and @Param2='')
		BEGIN
			SELECT @Resolved = 1,
				@ErrorDescription = '',
				@ResponseURL = @REDIRECTPAGE  + '?tab=people'				
					
		END		
		if(@Param1='people' and @Param2='results')
		BEGIN
			SELECT @Resolved = 1,
				@ErrorDescription = '',
				@ResponseURL = @REDIRECTPAGE  + '?tab=people&action=results'				
					
		END		


set	@ResponseContentType =''
set	@ResponseStatusCode  =''
set	@ResponseRedirect =0
set	@ResponseIncludePostData =0



				
	END

END

GO

/****** Object:  StoredProcedure [Profile.Framework].[ResolveURL]    Script Date: 10/31/2013 12:53:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [Profile.Framework].[ResolveURL]
	@ApplicationName varchar(1000) = '',
	@param1 varchar(1000) = '',
	@param2 varchar(1000) = '',
	@param3 varchar(1000) = '',
	@param4 varchar(1000) = '',
	@param5 varchar(1000) = '',
	@param6 varchar(1000) = '',
	@param7 varchar(1000) = '',
	@param8 varchar(1000) = '',
	@param9 varchar(1000) = '',
	@SessionID uniqueidentifier = null,
	@ContentType varchar(255) = null,
	@FullApplicationPath varchar(255) = null,
	@Resolved bit = NULL OUTPUT,
	@ErrorDescription varchar(max) = NULL OUTPUT,
	@ResponseURL varchar(1000) = NULL OUTPUT,
	@ResponseContentType varchar(255) = NULL OUTPUT,
	@ResponseStatusCode int = NULL OUTPUT,
	@ResponseRedirect bit = NULL OUTPUT,
	@ResponseIncludePostData bit = NULL OUTPUT,
	@subject BIGINT = NULL OUTPUT,
	@predicate BIGINT = NULL OUTPUT,
	@object BIGINT = NULL OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- URL Pattern String:
	-- domainname	/{profile | display}	/{sNodeID | sAliasType/sAliasID}	/{pNodeID | pAliasType/pAliasID | sTab}	/{oNodeID | oAliasType/oAliasID | pTab}	/oTab	/sNodeID_pNodeID_oNodeID.rdf

	DECLARE @SessionHistory XML

	-- By default we were not able to resolve the URL
	SELECT @Resolved = 0

	-- Load param values into a table
	DECLARE @params TABLE (id int, val varchar(1000))
	INSERT INTO @params (id, val) VALUES (1, @param1)
	INSERT INTO @params (id, val) VALUES (2, @param2)
	INSERT INTO @params (id, val) VALUES (3, @param3)
	INSERT INTO @params (id, val) VALUES (4, @param4)
	INSERT INTO @params (id, val) VALUES (5, @param5)
	INSERT INTO @params (id, val) VALUES (6, @param6)
	INSERT INTO @params (id, val) VALUES (7, @param7)
	INSERT INTO @params (id, val) VALUES (8, @param8)
	INSERT INTO @params (id, val) VALUES (9, @param9)

	DECLARE @MaxParam int
	SELECT @MaxParam = 0
	SELECT @MaxParam = MAX(id) FROM @params WHERE val > ''

	DECLARE @Tab VARCHAR(1000)
	DECLARE @File VARCHAR(1000)
	DECLARE @ViewAs VARCHAR(50)
	
	SELECT @subject=NULL, @predicate=NULL, @object=NULL, @Tab=NULL, @File=NULL
	
	SELECT @File = val, @MaxParam = @MaxParam-1
		FROM @params
		WHERE id = @MaxParam and val like '%.%'

	DECLARE @pointer INT
	SELECT @pointer=1
	
	DECLARE @aliases INT
	SELECT @aliases = 0
	
	-- UCSF subject when Application name is based on PRETTY_URL
	DECLARE @PRETTY_URL VARCHAR(1000)
	DECLARE @InternalUserName VARCHAR(100)
	DECLARE @PersonID INT
	IF (@MaxParam IS NULL) 
	BEGIN
		SELECT @PersonID = PersonID from [Profile.Data].[Person] p JOIN [UCSF.].NameAdditions n ON
			p.InternalUserName = n.InternalUserName WHERE n.PrettyURL = @FullApplicationPath + '/' + @ApplicationName
  		SELECT @subject = i.nodeid from  [RDF.Stage].internalnodemap i with(nolock) where 
			i.class = 'http://xmlns.com/foaf/0.1/Person' and i.internalid = @PersonID
        IF @subject is not null
			SELECT @PRETTY_URL=@subject				
	END
	-- subject
	IF (@MaxParam >= @pointer)
	BEGIN
		SELECT @subject = CAST(val AS BIGINT), @pointer = @pointer + 1
			FROM @params 
			WHERE id=@pointer AND val NOT LIKE '%[^0-9]%'
		IF @subject IS NULL AND @MaxParam > @pointer
			SELECT @subject = NodeID, @pointer = @pointer + 2, @aliases = @aliases + 1
				FROM [RDF.].Alias 
				WHERE AliasType = (SELECT val FROM @params WHERE id = @pointer)
					AND AliasID = (SELECT val FROM @params WHERE id = @pointer+1)
		IF @subject IS NULL
			SELECT @ErrorDescription = 'The subject cannot be found.'
	END

	-- UCSF if we only have Subject and this is for a person, replace with PRETTY_URL
	IF (@MaxParam = 1) AND (@Subject IS NOT NULL)
	    SELECT @InternalUserName = InternalUserName FROM [Profile.Data].[Person] WHERE
			PersonID = (select InternalID from [RDF.Stage].internalnodemap i with(nolock) where i.class = 'http://xmlns.com/foaf/0.1/Person' and i.nodeId = @Subject)		
		SELECT @PRETTY_URL = PrettyURL from [UCSF.].[NameAdditions] WHERE InternalUserName = @InternalUserName

	-- predicate
	IF (@MaxParam >= @pointer) AND (@subject IS NOT NULL)
	BEGIN
		SELECT @predicate = CAST(val AS BIGINT), @pointer = @pointer + 1
			FROM @params 
			WHERE id=@pointer AND val NOT LIKE '%[^0-9]%'
		IF @predicate IS NULL AND @MaxParam > @pointer
			SELECT @predicate = NodeID, @pointer = @pointer + 2, @aliases = @aliases + 1
				FROM [RDF.].Alias 
				WHERE AliasType = (SELECT val FROM @params WHERE id = @pointer)
					AND AliasID = (SELECT val FROM @params WHERE id = @pointer+1)
		IF @predicate IS NULL AND @MaxParam = @pointer
			SELECT @Tab=(SELECT val FROM @params WHERE id = @pointer)
		IF @predicate IS NULL AND @Tab IS NULL
			SELECT @ErrorDescription = 'The predicate cannot be found.'
	END
	
	-- object
	IF (@MaxParam >= @pointer) AND (@predicate IS NOT NULL)
	BEGIN
		SELECT @object = CAST(val AS BIGINT), @pointer = @pointer + 1
			FROM @params 
			WHERE id=@pointer AND val NOT LIKE '%[^0-9]%'
		IF @object IS NULL AND @MaxParam > @pointer
			SELECT @object = NodeID, @pointer = @pointer + 2, @aliases = @aliases + 1
				FROM [RDF.].Alias 
				WHERE AliasType = (SELECT val FROM @params WHERE id = @pointer)
					AND AliasID = (SELECT val FROM @params WHERE id = @pointer+1)
		IF @object IS NULL AND @MaxParam = @pointer
			SELECT @Tab=(SELECT val FROM @params WHERE id = @pointer)
		IF @object IS NULL AND @Tab IS NULL
			SELECT @ErrorDescription = 'The object cannot be found.'
	END
	
	-- tab
	IF (@MaxParam = @pointer) AND (@object IS NOT NULL) AND (@Tab IS NULL)
		SELECT @Tab=(SELECT val FROM @params WHERE id = @pointer)
	
	-- Return results
	IF (@ErrorDescription IS NULL)
	BEGIN

		declare @basePath nvarchar(400)
		select @basePath = value from [Framework.].Parameter where ParameterID = 'basePath'

		-- Default
		SELECT	@Resolved = 1,
				@ErrorDescription = '',
				@ResponseContentType = @ContentType,
				@ResponseStatusCode = 200,
				@ResponseRedirect = 0,
				@ResponseIncludePostData = 0,
				@ResponseURL = '~/profile/Profile.aspx?'
					+ 'subject=' + IsNull(cast(@subject as varchar(50)),'')
					+ '&predicate=' + IsNull(cast(@predicate as varchar(50)),'')
					+ '&object=' + IsNull(cast(@object as varchar(50)),'')
					+ '&tab=' + IsNull(@tab,'')
					+ '&file=' + IsNull(@file,'')

		DECLARE @FileRDF varchar(1000)
		SELECT @FileRDF =	IsNull(cast(@subject as varchar(50)),'')
							+IsNull('_'+cast(@predicate as varchar(50)),'')
							+IsNull('_'+cast(@object as varchar(50)),'')+'.rdf'

		DECLARE @FilePresentationXML varchar(1000)
		SELECT @FilePresentationXML = 'presentation_'
							+IsNull(cast(@subject as varchar(50)),'')
							+IsNull('_'+cast(@predicate as varchar(50)),'')
							+IsNull('_'+cast(@object as varchar(50)),'')+'.xml'

		IF (@ApplicationName = 'profile') AND (@File = @FileRDF)
				-- Display as RDF
				SELECT	@ResponseContentType = 'application/rdf+xml',
						@ResponseURL = @ResponseURL + '&viewas=RDF'
		ELSE IF (@ApplicationName = 'profile') AND (@File = @FilePresentationXML)
				-- Display PresentationXML
				SELECT	@ResponseContentType = 'application/rdf+xml',
						@ResponseURL = @ResponseURL + '&viewas=PresentationXML'
		ELSE IF (@ApplicationName = 'profile') AND (@ContentType = 'application/rdf+xml')
				-- Redirect 303 to the RDF URL
				SELECT	@ResponseContentType = 'application/rdf+xml',
						@ResponseStatusCode = 303,
						@ResponseRedirect = 1,
						@ResponseIncludePostData = 1,
						@ResponseURL = @basePath + '/profile'
							+ IsNull('/'+cast(@subject as varchar(50)),'')
							+ IsNull('/'+cast(@predicate as varchar(50)),'')
							+ IsNull('/'+cast(@object as varchar(50)),'')
							+ '/' + @FileRDF
		ELSE IF (@ApplicationName = 'profile')
				-- Redirect 303 to the HTML URL
				SELECT	@ResponseContentType = @ContentType,
						@ResponseStatusCode = (CASE WHEN @PRETTY_URL IS NOT NULL THEN 301 ELSE 303 END),
						@ResponseRedirect = 1,
						@ResponseIncludePostData = 1,
						@ResponseURL = ISNULL(@PRETTY_URL, @basePath + '/display' 
							+ (CASE WHEN @Subject IS NULL THEN ''
									ELSE IsNull((SELECT TOP 1 '/'+Subject
											FROM (
												SELECT 1 k, AliasType+'/'+AliasID Subject
													FROM [RDF.].Alias
													WHERE NodeID = @Subject AND Preferred = 1
												UNION ALL
												SELECT 2, CAST(@Subject AS VARCHAR(50))
											) t
											ORDER BY k, Subject),'')
									END)
							+ (CASE WHEN @Predicate IS NULL THEN ''
									ELSE IsNull((SELECT TOP 1 '/'+Subject
											FROM (
												SELECT 1 k, AliasType+'/'+AliasID Subject
													FROM [RDF.].Alias
													WHERE NodeID = @Predicate AND Preferred = 1
												UNION ALL
												SELECT 2, CAST(@Predicate AS VARCHAR(50))
											) t
											ORDER BY k, Subject),'')
									END)
							+ (CASE WHEN @Object IS NULL THEN ''
									ELSE IsNull((SELECT TOP 1 '/'+Subject
											FROM (
												SELECT 1 k, AliasType+'/'+AliasID Subject
													FROM [RDF.].Alias
													WHERE NodeID = @Object AND Preferred = 1
												UNION ALL
												SELECT 2, CAST(@Object AS VARCHAR(50))
											) t
											ORDER BY k, Subject),'')
									END)
							+ (CASE WHEN @MaxParam >= 1 AND @Pointer <= 1 THEN '/'+@param1 ELSE '' END)
							+ (CASE WHEN @MaxParam >= 2 AND @Pointer <= 2 THEN '/'+@param2 ELSE '' END)
							+ (CASE WHEN @MaxParam >= 3 AND @Pointer <= 3 THEN '/'+@param3 ELSE '' END)
							+ (CASE WHEN @MaxParam >= 4 AND @Pointer <= 4 THEN '/'+@param4 ELSE '' END)
							+ (CASE WHEN @MaxParam >= 5 AND @Pointer <= 5 THEN '/'+@param5 ELSE '' END)
							+ (CASE WHEN @MaxParam >= 6 AND @Pointer <= 6 THEN '/'+@param6 ELSE '' END)
							+ (CASE WHEN @MaxParam >= 7 AND @Pointer <= 7 THEN '/'+@param7 ELSE '' END)
							+ (CASE WHEN @MaxParam >= 8 AND @Pointer <= 8 THEN '/'+@param8 ELSE '' END)
							+ (CASE WHEN @MaxParam >= 9 AND @Pointer <= 9 THEN '/'+@param9 ELSE '' END))
		ELSE IF (@ApplicationName = 'presentation')
				-- Display as HTML
				SELECT	@ResponseURL = @ResponseURL + '&viewas=PresentationXML'
		ELSE
				-- Display as HTML
				SELECT	@ResponseURL = replace(@ResponseURL,'~/Profile/Profile.aspx','~/Profile/Display.aspx') + '&viewas=HTML'


		IF @ResponseRedirect = 0
			SELECT @ResponseURL = @ResponseURL + '&ContentType='+IsNull(@ResponseContentType,'') + '&StatusCode='+IsNull(cast(@ResponseStatusCode as varchar(50)),'')

	END

	/*
		Valid Rest Paths (T=text, N=numeric):

		T
		T/N
			T/N/N
				T/N/N/N
					T/N/N/N/T
				T/N/N/T
				T/N/N/T/T
					T/N/N/T/T/T
			T/N/T
			T/N/T/T
				T/N/T/T/N
					T/N/T/T/N/T
				T/N/T/T/T
				T/N/T/T/T/T
					T/N/T/T/T/T/T
		T/T/T
			T/T/T/N
				T/T/T/N/N
					T/T/T/N/N/T
				T/T/T/N/T
				T/T/T/N/T/T
					T/T/T/N/T/T/T
			T/T/T/T
			T/T/T/T/T
				T/T/T/T/T/N
					T/T/T/T/T/N/T
				T/T/T/T/T/T
				T/T/T/T/T/T/T
					T/T/T/T/T/T/T/T
	*/

END





GO







