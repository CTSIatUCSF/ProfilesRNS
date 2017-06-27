/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM [Ontology.].[ClassProperty] where property like '%orng%'

-- this cheap trick seems to work for hiding the tag editor on the Profile page.  Also hides the heading!
update [Ontology.].[ClassProperty] set CustomDisplayModule = NULL where property = 'http://orng.info/ontology/orng#hasTagEditor';

-- this is to destroy the fix above.
--update [Ontology.].[ClassProperty] set CustomDisplayModule =  N'<Module ID="ViewPersonalGadget">
--  <ParamList>
--    <Param Name="AppId">122</Param>
--    <Param Name="Label">Tag Editor</Param>
--    <Param Name="View">profile</Param>
--    <Param Name="OptParams">{}</Param>
--  </ParamList>
--</Module>'  where property = 'http://orng.info/ontology/orng#hasTagEditor';