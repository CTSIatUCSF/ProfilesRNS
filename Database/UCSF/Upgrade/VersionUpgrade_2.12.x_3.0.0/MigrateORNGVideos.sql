/*** Remember to remove filters  **/

declare @wNodeID bigint, @orngwNodeID bigint

select @wNodeID = NodeID from [RDF.].[Node] where value in ('http://profiles.catalyst.harvard.edu/ontology/plugins#FeaturedVideos')
select @orngwNodeID = NodeID from [RDF.].[Node] where value in ('http://orng.info/ontology/orng#hasVideos')
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
	where property = 'http://orng.info/ontology/orng#hasVideos'


DECLARE @vNodeID BIGINT
DECLARE @vValue nvarchar(max)
DECLARE @vSearchableData nvarchar(max)
DECLARE @vAppID int
SELECT @vAppID = appID from [ORNG.].Apps where Name = 'Featured Videos'
DECLARE @curVideos CURSOR
SET @curVideos = CURSOR FOR select NodeID, [Value], RTRIM(JSON_VALUE(Value, '$[0].name') 
	  + ISNULL(' ' + JSON_VALUE(Value, '$[1].name'), '') + ISNULL(' ' + JSON_VALUE(Value, '$[2].name'), '') + ISNULL(' ' + JSON_VALUE(Value, '$[3].name'), '')
	  + ISNULL(' ' + JSON_VALUE(Value, '$[5].name'), '') + ISNULL(' ' + JSON_VALUE(Value, '$[6].name'), '') + ISNULL(' ' + JSON_VALUE(Value, '$[7].name'), '')
	  + ISNULL(' ' + JSON_VALUE(Value, '$[7].name'), '') + ISNULL(' ' + JSON_VALUE(Value, '$[8].name'), '') + ISNULL(' ' + JSON_VALUE(Value, '$[9].name'), '')
	  + ISNULL(' ' + JSON_VALUE(Value, '$[10].name'), '') + ISNULL(' ' + JSON_VALUE(Value, '$[11].name'), '') + ISNULL(' ' + JSON_VALUE(Value, '$[12].name'), ''))
 from [ORNG.].[AppData] where appID = @vAppID and keyname = 'videos' and ISJSON(VALUE) = 1 AND JSON_VALUE(Value, '$[0].name') is not null
OPEN @curVideos
	FETCH NEXT
	FROM @curVideos INTO @vNodeID, @vValue, @vSearchableData
	WHILE @@FETCH_STATUS = 0
	BEGIN
		exec [Profile.Module].[GenericRDF.AddEditPluginData] @name='FeaturedVideos',@NodeID=@vNodeID,@Data=@vValue,@SearchableData=@vSearchableData 
		FETCH NEXT
		FROM @curVideos INTO @vNodeID, @vValue, @vSearchableData
	END
CLOSE @curVideos
DEALLOCATE @curVideos
GO

--- STOP HERE and look around

-- FIX IDS
-- keep running until nothing happens or you only get unknwown URL's
DECLARE @vNodeID BIGINT
DECLARE @vData nvarchar(max)
DECLARE @vDataFixed nvarchar(max)
DECLARE @curVideos CURSOR
DECLARE @start int
DECLARE @urlNdx int
DECLARE @id nvarchar(max)
SET @curVideos = CURSOR FOR select NodeID, [Data]  
 from [Profile.Module].[GenericRDF.Data]  where [Name] = 'FeaturedVideos' AND ( [Data] Like '%"id": ""%' OR [Data] Like '%"id":""%') 
OPEN @curVideos
	FETCH NEXT
	FROM @curVideos INTO @vNodeID, @vData
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--PRINT @vData
		SET @start = CHARINDEX('"id": ""', @vData)  + CHARINDEX('"id":""', @vData)
		SET @urlNdx = -1
		IF (CHARINDEX('https://www.youtube.com/watch?v=', @vData, @start) > 0)
			SET @urlNdx = CHARINDEX('https://www.youtube.com/watch?v=', @vData, @start) + LEN('https://www.youtube.com/watch?v=')
		ELSE IF (CHARINDEX('https://youtu.be/', @vData, @start) > 0)
			SET @urlNdx = CHARINDEX('https://youtu.be/', @vData, @start) + LEN('https://youtu.be/')
		ELSE
			PRINT 'Unknown URL in :' + SUBSTRING(@vData, @start, 100) + ' for Profile NodeID = ' + CAST(@vNodeID as varchar)

		IF (@urlNdx > -1)
		BEGIN
			SET @id=SUBSTRING(@vData, @urlNdx, IIF(CHARINDEX('&', @vData, @urlNdx) < CHARINDEX('"', @vData, @urlNdx) AND CHARINDEX('&', @vData, @urlNdx) > 0, CHARINDEX('&', @vData, @urlNdx), CHARINDEX('"', @vData, @urlNdx))-@urlNdx)
			SET @vDataFixed = LEFT(@vData, CHARINDEX('""', @vData, @start)) + @id + RIGHT(@vData, LEN(@vData) -  CHARINDEX('""', @vData, @start))

			UPDATE [Profile.Module].[GenericRDF.Data] SET [Data] = @vDataFixed WHERE NodeID = @vNodeID AND [Name] = 'FeaturedVideos'
		END
		FETCH NEXT
		FROM @curVideos INTO @vNodeID, @vData
	END
