-- set gadget section in the right place
DECLARE @sortOrder INT

SELECT @sortOrder = SortOrder FROM [Ontology.].[PropertyGroup] where PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupOutreach'

SELECT @sortOrder

IF EXISTS (SELECT * FROM [Ontology.].[PropertyGroup] WHERE PropertyGroupURI = 'http://orng.info/ontology/orng#PropertyGroupORNGApplications' AND SortOrder < @sortOrder)
BEGIN
	UPDATE [Ontology.].[PropertyGroup] SET SortOrder = SortOrder+1 WHERE SortOrder > @sortOrder
	UPDATE [Ontology.].[PropertyGroup] SET SortOrder = @sortOrder+1 WHERE PropertyGroupURI = 'http://orng.info/ontology/orng#PropertyGroupORNGApplications'
END

-- now order the gadgets
SELECT @sortOrder = SortOrder FROM [Ontology.].[PropertyGroupProperty] where PropertyURI = 'http://orng.info/ontology/orng#hasApplicationInstanceData'
SELECT @sortOrder
IF (@sortOrder < 10)
BEGIN
	UPDATE [Ontology.].[PropertyGroupProperty] SET SortOrder = 10 where PropertyURI = 'http://orng.info/ontology/orng#hasFeaturedPublications'
	UPDATE [Ontology.].[PropertyGroupProperty] SET SortOrder = 11 where PropertyURI = 'http://orng.info/ontology/orng#hasMediaLinks'
	UPDATE [Ontology.].[PropertyGroupProperty] SET SortOrder = 12 where PropertyURI = 'http://orng.info/ontology/orng#hasSlideShare'
	UPDATE [Ontology.].[PropertyGroupProperty] SET SortOrder = 13 where PropertyURI = 'http://orng.info/ontology/orng#hasMentor'
	UPDATE [Ontology.].[PropertyGroupProperty] SET SortOrder = 14 where PropertyURI = 'http://orng.info/ontology/orng#hasClinicalTrials'
	UPDATE [Ontology.].[PropertyGroupProperty] SET SortOrder = 15 where PropertyURI = 'http://orng.info/ontology/orng#hasTwitter'
	UPDATE [Ontology.].[PropertyGroupProperty] SET SortOrder = 16 where PropertyURI = 'http://orng.info/ontology/orng#hasVideos'
	UPDATE [Ontology.].[PropertyGroupProperty] SET SortOrder = 17 where PropertyURI = 'http://orng.info/ontology/orng#hasLinks'
	UPDATE [Ontology.].[PropertyGroupProperty] SET SortOrder = 18 where PropertyURI = 'http://orng.info/ontology/orng#hasGlobalHealth'
	UPDATE [Ontology.].[PropertyGroupProperty] SET SortOrder = 19 where PropertyURI = 'http://orng.info/ontology/orng#hasLinkedIn'
	UPDATE [Ontology.].[PropertyGroupProperty] SET SortOrder = 20 where PropertyURI = 'http://orng.info/ontology/orng#hasRSS'
	UPDATE [Ontology.].[PropertyGroupProperty] SET SortOrder = 21 where PropertyURI = 'http://orng.info/ontology/orng#hasPopulationHealthSciences'
	UPDATE [Ontology.].[PropertyGroupProperty] SET SortOrder = 22 where PropertyURI = 'http://orng.info/ontology/orng#hasStudentProjects'

	UPDATE [Ontology.].[PropertyGroupProperty] SET SortOrder = 100 where PropertyURI = 'http://orng.info/ontology/orng#hasRequiredScholarlyProjectMentor'
	UPDATE [Ontology.].[PropertyGroupProperty] SET SortOrder = 101 where PropertyURI = 'http://orng.info/ontology/orng#hasTagEditor'
END 
ELSE
	SELECT 'TAKE A LOOK! Somethign is wrong'

	