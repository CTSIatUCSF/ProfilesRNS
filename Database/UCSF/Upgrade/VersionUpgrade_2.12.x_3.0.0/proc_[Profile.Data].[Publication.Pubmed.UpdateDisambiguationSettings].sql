USE [profilesRNS]
GO
/****** Object:  StoredProcedure [Profile.Data].[Publication.Pubmed.UpdateDisambiguationSettings]    Script Date: 8/5/2021 4:28:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER Procedure [Profile.Data].[Publication.Pubmed.UpdateDisambiguationSettings](
	@PersonID int,
	@Enabled bit = 1
	)
AS 
BEGIN
	if exists (select 1 from [Profile.Data].[Publication.Pubmed.DisambiguationSettings] where PersonID = @PersonID)
	BEGIN
		update [Profile.Data].[Publication.Pubmed.DisambiguationSettings] set Enabled = @Enabled where PersonID = @PersonID
	END
	ELSE 
	BEGIN
		insert into [Profile.Data].[Publication.Pubmed.DisambiguationSettings] (PersonID, Enabled) values (@PersonID, @Enabled)
	END
	if @Enabled=0
	BEGIN
		print 'deleting previously disambiguated PMIDs'
		delete from [Profile.Data].[Publication.PubMed.Disambiguation]
		where personid=@personid
	END
END
