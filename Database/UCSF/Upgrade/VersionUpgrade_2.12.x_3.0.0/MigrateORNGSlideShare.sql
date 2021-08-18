/*** Remember to remove filters  **/

--DELETE FROM [Profile.Module].[GenericRDF.Data] WHERE [Name] = 'FeaturedPresentations';

declare @wNodeID bigint, @orngwNodeID bigint

select @wNodeID = NodeID from [RDF.].[Node] where value in ('http://profiles.catalyst.harvard.edu/ontology/plugins#FeaturedPresentations')
select @orngwNodeID = NodeID from [RDF.].[Node] where value in ('http://orng.info/ontology/orng#hasSlideShare')
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
	where property = 'http://orng.info/ontology/orng#hasSlideShare'


DECLARE @vNodeID BIGINT
DECLARE @vValue nvarchar(max)
DECLARE @vAppID int
SELECT @vAppID = appID from [ORNG.].Apps where Name = 'Featured Presentations'
DECLARE @curSlideShare CURSOR
SET @curSlideShare = CURSOR FOR select NodeID, [Value]
 from [ORNG.].[AppData] where appID = @vAppID and keyname = 'username' AND LEN(LTRIM(RTRIM([Value]))) > 0 
OPEN @curSlideShare
	FETCH NEXT
	FROM @curSlideShare INTO @vNodeID, @vValue
	WHILE @@FETCH_STATUS = 0
	BEGIN
		exec [Profile.Module].[GenericRDF.AddEditPluginData] @name='FeaturedPresentations',@NodeID=@vNodeID,@Data=@vValue,@SearchableData='' 
		FETCH NEXT
		FROM @curSlideShare INTO @vNodeID, @vValue
	END
CLOSE @curSlideShare
DEALLOCATE @curSlideShare
GO

--- STOP HERE and look around, set SearchabelData
SELECT v.PrettyURL, d.* FROM [Profile.Module].[GenericRDF.Data] d JOIN [UCSF.].vwPerson v on d.NodeID = v.NodeID WHERE d.[Name] = 'FeaturedPresentations';
--UPDATE [Profile.Module].[GenericRDF.Data] SET [Data] = 'billresh' WHERE [Data] = 'billresh/status/492370468696231936';

UPDATE [Profile.Module].[GenericRDF.Data] SET SearchableData = 'SlideShare Slide Share ' + [Data] WHERE [Name] = 'FeaturedPresentations' AND [Data] NOT LIKE 'http%';


--- STOP HERE and look around

-- Now remove the ORNG app from people
DECLARE @vNodeID BIGINT
DECLARE @vAppID int
SELECT @vAppID = appID from [ORNG.].Apps where Name = 'Featured Presentations'
DECLARE @curSlideShare CURSOR
SET @curSlideShare = CURSOR FOR select NodeID  
 from [ORNG.].[AppData] where appID = @vAppID and keyname = 'username'
OPEN @curSlideShare
	FETCH NEXT
	FROM @curSlideShare INTO @vNodeID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		exec [ORNG.].[RemoveAppFromAgent] @SubjectID=@vNodeID, @AppID=@vAppID
		FETCH NEXT
		FROM @curSlideShare INTO @vNodeID
	END
CLOSE @curSlideShare
DEALLOCATE @curSlideShare

-- disable gadget
exec [ORNG.].[RemoveAppFromOntology] @AppID=@vAppID 

UPDATE [ORNG.].Apps SET [Enabled] = 0 WHERE AppID=@vAppID 

-- STOP

-- delete filters
--SELECT * FROM [Profile.Data].[Person.Filter]
DECLARE @PersonFilterID INT
SELECT @PersonFilterID = PersonFilterID FROM [Profile.Data].[Person.Filter] WHERE PersonFilter = 'Featured Presentations';

-- check this, if any return then STOP
SELECT * FROM [Profile.Data].[Person.FilterRelationship] WHERE PersonFilterid = @PersonFilterID;
--DELETE FROM [Profile.Data].[Person.FilterRelationship] WHERE PersonFilterid = 14;
DELETE FROM [Profile.Data].[Person.Filter] WHERE PersonFilter = 'Featured Presentations';
delete from [Profile.Import].[PersonFilterFlag] where personfilter = 'Featured Presentations';
