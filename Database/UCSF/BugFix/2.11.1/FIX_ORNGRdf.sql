SELECT count(*) FROM [RDF.].Node WHERE Value  like '%^^%' and Value  like 'http://orng.info/ontology/orng%';

SELECT count(*)  FROM [RDF.].Node WHERE Value like 'http://orng.info/ontology/orng#ApplicationInstance^^ORNGApplicationInstance^^%';
SELECT count(*)  FROM [RDF.].Node WHERE Value like 'http://orng.info/ontology/orng#ApplicationInstance^^ORNG Application Instance^^%';

DECLARE @baseURI varchar(50);
SELECT @baseURI = Value from [Framework.].Parameter where ParameterID = 'baseURI';
select @baseURI

update [RDF.].Node set Value = @baseURI + cast(nodeid as varchar) 
, ValueHash = [RDF.].fnValueHash(null,null,@baseURI + cast(nodeid as varchar) ) 
where Value like 'http://orng.info/ontology/orng#ApplicationInstance^^ORNGApplicationInstance^^%';

update [RDF.].Node set Value = @baseURI + cast(nodeid as varchar) 
, ValueHash = [RDF.].fnValueHash(null,null,@baseURI + cast(nodeid as varchar) ) 
where Value like 'http://orng.info/ontology/orng#ApplicationInstance^^ORNG Application Instance^^%';


-- new approach, see labels for all ORNG Applications

-- labels of all the ORNG applications
SELECT n.* FROM [RDF.].Triple t JOIN [RDF.].Node n on t.object = n.nodeid where t.Predicate = [RDF.].fnURI2NodeID('http://www.w3.org/2000/01/rdf-schema#label')
and t.Subject in (SELECT Subject FROM [RDF.].Triple WHERE Predicate = [RDF.].fnURI2NodeID('http://www.w3.org/1999/02/22-rdf-syntax-ns#type') AND 
	Object = [RDF.].fnURI2NodeID('http://orng.info/ontology/orng#Application'))

-- labels of all the ORNG application instances
SELECT t.subject, n.* FROM [RDF.].Triple t JOIN [RDF.].Node n on t.object = n.nodeid where t.Predicate = [RDF.].fnURI2NodeID('http://www.w3.org/2000/01/rdf-schema#label')
and t.Subject in (SELECT Subject FROM [RDF.].Triple WHERE Predicate = [RDF.].fnURI2NodeID('http://www.w3.org/1999/02/22-rdf-syntax-ns#type') AND 
	Object = [RDF.].fnURI2NodeID('http://orng.info/ontology/orng#ApplicationInstance')) --4573

-- fix the labels to match the SP that adds apps to people
SELECT 'UPDATE [RDF.].[Node] SET Value = ''ORNGApplicationInstance ' + cast(t.subject as varchar) +
 ''', ValueHash = [RDF.].fnValueHash(null, null, ''ORNGApplicationInstance ' + cast(t.subject as varchar) + 
	'''), ObjectType = 1 WHERE NodeID = ' + cast(n.NodeID as varchar) + ';' 
FROM [RDF.].Triple t JOIN [RDF.].Node n on t.object = n.nodeid where t.Predicate = [RDF.].fnURI2NodeID('http://www.w3.org/2000/01/rdf-schema#label')
and t.Subject in (SELECT Subject FROM [RDF.].Triple WHERE Predicate = [RDF.].fnURI2NodeID('http://www.w3.org/1999/02/22-rdf-syntax-ns#type') AND 
	Object = [RDF.].fnURI2NodeID('http://orng.info/ontology/orng#ApplicationInstance')) AND n.Value NOT LIKE 'ORNGApplicationInstance %' --4460



