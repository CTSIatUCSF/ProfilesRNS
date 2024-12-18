

-- fix all 3 views in ucd_imort to use ucdavis.edu is internalusername and to have UC Davis be the abbreviation
-- fix the godzilla import as well 
-- fix the URL in UCSF..Theme to be ../ucdavis
update [Profile.Data].[Organization.Institution] set InstitutionAbbreviation = 'UC Davis' WHERE InstitutionAbbreviation = 'UCD';
update [UCSF.].[InstitutionAdditions] set InstitutionAbbreviation = 'UC Davis' WHERE InstitutionAbbreviation = 'UCD';
update [Profile.Data].Person set InternalUsername = REPLACE(internalusername, 'ucd.edu', 'ucdavis.edu') WHERE InternalUsername like '%ucd.edu';
update [User.Account].[User] set InternalUsername = REPLACE(internalusername, 'ucd.edu', 'ucdavis.edu') WHERE InternalUsername like '%ucd.edu';
update [UCSF.].NameAdditions set InternalUserName = REPLACE(internalusername, 'ucd.edu', 'ucdavis.edu') WHERE InternalUsername like '%ucd.edu'

-- now run import
-- finally run nightly

-- And don't figure to make binding changes or other changes to IIS as needed