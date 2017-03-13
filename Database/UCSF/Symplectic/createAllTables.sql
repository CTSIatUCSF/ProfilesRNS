
USE [profiles_ucsf]
GO

/****** Object:  Table [Symplectic.Elements].[AllXML]    Script Date: 9/2/2016 4:24:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO


if not exists (SELECT  * FROM    sys.schemas
                WHERE   name like 'Symplectic.Elements')
exec ('CREATE SCHEMA [Symplectic.Elements] AUTHORIZATION [dbo]');

if exists (
		select * from INFORMATION_SCHEMA.TABLES 
			where table_schema='Symplectic.Elements'
				and table_name='Publication'
)
		begin
			drop table [Symplectic.Elements].[Publication];
		END

if exists (
		select * from INFORMATION_SCHEMA.TABLES 
			where table_schema='Symplectic.Elements'
				and table_name='Details'
)
		begin
			drop table [Symplectic.Elements].[Details];
		END
if exists (
		select * from INFORMATION_SCHEMA.TABLES 
			where table_schema='Symplectic.Elements'
				and table_name='PubXML'
)
		begin
			drop table [Symplectic.Elements].[PubXML];
		END
if exists (
		select * from INFORMATION_SCHEMA.TABLES 
			where table_schema='Symplectic.Elements'
				and table_name='UserXML'
)
		begin
			drop table [Symplectic.Elements].[UserXML];
		END


if exists (
		SELECT [name] FROM sys.tables
		where [name] ='[Symplectic.Elements].[Details]'
)
		begin
			drop table [Symplectic.Elements].[Details];
		END

CREATE TABLE [Symplectic.Elements].[Publication](
	[username] [varchar](30) NOT NULL,
	[displayName] [varchar](max) NULL,
	[uclib_userid] [int] NOT NULL,
	[uclib_pubid] [int] NOT NULL,
	[PMID] [int] NULL,
	[PCMID] [varchar](30) NULL,
	[AUTHORS] [varchar](max) NULL,
	[TITLE] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY];

CREATE TABLE [Symplectic.Elements].[userXML](
	[idtype] [varchar](30) NOT NULL,
	[id] [varchar](30) NOT NULL,
	[page] int NOT NULL,
	[XmlCol] [xml] NULL,
	[createdDT] [datetime] NOT NULL,
	[updatedDT] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[idtype] ASC,
	[id] ASC,
	[page] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

CREATE TABLE [Symplectic.Elements].[pubXML](
	[idtype] [varchar](30) NOT NULL,
	[id] [varchar](30) NOT NULL,
	[XmlCol] [xml] NULL,
	[createdDT] [datetime] NOT NULL,
	[updatedDT] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[idtype] ASC,
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


