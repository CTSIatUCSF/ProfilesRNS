Make sure to clean up our custom changes to [Profile.Data].[Publication.Entity.InformationResource] so that the following works!

DROP INDEX [idx_PublicationEntityInformationResourceIsActive] ON [Profile.Data].[Publication.Entity.InformationResource] 
ALTER TABLE [Profile.Data].[Publication.Entity.InformationResource] ADD [doi] VARCHAR (100)
ALTER TABLE [Profile.Data].[Publication.Entity.InformationResource] ALTER COLUMN [EntityName] NVARCHAR (4000)
ALTER TABLE [Profile.Data].[Publication.Entity.InformationResource] ALTER COLUMN [EntityDate] DATETIME
ALTER TABLE [Profile.Data].[Publication.Entity.InformationResource] ALTER COLUMN [Reference]  NVARCHAR (MAX)
ALTER TABLE [Profile.Data].[Publication.Entity.InformationResource] ADD [Authors] NVARCHAR (MAX)
DBCC CLEANTABLE (0,'[Profile.Data].[Publication.Entity.InformationResource]');  
CREATE NONCLUSTERED INDEX [idx_PublicationEntityInformationResourceIsActive]
    ON [Profile.Data].[Publication.Entity.InformationResource]([IsActive] ASC)
    INCLUDE([EntityID], [PubYear], [PMID], [EntityDate], [Reference]);
GO