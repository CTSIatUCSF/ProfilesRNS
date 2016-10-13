---------------------------------------------------------------------------------------------------------------------
--
--	Create Schema
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
	[InternalUserName] [varchar](9) NOT NULL,
	[CleanFirst] [nvarchar](50) NULL,
	[CleanMiddle] [nvarchar](50) NULL,
	[CleanLast] [nvarchar](50) NULL,
	[CleanSuffix] [nvarchar](50) NULL,
	[GivenName] [nvarchar](50) NULL,  
	[CleanGivenName] [nvarchar](50) NULL,  
	[UrlName] [nvarchar](255) NULL,
	[Strategy] [nvarchar](50) NULL,
	[PublishingFirst] [nvarchar](50) NULL,
 CONSTRAINT [PK_uniqueNames] PRIMARY KEY CLUSTERED 
(
	[InternalUserName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]


CREATE UNIQUE INDEX urlNameUnique ON [UCSF.].[NameAdditions](UrlName)
WHERE UrlName IS NOT NULL
GO

SET ANSI_PADDING OFF
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
      ,na.UrlName
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
  FROM [Profile.Data].[Person] p 
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
					 p.UrlName,
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

---------------------------------------------------------------------------------------------------------------------
--
--	Create Stored Procedures
--
---------------------------------------------------------------------------------------------------------------------

/****** Object:  StoredProcedure [UCSF.].[CreateURLNames]    Script Date: 10/11/2013 10:52:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [UCSF.].[CreateURLNames] 
AS
BEGIN
		
	DECLARE @id varchar(9)
	DECLARE @CleanFirst nvarchar(255)
	DECLARE @CleanMiddle nvarchar(255)
	DECLARE @CleanLast nvarchar(255)
	DECLARE @CleanSuffix nvarchar(255)
	DECLARE @CleanGivenName nvarchar(255)
	DECLARE @UrlName nvarchar(255)
	DECLARE @Strategy nvarchar(50)
	DECLARE @i int
		
	WHILE exists (SELECT *
		FROM [UCSF.].[NameAdditions] WHERE UrlName is null)
	BEGIN
		SELECT TOP 1 @id=internalusername,
					 @CleanFirst=CleanFirst, 
					 @CleanMiddle=CleanMiddle,
					 @CleanLast=CleanLast,
					 @CleanSuffix=CleanSuffix,
 					 @CleanGivenName=CleanGivenName
		FROM [UCSF.].[NameAdditions] WHERE UrlName is null ORDER BY len(CleanMiddle) + len(CleanSuffix)					 

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
		SET @UrlName = @CleanFirst + '.' + @CleanLast -- first and last
		
		IF exists (SELECT * from [UCSF.].[NameAdditions] WHERE UrlName = @UrlName) AND len(@CleanMiddle) > 0
		BEGIN
			SET @strategy = 'P.I.L'
			SET @UrlName = @CleanFirst + '.' + substring(@CleanMiddle,1,1) + '.' + @CleanLast -- middle initial
		END
		IF exists (SELECT * from [UCSF.].[NameAdditions] WHERE UrlName = @UrlName) AND len(@CleanMiddle) > 0
		BEGIN
			SET @strategy = 'P.M.L'
			SET @UrlName = @CleanFirst + '.' + @CleanMiddle + '.' + @CleanLast -- middle name
		END
		IF exists (SELECT * from [UCSF.].[NameAdditions] WHERE UrlName = @UrlName) AND len(@CleanSuffix) > 0
		BEGIN
			SET @strategy = 'P.L.S'
			SET @UrlName = @CleanFirst + '.' + @CleanLast + '.' + @CleanSuffix -- suffix
		END
		IF exists (SELECT * from [UCSF.].[NameAdditions] WHERE UrlName = @UrlName) AND len(@CleanMiddle) > 0 AND len(@CleanSuffix) > 0
		BEGIN
			SET @strategy = 'P.I.L.S'
			SET @UrlName = @CleanFirst + '.' + substring(@CleanMiddle,1,1) + '.' + @CleanLast + '.' + @CleanSuffix-- middle initial and suffix
		END
		IF exists (SELECT * from [UCSF.].[NameAdditions] WHERE UrlName = @UrlName) AND len(@CleanMiddle) > 0 AND len(@CleanSuffix) > 0
		BEGIN
			SET @strategy = 'P.M.L.S'
			SET @UrlName = @CleanFirst + '.' + @CleanMiddle + '.' + @CleanLast + '.' + @CleanSuffix -- middle name and suffix
		END
		-- if all else fails, add numbers
		SET @i = 2
		WHILE exists (SELECT * from [UCSF.].[NameAdditions] WHERE UrlName = @UrlName)
		BEGIN
			SET @strategy = 'P.L.N'
			SET @UrlName = @CleanFirst + '.' + @CleanLast + '.' + CAST(@i as varchar)			
			SET @i = @i + 1
		END				
		-- it should be unique at this point
		UPDATE [UCSF.].[NameAdditions] SET UrlName = @UrlName, [Strategy] = @strategy WHERE internalusername = @id
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

