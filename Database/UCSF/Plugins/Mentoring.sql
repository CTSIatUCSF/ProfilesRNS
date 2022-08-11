-- Add the new one
INSERT [Profile.Module].[GenericRDF.Plugins] ([Name], [EnabledForPerson], [EnabledForGroup], [Label], [PropertyGroupURI], [CustomDisplayModule], [CustomEditModule], [CustomDisplayModuleXML], [CustomEditModuleXML]) VALUES (N'Mentoring', 1, 1, N'Mentoring', N'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupOverview', N'Mentoring', N'EditMentoring', NULL, NULL)

EXEC [Profile.Module].[GenericRDF.AddUpdateOntology] @pluginName='Mentoring'


-- Add code to remove old gadget and remove from drop down (if only for UC Davis)
-- Gadget should be manually removed from the profiles first
DELETE FROM [UCSF.ORNG].[InstitutionalizedApps] WHERE URL LIKE '%Mentor_UCD.xml';