/****** Object:  StoredProcedure [UCSF.].[Publication.Pubmed.AddPMID]    Script Date: 3/12/2026 9:55:29 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [UCSF.].[Publication.Pubmed.AddPMID] (@PrettyURL nvarchar(255)=null, @PersonID INT=null, @PMID INT)
AS
BEGIN
	SET NOCOUNT ON;	
	
		IF @PersonID is null AND @PrettyURL is not null
			select @PersonID = PersonID FROM [UCSF.].vwPerson where PrettyURL=@PrettyURL

		IF @PersonID is not null AND not exists(SELECT TOP 1 * FROM [Profile.Data].[Publication.PubMed.Disambiguation] WHERE personid = @personid AND pmid=@PMID)
			AND not exists(SELECT TOP 1 * FROM [Profile.Data].[Publication.Person.Exclude] WHERE personid = @personid AND pmid=@PMID)
				INSERT INTO [Profile.Data].[Publication.PubMed.Disambiguation] (personid,pmid) VALUES (@PersonID, @PMID)

END
GO


