DROP VIEW [UCSF.].[vwPerson]
DROP VIEW [UCSF.].[vwPublication.Entity.Claimed]
DROP VIEW [UCSF.].[vwPublication.MyPub.General]
DROP PROCEDURE [UCSF.].[AddProxyByInternalUsername]
DROP PROCEDURE [UCSF.].[CreatePrettyURLs]
DROP PROCEDURE [UCSF.].[ReadActivityLog]
DROP FUNCTION [UCSF.].[fn_UrlCleanName]
DROP FUNCTION [UCSF.].[fn_ApplicationNameFromPrettyUrl]
DROP FUNCTION [UCSF.].fn_LegacyInternalusername2EPPN
DROP TABLE [UCSF.].[NameAdditions]
DROP TABLE [UCSF.].[Brand]
DROP SCHEMA [UCSF.]

DROP PROCEDURE [UCSF.CTSASearch].[Publication.Pubmed.AddCoAuthorXML]
DROP PROCEDURE [UCSF.CTSASearch].[Publication.Pubmed.GetAllPMIDs]
DROP PROCEDURE [UCSF.CTSASearch].[Publication.Pubmed.ParseCoAuthorXML]
DROP FUNCTION [UCSF.CTSASearch].[fn_UrlFromURI]
DROP FUNCTION [UCSF.CTSASearch].[fnPublication.Pubmed.General2Reference]
DROP TABLE [UCSF.CTSASearch].[Publication.PubMed.Author]
DROP TABLE [UCSF.CTSASearch].[Publication.PubMed.CoAuthorXML]
DROP SCHEMA [UCSF.CTSASearch]

ALTER TABLE [Profile.Data].[Publication.Entity.InformationResource]	DROP COLUMN Authors
DROP PROCEDURE [Profile.Data].[Publication.ClaimOnePublication]

-- we do NOT replace all the existing SP's we altered.