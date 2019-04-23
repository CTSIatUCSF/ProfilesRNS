
/****** Object:  Table [External.Publication].[Import.PubData]    Script Date: 4/11/2019 10:07:54 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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


if exists (
		select * from INFORMATION_SCHEMA.TABLES 
			where table_schema='External.Publication'
				and table_name='Import.PubData'
)
		begin
		print 'Table Pubdata exists'
			truncate table [External.Publication].[Import.PubData]
		END
else 
		begin
		print 'Table Pubdata does not exist'
			CREATE TABLE [External.Publication].[Import.PubData](
				ImportPubID int identity(-1,-1) primary key,
				ImportFileID int,
				ActualIDType varchar(50),
				ActualID varchar(100),
				X xml,
				Data nvarchar(max),
				AuthorsList nvarchar(1000),
				URL varchar(2000),
				ParseDT datetime
			)
		END

if exists (
		select * from INFORMATION_SCHEMA.TABLES 
			where table_schema='External.Publication'
				and table_name='AutorIDs'
)
		begin
			truncate table [External.Publication].[AutorIDs]
		END
else 
		begin
			CREATE TABLE [External.Publication].[AutorIDs](
				AuthorIDType varchar(50),
				AuthorID varchar(100),
				FirstName varchar(100),
				LastName varchar(100),
				InternaluserName varchar(50)
			)
		end