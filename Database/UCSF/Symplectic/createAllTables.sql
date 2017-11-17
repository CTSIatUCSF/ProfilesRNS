USE [profiles_ucsf]
GO

/****** Object:  Table [Symplectic.Elements].[AllXML]    Script Date: 9/2/2016 4:24:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

if exists (
		select * from INFORMATION_SCHEMA.TABLES 
			where table_schema='UCSF.'
				and table_name='Publication.URL'
)
		begin
			truncate table [UCSF.].[Publication.URL]
		END
else 
		begin
			CREATE TABLE [UCSF.].[Publication.URL](
				PMID int NOT NULL,
				DBType varchar(50),
				ISSN varchar(20),
				DOI varchar(1000),
				URL varchar(1000)
			)
		end




if not exists (SELECT  * FROM    sys.schemas
                WHERE   name like 'Symplectic.Elements')
exec ('CREATE SCHEMA [Symplectic.Elements] AUTHORIZATION [dbo]');

-----------------[Symplectic.Elements].[UserXML]----------
if exists (
		select * from INFORMATION_SCHEMA.TABLES 
			where table_schema='Symplectic.Elements'
				and table_name='UserXML'
)
		begin
			drop table [Symplectic.Elements].[UserXML];
		END


CREATE TABLE [Symplectic.Elements].[userXML](
	   [username] varchar(30) NOT NULL,
	   [lib_userid] [varchar](30) NOT NULL, 
	   [displayname] varchar(100), 
       [XmlCol] [xml] NULL, --pageXML
       [createdDT] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
       [username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

--- [Symplectic.Elements].[pagesXML] ----

if exists (
		select * from INFORMATION_SCHEMA.TABLES 
			where table_schema='Symplectic.Elements'
				and table_name='pagesXML'
)
		begin
			drop table [Symplectic.Elements].[pagesXML];
		END


CREATE TABLE [Symplectic.Elements].[pagesXML](
       [lib_userid] [varchar](30) NOT NULL, --user CDL ID
       [page] int NOT NULL, --for multiple pages with publication
       [XmlCol] [xml] NULL, --pageXML
       [createdDT] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
       [lib_userid] ASC,
       [page] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, 
	ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

---- [Symplectic.Elements].[PubXML] -------------------
if exists (
		select * from INFORMATION_SCHEMA.TABLES 
			where table_schema='Symplectic.Elements'
				and table_name='PubXML'
)
		begin
			drop table [Symplectic.Elements].[PubXML];
		END



CREATE TABLE [Symplectic.Elements].[pubXML](
       [lib_pubid] [varchar](30) NOT NULL, --publication CDL ID
       [XmlCol] [xml] NULL, --publication XML
	   [PubType] [varchar] (60) NULL,
	   [Title] [varchar] (600),
	   [Authors] [varchar] (500), 
	   [PMID] [int] NULL,
	   [PMCID] [nvarchar] (55) NULL,
	   [concepts] [varchar](500) NULL, --comma delimited  structures with possible dups (need to clean) , any parameter could be empty [<source>|<schema>(<concept>)]
	   [OtherDB] [varchar] (10) NULL, 
	   [OtherID] [varchar] (50) NULL,
	   [OtherLink] [varchar] (300) NULL,
       [createdDT] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
       [lib_pubid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, 
	ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

--- [Symplectic.Elements].[UserPublication]-------------
if exists (
		select * from INFORMATION_SCHEMA.TABLES 
			where table_schema='Symplectic.Elements'
				and table_name='UserPublication'
)
		begin
			drop table [Symplectic.Elements].[UserPublication];
		END

CREATE TABLE [Symplectic.Elements].[UserPublication](
       [username] [varchar](30) NOT NULL, --UCSF username
	   [personid] int,
       [lib_pubid] [varchar](30) NOT NULL 
PRIMARY KEY CLUSTERED 
(
       [username] ASC,
	   [lib_pubid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, 
	ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
);

-----[Profile.Data].[Publication.Import.PubData] ---------------
if exists (
		select * from INFORMATION_SCHEMA.TABLES 
			where table_schema='Profile.Data'
				and table_name='Publication.Import.PubData'
)
		begin
			drop table [Profile.Data].[Publication.Import.PubData];
		END


CREATE TABLE [Profile.Data].[Publication.Import.PubData] (
	ImportPubID int primary key,
	ActualIDType varchar(50),
	ActualID varchar(100),
	X xml,
	Data nvarchar(max),
	URL varchar(2000),
	ParseDT datetime
)

--CREATE UNIQUE NONCLUSTERED INDEX idx_ActualTypeID ON [Profile.Data].[Publication.Import.PubData] (ActualIDType, ActualID)

--- [Profile.Data].[Publication.Import.Author];---
if exists (
		select * from INFORMATION_SCHEMA.TABLES 
			where table_schema='Profile.Data'
				and table_name='Publication.Import.Author'
)
		begin
			drop table [Profile.Data].[Publication.Import.Author];
		END

CREATE TABLE [Profile.Data].[Publication.Import.Author] (
	AuthorID int identity(1,1) primary key,
	ImportPubID int,
	personID int,
	AuthorRank int,
	FullName varchar(250),
	LastName varchar(100),
	ForeName varchar(100),
	FirstName varchar(100),
	MiddleName varchar(100),
	PrefixName varchar(20),
	SuffixName varchar(20),
	AuthorName varchar(100),
	Email varchar(250)
)

CREATE NONCLUSTERED INDEX idx_PubIDRank ON [Profile.Data].[Publication.Import.Author] (ImportPubID, AuthorRank)


--- [Profile.Data].[Publication.Import.Pub2Person]------
/*
if exists (
		select * from INFORMATION_SCHEMA.TABLES 
			where table_schema='Profile.Data'
				and table_name='Publication.Import.Pub2Person'
)
		begin
			drop table [Profile.Data].[Publication.Import.Pub2Person];
		END

CREATE TABLE [Profile.Data].[Publication.Import.Pub2Person] (
	ImportAuthorID int identity(1,1) primary key,
	ActualIDType varchar(50),
	ActualID varchar(100),
	PersonID int,
	AuthorRank int,
	ImportPubID int
)

CREATE UNIQUE NONCLUSTERED INDEX idx_ActualTypeIDPerson ON [Profile.Data].[Publication.Import.Pub2Person] (ActualIDType, ActualID, PersonID)
*/
--- [Profile.Data].[Publication.Import.General]------
if exists (
		select * from INFORMATION_SCHEMA.TABLES 
			where table_schema='Profile.Data'
				and table_name='Publication.Import.General'
)
		begin
			drop table [Profile.Data].[Publication.Import.General];
		END


