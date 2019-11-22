SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
 -- make this like it was originally
ALTER VIEW [Profile.Data].[vwPublication.Entity.InformationResource]
AS
SELECT EntityID, PMID, 
	   MPID, EntityName, EntityDate, Reference, Source, URL, PubYear, YearWeight, SummaryXML, IsActive
       FROM [Profile.Data].[Publication.Entity.InformationResource]
       WHERE IsActive = 1 
GO

SET ANSI_NULLS ON
GO
 
SET QUOTED_IDENTIFIER ON
GO
 
CREATE VIEW [UCSF.].[vwPublication.Entity.InformationResource]
AS
SELECT EntityID, case when PMID > 0 then PMID else null end PMID, 
	   case when [URL] like 'http://dx.doi.org/%' THEN REPLACE([URL], 'http://dx.doi.org/', '') ELSE NULL END DOI,
	   MPID, EntityName, EntityDate, Reference, Source, URL, PubYear, YearWeight, SummaryXML, IsActive
       FROM [Profile.Data].[Publication.Entity.InformationResource]
       WHERE IsActive = 1 
GO

SELECT TOP 1000 * FROM [UCSF.].[vwPublication.Entity.InformationResource] where Source like 'Dimensions';
SELECT TOP 1000 * FROM [Profile.Data].[vwPublication.Entity.InformationResource] where Source like 'Dimensions';