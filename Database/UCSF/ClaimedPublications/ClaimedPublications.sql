/****** Object:  StoredProcedure [Edit.Module].[CustomEditAuthorInAuthorship.GetList]    Script Date: 2/1/2017 10:45:57 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Edit.Module].[CustomEditAuthorInAuthorship.GetList]
@NodeID BIGINT=NULL, @SessionID UNIQUEIDENTIFIER=NULL
AS
BEGIN

	DECLARE @PersonID INT
 
	SELECT @PersonID = CAST(m.InternalID AS INT)
		FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n
		WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @NodeID
 
	SELECT r.Reference, (CASE WHEN r.PMID IS NOT NULL THEN 1 ELSE 0 END) FromPubMed, i.PubID, r.PMID, r.MPID, NULL Category, r.URL, r.EntityDate PubDate, r.EntityID, r.Source, r.IsActive, i.PersonID, 
			(CASE WHEN a.PubID IS NOT NULL THEN 1 ELSE 0 END) Claimed
		FROM [Profile.Data].[Publication.Person.Include] i
			INNER JOIN [Profile.Data].[Publication.Entity.InformationResource] r
				ON i.PMID = r.PMID AND i.PMID IS NOT NULL
				AND i.PersonID = @PersonID
			LEFT OUTER JOIN [Profile.Data].[Publication.Person.Add] a on i.PMID = a.PMID and i.PMID IS NOT NULL 
				AND a.PersonID = @PersonID
	UNION ALL
	SELECT r.Reference, (CASE WHEN r.PMID IS NOT NULL THEN 1 ELSE 0 END) FromPubMed, i.PubID, r.PMID, r.MPID, g.HmsPubCategory Category, r.URL, r.EntityDate PubDate, r.EntityID, r.Source, r.IsActive, i.PersonID, 1 Claimed
		FROM [Profile.Data].[Publication.Person.Include] i
			INNER JOIN [Profile.Data].[Publication.Entity.InformationResource] r
				ON i.MPID = r.MPID AND i.PMID IS NULL AND i.MPID IS NOT NULL
				AND i.PersonID = @PersonID
			INNER JOIN [Profile.Data].[Publication.MyPub.General] g
				ON i.MPID = g.MPID
	ORDER BY EntityDate DESC, EntityID

END



GO


/****** Object:  StoredProcedure [Profile.Data].[Publication.ClaimOnePublication]    Script Date: 2/1/2017 11:24:36 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [Profile.Data].[Publication.ClaimOnePublication]
	@PersonID INT,
	@PubID varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
BEGIN TRY 	 
	BEGIN TRANSACTION

		if exists (select * from [Profile.Data].[Publication.Person.Include]  where pubid = @PubID and PersonID = @PersonID)
		begin

			declare @pmid int
			declare @mpid varchar(50)

			set @pmid = (select pmid from [Profile.Data].[Publication.Person.Include] where pubid = @PubID)
			set @mpid = (select mpid from [Profile.Data].[Publication.Person.Include] where pubid = @PubID)

			--delete from [Profile.Data].[Publication.Person.Exclude] where pubid = @PubID
			insert into [Profile.Data].[Publication.Person.Add] 
				values (@pubid,@PersonID,@pmid,@mpid)

		end

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
		--Check success
		IF @@TRANCOUNT > 0  ROLLBACK
 
		-- Raise an error with the details of the exception
		SELECT @ErrMsg =  ERROR_MESSAGE(),
					 @ErrSeverity = ERROR_SEVERITY()
 
		RAISERROR(@ErrMsg, @ErrSeverity, 1)
			 
	END CATCH		

END

GO


CREATE VIEW [UCSF.].[vwPublication.Entitity.Claimed] AS
  SELECT a.EntityID, a.PersonID, CAST (CASE WHEN p.PubID is not null THEN 1 ELSE 0 END AS BIT) Claimed FROM [Profile.Data].[vwPublication.Entity.Authorship] a 
  JOIN [Profile.Data].[vwPublication.Entity.InformationResource] i ON
  a.InformationResourceID = i.ENtityID left outer join [Profile.Data].[Publication.Person.Add] p ON p.personid = a.personid and p.PMID = i.PMID WHERE i.PMID IS NOT NULL;
