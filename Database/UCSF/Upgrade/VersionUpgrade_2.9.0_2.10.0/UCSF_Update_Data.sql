DELETE FROM [Ontology.Import].OWL WHERE name like 'UCSF_%'
DELETE FROM [Ontology.Import].Triple WHERE OWL like 'UCSF_%'
---EXEC [Framework.].[LoadXMLFile] @FilePath = '$(ProfilesRNSRootPath)\Data\PRNS_1.2.owl', @TableDestination = '[Ontology.Import].owl', @DestinationColumn = 'DATA', @NameValue = 'PRNS_1.2'

INSERT [Ontology.Import].OWL VALUES ('UCSF_1.2', N'<rdf:RDF xmlns:geo="http://aims.fao.org/aos/geopolitical.owl#" xmlns:afn="http://jena.hpl.hp.com/ARQ/function#" xmlns:catalyst="http://profiles.catalyst.harvard.edu/ontology/catalyst#" xmlns:ucsf="http://profiles.ucsf.edu/ontology/ucsf#" xmlns:prns="http://profiles.catalyst.harvard.edu/ontology/prns#" xmlns:obo="http://purl.obolibrary.org/obo/" xmlns:dcelem="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:event="http://purl.org/NET/c4dm/event.owl#" xmlns:bibo="http://purl.org/ontology/bibo/" xmlns:vann="http://purl.org/vocab/vann/" xmlns:vitro07="http://vitro.mannlib.cornell.edu/ns/vitro/0.7#" xmlns:vitro="http://vitro.mannlib.cornell.edu/ns/vitro/public#" xmlns:vivo="http://vivoweb.org/ontology/core#" xmlns:pvs="http://vivoweb.org/ontology/provenance-support#" xmlns:scirr="http://vivoweb.org/ontology/scientific-research-resource#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:swvs="http://www.w3.org/2003/06/sw-vocab-status/ns#" xmlns:skco="http://www.w3.org/2004/02/skos/core#" xmlns:owl2="http://www.w3.org/2006/12/owl2-xml#" xmlns:skos="http://www.w3.org/2008/05/skos#" xmlns:foaf="http://xmlns.com/foaf/0.1/">
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
  <rdf:Description rdf:about="http://profiles.ucsf.edu/ontology/ucsf#hasClaimedPublication">
    <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#DatatypeProperty" />
    <rdfs:label rdf:resource="Person has claimed publications" />
    <rdfs:domain rdf:resource="http://vivoweb.org/ontology/core#Authorship" />
    <vitro:descriptionAnnot rdf:datatype="http://www.w3.org/2001/XMLSchema#boolean">
      A flag indicating that this person has verified being an author for this publication.
    </vitro:descriptionAnnot>
  </rdf:Description>
</rdf:RDF>', 100)

-- Import the Updated PRNS ontology into Profiles. This should not eliminate any customizations unless additional 
-- classes have been added to the PRNS ontology

-- 
IF NOT EXISTS(SELECT * FROM [Ontology.].[Namespace] WHERE Prefix='ucsf')
BEGIN
	INSERT INTO [Ontology.].[Namespace] (URI, Prefix) VALUES ('http://profiles.ucsf.edu/ontology/ucsf#', 'ucsf')
END

UPDATE [Ontology.Import].OWL SET Graph = 5 WHERE name = 'UCSF_1.2'
EXEC [Ontology.Import].[ConvertOWL2Triple] @OWL = 'UCSF_1.2'

EXEC [RDF.Stage].[LoadTriplesFromOntology] @Truncate = 1
EXEC [RDF.Stage].[ProcessTriples]

-- see if work needs to be done to get the ClassProperty items correct!  Compare to old DB


-- Claimed Publications
EXEC [Ontology.].[AddProperty]	@OWL = 'UCSF_1.2',
								@PropertyURI = 'http://profiles.ucsf.edu/ontology/ucsf#hasClaimedPublication',
								@PropertyName = 'hasClaimedPublication',
								@ObjectType = 1,
								@PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupOverview',
								@ClassURI = 'http://vivoweb.org/ontology/core#Authorship',
								@IsDetail = 0,
								@IncludeDescription = 0,
								@SearchWeight = 0

-- add new one
INSERT INTO [Ontology.].[DataMap] (DataMapID, DataMapGroup, IsAutoFeed, Graph, 
		Class, NetworkProperty, Property, 
		MapTable, 
		sInternalType, sInternalID, 
		oClass, oInternalType, oInternalID, oValue, oDataType, oLanguage, 
		oObjectType, Weight, OrderBy, ViewSecurityGroup, EditSecurityGroup)
	VALUES (1002, 1, 1, 1,
		'http://vivoweb.org/ontology/core#Authorship', NULL, 'http://profiles.ucsf.edu/ontology/ucsf#hasClaimedPublication',
		'[UCSF.].[vwPublication.Entitity.Claimed]',
		'Authorship', 'EntityID',
		NULL, NULL, NULL, 'Claimed', 'http://www.w3.org/2001/XMLSchema#boolean', NULL,
		1, 1, NULL, -1, -40);
		
		
EXEC [Ontology.].UpdateDerivedFields;

EXEC [RDF.Stage].[ProcessDataMap] @DataMapID = 1002, @ShowCounts = 1

EXEC [Ontology.].[CleanUp] @Action = 'UpdateIDs';