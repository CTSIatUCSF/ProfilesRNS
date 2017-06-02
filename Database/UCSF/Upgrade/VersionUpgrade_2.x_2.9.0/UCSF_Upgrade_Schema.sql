
CREATE VIEW [UCSF.].[vwPublication.MyPub.General] AS
SELECT ir.EntityID, g.* FROM [Profile.Data].[Publication.Entity.InformationResource] ir JOIN [Profile.Data].[Publication.MyPub.General] g ON
ir.MPID = g.MPID WHERE ir.MPID IS NOT NULL;

