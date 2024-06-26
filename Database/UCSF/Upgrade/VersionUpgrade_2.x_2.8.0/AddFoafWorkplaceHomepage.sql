--SELECT * FROM  [Ontology.].[ClassProperty] WHERE property LIKE '%foaf%' --1993, 2001

-- we use our OWL to add this even though it is FOAF.  Chalk it up to general Profiles RDF strangeness
EXEC [Ontology.].[AddProperty]	@OWL = 'UCSF_1.0',
								@PropertyURI = 'http://xmlns.com/foaf/0.1/workplaceHomepage',
								@PropertyName = 'workplace homepage',
								@ObjectType = 1,
								@PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupAddress',
								@ClassURI = 'http://xmlns.com/foaf/0.1/Person',
								@IsDetail = 0,
								@IncludeDescription = 0;
								
UPDATE [Ontology.].[ClassProperty] SET CustomDisplay = 1 WHERE Property = 'http://xmlns.com/foaf/0.1/workplaceHomepage';
-- DO NOT NEED AN INSERT
--INSERT [Ontology.].[ClassProperty] (ClassPropertyID, Class, NetworkProperty, Property, IsDetail, Limit, 
--IncludeDescription, IncludeNetwork, SearchWeight, CustomDisplay, CustomEdit, 
--ViewSecurityGroup, EditSecurityGroup, EditPermissionsSecurityGroup, EditExistingSecurityGroup, EditAddNewSecurityGroup, EditAddExistingSecurityGroup,
--EditDeleteSecurityGroup, MinCardinality, MaxCardinality, CustomDisplayModule, CustomEditModule) VALUES (1000,
--'http://xmlns.com/foaf/0.1/Person', NULL, 'http://xmlns.com/foaf/0.1/workplaceHomepage', 0, NULL, 0, 0, 0, 1, 0,   
---1, -40, -40, -40, -40, -40, -40, 0, NULL, NULL, NULL);

--SELECT * FROM  [Ontology.].[PropertyGroupProperty] WHERE PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupAddress' ORDER BY SortOrder;

--INSERT [Ontology.].[PropertyGroupProperty] (PropertyGroupURI, PropertyURI, SortOrder, [_PropertyLabel]) VALUES (
--'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupAddress', 'http://xmlns.com/foaf/0.1/workplaceHomepage', 26, 'workplace hompage');

--EXEC [Ontology.].UpdateDerivedFields;

--SELECT * FROM  [Ontology.].[DataMap] WHERE Property LIKE '%foaf%'

--SELECT p.PersonID, f.Value + '/' + p.UrlName workplaceHomepage FROM [UCSF.].[vwPerson] p LEFT JOIN [Framework.].[Parameter] f ON f.ParameterID = 'basePath' AND p.UrlName IS NOT NULL;

INSERT INTO [Ontology.].[DataMap] (DataMapID, DataMapGroup, IsAutoFeed, Graph, 
		Class, NetworkProperty, Property, 
		MapTable, 
		sInternalType, sInternalID, 
		oValue,
		oObjectType, Weight, OrderBy, ViewSecurityGroup, EditSecurityGroup)
	VALUES (1000, 1, 1, 1,
		'http://xmlns.com/foaf/0.1/Person', NULL, 'http://xmlns.com/foaf/0.1/workplaceHomepage',
		'(SELECT p.PersonID, f.Value + ''/'' + p.UrlName workplaceHomepage FROM [UCSF.].[vwPerson] p LEFT JOIN [Framework.].[Parameter] f ON f.ParameterID = ''basePath'' AND p.UrlName IS NOT NULL) t',
		'Person', 'PersonID',
		'workplaceHomepage',
		1, 1, NULL, -1, -40)
		
EXEC [Ontology.].UpdateDerivedFields;		
		
EXEC [RDF.Stage].[ProcessDataMap] @DataMapID = 1000, @ShowCounts = 1

EXEC [Ontology.].[CleanUp] @Action = 'UpdateIDs';

-- now run FixLabels!

--SELECT * FROM [RDF.].Node WHERE NodeID IN (1993, 2001);

--DELETE FROM [Ontology.].[ClassProperty] WHERE Property = 'http://xmlns.com/foaf/0.1/workplaceHomepage';
--DELETE FROM [Ontology.].[PropertyGroupProperty] WHERE PropertyURI = 'http://xmlns.com/foaf/0.1/workplaceHomepage';
--DELETE FROM [Ontology.].[DataMap] WHERE Property = 'http://xmlns.com/foaf/0.1/workplaceHomepage';


--EXEC [RDF.].GetDataRDF @subject = 368698, -- bigint
--    @showDetails = 1, -- bit
--    @expand = 1;
