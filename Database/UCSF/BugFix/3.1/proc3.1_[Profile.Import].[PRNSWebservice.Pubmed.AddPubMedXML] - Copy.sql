USE [profilesRNS]
GO
/****** Object:  StoredProcedure [Profile.Import].[PRNSWebservice.Pubmed.AddPubMedXML]    Script Date: 10/19/2021 8:08:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Profile.Import].[PRNSWebservice.Pubmed.AddPubMedXML]
	@Job varchar(55) = '',
	@BatchID varchar(100) = '',
	@RowID int = -1,
	@LogID int = -1,
	@URL varchar (500) = '',
	@Data nvarchar(max)
AS
BEGIN
	SET NOCOUNT ON;	

	BEGIN TRY 	 
		IF ISNULL(@Data,'')='' 
		BEGIN
			DELETE FROM [Profile.Data].[Publication.PubMed.Disambiguation] WHERE pmid = @RowID AND NOT EXISTS (SELECT 1 FROM [Profile.Data].[Publication.Person.Add]  pa WHERE pa.pmid = @RowID)
			RETURN
		END
 -------------------------------------------
		-- Remove existing pmid record
		DELETE FROM [Profile.Data].[Publication.PubMed.AllXML] WHERE pmid = @RowID
		
		-- Add Pub Med XML
		INSERT INTO [Profile.Data].[Publication.PubMed.AllXML](pmid,X) VALUES(@RowID,CAST(@Data AS XML))		
		RETURN
	END TRY
	BEGIN CATCH
		declare @errorMessage varchar(max)
		select @errorMessage = Error_Message()

		if @LogID < 0
		begin
			select @LogID = isnull(LogID, -1) from [Profile.Import].[PRNSWebservice.Log] where BatchID = @BatchID and RowID = @RowID
		end
		select @logid
		if @LogID > 0
			update [Profile.Import].[PRNSWebservice.Log] set Success = 0, HttpResponse = @Data, ErrorText = @errorMessage where LogID = @LogID
		else
			insert into [Profile.Import].[PRNSWebservice.Log] (Job, BatchID, RowID, URL, HttpResponse, Success, ErrorText) Values (@Job, @BatchID, @RowID, @URL, @Data, 0, @errorMessage)
	END CATCH	
END
