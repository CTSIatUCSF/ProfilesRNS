-- Add the new one
INSERT [Profile.Module].[GenericRDF.Plugins] ([Name], [EnabledForPerson], [EnabledForGroup], [Label], [PropertyGroupURI], [CustomDisplayModule], [CustomEditModule], [CustomDisplayModuleXML], [CustomEditModuleXML]) VALUES (N'UCSDFacultyMentoring', 1, 0, N'Faculty Mentoring', N'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupFeaturedContent', N'UCSDFacultyMentoring', N'EditUCSDFacultyMentoring', NULL, NULL)

EXEC [Profile.Module].[GenericRDF.AddUpdateOntology] @pluginName='UCSDFacultyMentoring'

-- fix the sort order, put it with Mentoring, make sure SortOrder matches the environment where you are doint this
SELECT *
  FROM [Ontology.].[PropertyGroupProperty] where PropertyURI like '%mentor%' or PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupFeaturedContent' 
  order by SortOrder

UPDATE [Ontology.].[PropertyGroupProperty] set SortOrder = 52 where PropertyURI = 'http://profiles.catalyst.harvard.edu/ontology/plugins#UCSDFacultyMentoring'

-- remove old gadget from all people
-- remove filter
  -- First remove ORNG gadget from everybody. MAKE SURE ONLY UCSD FOLKS SHOW UP!!!
  DECLARE @PropertyNode INT
  SELECT @PropertyNode = _PropertyNode FROM [Ontology.].[ClassProperty] where Property = 'http://orng.info/ontology/orng#hasMentor'
  SELECT @PropertyNode
-- disable gadget

  -- run this and execute the output
  SELECT 'Exec [ORNG.].[RemoveAppFromAgent] @SubjectID=' + cast(Subject as varchar) + ', @AppID=102;' FROM [RDF.].Triple where Predicate = @PropertyNode 
	and Subject in (select NodeID from [UCSF.].vwPerson where InstitutionAbbreviation = 'UCSD');

-- remove the gadget but only for UCSD
 delete FROM [UCSF.ORNG].[InstitutionalizedApps] where AppID = 102 and InstitutionAbbreviation = 'UCSD';
 -- actually remove it for all now? Yes
 
--remove the gadget
EXEC [ORNG.].[RemoveAppFromOntology] @AppID=102
UPDATE [ORNG.].[Apps] SET Enabled=0 WHERE AppID=102
 
