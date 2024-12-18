DECLARE @groupsSortOrder INT
DECLARE @orngSortOrder INT

SELECT @groupsSortOrder = SortOrder FROM [Ontology.].[PropertyGroup] WHERE PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupAffiliation';
SELECT @orngSortOrder = SortOrder FROM [Ontology.].[PropertyGroup] WHERE PropertyGroupURI = 'http://orng.info/ontology/orng#PropertyGroupORNGApplications';

SELECT @groupsSortOrder, @orngSortOrder
-- move groups just before ORNG, and shift everything in between down
UPDATE [Ontology.].[PropertyGroup] set SortOrder = SortOrder - 1 WHERE SortOrder > @groupsSortOrder AND SortOrder < @orngSortOrder;
UPDATE [Ontology.].[PropertyGroup] set SortOrder = @orngSortOrder - 1 WHERE PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupAffiliation';

SELECT * FROM  [Ontology.].[PropertyGroup] ORDER BY SortOrder;