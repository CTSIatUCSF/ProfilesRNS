use ProfilesRNS
alter table  [Profile.Data].[Publication.PubMed.General]
alter column [ArticleTitle] [nvarchar](4000) NULL
alter table  [Profile.Data].[Publication.PubMed.General]
alter column [Authors] [nvarchar](4000) NULL;

DECLARE @needIndex int=0
IF EXISTS
(
SELECT 1 FROM sys. indexes
WHERE name='[idx_PublicationEntityInformationResourceIsActive]' AND object_id = OBJECT_ID('[Profile.Data].[Publication.Entity.InformationResource]')
)
BEGIN
drop INDEX [idx_PublicationEntityInformationResourceIsActive] on [Profile.Data].[Publication.Entity.InformationResource]
set @needIndex=1 
END
alter TABLE [Profile.Data].[Publication.Entity.InformationResource]
alter column [Reference] [nvarchar](MAX) NULL
alter TABLE [Profile.Data].[Publication.Entity.InformationResource]
alter column [Authors] [nvarchar](MAX) NULL
if @needIndex=1
BEGIN
CREATE NONCLUSTERED INDEX [idx_PublicationEntityInformationResourceIsActive] ON [Profile.Data].[Publication.Entity.InformationResource]
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

