
/********** ORNG Make sure that ORNG..Apps Name field matches [Ontology.].[ClassProperty] _PropertyLabel !!!!!
Also check that App Names match
****************************************************************************************/


DECLARE @Institution VARCHAR(50) = 'UCSF'
DECLARE @SourceDB VARCHAR(50) = 'profiles_ucsf_do' 

DECLARE @SQL NVARCHAR(MAX)
DECLARE @AppID int

/**********
To move the Apps over do this, but only from ONE insitution!
*************/
DELETE FROM [ORNG.].[AppViews]

WHILE EXISTS (SELECT * FROM [ORNG.].[Apps])
BEGIN 
	SELECT TOP 1 @AppID = AppID FROM [ORNG.].[Apps]

	EXEC [ORNG.].[RemoveAppFromOntology] @AppID = @AppID

	DELETE FROM [ORNG.].[Apps] WHERE AppID = @AppID
END

SELECT @SQL = N'
INSERT INTO [ORNG.].[Apps] (AppID, Name, Url, PersonFilterID, OAuthSecret, Enabled) 
SELECT AppID, Name, REPLACE(Url, ''apps_ucsf'', ''apps_godzilla''), NULL, OAuthSecret, [Enabled] FROM [' + @SourceDB + '].[ORNG.].[Apps] WHERE Enabled = 1'
--SELECT @SQL
EXEC dbo.sp_executesql @SQL

SELECT @SQL = N'
INSERT INTO [ORNG.].[AppViews] (AppID, Page, [View], ChromeID, Visibility, DisplayOrder, OptParams) 
SELECT AppID, Page, [View], ChromeID, Visibility, DisplayOrder, OptParams FROM [' + @SourceDB + '].[ORNG.].[AppViews] WHERE AppID IN (SELECT AppID FROM [ORNG.].[Apps])'
--SELECT @SQL
EXEC dbo.sp_executesql @SQL

/**** Now need to move over the ontology apps  ***/
SELECT @SQL = N'
SELECT d.AppID, d.Name, CAST(s.CustomDisplayModule.query(''/Module/ParamList/Param[@Name="OptParams"]/text()'') as nvarchar(255)) ProfileOptParams, 
	CAST(s.CustomEditModule.query(''/Module/ParamList/Param[@Name="OptParams"]/text()'') as nvarchar(255)) EditOptParams INTO tmpOrng FROM [' + @SourceDB + '].[Ontology.].[ClassProperty] s LEFT OUTER JOIN [ORNG.].[Apps] d ON
	s._PropertyLabel = d.Name WHERE s.Property LIKE ''http://orng.info/ontology/orng#has%'''
--SELECT @SQL
EXEC dbo.sp_executesql @SQL

DECLARE @EditOptParams nvarchar(255)
DECLARE @ProfileOptParams nvarchar(255)

WHILE EXISTS (SELECT * FROM tmpOrng)
BEGIN 
	SELECT TOP 1 @AppID = AppID, @ProfileOptParams = ProfileOptParams, @EditOptParams = EditOptParams FROM tmpOrng

	EXEC [ORNG.].[AddAppToOntology] @AppID = @AppID, @EditOptParams = @EditOptParams, @ProfileOptParams = @ProfileOptParams

	DELETE FROM tmpOrng WHERE AppID = @AppID
END
DROP TABLE tmpOrng

/***** LOOK AT THIS FIRST *********
insert [Profile.Data].[Person.Filter] (PersonFilter, PersonFilterCategory, PersonFilterSort) 
	select PersonFilter, PersonFilterCategory, PersonFilterSort
	FROM [profiles_ucsf].[Profile.Data].[Person.Filter] order by PersonFilterSort

select * from [ORNG.].Apps
update a set a.PersonFilterID = f.PersonFilterId FROM [ORNG.].Apps a JOIN [Profile.Data].[Person.Filter] f on a.Name = f.PersonFilter
*******************/
