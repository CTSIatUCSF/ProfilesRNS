

---EXEC [Framework.].[LoadXMLFile] @FilePath = '$(ProfilesRNSRootPath)\Data\PRNS_1.2.owl', @TableDestination = '[Ontology.Import].owl', @DestinationColumn = 'DATA', @NameValue = 'PRNS_1.2'

INSERT [Ontology.Import].OWL VALUES ('UCSF_1.1', N'<rdf:RDF xmlns:geo="http://aims.fao.org/aos/geopolitical.owl#" xmlns:afn="http://jena.hpl.hp.com/ARQ/function#" xmlns:catalyst="http://profiles.catalyst.harvard.edu/ontology/catalyst#" xmlns:ucsf="http://profiles.ucsf.edu/ontology/ucsf#" xmlns:prns="http://profiles.catalyst.harvard.edu/ontology/prns#" xmlns:obo="http://purl.obolibrary.org/obo/" xmlns:dcelem="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:event="http://purl.org/NET/c4dm/event.owl#" xmlns:bibo="http://purl.org/ontology/bibo/" xmlns:vann="http://purl.org/vocab/vann/" xmlns:vitro07="http://vitro.mannlib.cornell.edu/ns/vitro/0.7#" xmlns:vitro="http://vitro.mannlib.cornell.edu/ns/vitro/public#" xmlns:vivo="http://vivoweb.org/ontology/core#" xmlns:pvs="http://vivoweb.org/ontology/provenance-support#" xmlns:scirr="http://vivoweb.org/ontology/scientific-research-resource#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:swvs="http://www.w3.org/2003/06/sw-vocab-status/ns#" xmlns:skco="http://www.w3.org/2004/02/skos/core#" xmlns:owl2="http://www.w3.org/2006/12/owl2-xml#" xmlns:skos="http://www.w3.org/2008/05/skos#" xmlns:foaf="http://xmlns.com/foaf/0.1/">
  <rdf:Description rdf:about="http://xmlns.com/foaf/0.1/workplaceHomepage">
    <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#DatatypeProperty" />
    <rdfs:label rdf:resource="workplace homepage" />
    <rdfs:domain rdf:resource="http://xmlns.com/foaf/0.1/Person" />
    <vitro:descriptionAnnot rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
      A workplace homepage of some person; the homepage of an organization they work for. 
    </vitro:descriptionAnnot>
  </rdf:Description>
  <rdf:Description rdf:about="http://profiles.ucsf.edu/ontology/ucsf#hmsPubCategory">
    <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#DatatypeProperty" />
    <rdfs:label rdf:resource="HMS publication category" />
    <rdfs:domain rdf:resource="http://vivoweb.org/ontology/core#InformationResource" />
    <vitro:descriptionAnnot rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
      The publication category used by HMS for recoginizing various types of publications.
    </vitro:descriptionAnnot>
  </rdf:Description>
</rdf:RDF>', 100)

-- Import the Updated PRNS ontology into Profiles. This should not eliminate any customizations unless additional 
-- classes have been added to the PRNS ontology
DELETE FROM [Ontology.Import].OWL WHERE name like 'UCSF_%'
DELETE FROM [Ontology.Import].Triple WHERE OWL like 'UCSF_%'
UPDATE [Ontology.Import].OWL SET Graph = 5 WHERE name = 'UCSF_1.1'
EXEC [Ontology.Import].[ConvertOWL2Triple] @OWL = 'UCSF_1.1'

EXEC [RDF.Stage].[LoadTriplesFromOntology] @Truncate = 1
EXEC [RDF.Stage].[ProcessTriples]

-- see if work needs to be done to get the ClassProperty items correct!  Compare to old DB


-- delete any old values from datamap
--SELECT * FROM [Ontology.].[DataMap] WHERE Property in ('http://xmlns.com/foaf/0.1/workplaceHomepage','http://profiles.ucsf.edu/ontology/ucsf#hmsPubCategory');
--DELETE FROM [Ontology.].[DataMap] WHERE Property in ('http://xmlns.com/foaf/0.1/workplaceHomepage','http://profiles.ucsf.edu/ontology/ucsf#hmsPubCategory')

-- Workplace Homepage
EXEC [Ontology.].[AddProperty]	@OWL = 'UCSF_1.1',
								@PropertyURI = 'http://xmlns.com/foaf/0.1/workplaceHomepage',
								@PropertyName = 'workplace homepage',
								@ObjectType = 1,
								@PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupAddress',
								@ClassURI = 'http://xmlns.com/foaf/0.1/Person',
								@IsDetail = 0,
								@IncludeDescription = 0;
								
UPDATE [Ontology.].[ClassProperty] SET CustomDisplay = 1 WHERE Property = 'http://xmlns.com/foaf/0.1/workplaceHomepage';

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

-- HMS Pub Category
EXEC [Ontology.].[AddProperty]	@OWL = 'UCSF_1.1',
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
	VALUES (1001, 1, 1, 1,
		'http://vivoweb.org/ontology/core#InformationResource', NULL, 'http://profiles.ucsf.edu/ontology/ucsf#hmsPubCategory',
		'[UCSF.].[vwPublication.MyPub.General]',
		'InformationResource', 'EntityID',
		NULL, NULL, NULL, 'HmsPubCategory', NULL, NULL,
		1, 1, NULL, -1, -40);

		
EXEC [Ontology.].UpdateDerivedFields;

EXEC [RDF.Stage].[ProcessDataMap] @DataMapID = 1000, @ShowCounts = 1
EXEC [RDF.Stage].[ProcessDataMap] @DataMapID = 1001, @ShowCounts = 1

EXEC [Ontology.].[CleanUp] @Action = 'UpdateIDs';