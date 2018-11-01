-- SEE HOW MANY
  SELECT COUNT(*) FROM [RDF.].Node WHERE Value  like '%^^%' and Value not like 'http://orng.info/ontology/orng%';
  SELECT COUNT(*) FROM [RDF.].Node WHERE Value  like 'http://vivoweb.org/ontology/core#Authorship^^Authorship^^%';

  SELECT TOP 10 * FROM [RDF.].Node WHERE Value  like 'http://vivoweb.org/ontology/core#Authorship^^Authorship^^%';

-- RUN THIS and then execute the results
SELECT --TOP 1000 
	'UPDATE [RDF.].Node SET Value = ''https://researcherprofiles.org/profile/' + cast(NodeID as varchar) + 
	''', ValueHash = [RDF.].fnValueHash(NULL, NULL, ''https://researcherprofiles.org/profile/' + cast(NodeID as varchar) + ''')	WHERE NodeID = ' + 
	cast(NodeID as varchar) + '; UPDATE [RDF.Stage].[InternalNodeMap] SET ValueHash = [RDF.].fnValueHash(NULL, NULL, ''https://researcherprofiles.org/profile/' + 
	cast(NodeID as varchar) + ''')	WHERE InternalNodeMapID = ' + cast(InternalNodeMapID as varchar) + ';'
	FROM [RDF.].Node WHERE Value  like 'http://vivoweb.org/ontology/core#Authorship^^Authorship^^%';  
	--and NodeID = 17401001;