
/********** ORNG Make sure that ORNG..Apps Name field matches [Ontology.].[ClassProperty] _PropertyLabel !!!!!
Also check that App Names and ID's match
****************************************************************************************/

-- really just for USC now
INSERT INTO [ORNG.].[Apps] (AppID, Name, Url, PersonFilterID, OAuthSecret, Enabled, InstitutionID) 
	SELECT 1000 + AppID, Name, Url, Null, OAuthSecret, Enabled, InstitutionID FROM [profiles_usc].[ORNG.].[Apps] a JOIN [Profile.Data].[Organization.Institution] i on i.InstitutionAbbreviation = 'USC'
	WHERE a.Enabled = 1 AND a.Name NOT IN (SELECT Name FROM [ORNG.].[Apps])

INSERT INTO [ORNG.].[AppViews] (AppID, Page, [View], ChromeID, Visibility, DisplayOrder, OptParams) 
	SELECT 1000 + AppID, Page, [View], ChromeID, Visibility, DisplayOrder, OptParams FROM [profiles_usc].[ORNG.].[AppViews] 
	WHERE AppID NOT IN (SELECT AppID FROM [ORNG.].[AppViews]) AND AppID IN (SELECT AppID FROM [ORNG.].[Apps]) 

/**** Now need to move over the ontology apps  ***/
SELECT d.AppID, d.Name, CAST(s.CustomDisplayModule.query('/Module/ParamList/Param[@Name="OptParams"]/text()') as nvarchar(255)) ProfileOptParams, 
	CAST(s.CustomEditModule.query('/Module/ParamList/Param[@Name="OptParams"]/text()') as nvarchar(255)) EditOptParams INTO tmpOrng FROM [profiles_usc].[Ontology.].[ClassProperty] s LEFT OUTER JOIN [ORNG.].[Apps] d ON
	s._PropertyLabel = d.Name WHERE s.Property LIKE 'http://orng.info/ontology/orng#has%' AND d.AppID > 1000 AND d.AppID < 2000

DECLARE @AppID int
DECLARE @EditOptParams nvarchar(255)
DECLARE @ProfileOptParams nvarchar(255)

WHILE EXISTS (SELECT * FROM tmpOrng)
BEGIN 
	SELECT TOP 1 @AppID = AppID, @ProfileOptParams = ProfileOptParams, @EditOptParams = EditOptParams FROM tmpOrng

	EXEC [ORNG.].[AddAppToOntology] @AppID = @AppID, @EditOptParams = @EditOptParams, @ProfileOptParams = @ProfileOptParams

	DELETE FROM tmpOrng WHERE AppID = @AppID
END
DROP TABLE tmpOrng


/************** New Structure for Institutional Apps *******************/
-- First rewire the USC ones. Look first that ID's make sense
UPDATE [ORNG.].[Apps] SET AppID = 127 WHERE Name = 'Tag Editor'
UPDATE [ORNG.].[Apps] SET AppID = 128 WHERE Name = 'Scholarly Project Student Mentor'
UPDATE [ORNG.].[Apps] SET AppID = 129 WHERE Name = 'Required Scholarly Project Mentor'

-- now add those in for USC
INSERT INTO [ORNG.].[InstitutionalizedApps] SELECT a.AppID, i.InstitutionID, a.Url FROM [ORNG.].[Apps] a JOIN [Profile.Data].[Organization.Institution] i on i.InstitutionAbbreviation = 'USC'
	 WHERE a.Name in ('Tag Editor', 'Scholarly Project Student Mentor', 'Required Scholarly Project Mentor')

-- now the Faculty Mentoring one USC, UCSD and UCSF
INSERT INTO [ORNG.].[InstitutionalizedApps] SELECT a.AppID, i.InstitutionID, REPLACE(a.Url, 'apps_godzilla', 'apps_' + LOWER(i.InstitutionAbbreviation)) FROM [Profile.Data].[Organization.Institution] i JOIN [ORNG.].[Apps] a on a.Name = 'Faculty Mentoring' 
	WHERE i.InstitutionAbbreviation in ('UCSF', 'UCSD', 'USC')

UPDATE [ORNG.].[Apps] SET Url = REPLACE(Url, 'apps_godzilla', '[INSTITUTION_SPECIFIC]') WHERE Name = 'Faculty Mentoring' 

--ALTER TABLE [ORNG.].Apps DROP COLUMN InstitutionID