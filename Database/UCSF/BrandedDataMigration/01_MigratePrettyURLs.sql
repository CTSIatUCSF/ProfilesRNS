
/********** freetext keyword ****************************************************************************************/
DECLARE @Institution VARCHAR(50) = 'UCSF'
DECLARE @SourceDB VARCHAR(50) = 'profiles_ucsf' 

DECLARE @SQL NVARCHAR(MAX)
DECLARE @BasePath NVARCHAR(255)

SELECT @BasePath = t.BasePath FROM [UCSF.].[Theme] t JOIN [UCSF.].[InstitutionAdditions] i ON t.Theme = i.Theme WHERE i.InstitutionAbbreviation = @Institution
--SELECT @BasePath

--SELECT @SQL = N'
SELECT @SQL = N'INSERT INTO [UCSF.].[NameAdditions] 
	SELECT [UCSF.].fn_LegacyInternalusername2EPPN(InternalUserName, ''' + @Institution + 
		'''), CleanFirst, CleanMiddle, CleanLast, CleanSuffix, GivenName, CleanGivenName, ''' + @BasePath + '/'' + UrlName, Strategy, PublishingFirst FROM [' + @SourceDB + '].[UCSF.].[NameAdditions]'  
--SELECT @SQL
EXEC dbo.sp_executesql @SQL



--	SELECT [UCSF.].fn_LegacyInternalusername2EPPN(InternalUserName, 'UCSF'), CleanFirst, CleanMiddle, CleanLast, CleanSuffix, GivenName, CleanGivenName, 'http://stage-profiles.ucsf.edu/ucsf/' + UrlName, Strategy, PublishingFirst FROM [profiles_ucsf].[UCSF.].[NameAdditions]
