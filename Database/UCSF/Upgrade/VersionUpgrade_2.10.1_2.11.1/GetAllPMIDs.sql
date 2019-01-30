/****** Object:  StoredProcedure [Profile.Data].[Publication.PubMed.GetAllPMIDs]    Script Date: 1/23/2019 10:19:32 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






-- Stored Procedure

ALTER procedure [Profile.Data].[Publication.PubMed.GetAllPMIDs] (@GetOnlyNewXML BIT=0, @MonthsOld INT=2)
AS
BEGIN
	SET NOCOUNT ON;	


	BEGIN TRY
		IF @GetOnlyNewXML = 1 
		-- ONLY GET XML FOR NEW Publications
			BEGIN
				SELECT distinct pmid
				  FROM [Profile.Data].[Publication.PubMed.Disambiguation]
				 WHERE pmid NOT IN(SELECT PMID FROM [Profile.Data].[Publication.PubMed.General])
				   AND pmid IS NOT NULL 
			END
		ELSE 
		-- FULL REFRESH
			BEGIN
				-- UCSF alteration begin
				DECLARE @cutoffDate datetime = dateadd(Month, -@MonthsOld, GETDATE())
				SELECT TOP 100000 pmid FROM  (
				-- UCSF alteration ended
				SELECT d.pmid
				  FROM [Profile.Data].[Publication.PubMed.Disambiguation] d JOIN [Profile.Data].[Publication.PubMed.AllXML] x on d.pmid = x.pmid
				 WHERE d.pmid IS NOT NULL AND x.ParseDT IS NOT NULL AND x.ParseDT < @cutoffDate
				 UNION   
				SELECT i.pmid
				  FROM [Profile.Data].[Publication.Person.Include] i JOIN [Profile.Data].[Publication.PubMed.AllXML] x on i.pmid = x.pmid
				 WHERE i.pmid IS NOT NULL AND x.ParseDT IS NOT NULL AND x.ParseDT < @cutoffDate) t
			END 

	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
		--Check success
		IF @@TRANCOUNT > 0  ROLLBACK

		-- Raise an error with the details of the exception
		SELECT @ErrMsg = 'FAILED WITH : ' + ERROR_MESSAGE(),
					 @ErrSeverity = ERROR_SEVERITY()

		RAISERROR(@ErrMsg, @ErrSeverity, 1)

	END CATCH				
END






GO


