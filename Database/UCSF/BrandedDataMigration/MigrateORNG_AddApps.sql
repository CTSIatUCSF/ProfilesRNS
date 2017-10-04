
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