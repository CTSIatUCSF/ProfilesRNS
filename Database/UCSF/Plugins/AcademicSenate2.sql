-- this is to create the standard Profiles job to pull in academic senate data, same as pubs, grants and clinical trials. 
-- with the this [UCSF.].[AcademicSenateAddDataToPlugin] sp and [UCSF.].[AcademicSenate] table are no longer needed and should be removed

DROP PROCEDURE [UCSF.].[AcademicSenateAddDataToPlugin]
DROP TABLE [UCSF.].[AcademicSenate]

insert [Profile.Import].[PRNSWebservice.Options] (job, [url], logLevel, GetPostDataProc, ImportDataProc)
values ('UCSFGetAcademicSenateData', 'https://dev-ucsf.researcherprofiles.org/CustomAPI/Secure/OAuthProxy.aspx?ClientID=changeme1', 0,
'[UCSF.Import].[GetProfilesURLsForAcademicSenate]', '[UCSF.Import].[ImportAcademicSenate]');

	--delete from [Profile.Import].[PRNSWebservice.Options] where job = 'UCSFGetAcademicSenateData';
/****** Object:  StoredProcedure [UCSF.Import].[GetProfilesURLsForClinicalTrials]    Script Date: 5/22/2026 10:22:43 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [UCSF.Import].[GetProfilesURLsForAcademicSenate]
	@Job varchar(55) = 'UCSFGetAcademicSenateData',
	@BatchID varchar(100)
AS
BEGIN
	SET NOCOUNT ON;	

	-- make sure the @Data infor is correct for whatever instance you are using 
	DECLARE @URL varchar(500), @rowsCount int, 
		@Data nvarchar(500) = 'grant_type=client_credentials&client_id=2&client_secret=PhS8Wd6rNCCUlTG0ItRUvU5Lljmxx3EPkmOcL9RV&token_url=https%3A%2F%2Fsenateserviceportal.ucsf.edu%2Foauth%2Ftoken&data_url=https%3A%2F%2Fsenateserviceportal.ucsf.edu%2Fapi%2Fprofile%2FINTERNALUSERNAME%3Ffields%3Demail%2Ccommittees'

	select @URL = URL from [Profile.Import].[PRNSWebservice.Options] where job = @Job

	select @rowsCount = count(*) from [UCSF.].[vwPerson] where IsActive = 1 and InstitutionAbbreviation = 'UCSF'
		--and LastName = 'schneider'

	Update [Profile.Import].[PRNSWebservice.Log.Summary] set RecordsCount = @rowsCount, RowsCount = @rowsCount where BatchID = @BatchID

	SELECT -1 [LogID], @BatchID [BatchID], PersonID [RowID], 'GET' [HttpMethod], 
		 @URL + '&' + REPLACE(@Data, 'INTERNALUSERNAME', REPLACE(InternalUsername, '@', '%40')) [Url], null [PostData]
		FROM [UCSF.].[vwPerson] where IsActive = 1 and InstitutionAbbreviation = 'UCSF'
		--and LastName = 'schneider'
END

GO

-- to test 
DECLARE	@return_value int

EXEC	@return_value = [UCSF.Import].[GetProfilesURLsForAcademicSenate]
		@BatchID = N'test'

SELECT	'Return Value' = @return_value
-- done test
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [UCSF.Import].[ImportAcademicSenate]
	@Job varchar(55) = '',
	@BatchID varchar(100) = '',
	@RowID int = -1,
	@LogID int = -1,
	@URL varchar (500) = '',
	@Data varchar(max)
AS
BEGIN
	DECLARE @NodeID BIGINT
	DECLARE @SearchableData nvarchar(max)

	BEGIN TRY
		BEGIN TRAN		 
			  SELECT @NodeID=NodeID FROM [RDF.Stage].internalnodemap where internalid = @RowID AND [class] = 'http://xmlns.com/foaf/0.1/Person' 
			  IF (ISJSON(@Data) = 0)
			  BEGIN
				  -- this will remove the pluggin from the individual if the data is null, and that's what we want
				  SET @Data = null
				  SET @SearchableData = null
			  END
			  ELSE
			  BEGIN
				  DECLARE @CommitteeLength INT
				  SELECT @CommitteeLength = COUNT(*) FROM openjson(@Data, '$.committees')
				  IF (@CommitteeLength > 0) 
				  --IF (CHARINDEX('"committees"', @Data) > 0 AND CHARINDEX('"committees":[]', @Data) = 0) -- this means it DOES have data
				  BEGIN
					  --SET @SearchableData='Academic Senate Committee'
					  SELECT @SearchableData='Academic Senate Committee, ' + STRING_AGG(title, ', ') FROM openjson(@Data, '$.committees') with (title nvarchar(500) '$.title')
				  END
				  ELSE
				  BEGIN
					  -- this will remove the pluggin from the individual if the data is null, and that's what we want
					  SET @Data = null
					  SET @SearchableData = null
				  END
			  END

	  		  EXEC [Profile.Module].[GenericRDF.AddEditPluginData] @Name='AcademicSenate', @NodeID=@NodeID, @Data=@Data, @SearchableData=@SearchableData
		
		COMMIT
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
		--Check success
		IF @@TRANCOUNT > 0  ROLLBACK

		-- Raise an error with the details of the exception
		SELECT @ErrMsg = '[Profile.Import].[ImportAcademicSenate]' + ERROR_MESSAGE(),
					 @ErrSeverity = ERROR_SEVERITY()

		RAISERROR(@ErrMsg, @ErrSeverity, 1)
			 
	END CATCH				
END

GO


-- testing stuff below
--		bodyText	"grant_type=client_credentials&client_id=1&client_secret=PhS8Wd6rNCCUlTG0ItRUvU5Lljmxx3EPkmOcL9RV&token_url=https%3A%2F%2Fsenateserviceportal.ucsf.edu%2Foauth%2Ftoken&data_url=https%3A%2F%2Fsenateserviceportal.ucsf.edu%2Fapi%2Fprofile%2F786125%40ucsf.edu%3Ffields%3Demail%2Ccommittees"	string

DECLARE 	@Data varchar(max) = '{"email":"valerie.flaherman@ucsf.edu","committees":[]}'
SELECT CHARINDEX('"committees":[]', @Data)
IF (@Data NOT LIKE '%"committees":[]%')
BEGIN
	SELECT 1
END
				  DECLARE @CommitteeLength INT
				  SELECT @CommitteeLength = COUNT(*) FROM openjson(@Data, '$.committees')
				  SELECT @CommitteeLength
SELECT COUNT(*) FROM  openjson(@Data, '$.committees')