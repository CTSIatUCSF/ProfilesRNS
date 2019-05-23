use ProfilesRNS_dev
--select * from [Profile.Import].[Publication];
select * from [External.Publication].[AutorIDs];
--delete from [Profile.Data].[Publication.Import.Author] where sourceAuthorID like'ur%' or SourceAuthorID=''
select * from [Profile.Data].[Publication.Import.Author];
--delete from [Profile.Data].[Publication.Import.PubData] where ActualIDType='Dimensions'
select * from [Profile.Data].[Publication.Import.PubData];
--delete from [Profile.Data].[Publication.Import.Pub2Person] where ActualIDType='Dimensions'
select * from [Profile.Data].[Publication.Import.Pub2Person]; 
select * from [Profile.Data].[Publication.Import.General];