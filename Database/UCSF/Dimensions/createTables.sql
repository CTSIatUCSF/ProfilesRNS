 --create schema [External.Publication] AUTHORIZATION App_Profiles10

if exists (
		select * from INFORMATION_SCHEMA.TABLES 
			where table_schema='UCSF.'
				and table_name='ExternalID'
)
		begin
			drop table  [UCSF.].[ExternalID]
		END
else 
		begin
			CREATE TABLE [UCSF.].[ExternalID](
				[PublicationSource] [varchar](50) NULL,
				[SourceAuthorID] [varchar](100) NOT NULL,
				[FirstName] [varchar](100) NOT NULL,
				[LastName] [varchar](100) NOT NULL,
				[PersonID] [int] NOT NULL
			CONSTRAINT [PK__personid__72C60C4A] PRIMARY KEY CLUSTERED 
			(
				[PersonID] ASC
			)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, 
				ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
			) ON [PRIMARY] 
		end

if exists (
		select * from INFORMATION_SCHEMA.TABLES 
			where table_schema='Profile.Data'
				and table_name='Publication.Import.Publication'
)
		begin
			drop table [Profile.Data].[Publication.Import.Publication];
		END
CREATE TABLE  [Profile.Data].[Publication.Import.Publication] (
	ImportFileID int identity(1,1) primary key,
	FileFormat varchar(50),
	DataFileName varchar(1000),
	MappingFileName varchar(1000),
	DataFile nvarchar(max),
	MappingFile nvarchar(max),
	ParseDT datetime
)

if exists (
		select * from INFORMATION_SCHEMA.TABLES 
			where table_schema='Profile.Data'
				and table_name='Publication.Import.PubData'
)
		begin
			drop table [Profile.Data].[Publication.Import.PubData];
		END
CREATE TABLE [Profile.Data].[Publication.Import.PubData] (
	ImportPubID int identity(-1,-1) primary key,
	ImportFileID int,
	ActualIDType varchar(50),
	ActualID varchar(100),
	X xml,
	Data nvarchar(max),
	URL varchar(2000),
	ParseDT datetime
)

CREATE UNIQUE NONCLUSTERED INDEX idx_ActualTypeID ON [Profile.Data].[Publication.Import.PubData] (ActualIDType, ActualID)

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
	ImportFileID int,
	ActualIDType varchar(50),
	ActualID varchar(100),
	PersonID int,
	AuthorRank int,
	ImportPubID int
)

CREATE UNIQUE NONCLUSTERED INDEX idx_ActualTypeIDPerson ON [Profile.Data].[Publication.Import.Pub2Person] (ActualIDType, ActualID, PersonID)

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
	ImportFileID int,
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

CREATE NONCLUSTERED INDEX idx_ImportFileID ON [Profile.Data].[Publication.Import.General] (ImportFileID)

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
	AuthorRank int,
	SourceAuthorID varchar(50),
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

