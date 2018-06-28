--++++++++++++++++++ For collecting data from import DBs +++++++++++++++++++++++
USE [import_profiles]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create schema [UCSF.ImportExtra] authorization dbo
create schema [UCSF.ExportExtra] authorization dbo

CREATE TABLE [UCSF.ImportExtra].[personalProxies](
	[proxyid] [nvarchar](50) NULL,
	[forid] [nvarchar](50) NULL,
	[Canbeproxy] [smallint] NULL
) ON [PRIMARY]

GO

CREATE TABLE [UCSF.ImportExtra].[globalProxies](
	[proxyid] [nvarchar](50) NULL,
	[Institution] [nvarchar](255) NULL,
	[Department] [nvarchar](255) NULL,
	[Canbeproxy] [smallint] NULL
) ON [PRIMARY]

GO
--+++++++
/****** Object:  Table [UCSF.Import].[NameForLogin]    Script Date: 6/8/2018 10:36:49 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [UCSF.Import].[NameForLogin](
	[internalusername] [nchar](50) NULL,
	[nameforlogin] [nchar](50) NULL
) ON [PRIMARY]

GO
--+++++++++++++++++ For any new Institution ++++++++++++++++++++++
create database import_<InstitutionAbbreviation>
use import_<InstitutionAbbreviation>
CREATE TABLE [dbo].[_person_import](
	[internalusername] [nvarchar](255) NULL,
	[firstname] [nvarchar](255) NULL,
	[middlename] [nvarchar](255) NULL,
	[lastname] [nvarchar](255) NULL,
	[displayname] [nvarchar](255) NULL,
	[suffix] [nvarchar](255) NULL,
	[addressline1] [nvarchar](255) NULL,
	[addressline2] [nvarchar](255) NULL,
	[addressline3] [nvarchar](255) NULL,
	[addressline4] [nvarchar](255) NULL,
	[addressstring] [nvarchar](255) NULL,
	[city] [nvarchar](255) NULL,
	[state] [nvarchar](1000) NULL,
	[zip] [nvarchar](1000) NULL,
	[building] [nvarchar](1000) NULL,
	[room] [nvarchar](1000) NULL,
	[floor] int NULL,
	[latitude] [numeric](18, 14) NULL,
	[longitude] [numeric](18, 14) NULL,
	[phone] [nvarchar](1000) NULL,
	[fax] [nvarchar](1000) NULL,
	[emailaddr] [nvarchar](1000) NULL,
	[isactive] [int] NULL,
	[isvisible] [int] NULL
) ON [PRIMARY]
	
CREATE TABLE [dbo].[_person_affiliations_import](
	[internalusername] [nvarchar](1000) NULL,
	[title] [nvarchar](1000) NULL,
	[emailaddr] [nvarchar](1000) NULL,
	[primaryaffiliation] [int] NULL,
	[affiliationorder] [int] NULL,
	[institutionname] [nvarchar](1000) NULL,
	[institutionabbreviation] [nvarchar](1000) NULL,
	[departmentname] [nvarchar](1000) NULL,
	[departmentvisible] [int] NULL,
	[divisionname] [nvarchar](1000) NULL,
	[facultyrank] [nvarchar](1000) NULL,
	[facultyrankorder] [int] NULL
) ON [PRIMARY]

CREATE TABLE [dbo].[_users_import](
	[internalusername] [nvarchar](1000) NULL,
	[firstname] [nvarchar](1000) NULL,
	[lastname] [nvarchar](1000) NULL,
	[displayname] [nvarchar](1000) NULL,
	[institution] [nvarchar](1000) NULL,
	[department] [nvarchar](1000) NULL,
	[emailaddr] [nvarchar](1000) NULL,
	[canbeproxy] [int] NULL
) ON [PRIMARY]

CREATE TABLE [dbo].[_userproxy_import](
	[internalusername] [nvarchar](150) NULL,
	[proxyid] [nvarchar](10) NULL,
	[Firstname] [nvarchar](50) NULL,
	[Lastname] [nvarchar](50) NULL,
	[Department] [nvarchar](255) NULL,
	[Canbeproxy] [smallint] NULL
) ON [PRIMARY]

CREATE TABLE [dbo].[_userlogin_import](
	[internalusername] [nchar](10) NULL,
	[nameforlogin] [nchar](50) NULL
) ON [PRIMARY]


CREATE TABLE [dbo].[_globaluserproxy_import](
	[Internalusername] [nvarchar](10) NULL,
	[Firstname] [nvarchar](50) NULL,
	[Lastname] [nvarchar](50) NULL,
	[Displayname] [nvarchar](100) NULL,
	[Institution] [nvarchar](255) NULL,
	[Department] [nvarchar](255) NULL,
	[Canbeproxy] [smallint] NULL,
) ON [PRIMARY]

