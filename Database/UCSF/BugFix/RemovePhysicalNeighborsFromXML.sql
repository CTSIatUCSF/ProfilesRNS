/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [PresentationID]
      ,[Type]
      ,[Subject]
      ,[Predicate]
      ,[Object]
      ,[PresentationXML]
      ,[_SubjectNode]
      ,[_PredicateNode]
      ,[_ObjectNode],
	  --PresentationXML.modify('/delete /Presentation/PanelList/Panel/Module[Param="Physical Neighbors"]'), 
	  cast(replace(cast(PresentationXML as varchar(max)), cast(PresentationXML.query('//Param[.="Physical Neighbors"]/../..') as varchar(max)), '') as xml),
	   PresentationXML.query('//Param[.="Physical Neighbors"]/../..')  
  FROM [profilesRNS].[Ontology.Presentation].[XML] where cast(PresentationXML as varchar(max)) like '%Physical%';
  
  UPDATE [Ontology.Presentation].[XML] 
	SET PresentationXML = cast(replace(cast(PresentationXML as varchar(max)), cast(PresentationXML.query('//Param[.="Physical Neighbors"]/../..') as varchar(max)), '') as xml)
  WHERE cast(PresentationXML as varchar(max)) like '%Physical Neighbors%';