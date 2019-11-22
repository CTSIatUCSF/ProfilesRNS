INSERT INTO [Ontology.].[DataMap] (DataMapID, DataMapGroup, IsAutoFeed, Graph, 
		Class, NetworkProperty, Property, 
		MapTable, 
		sInternalType, sInternalID, 
		oValue, 
		oObjectType, Weight, OrderBy, ViewSecurityGroup, EditSecurityGroup)
	VALUES (1001, 1, 1, 1,
		'http://vivoweb.org/ontology/core#InformationResource', NULL, 'http://purl.org/ontology/bibo/doi',
		'[UCSF.].[vwPublication.Entity.InformationResource]',
		'InformationResource', 'EntityID',
		'DOI', 
		1, 1, NULL, -1, -40)

-- Update derived fields in the [Ontology.].[DataMap]

INSERT INTO [Ontology.].[ClassProperty] (ClassPropertyID, 
		Class, NetworkProperty, Property, 
		IsDetail, Limit, IncludeDescription, IncludeNetwork, SearchWeight, 
		CustomDisplay, CustomEdit, ViewSecurityGroup, 
		EditSecurityGroup, EditPermissionsSecurityGroup, EditExistingSecurityGroup, EditAddNewSecurityGroup, EditAddExistingSecurityGroup, EditDeleteSecurityGroup, 
		MinCardinality, MaxCardinality, 
		CustomDisplayModule, CustomEditModule)
	VALUES (9998,
			'http://purl.org/ontology/bibo/Document', NULL, 'http://purl.org/ontology/bibo/doi',
			1, NULL, 0, 0, 0.5,
			0, 0, -1,
			-40, -40, -40, -40, -40, -40,
			0, NULL,
			NULL, NULL)

INSERT INTO [Ontology.].[ClassProperty] (ClassPropertyID, 
		Class, NetworkProperty, Property, 
		IsDetail, Limit, IncludeDescription, IncludeNetwork, SearchWeight, 
		CustomDisplay, CustomEdit, ViewSecurityGroup, 
		EditSecurityGroup, EditPermissionsSecurityGroup, EditExistingSecurityGroup, EditAddNewSecurityGroup, EditAddExistingSecurityGroup, EditDeleteSecurityGroup, 
		MinCardinality, MaxCardinality, 
		CustomDisplayModule, CustomEditModule)
	VALUES (9999,
			'http://vivoweb.org/ontology/core#InformationResource', NULL, 'http://purl.org/ontology/bibo/doi',
			0, NULL, 0, 0, 1,
			0, 0, -1,
			-40, -40, -40, -40, -40, -40,
			0, NULL,
			NULL, NULL)

EXEC [Ontology.].[UpdateDerivedFields]


EXEC [Ontology.].[CleanUp] @Action = 'UpdateIDs'

-- remember to run FixLabels.sql after running this!

select * from [Ontology.].[DataMap] WHERE MapTable like '%vwPublication.Entity.InformationResource%';
select * from [Ontology.].[DataMap] WHERE Property IN ('http://purl.org/ontology/bibo/doi', 'http://purl.org/ontology/bibo/pmid');

UPDATE [Ontology.].[DataMap] SET MapTable = '[UCSF.].[vwPublication.Entity.InformationResource]' WHERE Property IN ('http://purl.org/ontology/bibo/doi', 'http://purl.org/ontology/bibo/pmid');

select * FROM [Ontology.].[DataMap] WHERE Property like '%source%';