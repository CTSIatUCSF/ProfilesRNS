-- Add the new one
INSERT [Profile.Module].[GenericRDF.Plugins] ([Name], [EnabledForPerson], [EnabledForGroup], [Label], [PropertyGroupURI], [CustomDisplayModule], [CustomEditModule], [CustomDisplayModuleXML], [CustomEditModuleXML]) VALUES (N'UCDStudentProjects', 1, 0, N'Student Projects', N'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupFeaturedContent', N'UCDStudentProjects', N'EditUCDStudentProjects', NULL, NULL)

EXEC [Profile.Module].[GenericRDF.AddUpdateOntology] @pluginName='UCDStudentProjects'

-- fix the sort order, put it with Mentoring, make sure SortOrder matches the environment where you are doint this
SELECT *
  FROM [Ontology.].[PropertyGroupProperty] where PropertyURI like '%project%' or PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupFeaturedContent' 
  order by SortOrder

UPDATE [Ontology.].[PropertyGroupProperty] set SortOrder = 80 where PropertyURI = 'http://profiles.catalyst.harvard.edu/ontology/plugins#UCDStudentProjects'

  -- remove old gadget from all people
-- remove filter
  -- First remove ORNG gadget from everybody. MAKE SURE ONLY UCSD FOLKS SHOW UP!!!
  DECLARE @PropertyNode INT
  SELECT @PropertyNode = _PropertyNode FROM [Ontology.].[ClassProperty] where Property = 'http://orng.info/ontology/orng#hasStudentProjects'
  SELECT @PropertyNode
-- disable gadget

  -- run this and execute the output
  SELECT 'Exec [ORNG.].[RemoveAppFromAgent] @SubjectID=' + cast(Subject as varchar) + ', @AppID=126;' FROM [RDF.].Triple where Predicate = @PropertyNode 
	and Subject in (select NodeID from [UCSF.].vwPerson where InstitutionAbbreviation = 'UC Davis');

-- remove the gadget but only for UC Davis
 delete FROM [UCSF.ORNG].[InstitutionalizedApps] where AppID = 126 and InstitutionAbbreviation = 'UC Davis';
 -- actually remove it for all now? Yes
 
--remove the gadget
EXEC [ORNG.].[RemoveAppFromOntology] @AppID=126
UPDATE [ORNG.].[Apps] SET Enabled=0 WHERE AppID=126

