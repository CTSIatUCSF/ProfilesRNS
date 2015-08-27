SELECT nodeId INTO #inactive FROM [UCSF.].vwPerson WHERE IsActive = 0 AND InternalUsername IN 
(SELECT InternalUsername FROM [Profile.Import].[User]); --25914

SELECT * FROM #inactive;

DELETE FROM [RDF.].Node WHERE NodeID IN (SELECT NodeID FROM #inactive); --25914
DELETE FROM [RDF.].Triple WHERE Subject IN (SELECT NodeID FROM #inactive); --447978

SELECT * FROM [User.Account].[User] WHERE PersonID IN (SELECT PersonID FROM [UCSF.].vwPerson WHERE NodeID IN (SELECT Nodeid FROM #inactive))
UPDATE [User.Account].[User] SET PersonID = NULL WHERE PersonID IN (SELECT PersonID FROM [UCSF.].vwPerson WHERE NodeID IN (SELECT Nodeid FROM #inactive))
DELETE FROM [Profile.Data].[Publication.Person.Include] WHERE PersonID IN (SELECT PersonID FROM [UCSF.].vwPerson WHERE NodeID IN (SELECT Nodeid FROM #inactive));
DELETE FROM [Profile.Data].[Publication.Person.Add] WHERE PersonID IN (SELECT PersonID FROM [UCSF.].vwPerson WHERE NodeID IN (SELECT Nodeid FROM #inactive));
DELETE FROM [Profile.Data].[Publication.Person.Exclude] WHERE PersonID IN (SELECT PersonID FROM [UCSF.].vwPerson WHERE NodeID IN (SELECT Nodeid FROM #inactive));
DELETE FROM [Profile.Data].[Person.Affiliation] WHERE PersonID IN (SELECT PersonID FROM [UCSF.].vwPerson WHERE NodeID IN (SELECT Nodeid FROM #inactive));
DELETE FROM [Profile.Data].[Person.Photo] WHERE PersonID IN (SELECT PersonID FROM [UCSF.].vwPerson WHERE NodeID IN (SELECT Nodeid FROM #inactive));
DELETE FROM [Profile.Data].[Publication.MyPub.General] WHERE PersonID IN (SELECT PersonID FROM [UCSF.].vwPerson WHERE NodeID IN (SELECT Nodeid FROM #inactive));
DELETE FROM [Profile.Data].[Person.FilterRelationship] WHERE PersonID IN (SELECT PersonID FROM [UCSF.].vwPerson WHERE NodeID IN (SELECT Nodeid FROM #inactive));
DELETE FROM [User.Session].[Session] WHERE PersonID IN (SELECT PersonID FROM [UCSF.].vwPerson WHERE NodeID IN (SELECT Nodeid FROM #inactive));
DELETE FROM [Profile.Data].[Publication.PubMed.Disambiguation] WHERE PersonID IN (SELECT PersonID FROM [UCSF.].vwPerson WHERE NodeID IN (SELECT Nodeid FROM #inactive));
DELETE FROM [Profile.Data].Person WHERE PersonID IN (SELECT PersonID FROM [UCSF.].vwPerson WHERE NodeID IN (SELECT Nodeid FROM #inactive));

-- clean stage RDF
SELECT COUNT(*) FROM [RDF.Stage].Triple WHERE TripleID NOT IN (SELECT TripleID FROM [RDF.].Triple)
SELECT COUNT(*) FROM [RDF.Stage].InternalNodeMap WHERE NodeID NOT IN (SELECT NodeID FROM [RDF.].Node)
DELETE FROM [RDF.Stage].InternalNodeMap WHERE NodeID IN (SELECT nodeid FROM #inactive) ; -- now run immediately above again
-- STOP
-- as this point we have orphaned RDF, but that might be OK

-- remove ORPHAN RDF
-- make sure all Import triples are clean, all should be blank
SELECT * FROM [Ontology.Import].Triple WHERE _SubjectNode NOT IN (SELECT NOdeid FROM [RDF.].Node); 
SELECT * FROM [Ontology.Import].Triple WHERE _PredicateNode NOT IN (SELECT NOdeid FROM [RDF.].Node); 
SELECT * FROM [Ontology.Import].Triple WHERE _ObjectNode NOT IN (SELECT NOdeid FROM [RDF.].Node); 
SELECT * FROM [Ontology.Import].Triple WHERE _SubjectNode NOT IN (SELECT Subject FROM [RDF.].Triple); 
SELECT * FROM [Ontology.Import].Triple WHERE _PredicateNode NOT IN (SELECT Predicate FROM [RDF.].Triple); 
SELECT * FROM [Ontology.Import].Triple WHERE _ObjectNode NOT IN (SELECT Object FROM [RDF.].Triple); 

SELECT COUNT(*) FROM [RDF.].Triple WHERE Subject NOT IN (SELECT NOdeid FROM [RDF.].Node); --2517354
--DELETE FROM [RDF.].Triple WHERE Subject NOT IN (SELECT NOdeid FROM [RDF.].Node);
SET NOCOUNT ON;
DECLARE @r INT; 
SET @r = 1;
WHILE @r > 0
BEGIN
  BEGIN TRANSACTION; 
  DELETE TOP (100000) FROM [RDF.].Triple WHERE Subject NOT IN (SELECT NOdeid FROM [RDF.].Node); 
  SET @r = @@ROWCOUNT; 
  COMMIT TRANSACTION; 
END

SELECT COUNT(*) FROM [RDF.].Triple WHERE Predicate NOT IN (SELECT NOdeid FROM [RDF.].Node); --2833
DELETE FROM [RDF.].Triple WHERE Predicate NOT IN (SELECT NOdeid FROM [RDF.].Node); --2970

SELECT COUNT(*) FROM [RDF.].Triple WHERE Object NOT IN (SELECT NOdeid FROM [RDF.].Node); --0
DELETE FROM [RDF.].Triple WHERE Object NOT IN (SELECT NOdeid FROM [RDF.].Node); --0

SELECT COUNT(*) FROM [RDF.].Node WHERE NodeID NOT IN (SELECT Subject FROM [RDF.].Triple UNION 
	SELECT Predicate FROM [RDF.].Triple UNION SELECT Object FROM [RDF.].Triple)
--DELETE FROM [RDF.].Node WHERE NodeID NOT IN (SELECT Subject FROM [RDF.].Triple UNION 
--	SELECT Predicate FROM [RDF.].Triple UNION SELECT Object FROM [RDF.].Triple)
SET NOCOUNT ON;
DECLARE @r INT; 
SET @r = 1;
WHILE @r > 0
BEGIN
  BEGIN TRANSACTION; 
	DELETE TOP (100000) FROM [RDF.].Node WHERE NodeID NOT IN (SELECT Subject FROM [RDF.].Triple UNION 
		SELECT Predicate FROM [RDF.].Triple UNION SELECT Object FROM [RDF.].Triple)

  SET @r = @@ROWCOUNT; 
  COMMIT TRANSACTION; 
END

SELECT * FROM [RDF.].Alias WHERE  NodeID NOT IN (SELECT NodeID FROM [RDF.].Node)

-- stage RDF
SELECT COUNT(*) FROM [RDF.Stage].Triple WHERE TripleID NOT IN (SELECT TripleID FROM [RDF.].Triple)
DELETE FROM [RDF.Stage].Triple WHERE TripleID NOT IN (SELECT TripleID FROM [RDF.].Triple)
SELECT COUNT(*) FROM [RDF.Stage].InternalNodeMap WHERE NodeID NOT IN (SELECT NodeID FROM [RDF.].Node)
DELETE FROM [RDF.Stage].InternalNodeMap WHERE NodeID NOT IN (SELECT NodeID FROM [RDF.].Node)

SELECT * FROM [RDF.Stage].[Triple.Map] WHERE TripleID NOT IN (SELECT TripleID FROM [RDF.].Triple)
SELECT * FROM [RDF.Security].[NodeProperty] WHERE NodeID NOT IN (SELECT NodeID FROM [RDF.].Node)
DELETE FROM [RDF.Security].[NodeProperty] WHERE NodeID NOT IN (SELECT NodeID FROM [RDF.].Node)

SELECT * FROM [RDF.SemWeb].Hash2Base64 WHERE NodeID NOT IN (SELECT NodeID FROM [RDF.].Node)
SET NOCOUNT ON;
DECLARE @r INT; 
SET @r = 1;
WHILE @r > 0
BEGIN
  BEGIN TRANSACTION; 
	DELETE TOP (100000) FROM [RDF.SemWeb].Hash2Base64 WHERE NodeID NOT IN (SELECT NodeID FROM [RDF.].Node)

  SET @r = @@ROWCOUNT; 
  COMMIT TRANSACTION; 
END



DROP TABLE #inactive;
