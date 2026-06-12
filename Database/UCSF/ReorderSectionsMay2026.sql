-- put the  PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupOverview' before http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupBiography

select * from [Ontology.].[PropertyGroup] order by SortOrder

-- swap order of overview and biography groups 
UPDATE [Ontology.].[PropertyGroup] set SortOrder = 10 where PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupSettings'
UPDATE [Ontology.].[PropertyGroup] set SortOrder = 20 where PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupAddress'
UPDATE [Ontology.].[PropertyGroup] set SortOrder = 30 where PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupIntroduction'
UPDATE [Ontology.].[PropertyGroup] set SortOrder = 40 where PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupLinks'
UPDATE [Ontology.].[PropertyGroup] set SortOrder = 50 where PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupLocation'
UPDATE [Ontology.].[PropertyGroup] set SortOrder = 60 where PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupIdentifiers'
UPDATE [Ontology.].[PropertyGroup] set SortOrder = 70 where PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupOverview'
UPDATE [Ontology.].[PropertyGroup] set SortOrder = 80 where PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupBiography'
UPDATE [Ontology.].[PropertyGroup] set SortOrder = 90 where PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupResearch'
UPDATE [Ontology.].[PropertyGroup] set SortOrder = 100 where PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupTime'
UPDATE [Ontology.].[PropertyGroup] set SortOrder = 110 where PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupTeaching'
UPDATE [Ontology.].[PropertyGroup] set SortOrder = 120 where PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupOutreach'
UPDATE [Ontology.].[PropertyGroup] set SortOrder = 130 where PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupAffiliation'
UPDATE [Ontology.].[PropertyGroup] set SortOrder = 140 where PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupFeaturedContent'
UPDATE [Ontology.].[PropertyGroup] set SortOrder = 150 where PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupBibliographic'
UPDATE [Ontology.].[PropertyGroup] set SortOrder = 160 where PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupBibliographiconline'
UPDATE [Ontology.].[PropertyGroup] set SortOrder = 170 where PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupBibobscure'
UPDATE [Ontology.].[PropertyGroup] set SortOrder = 180 where PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupBibmapping'
UPDATE [Ontology.].[PropertyGroup] set SortOrder = 190 where PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupMapping'
UPDATE [Ontology.].[PropertyGroup] set SortOrder = 1000 where PropertyGroupURI = 'http://orng.info/ontology/orng#PropertyGroupORNGApplications'

-- old stuff
-- update [Ontology.].[PropertyGroup] set SortOrder = 7 where [PropertyGroupURI] = 
	-- 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupIdentifiers';
-- update [Ontology.].[PropertyGroup] set SortOrder = 8 where [PropertyGroupURI] = 
	-- 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupOverview';
-- update [Ontology.].[PropertyGroup] set SortOrder = 9 where [PropertyGroupURI] = 
	-- 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupBiography';
-- update [Ontology.].[PropertyGroup] set SortOrder = 10 where [PropertyGroupURI] = 
	-- 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupResearch';
	-- -- put ORNG below even publications
-- update [Ontology.].[PropertyGroup] set SortOrder = 100 where [PropertyGroupURI] = 
	-- 'http://orng.info/ontology/orng#PropertyGroupORNGApplications';

-- should NOT run this more than once, although it won't really break anything
DECLARE @SortOrder int
SELECT @SortOrder = max(SortOrder)+10 FROM  [Ontology.].[PropertyGroupProperty] where PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupResearch';
SELECT @SortOrder 

-- add freetext keyword, featuredPublications and research activities and funding, clinical trials to end of research
update [Ontology.].[PropertyGroupProperty] set PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupResearch', SortOrder = @SortOrder 
	WHERE [PropertyURI] = 'http://vivoweb.org/ontology/core#freetextKeyword';
SET @SortOrder = @SortOrder + 10;
-- redo when we make this a plugin!!!
update [Ontology.].[PropertyGroupProperty] set PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupResearch', SortOrder = @SortOrder 
	WHERE [PropertyURI] = 'http://orng.info/ontology/orng#hasFeaturedPublications'; 
