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
DROP VIEW [UCSF].[vwBrand]
DROP TABLE [UCSF.].[InstitutionAbbreviation2Theme]
DROP TABLE [UCSF.].[Theme]
DROP SCHEMA [UCSF.]

ALTER TABLE [ORNG.].[Apps] DROP CONSTRAINT [FK_orng_apps_institution]
ALTER TABLE [ORNG.].[Apps] DROP COLUMN InstitutionID

ALTER TABLE [Profile.Data].[Publication.PubMed.DisambiguationAffiliation]  DROP CONSTRAINT [FK_pubmed_disambiguation_affiliation_institution]
ALTER TABLE [Profile.Data].[Publication.PubMed.DisambiguationAffiliation]  DROP COLUMN InstitutionID

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