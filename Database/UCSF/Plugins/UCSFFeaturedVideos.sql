-- TURN OFF OLD ONE
UPDATE [Profile.Module].[GenericRDF.Plugins] set [EnabledForPerson] = 0, [EnabledForGroup] = 0 WHERE [Name] = 'FeaturedVideos';

EXEC [Profile.Module].[GenericRDF.AddUpdateOntology] @PluginName='FeaturedVideos';

-- do we need to remove/hide these in the profile RDF as well?
-- YES
-- Copy the data over, run this and execute results
SELECT 'exec [Profile.Module].[GenericRDF.RemovePluginFromProfile] @SubjectID=' + cast(nodeid as varchar) + ', @PluginName=''FeaturedVideos'';' FROM [Profile.Module].[GenericRDF.Data] where Name = 'FeaturedVideos';

-- Add the new one
INSERT [Profile.Module].[GenericRDF.Plugins] ([Name], [EnabledForPerson], [EnabledForGroup], [Label], [PropertyGroupURI], [CustomDisplayModule], [CustomEditModule], [CustomDisplayModuleXML], [CustomEditModuleXML]) VALUES (N'UCSFFeaturedVideos', 1, 1, N'Featured Videos', N'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupFeaturedContent', N'UCSFFeaturedVideos', N'EditUCSFFeaturedVideos', NULL, NULL)

EXEC [Profile.Module].[GenericRDF.AddUpdateOntology] @pluginName='UCSFFeaturedVideos'

-- Copy the data over, run this and execute results
INSERT [Profile.Module].[GenericRDF.Data] ([Name], [NodeID], [Data], [SearchableData]) 
SELECT 'UCSFFeaturedVideos', [NodeID], REPLACE([Data], '"id"', '"youTubeId"'), [SearchableData] 
FROM [Profile.Module].[GenericRDF.Data] WHERE [Name] = 'FeaturedVideos';

-- now run this to add the new plugin to the profiles. Note that this needs to run AFTER the data has been added to the GenericRDF.Data table because
-- this SP is how the data ends up in the RDF.
SELECT 'exec [Profile.Module].[GenericRDF.AddPluginToProfile] @SubjectID=' + cast(nodeid as varchar) + ', @PluginName=''UCSFFeaturedVideos'';' FROM [Profile.Module].[GenericRDF.Data] where Name = 'UCSFFeaturedVideos';

-- To change the grouping run the following
--UPDATE [Profile.Module].[GenericRDF.Plugins] SET [PropertyGroupURI] = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupOverview' WHERE [Name] = 'UCSFFeaturedVideos';
--Update [Ontology.].[PropertyGroupProperty] set  [PropertyGroupURI] = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupOverview' WHERE PropertyURI = 'http://profiles.catalyst.harvard.edu/ontology/plugins#UCSFFeaturedVideos';


-- 8/11/2022  Convert "name" to "title"
UPDATE [Profile.Module].[GenericRDF.Data] SET [Data] = REPLACE([Data], '"name"', '"title"') WHERE [Name] = 'UCSFFeaturedVideos';