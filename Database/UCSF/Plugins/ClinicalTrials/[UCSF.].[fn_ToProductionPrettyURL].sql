/****** Object:  UserDefinedFunction [UCSF.].[fn_UrlCleanName]    Script Date: 4/2/2026 1:18:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [UCSF.].[fn_ToProductionPrettyURL]
(
	@prettyURL varchar(255)
)
RETURNS varchar(255)
AS
BEGIN
	DECLARE @str varchar(255) = @prettyURL
	
	SET @str = REPLACE(@str, 'dev-ucdavis.researcherprofiles.org', 'profiles.ucdavis.edu') 
	SET @str = REPLACE(@str, 'dev-uci.researcherprofiles.org', 'profiles.icts.uci.edu') 
	SET @str = REPLACE(@str, 'dev-ucla.researcherprofiles.org', 'profiles.ucla.edu') 
	SET @str = REPLACE(@str, 'dev-ucsd.researcherprofiles.org', 'profiles.ucsd.edu') 
	SET @str = REPLACE(@str, 'dev-ucsf.researcherprofiles.org', 'profiles.ucsf.edu') 
	SET @str = REPLACE(@str, 'dev-uc.researcherprofiles.org', 'profiles.ucbraid.org') 
	SET @str = REPLACE(@str, 'dev-usc.researcherprofiles.org', 'profiles.sc-ctsi.org') 
	SET @str = REPLACE(@str, 'dev.researcherprofiles.org', 'researcherprofiles.org') 
			
	SET @str = REPLACE(@str, 'stage-profiles.ucdavis.edu', 'profiles.ucdavis.edu') 
	SET @str = REPLACE(@str, 'stage-profiles.icts.uci.edu', 'profiles.icts.uci.edu') 
	SET @str = REPLACE(@str, 'stage-ucla.researcherprofiles.org', 'profiles.ucla.edu') 
	SET @str = REPLACE(@str, 'stage-ucsd.researcherprofiles.org', 'profiles.ucsd.edu') 
	SET @str = REPLACE(@str, 'stage-ucsf.researcherprofiles.org', 'profiles.ucsf.edu') 
	SET @str = REPLACE(@str, 'stage-profilel.ucbraid.org', 'profiles.ucbraid.org') 
	SET @str = REPLACE(@str, 'stage-usc.researcherprofiles.org', 'profiles.sc-ctsi.org') 
	SET @str = REPLACE(@str, 'stage.researcherprofiles.org', 'researcherprofiles.org') 

	RETURN @str

END

GO


--select [UCSF.].[fn_ToProductionPrettyURL]('https://dev-ucsf.researcherprofiles.org/eric.meeks')



