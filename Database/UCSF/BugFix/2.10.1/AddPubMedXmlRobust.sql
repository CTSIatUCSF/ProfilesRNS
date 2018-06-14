SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [UCSF.].[BadPubmed] (
	[PMID] [int] NOT NULL,
	[X] [nvarchar](max) NULL,
	[ErrorMessage] [nvarchar](4000) NULL,
	[CreatedDT] [datetime] NULL CONSTRAINT [DF_badpubmed_createdDT]  DEFAULT (getdate()),
) ON [PRIMARY]


--DROP TABLE [UCSF.].[BadPubmed]

/****** Object:  StoredProcedure [Profile.Data].[Publication.Pubmed.AddPubMedXML]    Script Date: 5/21/2018 12:49:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER procedure  [Profile.Data].[Publication.Pubmed.AddPubMedXML] ( @pmid INT,
																			   @pubmedxml nvarchar(max))
AS
BEGIN
	SET NOCOUNT ON;	
	 
	-- Parse Load Publication XML
	BEGIN TRY 	 
		IF ISNULL(@pubmedxml,'')='' 
		BEGIN
			DELETE FROM [Profile.Data].[Publication.PubMed.Disambiguation] WHERE pmid = @pmid AND NOT EXISTS (SELECT 1 FROM [Profile.Data].[Publication.Person.Add]  pa WHERE pa.pmid = @pmid)
			RETURN
		END
		DECLARE @pubmedxmlTrue XML = CAST(@pubmedxml as XML)
 
		BEGIN TRAN
			-- Remove existing pmid record
			DELETE FROM [Profile.Data].[Publication.PubMed.AllXML] WHERE pmid = @pmid
		
			-- Add Pub Med XML	
			INSERT INTO [Profile.Data].[Publication.PubMed.AllXML](pmid,X) VALUES(@pmid, @pubmedxmlTrue  )		
			
			-- Parse Pub Med XML
			--EXEC [Profile.Data].[Publication.Pubmed.ParsePubMedXML] 	 @pmid		
		 
		COMMIT
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
		--Check success
		IF @@TRANCOUNT > 0  ROLLBACK
 
		-- Raise an error with the details of the exception
		SELECT @ErrMsg = '[Profile.Data].[Publication.Pubmed.AddPubMedXML] PMID = ' + cast(@pmid as varchar) + ' FAILED WITH : ' + ERROR_MESSAGE(),
					 @ErrSeverity = ERROR_SEVERITY()
 
		-- UCSF. Just log it and keep going
		--RAISERROR(@ErrMsg, @ErrSeverity, 1)
		INSERT [UCSF.].[BadPubmed] (PMID, X, ErrorMessage) VALUES (@pmid, @pubmedxml, @ErrMsg)
			 
	END CATCH				
END


GO

