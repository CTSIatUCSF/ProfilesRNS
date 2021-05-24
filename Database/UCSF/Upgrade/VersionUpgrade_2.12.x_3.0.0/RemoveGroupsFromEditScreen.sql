
  -- change from -20 to -40
  UPDATE [Ontology.].[ClassProperty] SET EditSecurityGroup = -40 WHERE [Class] = 'http://xmlns.com/foaf/0.1/Person' and [Property] = 'http://vivoweb.org/ontology/core#hasMemberRole';