SET @SortOrder = @SortOrder + 10;
update [Ontology.].[PropertyGroupProperty] set PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupResearch', SortOrder = @SortOrder 
	WHERE [PropertyURI] = 'http://vivoweb.org/ontology/core#hasResearcherRole'; 
SET @SortOrder = @SortOrder + 10;
update [Ontology.].[PropertyGroupProperty] set PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupResearch', SortOrder = @SortOrder 
	WHERE [PropertyURI] = 'http://profiles.catalyst.harvard.edu/ontology/plugins#ClinicalTrials'; 

--DECLARE @SortOrder int
-- the next block is featured content, safe to run more than once
SET @SortOrder = @SortOrder + 10;
update [Ontology.].[PropertyGroupProperty] set PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupFeaturedContent', SortOrder = @SortOrder 
	WHERE [PropertyURI] = 'http://vivoweb.org/ontology/core#webpage';

SET @SortOrder = 10
update [Ontology.].[PropertyGroupProperty] set PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupFeaturedContent', SortOrder = @SortOrder 
	WHERE [PropertyURI] = 'http://profiles.catalyst.harvard.edu/ontology/plugins#CollaborationInterests'; 

SET @SortOrder = @SortOrder + 10;
update [Ontology.].[PropertyGroupProperty] set PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupFeaturedContent', SortOrder = @SortOrder 
	WHERE [PropertyURI] = 'http://vivoweb.org/ontology/core#webpage';
	
SET @SortOrder = @SortOrder + 10;
update [Ontology.].[PropertyGroupProperty] set PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupFeaturedContent', SortOrder = @SortOrder 
	WHERE [PropertyURI] = 'http://profiles.catalyst.harvard.edu/ontology/plugins#UCSFFeaturedVideos';

SET @SortOrder = @SortOrder + 10;
update [Ontology.].[PropertyGroupProperty] set PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupFeaturedContent', SortOrder = @SortOrder 
	WHERE [PropertyURI] = 'http://profiles.catalyst.harvard.edu/ontology/prns#mediaLinks';

SET @SortOrder = @SortOrder + 10;
update [Ontology.].[PropertyGroupProperty] set PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupFeaturedContent', SortOrder = @SortOrder 
	WHERE [PropertyURI] = 'http://profiles.catalyst.harvard.edu/ontology/plugins#GlobalHealthEquity';

SET @SortOrder = @SortOrder + 10;
update [Ontology.].[PropertyGroupProperty] set PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupFeaturedContent', SortOrder = @SortOrder 
	WHERE [PropertyURI] = 'http://profiles.catalyst.harvard.edu/ontology/plugins#Mentoring';

SET @SortOrder = @SortOrder + 10;
update [Ontology.].[PropertyGroupProperty] set PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupFeaturedContent', SortOrder = @SortOrder 
	WHERE [PropertyURI] = 'http://profiles.catalyst.harvard.edu/ontology/plugins#CommunityAndPublicService';

SET @SortOrder = @SortOrder + 10;
update [Ontology.].[PropertyGroupProperty] set PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupFeaturedContent', SortOrder = @SortOrder 
	WHERE [PropertyURI] = 'http://profiles.catalyst.harvard.edu/ontology/plugins#AcademicSenate';

-- keep pubs in bibliographic

-- push unused pluggins to ORNG for now
-- ONLY NEEDED FOR DEV
-- update [Ontology.].[PropertyGroupProperty] set PropertyGroupURI = 'http://orng.info/ontology/orng#PropertyGroupORNGApplications'
	-- WHERE [PropertyURI] = 'http://profiles.catalyst.harvard.edu/ontology/plugins#FeaturedVideos';
-- update [Ontology.].[PropertyGroupProperty] set PropertyGroupURI = 'http://orng.info/ontology/orng#PropertyGroupORNGApplications'
	-- WHERE [PropertyURI] = 'http://profiles.catalyst.harvard.edu/ontology/plugins#Twitter';
-- update [Ontology.].[PropertyGroupProperty] set PropertyGroupURI = 'http://orng.info/ontology/orng#PropertyGroupORNGApplications'
	-- WHERE [PropertyURI] = 'http://profiles.catalyst.harvard.edu/ontology/plugins#Identity';

exec [Ontology.].UpdateDerivedFields






