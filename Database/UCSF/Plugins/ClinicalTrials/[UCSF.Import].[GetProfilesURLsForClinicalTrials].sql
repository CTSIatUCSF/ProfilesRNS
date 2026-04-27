/****** Object:  StoredProcedure [UCSF.Import].[GetProfilesURLsForClinicalTrials]    Script Date: 4/2/2026 1:17:07 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [UCSF.Import].[GetProfilesURLsForClinicalTrials]
	@Job varchar(55),
	@BatchID varchar(100)
AS
BEGIN
	SET NOCOUNT ON;	

	DECLARE @URL varchar(500),
			@rowsCount int

	select @URL = URL from [Profile.Import].[PRNSWebservice.Options] where job = @Job

	select @rowsCount = count(*) from [UCSF.].[vwPerson] where IsActive = 1 and InstitutionAbbreviation != 'USC'

	Update [Profile.Import].[PRNSWebservice.Log.Summary]  set RecordsCount = @rowsCount, RowsCount = @rowsCount where BatchID = @BatchID


	SELECT -1 [LogID], @BatchID [BatchID], PersonID [RowID], 'GET' [HttpMethod], @URL + '?add=' + ISNULL(c.[Add], '') + '&remove=' + ISNULL(c.[Remove],'') + '&person_url=' + [UCSF.].[fn_ToProductionPrettyURL](PrettyURL) [Url], NULL [PostData]
		FROM [UCSF.].[vwPerson] p LEFT OUTER JOIN [UCSF.Import].[ClinicalTrialsEdits] c on p.nodeid = c.nodeid where p.IsActive = 1 and p.InstitutionAbbreviation != 'USC'-- and LastName = 'Abrams'
END

GO


--exec [UCSF.Import].[GetProfilesURLsForClinicalTrials] @Job='UCSFGetClinicalTrials', @BatchID=null;

