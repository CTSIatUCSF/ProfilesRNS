/*******************************
*
* Convert Websites Data. 
* If you did not have the open social websites app installed you can skip this script
*
* This Script is split into 3 sections
* 1. Convert website data to the new format
* 2. Convert security settings to the new nodes
* 3. Generate the RDF
*
* Run each step one at a time, and confirm that there were no errors before going on to the next step.
* After step 1, we recommend looking in the websites tables and confirming the websites are correct for a few people
* before progressing to step 2.
* 
* Ensure step 2 completes without errors before progressing to step 3. Any errors during steps 1 and 2 will be 
* pushed into the RDF data during step 3, and will be much harder to fix after running step 3
*
*******************************/

declare @appID int
select @appID = AppID from [ORNG.].[Apps] where Url like '%/Links.xml' 

declare @maxNdx int
select @maxNdx = MAX(CAST(REPLACE(Keyname, 'link_', '') AS INT)) FROM [ORNG.].[AppData] WHERE AppID = @AppID and Keyname like 'link_%' and Keyname not like 'links%';
 
create table #websites (
	nodeid bigint,
	link_name varchar(max),
	link_url varchar(max),
	sort_order int,
	PersonID int,
	GroupID int 
)

-- insert the ones that have one row per entry
DECLARE @ndx int = 0
WHILE @ndx <= @maxNdx
BEGIN
	INSERT INTO #websites
		SELECT d.NodeID, JSON_VALUE(d.[Value], '$.name'), JSON_VALUE(d.[Value], '$.url'), @ndx, p.PersonID, null FROM [ORNG.].[AppData] d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID  WHERE AppID = @appID and Keyname = 'link_' + cast(@ndx as varchar);
	SET @ndx = @ndx + 1
END
 
 -- find max amount but altering the number here and seeing biggest value to return something. Check appid!!
SELECT * FROM [ORNG.].[AppData] WHERE AppID = @appID and Keyname = 'links' AND JSON_VALUE([Value], '$[6].link_name') IS NOT NULL;

-- now do the array ones, ugly but what works for our version of SQL Server
INSERT INTO #websites SELECT d.NodeID, JSON_VALUE(d.[Value], '$[0].link_name'), JSON_VALUE(d.[Value], '$[0].link_url'), 0, p.PersonID, null FROM [ORNG.].[AppData] d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID  WHERE AppID = @appID and Keyname = 'links' AND JSON_VALUE(d.[Value], '$[0].link_name') IS NOT NULL;
INSERT INTO #websites SELECT d.NodeID, JSON_VALUE(d.[Value], '$[1].link_name'), JSON_VALUE(d.[Value], '$[1].link_url'), 1, p.PersonID, null FROM [ORNG.].[AppData] d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID  WHERE AppID = @appID and Keyname = 'links' AND JSON_VALUE(d.[Value], '$[1].link_name') IS NOT NULL
INSERT INTO #websites SELECT d.NodeID, JSON_VALUE(d.[Value], '$[2].link_name'), JSON_VALUE(d.[Value], '$[2].link_url'), 2, p.PersonID, null FROM [ORNG.].[AppData] d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID  WHERE AppID = @appID and Keyname = 'links' AND JSON_VALUE(d.[Value], '$[2].link_name') IS NOT NULL
INSERT INTO #websites SELECT d.NodeID, JSON_VALUE(d.[Value], '$[3].link_name'), JSON_VALUE(d.[Value], '$[3].link_url'), 3, p.PersonID, null FROM [ORNG.].[AppData] d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID  WHERE AppID = @appID and Keyname = 'links' AND JSON_VALUE(d.[Value], '$[3].link_name') IS NOT NULL
INSERT INTO #websites SELECT d.NodeID, JSON_VALUE(d.[Value], '$[4].link_name'), JSON_VALUE(d.[Value], '$[4].link_url'), 4, p.PersonID, null FROM [ORNG.].[AppData] d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID  WHERE AppID = @appID and Keyname = 'links' AND JSON_VALUE(d.[Value], '$[4].link_name') IS NOT NULL
INSERT INTO #websites SELECT d.NodeID, JSON_VALUE(d.[Value], '$[5].link_name'), JSON_VALUE(d.[Value], '$[5].link_url'), 5, p.PersonID, null FROM [ORNG.].[AppData] d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID  WHERE AppID = @appID and Keyname = 'links' AND JSON_VALUE(d.[Value], '$[5].link_name') IS NOT NULL
INSERT INTO #websites SELECT d.NodeID, JSON_VALUE(d.[Value], '$[6].link_name'), JSON_VALUE(d.[Value], '$[6].link_url'), 6, p.PersonID, null FROM [ORNG.].[AppData] d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID  WHERE AppID = @appID and Keyname = 'links' AND JSON_VALUE(d.[Value], '$[6].link_name') IS NOT NULL
INSERT INTO #websites SELECT d.NodeID, JSON_VALUE(d.[Value], '$[7].link_name'), JSON_VALUE(d.[Value], '$[7].link_url'), 7, p.PersonID, null FROM [ORNG.].[AppData] d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID  WHERE AppID = @appID and Keyname = 'links' AND JSON_VALUE(d.[Value], '$[7].link_name') IS NOT NULL
INSERT INTO #websites SELECT d.NodeID, JSON_VALUE(d.[Value], '$[8].link_name'), JSON_VALUE(d.[Value], '$[8].link_url'), 8, p.PersonID, null FROM [ORNG.].[AppData] d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID  WHERE AppID = @appID and Keyname = 'links' AND JSON_VALUE(d.[Value], '$[8].link_name') IS NOT NULL
INSERT INTO #websites SELECT d.NodeID, JSON_VALUE(d.[Value], '$[9].link_name'), JSON_VALUE(d.[Value], '$[9].link_url'), 9, p.PersonID, null FROM [ORNG.].[AppData] d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID  WHERE AppID = @appID and Keyname = 'links' AND JSON_VALUE(d.[Value], '$[9].link_name') IS NOT NULL
INSERT INTO #websites SELECT d.NodeID, JSON_VALUE(d.[Value], '$[10].link_name'), JSON_VALUE(d.[Value], '$[10].link_url'), 10, p.PersonID, null FROM [ORNG.].[AppData] d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID  WHERE AppID = @appID and Keyname = 'links' AND JSON_VALUE(d.[Value], '$[10].link_name') IS NOT NULL
INSERT INTO #websites SELECT d.NodeID, JSON_VALUE(d.[Value], '$[11].link_name'), JSON_VALUE(d.[Value], '$[11].link_url'), 11, p.PersonID, null FROM [ORNG.].[AppData] d
			JOIN [UCSF.].vwPerson p on d.NodeID = p.NodeID  WHERE AppID = @appID and Keyname = 'links' AND JSON_VALUE(d.[Value], '$[11].link_name') IS NOT NULL