CLOSE @curVideos
DEALLOCATE @curVideos
GO
-- actually, stop

-- Now remove the ORNG app from people
DECLARE @vNodeID BIGINT
DECLARE @vAppID int
SELECT @vAppID = appID from [ORNG.].Apps where Name = 'Featured Videos'
DECLARE @curVideos CURSOR
SET @curVideos = CURSOR FOR select NodeID  
 from [ORNG.].[AppData] where appID = @vAppID and keyname = 'videos'
OPEN @curVideos
	FETCH NEXT
	FROM @curVideos INTO @vNodeID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		exec [ORNG.].[RemoveAppFromAgent] @SubjectID=@vNodeID, @AppID=@vAppID
		FETCH NEXT
		FROM @curVideos INTO @vNodeID
	END
CLOSE @curVideos
DEALLOCATE @curVideos

-- disable gadget
exec [ORNG.].[RemoveAppFromOntology] @AppID=@vAppID 

UPDATE [ORNG.].Apps SET [Enabled] = 0 WHERE AppID=@vAppID 

-- print bad people, fix this manually
SELECT v.prettyURL, a.* FROM [ORNG.].AppData a JOIN [UCSF.].[vwPerson] v on a.NodeID = v.nodeid where a.appID=@vAppID and a.keyname = 'videos' and ISJSON(VALUE) != 1
GO

-- STOP

-- delete filters
DECLARE @PersonFilterID INT
SELECT @PersonFilterID = PersonFilterID FROM [Profile.Data].[Person.Filter] WHERE PersonFilter = 'Featured Videos';

-- check this, if any return then STOP
SELECT * FROM [Profile.Data].[Person.FilterRelationship] WHERE PersonFilterid = @PersonFilterID;
DELETE FROM [Profile.Data].[Person.Filter] WHERE PersonFilter = 'Featured Videos';
delete from [Profile.Import].[PersonFilterFlag] where personfilter = 'Featured Videos';

-- need to fix single quote 
-- Look
select  v.prettyurl, d.[data], d.* from [Profile.Module].[GenericRDF.Data] d join [UCSF.].vwPerson v on v.nodeid = d.nodeid where d.[Name] = 'FeaturedVideos' and 
(d.[Data] like '%''%' and d.[Data] not like '%\''%'); -- 18 rows
-- Fix
update [Profile.Module].[GenericRDF.Data] set [Data] = REPLACE([Data], '''', '\''') WHERE [Name] = 'FeaturedVideos' and ([Data] like '%''%' and [Data] not like '%\''%');
-- Check changed
select  v.prettyurl, d.[data], d.* from [Profile.Module].[GenericRDF.Data] d join [UCSF.].vwPerson v on v.nodeid = d.nodeid where d.[Name] = 'FeaturedVideos' and 
d.[Data] like '%\''%';--'%''%';

-- need to fix double quote. Note that current double quotes are escaped wiht \
-- Look
select  v.prettyurl, d.[data], d.* from [Profile.Module].[GenericRDF.Data] d join [UCSF.].vwPerson v on v.nodeid = d.nodeid where d.[Name] = 'FeaturedVideos' and 
d.[Data] like '%\"%';--'%''%';
-- Fix
update [Profile.Module].[GenericRDF.Data] set [Data] = REPLACE([Data], '\"', '\''') WHERE [Name] = 'FeaturedVideos' and [Data] like '%\"%';
-- Check changed
select  v.prettyurl, d.[data], d.* from [Profile.Module].[GenericRDF.Data] d join [UCSF.].vwPerson v on v.nodeid = d.nodeid where d.[Name] = 'FeaturedVideos' and 
d.[Data] like '%\''%';--'%''%';


