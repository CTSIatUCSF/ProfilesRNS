/****** Object:  StoredProcedure [UCSF.Import].[UpsertClinicalTrialsEdits]    Script Date: 4/2/2026 1:37:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [UCSF.Import].[UpsertClinicalTrialsEdits] @NodeID bigint,  @Add nvarchar(250), @Remove nvarchar(500)
As
BEGIN
	IF (ISNULL(@Add, '') = '' AND ISNULL(@Remove, '') = '')
		DELETE FROM [UCSF.Import].[ClinicalTrialsEdits] WHERE NodeID = @NodeID	
	ELSE IF (SELECT COUNT(*) FROM [UCSF.Import].[ClinicalTrialsEdits] WHERE NodeID = @NodeID ) > 0
		UPDATE [UCSF.Import].[ClinicalTrialsEdits] set [Add] = @Add, [Remove] = @Remove, updatedDT = GETDATE() WHERE NodeID = @NodeId 
	ELSE 
		INSERT [UCSF.Import].[ClinicalTrialsEdits] (NodeID, [Add], [Remove]) values (@NodeID, @Add, @Remove)
END		

GO


GRANT EXECUTE ON [UCSF.Import].[UpsertClinicalTrialsEdits] TO App_Profiles10