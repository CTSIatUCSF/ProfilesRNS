USE [profilesRNS]
GO
/****** Object:  StoredProcedure [Profile.Data].[Publication.Pubmed.AddPubMedXML]    Script Date: 7/28/2021 11:52:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure  [Profile.Data].[Publication.Pubmed.AddPubMedXML] ( @pmid INT, @pubmedXML varchar(max)='')
AS
BEGIN
	SET NOCOUNT ON;	
	DECLARE @dataxml as XML
	-- Parse Load Publication XML
	BEGIN TRY 

	IF @pubmedXML !='' set @dataxml=convert(XML, @pubmedXML,2)	
	BEGIN TRAN
		if @pubmedXML=''
		BEGIN
			DELETE FROM [Profile.Data].[Publication.PubMed.Disambiguation] WHERE pmid = @pmid AND 
				NOT EXISTS (SELECT 1 FROM [Profile.Data].[Publication.Person.Add]  pa WHERE pa.pmid = @pmid)
			--RETURN
		END
		ELSE
		BEGIN
			-- Remove existing pmid record
			DELETE FROM [Profile.Data].[Publication.PubMed.AllXML] WHERE pmid = @pmid
		
			-- Add Pub Med XML	
			INSERT INTO [Profile.Data].[Publication.PubMed.AllXML](pmid,X) VALUES(@pmid,@dataxml)		
			
			-- Parse Pub Med XML
			--EXEC [Profile.Data].[Publication.Pubmed.ParsePubMedXML] 	 @pmid		
		END 
		COMMIT
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
		--Check success
		IF @@TRANCOUNT > 0  ROLLBACK
 
		-- Raise an error with the details of the exception
		SELECT @ErrMsg = '[Profile.Data].[Publication.Pubmed.AddPubMedXML] FAILED for PMID: ' + cast(@PMID as varchar(50)) + ' WITH : ' + ERROR_MESSAGE(),
					 @ErrSeverity = 1
 
		RAISERROR(@ErrMsg, @ErrSeverity, 1)
			 
	END CATCH				
END
