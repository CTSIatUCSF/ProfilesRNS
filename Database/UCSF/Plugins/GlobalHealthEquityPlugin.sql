INSERT [Profile.Module].[GenericRDF.Plugins] ([Name], [EnabledForPerson], [EnabledForGroup], [Label], [PropertyGroupURI], [CustomDisplayModule], [CustomEditModule], [CustomDisplayModuleXML], [CustomEditModuleXML]) VALUES (N'GlobalHealthEquity', 1, 1, N'Global Health Equity', N'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupFeaturedContent', N'GlobalHealthEquity', N'EditGlobalHealthEquity', NULL, NULL)

EXEC [Profile.Module].[GenericRDF.AddUpdateOntology] @pluginName='GlobalHealthEquity'

--- Add fake data to Eric
DECLARE @NodeID bigint;
select @NodeID = nodeid FROM [UCSF.].[vwPerson] where InternalUsername = '569307@ucsf.edu';
SELECT @nodeID;

exec [Profile.Module].[GenericRDF.AddEditPluginData] @Name='GlobalHealthEquity', @NodeID=@NodeID, 
	@Data='{"interests": ["urban health", "substance abuse and mental health", "infectious diseases", "care delivery", "ebola"],"locations": ["Congo", "Liberia", "Africa"]}', 
	@SearchableData='Global Health, urban health, substance abuse and mental health, infectious diseases, care delivery, ebola​, Congo, Liberia, Africa​';


exec [RDF.].GetDataRDF @subject=225751;
