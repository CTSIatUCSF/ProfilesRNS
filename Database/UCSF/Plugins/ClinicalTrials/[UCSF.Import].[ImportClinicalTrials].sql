/****** Object:  StoredProcedure [UCSF.Import].[ImportClinicalTrials]    Script Date: 4/2/2026 1:36:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [UCSF.Import].[ImportClinicalTrials]
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
			  IF (LTRIM(RTRIM(ISNULL(@Data, '[]'))) = '[]')
			  BEGIN
				  -- this will remove the pluggin from the individual if the data is null, and that's what we want
				  SET @Data = NULL
				  SET @SearchableData = NULL
			  END
			  ELSE
			  BEGIN
				  --SET @SearchableData='Clinical Trials'
			     SELECT @SearchableData='Clinical Trials' + ', ' + STRING_AGG(cast(id as nvarchar(max)) + ', ' + title, ', ') FROM openjson(@Data, '$') with (id nvarchar(50) '$.Id', title nvarchar(500) '$.Title')
			  END

	  		  EXEC [Profile.Module].[GenericRDF.AddEditPluginData] @Name='ClinicalTrials', @NodeID=@NodeID, @Data=@Data, @SearchableData=@SearchableData
		
		COMMIT
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
		--Check success
		IF @@TRANCOUNT > 0  ROLLBACK

		-- Raise an error with the details of the exception
		SELECT @ErrMsg = '[Profile.Import].[UCSF.ImportClinicalTrials]' + ERROR_MESSAGE(),
					 @ErrSeverity = ERROR_SEVERITY()

		RAISERROR(@ErrMsg, @ErrSeverity, 1)
			 
	END CATCH				
END

GO


--30021514