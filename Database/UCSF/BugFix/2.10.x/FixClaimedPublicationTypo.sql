/***************** Rename Entitity to Entity ************************************************************/

/****** Object:  View [UCSF.].[vwPublication.Entitity.Claimed]    Script Date: 5/3/2017 2:42:50 PM ******/
DROP VIEW [UCSF.].[vwPublication.Entitity.Claimed]
GO

/****** Object:  View [UCSF.].[vwPublication.Entitity.Claimed]    Script Date: 5/3/2017 2:42:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [UCSF.].[vwPublication.Entity.Claimed] AS
  SELECT a.EntityID, a.PersonID, CAST (CASE WHEN p.PubID is not null THEN 1 ELSE 0 END AS BIT) Claimed FROM [Profile.Data].[vwPublication.Entity.Authorship] a 
  JOIN [Profile.Data].[vwPublication.Entity.InformationResource] i ON
  a.InformationResourceID = i.ENtityID left outer join [Profile.Data].[Publication.Person.Add] p ON p.personid = a.personid and p.PMID = i.PMID WHERE i.PMID IS NOT NULL;
GO

UPDATE [Ontology.].[DataMap] SET MapTable = '[UCSF.].[vwPublication.Entity.Claimed]' WHERE MapTable = '[UCSF.].[vwPublication.Entitity.Claimed]'