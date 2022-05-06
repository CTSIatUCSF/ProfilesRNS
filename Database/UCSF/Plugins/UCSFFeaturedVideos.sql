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
SELECT 'exec [Profile.Module].[GenericRDF.AddPluginToProfile] @SubjectID=' + cast(nodeid as varchar) + ', @PluginName=''UCSFFeaturedVideos'';' FROM [Profile.Module].[GenericRDF.Data] where Name = 'FeaturedVideos';

-- now run this
INSERT [Profile.Module].[GenericRDF.Data] ([Name], [NodeID], [Data], [SearchableData]) 
SELECT 'UCSFFeaturedVideos', [NodeID], REPLACE([Data], '"id"', '"youTubeId"'), [SearchableData] 
FROM [Profile.Module].[GenericRDF.Data] WHERE [Name] = 'FeaturedVideos';

-- To change the grouping run the following
--UPDATE [Profile.Module].[GenericRDF.Plugins] SET [PropertyGroupURI] = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupOverview' WHERE [Name] = 'UCSFFeaturedVideos';
--Update [Ontology.].[PropertyGroupProperty] set  [PropertyGroupURI] = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupOverview' WHERE PropertyURI = 'http://profiles.catalyst.harvard.edu/ontology/plugins#UCSFFeaturedVideos';
