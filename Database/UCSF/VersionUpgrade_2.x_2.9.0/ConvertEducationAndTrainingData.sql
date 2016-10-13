  -- institution http://profiles.catalyst.harvard.edu/ontology/prns#trainingAtOrganization from vivo to prns
  -- School or Department to major Field
    
  DECLARE @educationNode bigint
  DECLARE @oldOrgPredicate bigint
  DECLARE @newOrgPredicate bigint
  DECLARE @oldSchoolPredicate bigint
  DECLARE @newFieldPredicate bigint

  SELECT @educationNode = _PropertyNode from [Ontology.].[ClassProperty] where Class = 'http://xmlns.com/foaf/0.1/Person'
	AND Property = 'http://vivoweb.org/ontology/core#educationalTraining';

  SELECT @oldOrgPredicate = _PropertyNode from [Ontology.].[ClassProperty] where Class = 'http://vivoweb.org/ontology/core#EducationalTraining'
	AND Property = 'http://vivoweb.org/ontology/core#trainingAtOrganization';

  SELECT @oldSchoolPredicate = _PropertyNode from [Ontology.].[ClassProperty] where Class = 'http://vivoweb.org/ontology/core#EducationalTraining'
	AND Property = 'http://vivoweb.org/ontology/core#departmentOrSchool';

  SELECT @newOrgPredicate = _PropertyNode from [Ontology.].[ClassProperty] where Class = 'http://vivoweb.org/ontology/core#EducationalTraining'
	AND Property = 'http://profiles.catalyst.harvard.edu/ontology/prns#trainingAtOrganization';

  SELECT @newFieldPredicate = _PropertyNode from [Ontology.].[ClassProperty] where Class = 'http://vivoweb.org/ontology/core#EducationalTraining'
	AND Property = 'http://vivoweb.org/ontology/core#majorField';

  SELECT @educationNode, @oldOrgPredicate, @oldSchoolPredicate, @newOrgPredicate, @newFieldPredicate

  --SELECT * FROM [RDF.].[Triple] WHERE Predicate = @newOrgPredicate AND Subject in 
  --(SELECT Object FROM [RDF.].[Triple] WHERE Predicate = @educationNode)-- 3716

  --SELECT * FROM [RDF.].[Triple] WHERE Predicate = @oldOrgPredicate AND Subject in 
  --(SELECT Object FROM [RDF.].[Triple] WHERE Predicate = @educationNode)-- 3359

  UPDATE [RDF.].[Triple] SET Predicate = @newOrgPredicate WHERE Predicate = @oldOrgPredicate AND Subject in 
  (SELECT Object FROM [RDF.].[Triple] WHERE Predicate = @educationNode)-- 3359

  UPDATE [RDF.].[Triple] SET Predicate = @newFieldPredicate WHERE Predicate = @oldSchoolPredicate AND Subject in 
  (SELECT Object FROM [RDF.].[Triple] WHERE Predicate = @educationNode)-- 3359 