---- PLUGGIN STUFF!!!!
-- Add the new one
INSERT [Profile.Module].[GenericRDF.Plugins] ([Name], [EnabledForPerson], [EnabledForGroup], [Label], [PropertyGroupURI], [CustomDisplayModule], [CustomEditModule], [CustomDisplayModuleXML], [CustomEditModuleXML]) VALUES (N'ClinicalTrials', 1, 0, N'Clinical Trials', N'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupOverview', N'ClinicalTrials', N'EditClinicalTrials', NULL, NULL)

EXEC [Profile.Module].[GenericRDF.AddUpdateOntology] @pluginName='ClinicalTrials' 
GO

CREATE SCHEMA [UCSF.Import]


-- copy over ORNG data. Make sure AppID = 121!!!!
-- to test
SELECT distinct a.NodeID, b.Keyname, b.[Value], c.Keyname, c.[Value] from [ORNG.].[AppData] a LEFT OUTER JOIN [ORNG.].[AppData] b on a.AppID = 121 and a.AppID = b.AppID and a.NodeID = b.NodeID LEFT OUTER JOIN [ORNG.].[AppData] c on 
	a.AppID = 121 and a.AppID = c.AppID and a.NodeID = c.NodeID where b.Keyname = 'clinical_trials_active' and c.Keyname = 'clinical_trials_deleted';

-- to do
INSERT INTO [UCSF.Import].[ClincalTrialsEdits] (NodeID, [Add], [Remove])
SELECT distinct a.NodeID, b.[Value],c.[Value] from [ORNG.].[AppData] a LEFT OUTER JOIN [ORNG.].[AppData] b on a.AppID = 121 and a.AppID = b.AppID and a.NodeID = b.NodeID LEFT OUTER JOIN [ORNG.].[AppData] c on 
	a.AppID = 121 and a.AppID = c.AppID and a.NodeID = c.NodeID where b.Keyname = 'clinical_trials_active' and c.Keyname = 'clinical_trials_deleted';

-- to check
SELECT * FROM [ProfilesRNS_Dev].[UCSF.Import].[ClincalTrialsEdits]

-- remove gadget
  -- First remove ORNG gadget from everybody 
  DECLARE @PropertyNode INT
  SELECT @PropertyNode = _PropertyNode FROM [Ontology.].[ClassProperty] where Property = 'http://orng.info/ontology/orng#hasClinicalTrials'
  SELECT @PropertyNode

  -- Run below then execute the output
  SELECT 'Exec [ORNG.].[RemoveAppFromAgent] @SubjectID=' + cast(Subject as varchar) + ', @AppID=121;' FROM [RDF.].Triple where Predicate = @PropertyNode
 
   -- be sure to remove the filter!!!!
  DECLARE @FilterID int
  SELECT @FilterID=PersonFilterID FROM [Profile.Data].[Person.Filter] WHERE PersonFilter = 'Clinical Trials'
  DELETE FROM [Profile.Data].[Person.FilterRelationship] WHERE PersonFilterid = @FilterID
  DELETE FROM [Profile.Data].[Person.Filter] WHERE PersonFilterid = @FilterID

  DELETE FROM [Profile.Import].[PersonFilterFlag] WHERE personfilter='Clinical Trials'

  --remove the gadget
  EXEC [ORNG.].[RemoveAppFromOntology] @AppID=121
  UPDATE [ORNG.].[Apps] SET Enabled=0 WHERE AppID=121

 -- remove verify view from DB manually!!!
 delete from [ORNG.].[AppViews] where AppID = 121