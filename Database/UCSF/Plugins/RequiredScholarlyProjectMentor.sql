   ---- PLUGGIN STUFF!!!!
-- Add the new one
INSERT [Profile.Module].[GenericRDF.Plugins] ([Name], [EnabledForPerson], [EnabledForGroup], [Label], [PropertyGroupURI], [CustomDisplayModule], [CustomEditModule], [CustomDisplayModuleXML], [CustomEditModuleXML]) VALUES (N'RequiredScholarlyProjectMentor', 1, 0, N'Required Scholarly Project Mentor', N'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupOverview', N'RequiredScholarlyProjectMentor', N'EditRequiredScholarlyProjectMentor', NULL, NULL)

EXEC [Profile.Module].[GenericRDF.AddUpdateOntology] @pluginName='RequiredScholarlyProjectMentor' 
GO

-- First add the pluggin for people who had it visible in their profiles  
DECLARE @PropertyNode INT
SELECT @PropertyNode = _PropertyNode FROM [Ontology.].[ClassProperty] where Property = 'http://orng.info/ontology/orng#hasRequiredScholarlyProjectMentor'
SELECT @PropertyNode

-- run below 
insert into [Profile.Module].[GenericRDF.Data]
SELECT DISTINCT 'RequiredScholarlyProjectMentor', [Subject], 'Required Scholarly Project Mentor', 'Required Scholarly Project Mentor' from [RDF.].Triple where Predicate = @PropertyNode and ViewSecurityGroup = -1;
  
-- Now remove ORNG gadget from everybody 
  --select * from [RDF.].Triple where Predicate = @PropertyNode
  -- check appid!
  -- Run below then execute the output
SELECT 'Exec [ORNG.].[RemoveAppFromAgent] @SubjectID=' + cast(Subject as varchar) + ', @AppID=129;' FROM [RDF.].Triple where Predicate = @PropertyNode
  
-- check
SELECT * FROM [Profile.Module].[GenericRDF.Data] WHERE [Name] = 'RequiredScholarlyProjectMentor';

  -- move data from gadget to genericRDF
--insert into [Profile.Module].[GenericRDF.Data]
--select distinct 'RequiredScholarlyProjectMentor', a.nodeid, 'Required Scholarly Project Mentor', 'Required Scholarly Project Mentor' 
--from [ORNG.].[AppData] a where AppID = 129
  
  -- be sure to remove the filter!!!!
  -- DECLARE @FilterID int
  -- SELECT @FilterID=PersonFilterID FROM [Profile.Data].[Person.Filter] WHERE PersonFilter = 'Academic Senate Committees'
  -- DELETE FROM [Profile.Data].[Person.FilterRelationship] WHERE PersonFilterid = @FilterID
  -- DELETE FROM [Profile.Data].[Person.Filter] WHERE PersonFilterid = @FilterID

  -- DELETE FROM [Profile.Import].[PersonFilterFlag] WHERE personfilter='Academic Senate Committees'

  --remove the gadget
  EXEC [ORNG.].[RemoveAppFromOntology] @AppID=129
  UPDATE [ORNG.].[Apps] SET Enabled=0 WHERE AppID=129

 -- remove verify view from DB manually!!!
 delete from [ORNG.].[AppViews] where AppID = 129

