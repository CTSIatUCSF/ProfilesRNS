-- fix old bad data

-- find redundant bad ones
SELECT b.* FROM [RDF.Stage].[InternalNodeMap] b JOIN [RDF.Stage].[InternalNodeMap] a on a.Class = b.Class and a.InternalID = b.InternalID
and a.InternalType <> b.InternalType WHERE b.InternalType like 'ORNG %';

-- delete redundant bad ones
DELETE FROM [RDF.Stage].[InternalNodeMap] WHERE InternalNodeMapID in (
SELECT b.InternalNodeMapID FROM [RDF.Stage].[InternalNodeMap] b JOIN [RDF.Stage].[InternalNodeMap] a on a.Class = b.Class and a.InternalID = b.InternalID
and a.InternalType <> b.InternalType WHERE b.InternalType like 'ORNG %');

-- find bad ones that are NOT redundant
SELECT * FROM [RDF.Stage].[InternalNodeMap] WHERE InternalType like 'ORNG %'; --21

-- fix the bad ones that are NOT reduandant
UPDATE [RDF.Stage].[InternalNodeMap] SET InternalType = REPLACE(InternalType, ' ', '') WHERE  InternalType like 'ORNG %';

-- run the data map
EXEC [RDF.Stage].[ProcessDataMap] @DataMapID=31

-- find bad nodes
SELECT * FROM [RDF.].Node where Value like 'http://orng.info/ontology/orng#%^^%'; --5314

--fix bad nodes
UPDATE n SET n.Value = p.Value + cast (n.NodeID as varchar), n.ValueHash = [RDF.].fnValueHash(null, null, p.Value + cast (n.NodeID as varchar))
FROM [RDF.].Node n JOIN [Framework.].[Parameter] p ON 1 = 1 WHERE n.Value LIKE 'http://orng.info/ontology/orng#%^^%' AND p.ParameterID = 'baseURI'


EXEC [RDF.].GetDataRDF @subject=6519125--13209950

EXEC [RDF.].GetDataRDF @subject=215213

--run the data map for these when done
6519125 -- the aplication instance ID for the person 215213
6519135
6519145
6519155
6519165
6519173
6519175
6519183
6519185
6519193