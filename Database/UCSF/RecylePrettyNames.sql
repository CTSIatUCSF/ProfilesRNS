-- make a backup first
SELECT * INTO [UCSF.].[NameAdditionsBak] FROM [UCSF.].[NameAdditions]
GO

-- Create view that removes inactive profiles. Note that we need to use "not in" because of the import sequencing, 
-- we want to include folks who are just added and not yet in the Person table
CREATE VIEW [UCSF.].[vwActiveNameAdditions] as SELECT * FROM [UCSF.].[NameAdditions] WHERE InternalUsername not in (SELECT InternalUsername FROM [Profile.Data].Person where IsActive != 1)

-- SELECT * FROM [UCSF.].[vwActiveNameAdditions]

/****** Object:  StoredProcedure [UCSF.].[CreatePrettyURLs]    Script Date: 11/13/2025 12:39:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [UCSF.].[CreatePrettyURLs] 
AS
BEGIN
		
	DECLARE @id nvarchar(50)
	DECLARE @CleanFirst nvarchar(255)
	DECLARE @CleanMiddle nvarchar(255)
	DECLARE @CleanLast nvarchar(255)
	DECLARE @CleanSuffix nvarchar(255)
	DECLARE @CleanGivenName nvarchar(255)
	DECLARE @PrettyURL nvarchar(255)
	DECLARE @Strategy nvarchar(50)
	DECLARE @i int
	DECLARE @BaseDomain nvarchar(255)
	DECLARE @Domain nvarchar(255)

	SELECT @BaseDomain=Value FROM [Framework.].[Parameter] WHERE ParameterID='basePath'
		
	WHILE exists (SELECT *
		FROM [UCSF.].[vwActiveNameAdditions] WHERE PrettyURL is null)
	BEGIN
		SELECT TOP 1 @id=n.internalusername,
					 @Domain=ISNULL(b.BasePath, @BaseDomain) + '/',
					 @CleanFirst=n.CleanFirst, 
					 @CleanMiddle=n.CleanMiddle,
					 @CleanLast=n.CleanLast,
					 @CleanSuffix=n.CleanSuffix,
 					 @CleanGivenName=n.CleanGivenName
		FROM [UCSF.].[vwActiveNameAdditions] n JOIN [Profile.Import].[PersonAffiliation] a on n.internalusername=a.internalusername and a.primaryaffiliation=1
			LEFT OUTER JOIN [UCSF.].[Theme2Institution] it on it.InstitutionAbbreviation=a.institutionabbreviation 
			and it.Theme in (select t.theme from (select Theme, count(*) cnt from [UCSF.].Theme2Institution group by Theme having count(*) = 1) as t)
			LEFT OUTER JOIN [UCSF.].[Brand] b on b.Theme=it.Theme 
			WHERE n.PrettyURL is null ORDER BY len(n.CleanMiddle) + len(n.CleanSuffix)					 

		-- try different strategies
		-- P = preferred first name
		-- I = middle initial
		-- M = middle name
		-- L = last name
		-- S = suffix
		-- G = given first name
		-- N = number
		
		-- for folks who go by their middle name as their preferred name, remove middle name from the strategy.
		-- also do this if it we only have middle initial and it looks like that's what they did
		IF (@CleanFirst = @CleanMiddle) OR 
			(
				(len(@CleanMiddle) = 1 OR (len(@CleanMiddle) = 2 AND charindex('.', @CleanMiddle) = 2)) 
				AND (@CleanFirst <> @CleanGivenName) 
				AND (substring(@CleanMiddle, 1, 1) = substring(@CleanFirst, 1, 1))
			)
			SET @CleanMiddle = ''

		SET @strategy = 'P.L'
		SET @PrettyURL = @Domain + @CleanFirst + '.' + @CleanLast -- first and last
		
		IF exists (SELECT * from [UCSF.].[vwActiveNameAdditions] WHERE PrettyURL = @PrettyURL) AND len(@CleanMiddle) > 0
		BEGIN
			SET @strategy = 'P.I.L'
			SET @PrettyURL = @Domain + @CleanFirst + '.' + substring(@CleanMiddle,1,1) + '.' + @CleanLast -- middle initial
		END
		IF exists (SELECT * from [UCSF.].[vwActiveNameAdditions] WHERE PrettyURL = @PrettyURL) AND len(@CleanMiddle) > 0
		BEGIN
			SET @strategy = 'P.M.L'
			SET @PrettyURL = @Domain + @CleanFirst + '.' + @CleanMiddle + '.' + @CleanLast -- middle name
		END
		IF exists (SELECT * from [UCSF.].[vwActiveNameAdditions] WHERE PrettyURL = @PrettyURL) AND len(@CleanSuffix) > 0
		BEGIN
			SET @strategy = 'P.L.S'
			SET @PrettyURL = @Domain + @CleanFirst + '.' + @CleanLast + '.' + @CleanSuffix -- suffix
		END
		IF exists (SELECT * from [UCSF.].[vwActiveNameAdditions] WHERE PrettyURL = @PrettyURL) AND len(@CleanMiddle) > 0 AND len(@CleanSuffix) > 0
		BEGIN
			SET @strategy = 'P.I.L.S'
			SET @PrettyURL = @Domain + @CleanFirst + '.' + substring(@CleanMiddle,1,1) + '.' + @CleanLast + '.' + @CleanSuffix-- middle initial and suffix
		END
		IF exists (SELECT * from [UCSF.].[vwActiveNameAdditions] WHERE PrettyURL = @PrettyURL) AND len(@CleanMiddle) > 0 AND len(@CleanSuffix) > 0
		BEGIN
			SET @strategy = 'P.M.L.S'
			SET @PrettyURL = @Domain + @CleanFirst + '.' + @CleanMiddle + '.' + @CleanLast + '.' + @CleanSuffix -- middle name and suffix
		END
		-- if all else fails, add numbers
		SET @i = 2
		WHILE exists (SELECT * from [UCSF.].[vwActiveNameAdditions] WHERE PrettyURL = @PrettyURL)
		BEGIN
			SET @strategy = 'P.L.N'
			SET @PrettyURL = @Domain + @CleanFirst + '.' + @CleanLast + '.' + CAST(@i as varchar)			
			SET @i = @i + 1
		END				

		-- Nov 2025 see if an another one already has this and if so set its to NULL because it must be for an inactive profile
		UPDATE [UCSF.].[NameAdditions] SET PrettyURL = NULL WHERE PrettyURL = @PrettyURL

		-- it should be unique at this point, 
		UPDATE [UCSF.].[NameAdditions] SET PrettyURL = @PrettyURL, [Strategy] = @strategy WHERE internalusername = @id
		IF @@Error != 0 
            RETURN
	END

END

GO

-- Add column for redirect
ALTER TABLE [UCSF.].[NameAdditions] ADD RedirectToURL NVARCHAR(255) NULL
GO


-- we should only have to run this once per instance. 
CREATE PROCEDURE [UCSF.].[FixPrettyURLs] 
AS
BEGIN
	DECLARE @id nvarchar(50)
	DECLARE @lessPrettyURL nvarchar(255)
	DECLARE @inactiveid nvarchar(50)
	DECLARE @inactivePrettyURL nvarchar(255)

	-- first clean out the nulls and 'nulls'. Actually Moisey has fixed the 'null' issue
	UPDATE [UCSF.].[NameAdditions] set CleanFirst = ISNULL(CleanFirst, ''), 
								   CleanMiddle =  ISNULL(CleanMiddle, ''), 
								   --CleanMiddle =  CASE WHEN ISNULL(CleanMiddle, '') = 'null' THEN '' ELSE ISNULL(CleanMiddle, '') END, 
								   CleanLast =  ISNULL(CleanLast, ''), 
								   CleanSuffix =  ISNULL(CleanSuffix, ''), 
								   --CleanSuffix =  CASE WHEN ISNULL(CleanSuffix, '') = 'null' THEN '' ELSE ISNULL(CleanSuffix, '') END, 
								   --GivenName =  ISNULL(GivenName, ''), 
								   CleanGivenName =  ISNULL(CleanGivenName, '')

	-- for a given individual based on name components see if an inactive profile has a shorter PrettyURL
	SELECT  n.InternalUserName, n.PrettyURL, ni.InternalUserName [InactiveInternalUserName], ni.PrettyURL [InactivePrettyURL] INTO #prettyUrlSwap
		FROM [UCSF.].[NameAdditions] n JOIN [Profile.Data].[Person] p on n.InternalUserName = p.InternalUsername AND p.IsActive = 1 
		JOIN [UCSF.].[NameAdditions] ni ON ni.CleanFirst = n.CleanFirst and ni.CleanMiddle = n.CleanMiddle and ni.CleanLast = n.CleanLast and 
			ni.CleanSuffix = n.CleanSuffix and ni.CleanGivenName = n.CleanGivenName and ni.InternalUserName != n.InternalUserName and 
			RIGHT(ni.InternalUserName, LEN(ni.InternalUserName) - CHARINDEX('@', ni.InternalUserName)) = RIGHT(n.InternalUserName, LEN(n.InternalUserName) - CHARINDEX('@', n.InternalUserName))
		JOIN [Profile.Data].[Person] p2 on ni.InternalUserName = p2.InternalUsername AND p2.IsActive != 1 
		WHERE LEN(ni.PrettyURL) < LEN (n.PrettyURL)

    SELECT * FROM #prettyUrlSwap

	WHILE EXISTS (SELECT * from #prettyUrlSwap)
	BEGIN
		SELECT TOP 1 @id=InternalUserName, @lessPrettyURL=PrettyURL, @inactiveid=InactiveInternalUserName, @inactivePrettyURL=InactivePrettyURL FROM #prettyUrlSwap
		-- set the active one to the shorter inactive one 
		UPDATE [UCSF.].[NameAdditions] SET PrettyURL = @inactivePrettyURL WHERE InternalUserName = @id
		-- set up the inactive one for a redirect to the shorter one
		UPDATE [UCSF.].[NameAdditions] SET PrettyURL = @lessPrettyURL, RedirectToURL=@inactivePrettyURL WHERE InternalUserName = @inactiveid
		-- remove from temp table
		DELETE FROM #prettyUrlSwap WHERE InternalUserName = @id

	END
END
GO

--DROP TABLE #prettyUrlSwap

--select * from [UCSF.].[NameAdditions] WHERE RedirectToURL is not null and RedirectToURL in (select PrettyURL from [UCSF.].[vwActiveNameAdditions])-- Dev 1339, QA 1072

-- EXEC [UCSF.].[FixPrettyURLs] 

-- SELECT * FROM [UCSF.].[NameAdditions] where CleanFirst = 'null' or CleanLast = 'null' or CleanMiddle = 'null' or CleanSuffix = 'null' or CleanGivenName = 'null';
-- SELECT * FROM [UCSF.].[vwActiveNameAdditions] where CleanFirst = 'null' or CleanLast = 'null' or CleanMiddle = 'null' or CleanSuffix = 'null' or CleanGivenName = 'null';

-- backtrack
UPDATE [UCSF.].[NameAdditions] SET GivenName = NULL WHERE GivenName = ''