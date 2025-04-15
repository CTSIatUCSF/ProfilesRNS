-- Add the new one
INSERT [Profile.Module].[GenericRDF.Plugins] ([Name], [EnabledForPerson], [EnabledForGroup], [Label], [PropertyGroupURI], [CustomDisplayModule], [CustomEditModule], [CustomDisplayModuleXML], [CustomEditModuleXML]) VALUES (N'CommunityAndPublicService', 1, 0, N'Community and Public Service', N'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupOverview', N'CommunityAndPublicService', N'EditCommunityAndPublicService', NULL, NULL)

EXEC [Profile.Module].[GenericRDF.AddUpdateOntology] @pluginName='CommunityAndPublicService'