-- STOP. look at stuff
select * from #websites order by nodeid, sort_order
select * from #websites w join [Profile.Data].[Person.Websites] p on w.PersonID = p.PersonID and w.PersonID is not null and w.link_url = p.URL

-- clear out dupes?  On PROD assume that Websites is empty!
DELETE FROM #websites WHERE PersonID in (Select PersonID FROM [Profile.Data].[Person.Websites])

insert into [Profile.Data].[Person.Websites] (URLID, PersonID, WebPageTitle, URL,  SortOrder)
select newID(), PersonID, link_name, link_url, sort_order from #websites where personID is not null

insert into [Profile.Data].[Group.Websites] (URLID, GroupID, WebPageTitle, URL,  SortOrder)
select newID(), GroupID, link_name, link_url, sort_order from #websites where GroupID is not null

--select * from [Profile.Data].[Person.Websites]
--select * from [Profile.Data].[Group.Websites] 
--select * from #websites

drop table #websites

/***********************
* End of Section 1
* Websites data has been converted to the new format, 
* This data can be inspected using the following queries:
*    select * from [Profile.Data].[Person.Websites]
*    select * from [Profile.Data].[Group.Websites]
* 
* If this section ran without errors, and the data looks good
* you can progress to section 2.
***********************/

declare @wNodeID bigint, @orngwNodeID bigint
select @wNodeID = NodeID from [RDF.].[Node] where value in ('http://vivoweb.org/ontology/core#webpage')
select @orngwNodeID = NodeID from [RDF.].[Node] where value in ('http://orng.info/ontology/orng#hasLinks')

insert into [RDF.Security].NodeProperty (NodeID, Property, ViewSecurityGroup)
select nodeID, @wNodeID, ViewSecurityGroup from [RDF.Security].NodeProperty where Property = @orngwNodeID

update [RDF.].Triple set ViewSecurityGroup = -50 where Predicate = @orngwNodeID

update [Ontology.].ClassProperty set
	ViewSecurityGroup = -50,
	EditSecurityGroup = -50,
	EditPermissionsSecurityGroup = -50,
	EditExistingSecurityGroup = -50,
	EditAddNewSecurityGroup = -50,
	EditAddExistingSecurityGroup = -50,
	EditDeleteSecurityGroup = -50 
	where property = 'http://orng.info/ontology/orng#hasLinks'

/***********************
* End of Section 2
* Security groups should be correct at this point
*
* If this section ran correcty, you can run section 3
***********************/

