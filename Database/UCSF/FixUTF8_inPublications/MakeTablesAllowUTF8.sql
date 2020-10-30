use ProfilesRNS
alter table  [Profile.Data].[Publication.PubMed.General]
alter column [ArticleTitle] [nvarchar](4000) NULL
alter table  [Profile.Data].[Publication.PubMed.General]
alter column [Authors] [nvarchar](4000) NULL;
alter table [Profile.Data].[Publication.PubMed.General.Stage]
alter column [ArticleTitle] [nvarchar](4000) NULL;
alter table [Profile.Data].[Publication.PubMed.General.Stage]
alter column [Authors] [nvarchar](4000) NULL;

DECLARE @needIndexResource int=0
IF EXISTS
(
SELECT 1 FROM sys. indexes
WHERE name='idx_PublicationEntityInformationResourceIsActive' 
	AND object_id = OBJECT_ID('[Profile.Data].[Publication.Entity.InformationResource]')
)
BEGIN
drop INDEX [idx_PublicationEntityInformationResourceIsActive] 
	on [Profile.Data].[Publication.Entity.InformationResource]
set @needIndexResource=1 
END
alter TABLE [Profile.Data].[Publication.Entity.InformationResource]
alter column [Reference] [nvarchar](MAX) NULL
alter TABLE [Profile.Data].[Publication.Entity.InformationResource]
alter column [Authors] [nvarchar](MAX) NULL
alter TABLE [Profile.Data].[Publication.Entity.InformationResource]
alter column [EntityName] [nvarchar](4000) NULL
if @needIndexResource=1
BEGIN
CREATE NONCLUSTERED INDEX [idx_PublicationEntityInformationResourceIsActive] 
	ON [Profile.Data].[Publication.Entity.InformationResource]
(
	[IsActive] ASC
)
INCLUDE ( 	[EntityID],
	[PubYear],
	[PMID],
	[EntityDate],
	[Reference]
	) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, 
		DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END
GO


DECLARE @needIndexAuthor int=0
IF EXISTS
(
SELECT 1 FROM sys. indexes
WHERE name='idx_PublicationEntityAuthorshipIsActive' 
	AND object_id = OBJECT_ID('[Profile.Data].[Publication.Entity.Authorship]')
)
BEGIN
drop INDEX [idx_PublicationEntityAuthorshipIsActive] 
on [Profile.Data].[Publication.Entity.Authorship]
set @needIndexAuthor=1 
END

alter TABLE [Profile.Data].[Publication.Entity.Authorship]
alter column [EntityName] [nvarchar](4000) NULL

if @needIndexAuthor =1
Begin
CREATE NONCLUSTERED INDEX [idx_PublicationEntityAuthorshipIsActive] 
	ON [Profile.Data].[Publication.Entity.Authorship]
(
	[IsActive] ASC
)
INCLUDE ( 	[EntityID],
	[EntityName],
	[EntityDate],
	[authorPosition],
	[authorRank],
	[PersonID],
	[numberOfAuthors],
	[authorWeight],
	[YearWeight],
	[InformationResourceID]) 
	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, 
	DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
	ON [PRIMARY]
End
GO

exec sp_refreshview '[Profile.Data].[vwPublication.Entity.Authorship]'
exec sp_refreshview '[Profile.Data].[vwPublication.Entity.General]'
exec sp_refreshview '[Profile.Data].[vwPublication.Entity.InformationResource]'


