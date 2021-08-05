
create table #medialinkssort (
	UrlID varchar(50),
	PersonID int,
	SortOrder int
)

-- order globally 
INSERT #medialinkssort SELECT UrlID, PersonID,  ROW_NUMBER() OVER(order by personid, try_cast([PublicationDate] as date) desc)
FROM  [Profile.Data].[Person.MediaLinks] 

SELECT * FROM #medialinkssort order by PersonID, SortOrder

-- reset for each person so its like 0,1,2 instead of 14,15,16, etc. 
UPDATE D set D.SortOrder = D.SortOrder  - MinSort FROM #medialinkssort D 
CROSS APPLY  ( SELECT  MIN(SortOrder) [MinSort] FROM  #medialinkssort where PersonID = D.PersonID) A

-- now fix in main table
UPDATE M set M.SortOrder = D.SortOrder FROM [Profile.Data].[Person.MediaLinks] M JOIN #medialinkssort D on M.UrlID = D.UrlID

-- then redo RDF

declare @d1 int, @d2 int, @d3 int, @d4 int, @d5 int, @d6 int, @d7 int
select @d1 = DataMapID from [Ontology.].DataMap where class = 'http://vivoweb.org/ontology/core#URLLink' AND Property is null
select @d2 = DataMapID from [Ontology.].DataMap where class = 'http://vivoweb.org/ontology/core#URLLink' AND Property = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'
select @d3 = DataMapID from [Ontology.].DataMap where class = 'http://vivoweb.org/ontology/core#URLLink' AND Property = 'http://www.w3.org/2000/01/rdf-schema#label'
select @d4 = DataMapID from [Ontology.].DataMap where class = 'http://vivoweb.org/ontology/core#URLLink' AND Property = 'http://profiles.catalyst.harvard.edu/ontology/prns#publicationDate'
select @d5 = DataMapID from [Ontology.].DataMap where class = 'http://vivoweb.org/ontology/core#URLLink' AND Property = 'http://vivoweb.org/ontology/core#linkAnchorText'
select @d6 = DataMapID from [Ontology.].DataMap where class = 'http://xmlns.com/foaf/0.1/Group' AND Property = 'http://profiles.catalyst.harvard.edu/ontology/prns#mediaLinks'
select @d7 = DataMapID from [Ontology.].DataMap where class = 'http://xmlns.com/foaf/0.1/Person' AND Property = 'http://profiles.catalyst.harvard.edu/ontology/prns#mediaLinks'

EXEC [RDF.Stage].[ProcessDataMap] @DataMapID = @d1, @ShowCounts = 1
EXEC [RDF.Stage].[ProcessDataMap] @DataMapID = @d2, @ShowCounts = 1
EXEC [RDF.Stage].[ProcessDataMap] @DataMapID = @d3, @ShowCounts = 1
EXEC [RDF.Stage].[ProcessDataMap] @DataMapID = @d4, @ShowCounts = 1
EXEC [RDF.Stage].[ProcessDataMap] @DataMapID = @d5, @ShowCounts = 1
EXEC [RDF.Stage].[ProcessDataMap] @DataMapID = @d6, @ShowCounts = 1
EXEC [RDF.Stage].[ProcessDataMap] @DataMapID = @d7, @ShowCounts = 1
   