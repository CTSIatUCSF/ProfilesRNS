USE [ProfilesRNS]
GO

/****** Object:  StoredProcedure [UCSF.].[SetORCID]    Script Date: 9/25/2019 10:41:13 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [UCSF.].[SetORCID]
@SubjectID bigint =NULL,
@SetORCID varchar(50)=NULL

 
AS
BEGIN
       -- SET NOCOUNT ON added to prevent extra result sets from
       -- interfering with SELECT statements.
       SET NOCOUNT ON;
       
              -- Moisey, the URI refers to the varchar version and the ID refers to the int, so call this an ID not a URI
       --DECLARE @PredicateURI bigint
          DECLARE @PredicateID bigint
          -- renamed this to ORCIDNodeID
       DECLARE @ORCIDNodeID bigint
       
       SELECT @PredicateID = [RDF.].fnURI2NodeID('http://vivoweb.org/ontology/core#orcidId');
                  
       ----------------------------------------------------------------
       -- Determine if ORCID has already been added to this Agent
       ----------------------------------------------------------------
          IF EXISTS (SELECT * FROM  [RDF.].[Triple] WHERE Subject=@SubjectID and predicate=@PredicateID )
          BEGIN
                     print 'Skip this person ('+cast(@SubjectID as varchar)+'), they already have an Orcid'
          END
          ELSE
          BEGIN
                     BEGIN TRANSACTION 
                     -- save the ORCID value and get back the node for it
                     EXEC [RDF.].[GetStoreNode] @Value = @SetORCID, @NodeID = @ORCIDNodeID OUTPUT

                     -- now link the ORCID value to the person
                     EXEC [RDF.].[GetStoreTriple]      @SubjectID = @SubjectID, @PredicateID = @PredicateID, @ObjectID = @ORCIDNodeID
                     COMMIT TRANSACTION
          END

END

GO


