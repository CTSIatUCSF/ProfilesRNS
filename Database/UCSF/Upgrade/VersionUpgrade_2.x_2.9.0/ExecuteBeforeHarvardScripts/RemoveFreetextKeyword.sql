/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM [Ontology.].[ClassProperty] where property like '%freetextKeyword%';

DELETE FROM [Ontology.].[ClassProperty] where property like '%freetextKeyword%';


-- to reset to Harvard style
UPDATE [Ontology.].[ClassProperty] set CustomDisplayModule = '<Module ID="ApplyXSLT"><ParamList><Param Name="XSLTPath">~/profile/XSLT/FreetextKeyword.xslt</Param></ParamList></Module>', 
CustomEditModule = '<Module ID="CustomEditFreetextKeyword"/>'
WHERE Property = 'http://vivoweb.org/ontology/core#freetextKeyword';


-- to reset to old UCSF style
UPDATE [Ontology.].[ClassProperty] set CustomDisplayModule = '<Module ID="CustomViewListProperty">
  <ParamList>
    <Param Name="nodes">rdf:RDF/rdf:Description/vivo:freetextKeyword</Param>
  </ParamList>
</Module>', 
CustomEditModule = '<Module ID="CustomEditListProperty" />' WHERE Property = 'http://vivoweb.org/ontology/core#freetextKeyword';

