USE [profilesRNS]
GO
/****** Object:  StoredProcedure [UCSF.].[CleanDimensionsImport]    Script Date: 11/9/2019 2:19:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [UCSF.].[CleanDimensionsImport]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
truncate table [Profile.Data].[Publication.Import.Author];
truncate table [Profile.Data].[Publication.Import.General];
truncate table [Profile.Data].[Publication.Import.Pub2Person];
Delete FROM [Profile.Data].[Publication.Import.PubData]
where ImportPubID not in (
select pmid from [Profile.Data].[Publication.PubMed.General]
where pmid<0
);

END