declare @d1 int, @d2 int, @d3 int, @d4 int, @d5 int, @d6 int, @d7 int
select @d1 = DataMapID from [Ontology.].DataMap where class = 'http://vivoweb.org/ontology/core#URLLink' AND Property is null
select @d2 = DataMapID from [Ontology.].DataMap where class = 'http://vivoweb.org/ontology/core#URLLink' AND Property = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'
select @d3 = DataMapID from [Ontology.].DataMap where class = 'http://vivoweb.org/ontology/core#URLLink' AND Property = 'http://www.w3.org/2000/01/rdf-schema#label'
select @d4 = DataMapID from [Ontology.].DataMap where class = 'http://vivoweb.org/ontology/core#URLLink' AND Property = 'http://profiles.catalyst.harvard.edu/ontology/prns#publicationDate'
select @d5 = DataMapID from [Ontology.].DataMap where class = 'http://vivoweb.org/ontology/core#URLLink' AND Property = 'http://vivoweb.org/ontology/core#linkAnchorText'
select @d6 = DataMapID from [Ontology.].DataMap where class = 'http://xmlns.com/foaf/0.1/Group' AND Property = 'http://vivoweb.org/ontology/core#webpage'
select @d7 = DataMapID from [Ontology.].DataMap where class = 'http://xmlns.com/foaf/0.1/Person' AND Property = 'http://vivoweb.org/ontology/core#webpage'

EXEC [RDF.Stage].[ProcessDataMap] @DataMapID = @d1, @ShowCounts = 1
EXEC [RDF.Stage].[ProcessDataMap] @DataMapID = @d2, @ShowCounts = 1
EXEC [RDF.Stage].[ProcessDataMap] @DataMapID = @d3, @ShowCounts = 1
EXEC [RDF.Stage].[ProcessDataMap] @DataMapID = @d4, @ShowCounts = 1
EXEC [RDF.Stage].[ProcessDataMap] @DataMapID = @d5, @ShowCounts = 1
EXEC [RDF.Stage].[ProcessDataMap] @DataMapID = @d6, @ShowCounts = 1
EXEC [RDF.Stage].[ProcessDataMap] @DataMapID = @d7, @ShowCounts = 1


/***********************
* End of Section 3
* Websites should be fully converted to the new websites module
***********************/
-- Now remove the ORNG app from people
DECLARE @vNodeID BIGINT
DECLARE @vAppID int
SELECT @vAppID = appID from [ORNG.].Apps where Url like '%/Links.xml' 
DECLARE @curLinks CURSOR
SET @curLinks = CURSOR FOR select distinct NodeID  
 from [ORNG.].[AppData] where appID = @vAppID 
OPEN @curLinks
	FETCH NEXT
	FROM @curLinks INTO @vNodeID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		exec [ORNG.].[RemoveAppFromAgent] @SubjectID=@vNodeID, @AppID=@vAppID
		FETCH NEXT
		FROM @curLinks INTO @vNodeID
	END
CLOSE @curLinks
DEALLOCATE @curLinks


-- disable gadget
declare @vAppID int
select @vAppID = AppID from [ORNG.].[Apps] where Url like '%/Links.xml' 
exec [ORNG.].[RemoveAppFromOntology] @AppID=@vAppID 

UPDATE [ORNG.].Apps SET [Enabled] = 0 WHERE AppID=@vAppID 

-- STOP

-- delete filters
DECLARE @PersonFilterID INT
SELECT @PersonFilterID = PersonFilterID FROM [Profile.Data].[Person.Filter] WHERE PersonFilter = 'Websites';


-- check this, if any return then STOP
SELECT * FROM [Profile.Data].[Person.FilterRelationship] WHERE PersonFilterid = @PersonFilterID;
--DELETE FROM [Profile.Data].[Person.FilterRelationship] WHERE PersonFilterid = 12;
DELETE FROM [Profile.Data].[Person.Filter] WHERE PersonFilter = 'Websites';
delete from [Profile.Import].[PersonFilterFlag] where personfilter = 'Websites';

-- BREAK GLASS IN EMERGENCY
-- run and exec results.
 select 'exec [Edit.Module].[CustomEditWebsite.AddEditWebsite] @ExistingURLID = ''' + w2.URLID + ''', @Delete=1;'
 from [Profile.Data].[Person.Websites] w1 join  [Profile.Data].[Person.Websites] w2 on w1.PersonID = w2.PersonID and
 w1.[URL] = w2.[URL] and w1.SortOrder < w2.SortOrder;
 
 -- these are ones that share sort order but have different UrlID's
  select 'exec [Edit.Module].[CustomEditWebsite.AddEditWebsite] @ExistingURLID = ''' + w2.URLID + ''', @Delete=1;'
 from [Profile.Data].[Person.Websites] w1 join  [Profile.Data].[Person.Websites] w2 on w1.PersonID = w2.PersonID and
 w1.[URL] = w2.[URL] and w1.SortOrder = w2.SortOrder and w1.UrlID < w2.UrlID;