CREATE TABLE [Profile.Data].[Publication.Import.General] (
	ImportPubID int primary key,
	ActualIDType varchar(50) not null,
	ActualID varchar(50) not null,
	ItemType varchar(100),
	SourceType varchar(100),
	ItemTitle varchar(4000),
	SourceTitle varchar(1000),
	SourceAbbr varchar(1000),
	Volume varchar(255),
	Issue varchar(255),
	Pagination varchar(255),
	PubDate datetime,
	ISSN varchar(20),
	DOI varchar(1000),
	PMID int,
	URL varchar(1000),
	Authors varchar(max),
	Reference varchar(max),
	TimesCited int
)


---- [Profile.Data].[Publication.Import.Concept] ------
if exists (
		select * from INFORMATION_SCHEMA.TABLES 
			where table_schema='Profile.Data'
				and table_name='Publication.Import.Concept'
)
		begin
			drop table [Profile.Data].[Publication.Import.Concept];
		END

CREATE TABLE [Profile.Data].[Publication.Import.Concept] (
	ConceptID int identity(1,1) primary key,
	ImportPubID int,
	Category varchar(20),
	IsActive bit,
	ConceptType varchar(50),
	ConceptCode varchar(1000),
	Descriptor varchar(255),
	Qualifier varchar(255),
	MajorTopicYN char(1)
)

CREATE NONCLUSTERED INDEX idx_cadq ON [Profile.Data].[Publication.Import.Concept] (Category, IsActive, Descriptor, Qualifier)


GO


