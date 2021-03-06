SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 
CREATE PROCEDURE [ORCID.].[cg2_PersonTokenAdd]

    @PersonTokenID  INT =NULL OUTPUT 
    , @PersonID  INT 
    , @PermissionID  INT 
    , @AccessToken  VARCHAR(50) 
    , @TokenExpiration  SMALLDATETIME 
    , @RefreshToken  VARCHAR(50) =NULL

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
    DECLARE @intRecordLevelAuditTrailID INT 
    DECLARE @intFieldLevelAuditTrailID INT 
    DECLARE @intTableID INT 
    SET @intTableID = 3595
 
  
        INSERT INTO [ORCID.].[PersonToken]
        (
            [PersonID]
            , [PermissionID]
            , [AccessToken]
            , [TokenExpiration]
            , [RefreshToken]
        )
        (
            SELECT
            @PersonID
            , @PermissionID
            , @AccessToken
            , @TokenExpiration
            , @RefreshToken
        )
   
        SET @intReturnVal = @@error
        SET @PersonTokenID = @@IDENTITY
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while adding the PersonToken record.', 11, 11); 
            RETURN @intReturnVal 
        END



GO
