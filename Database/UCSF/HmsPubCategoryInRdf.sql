
CREATE VIEW [UCSF.].[vwPublication.MyPub.General] AS
SELECT ir.EntityID, g.* FROM [Profile.Data].[Publication.Entity.InformationResource] ir JOIN [Profile.Data].[Publication.MyPub.General] g ON
ir.MPID = g.MPID WHERE ir.MPID IS NOT NULL;

-- Check that UCSF_1.0 is in [Ontology.Import].[OWL]!

EXEC [Ontology.].[AddProperty]	@OWL = 'UCSF_1.0',
								@PropertyURI = 'http://profiles.ucsf.edu/ontology/ucsf#hmsPubCategory',
								@PropertyName = 'hmsPubCategory',
								@ObjectType = 1,
								@PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupBibobscure',
								@ClassURI = 'http://vivoweb.org/ontology/core#InformationResource',
								@IsDetail = 0,
								@IncludeDescription = 0;
								
INSERT INTO [Ontology.].[DataMap] (DataMapID, DataMapGroup, IsAutoFeed, Graph, 
		Class, NetworkProperty, Property, 
		MapTable, 
		sInternalType, sInternalID, 
		oClass, oInternalType, oInternalID, oValue, oDataType, oLanguage, 
		oObjectType, Weight, OrderBy, ViewSecurityGroup, EditSecurityGroup)
	VALUES (1004, 1, 1, 1,
		'http://vivoweb.org/ontology/core#InformationResource', NULL, 'http://profiles.ucsf.edu/ontology/ucsf#hmsPubCategory',
		'[UCSF.].[vwPublication.MyPub.General]',
		'InformationResource', 'EntityID',
		NULL, NULL, NULL, 'HmsPubCategory', NULL, NULL,
		1, 1, NULL, -1, -40);
		
EXEC [Ontology.].UpdateDerivedFields;

EXEC [Ontology.].[CleanUp] @Action = 'UpdateIDs';

-- now run FixLabels.sql		