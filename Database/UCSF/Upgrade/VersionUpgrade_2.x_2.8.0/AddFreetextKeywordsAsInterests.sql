INSERT [Ontology.].[ClassProperty] (ClassPropertyID, Class, NetworkProperty, Property, IsDetail, Limit, 
IncludeDescription, IncludeNetwork, SearchWeight, CustomDisplay, CustomEdit, 
ViewSecurityGroup, EditSecurityGroup, EditPermissionsSecurityGroup, EditExistingSecurityGroup, EditAddNewSecurityGroup, EditAddExistingSecurityGroup,
EditDeleteSecurityGroup, MinCardinality, MaxCardinality, CustomDisplayModule, CustomEditModule) VALUES (1000,
'http://xmlns.com/foaf/0.1/Person', NULL, 'http://vivoweb.org/ontology/core#freetextKeyword', 1, NULL, 0, 0, 0.5, 1, 1,   
-1, -20, -20, -20, -20, -40, -20, 0, 0, 
N'<Module ID="CustomViewListProperty">
  <ParamList>
    <Param Name="nodes">rdf:RDF/rdf:Description/vivo:freetextKeyword</Param>
  </ParamList>
</Module>', 
N'<Module ID="CustomEditListProperty" />');

EXEC [Ontology.].UpdateDerivedFields;
EXEC [Ontology.].[CleanUp] @Action = 'UpdateIDs';

-- now run FixLabels!