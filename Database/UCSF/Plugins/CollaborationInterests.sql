 ---- PLUGGIN STUFF!!!!
-- Add the new one
INSERT [Profile.Module].[GenericRDF.Plugins] ([Name], [EnabledForPerson], [EnabledForGroup], [Label], [PropertyGroupURI], [CustomDisplayModule], [CustomEditModule], [CustomDisplayModuleXML], [CustomEditModuleXML]) VALUES (N'CollaborationInterests', 1, 0, N'Collaboration Interests', N'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupFeaturedContent', N'CollaborationInterests', N'EditCollaborationInterests', NULL, NULL)

EXEC [Profile.Module].[GenericRDF.AddUpdateOntology] @pluginName='CollaborationInterests' 
GO

-- Move data over. Check AppID
insert into [Profile.Module].[GenericRDF.Data]
select distinct 'CollaborationInterests', a.nodeid, 
REPLACE(
	REPLACE(
		'{"collaborationInterests":["' +
		CASE WHEN b.[Keyname] IS NOT NULL then 'Academic Collaboration' + '","' ELSE '' END +
		CASE WHEN c.[Keyname] IS NOT NULL then 'Academic Senate Committee Service' + '","' ELSE '' END +
		CASE WHEN d.[Keyname] IS NOT NULL then 'Multicenter Clinical Research' + '","' ELSE '' END +
		CASE WHEN e.[Keyname] IS NOT NULL then 'Community and Partner Organizations' + '","' ELSE '' END +
		CASE WHEN f.[Keyname] IS NOT NULL then 'Companies and Entrepreneurs' + '","' ELSE '' END +
		CASE WHEN g.[Keyname] IS NOT NULL then 'Policy Change' + '","' ELSE '' END +
		CASE WHEN h.[Keyname] IS NOT NULL then 'Press' + '","' ELSE '' END + '"],"narrative":"' + 
		ISNULL(i.[Value],'') + '","lastUpdated":"' + REPLACE(REPLACE(REPLACE(RTRIM(ISNULL(j.[Value],'')), CHAR(13),'\r'), CHAR(10), '\n'),'\', '\\') + '"}', 
	',""]', ']'),
'[""]', '[]'),
-- search terms
'Collaboration Interest' + 
		CASE WHEN b.[Keyname] IS NOT NULL then ', Academic Collaboration' ELSE '' END +
		CASE WHEN c.[Keyname] IS NOT NULL then ', Academic Senate Committee Service' ELSE '' END +
		CASE WHEN d.[Keyname] IS NOT NULL then ', Multicenter Clinical Research' ELSE '' END +
		CASE WHEN e.[Keyname] IS NOT NULL then ', Community and Partner Organizations' ELSE '' END +
		CASE WHEN f.[Keyname] IS NOT NULL then ', Companies and Entrepreneurs' ELSE '' END +
		CASE WHEN g.[Keyname] IS NOT NULL then ', Policy Change' ELSE '' END +
		CASE WHEN h.[Keyname] IS NOT NULL then ', Press' ELSE '' END + ', ' + ISNULL(i.[Value],'')
from [ORNG.].[AppData] a 
left outer join [ORNG.].[AppData] b on a.NodeID = b.NodeID and b.AppID = 131 and b.[value] = 'true' and b.Keyname = 'AcademicCollaboration'
left outer join [ORNG.].[AppData] c on a.NodeID = c.NodeID and c.AppID = 131 and c.[value] = 'true' and c.Keyname = 'AcademicSenateCommitteeService'
left outer join [ORNG.].[AppData] d on a.NodeID = d.NodeID and d.AppID = 131 and d.[value] = 'true' and d.Keyname = 'MulticenterClinicalResearch'
left outer join [ORNG.].[AppData] e on a.NodeID = e.NodeID and e.AppID = 131 and e.[value] = 'true' and e.Keyname = 'CommunityAndStakeholderOrganizations'
left outer join [ORNG.].[AppData] f on a.NodeID = f.NodeID and f.AppID = 131 and f.[value] = 'true' and f.Keyname = 'CompaniesAndEntrepreneurs'
left outer join [ORNG.].[AppData] g on a.NodeID = g.NodeID and g.AppID = 131 and g.[value] = 'true' and g.Keyname = 'PolicyChange'
left outer join [ORNG.].[AppData] h on a.NodeID = h.NodeID and h.AppID = 131 and h.[value] = 'true' and h.Keyname = 'Press'
left outer join [ORNG.].[AppData] i on a.NodeID = i.NodeID and i.AppID = 131 and i.Keyname = 'Narrative'
left outer join [ORNG.].[AppData] j on a.NodeID = j.NodeID and j.AppID = 131 and j.Keyname = 'UpdatedOn'
where a.AppID = 131

SELECT *, ISJSON([Data]) FROM [Profile.Module].[GenericRDF.Data] WHERE [Name] = 'CollaborationInterests';
--DELETE FROM [Profile.Module].[GenericRDF.Data] WHERE [Name] = 'CollaborationInterests';

-- remove from all people
-- remove filter
  -- First remove ORNG gadget from everybody 
  DECLARE @PropertyNode INT
  SELECT @PropertyNode = _PropertyNode FROM [Ontology.].[ClassProperty] where Property = 'http://orng.info/ontology/orng#hasCollaborationInterests'
  SELECT @PropertyNode
-- disable gadget

  -- run this and execute the output
  SELECT 'Exec [ORNG.].[RemoveAppFromAgent] @SubjectID=' + cast(Subject as varchar) + ', @AppID=131;' FROM [RDF.].Triple where Predicate = @PropertyNode
  
  -- be sure to remove the filtesr!!!!
  DECLARE @FilterID int
  SELECT @FilterID=PersonFilterID FROM [Profile.Data].[Person.Filter] WHERE PersonFilter = 'Clinical Research'
  DELETE FROM [Profile.Data].[Person.FilterRelationship] WHERE PersonFilterid = @FilterID
  DELETE FROM [Profile.Data].[Person.Filter] WHERE PersonFilterid = @FilterID
  DELETE FROM [Profile.Import].[PersonFilterFlag] WHERE personfilter='Clinical Research'

  SELECT @FilterID=PersonFilterID FROM [Profile.Data].[Person.Filter] WHERE PersonFilter = 'Community And Partner Organizations'
  DELETE FROM [Profile.Data].[Person.FilterRelationship] WHERE PersonFilterid = @FilterID
  DELETE FROM [Profile.Data].[Person.Filter] WHERE PersonFilterid = @FilterID
  DELETE FROM [Profile.Import].[PersonFilterFlag] WHERE personfilter='Community And Partner Organizations'

  SELECT @FilterID=PersonFilterID FROM [Profile.Data].[Person.Filter] WHERE PersonFilter = 'Academic Senate Committee Service'
  DELETE FROM [Profile.Data].[Person.FilterRelationship] WHERE PersonFilterid = @FilterID
  DELETE FROM [Profile.Data].[Person.Filter] WHERE PersonFilterid = @FilterID
  DELETE FROM [Profile.Import].[PersonFilterFlag] WHERE personfilter='Academic Senate Committee Service'

  SELECT @FilterID=PersonFilterID FROM [Profile.Data].[Person.Filter] WHERE PersonFilter = 'Academic Collaboration'
  DELETE FROM [Profile.Data].[Person.FilterRelationship] WHERE PersonFilterid = @FilterID
  DELETE FROM [Profile.Data].[Person.Filter] WHERE PersonFilterid = @FilterID
  DELETE FROM [Profile.Import].[PersonFilterFlag] WHERE personfilter='Academic Collaboration'

  SELECT @FilterID=PersonFilterID FROM [Profile.Data].[Person.Filter] WHERE PersonFilter = 'Prospective Donors'
  DELETE FROM [Profile.Data].[Person.FilterRelationship] WHERE PersonFilterid = @FilterID
  DELETE FROM [Profile.Data].[Person.Filter] WHERE PersonFilterid = @FilterID
  DELETE FROM [Profile.Import].[PersonFilterFlag] WHERE personfilter='Prospective Donors'

  SELECT @FilterID=PersonFilterID FROM [Profile.Data].[Person.Filter] WHERE PersonFilter = 'Press'
  DELETE FROM [Profile.Data].[Person.FilterRelationship] WHERE PersonFilterid = @FilterID
  DELETE FROM [Profile.Data].[Person.Filter] WHERE PersonFilterid = @FilterID
  DELETE FROM [Profile.Import].[PersonFilterFlag] WHERE personfilter='Press'

  SELECT @FilterID=PersonFilterID FROM [Profile.Data].[Person.Filter] WHERE PersonFilter = 'Companies And Entrepreneurs'
  DELETE FROM [Profile.Data].[Person.FilterRelationship] WHERE PersonFilterid = @FilterID
  DELETE FROM [Profile.Data].[Person.Filter] WHERE PersonFilterid = @FilterID
  DELETE FROM [Profile.Import].[PersonFilterFlag] WHERE personfilter='Companies And Entrepreneurs'

  SELECT @FilterID=PersonFilterID FROM [Profile.Data].[Person.Filter] WHERE PersonFilter = 'Physician Scientist'
  DELETE FROM [Profile.Data].[Person.FilterRelationship] WHERE PersonFilterid = @FilterID
  DELETE FROM [Profile.Data].[Person.Filter] WHERE PersonFilterid = @FilterID
  DELETE FROM [Profile.Import].[PersonFilterFlag] WHERE personfilter='Physician Scientist'

  SELECT @FilterID=PersonFilterID FROM [Profile.Data].[Person.Filter] WHERE PersonFilter = 'Policy Change'
  DELETE FROM [Profile.Data].[Person.FilterRelationship] WHERE PersonFilterid = @FilterID
  DELETE FROM [Profile.Data].[Person.Filter] WHERE PersonFilterid = @FilterID
  DELETE FROM [Profile.Import].[PersonFilterFlag] WHERE personfilter='Policy Change'

  --remove the gadget
  EXEC [ORNG.].[RemoveAppFromOntology] @AppID=131
  UPDATE [ORNG.].[Apps] SET Enabled=0 WHERE AppID=131

 -- remove verify view from DB manually!!!
 delete from [ORNG.].[AppViews] where AppID = 131