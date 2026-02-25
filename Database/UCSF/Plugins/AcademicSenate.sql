  -- First remove ORNG gadget from everybody 
  DECLARE @PropertyNode INT
  SELECT @PropertyNode = _PropertyNode FROM [Ontology.].[ClassProperty] where Property = 'http://orng.info/ontology/orng#hasAcademicSenate'
  SELECT @PropertyNode

  --select * from [RDF.].Triple where Predicate = @PropertyNode
  -- check appid!
  -- Run below then execute the output
  SELECT 'Exec [ORNG.].[RemoveAppFromAgent] @SubjectID=' + cast(Subject as varchar) + ', @AppID=132;' FROM [RDF.].Triple where Predicate = @PropertyNode
  
  -- be sure to remove the filter!!!!
  DECLARE @FilterID int
  SELECT @FilterID=PersonFilterID FROM [Profile.Data].[Person.Filter] WHERE PersonFilter = 'Academic Senate Committees'
  DELETE FROM [Profile.Data].[Person.FilterRelationship] WHERE PersonFilterid = @FilterID
  DELETE FROM [Profile.Data].[Person.Filter] WHERE PersonFilterid = @FilterID

  DELETE FROM [Profile.Import].[PersonFilterFlag] WHERE personfilter='Academic Senate Committees'

  --remove the gadget
  EXEC [ORNG.].[RemoveAppFromOntology] @AppID=132
  UPDATE [ORNG.].[Apps] SET Enabled=0 WHERE AppID=132

 -- remove verify view from DB manually!!!
 delete from [ORNG.].[AppViews] where AppID = 132

 ---- PLUGGIN STUFF!!!!
-- Add the new one
INSERT [Profile.Module].[GenericRDF.Plugins] ([Name], [EnabledForPerson], [EnabledForGroup], [Label], [PropertyGroupURI], [CustomDisplayModule], [CustomEditModule], [CustomDisplayModuleXML], [CustomEditModuleXML]) VALUES (N'AcademicSenate', 1, 0, N'Academic Senate', N'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupOverview', N'AcademicSenate', N'EditAcademicSenate', NULL, NULL)

EXEC [Profile.Module].[GenericRDF.AddUpdateOntology] @pluginName='AcademicSenate' 
GO

CREATE PROCEDURE [UCSF.].[AcademicSenateAddDataToPlugin]
AS
BEGIN

  DECLARE @PluginName nvarchar(50) = 'AcademicSenate'
  DECLARE @nodeid bigint
  DECLARE @PluginData varchar(max)
  DECLARE @SearchableData varchar(max)

  SELECT nodeid, '{"committees":' + JSON_QUERY([Data],'$.committees') + '}' [Data] into #temp FROM [UCSF.].[AcademicSenate] WHERE
  -- fake way to do it in DEV which doesn't have JSON functions
	  --[Data] not like '%"committees":[[]]%'
  -- real way to do it
	(select count(*) from openjson([Data], '$.committees')) > 0

  -- to be safe
  DELETE FROM #temp where nodeid not in (SELECT nodeid FROM [UCSF.].vwPerson)
  
  SELECT nodeid into #temp2 FROM [Profile.Module].[GenericRDF.Data] WHERE [Name]=@PluginName AND nodeid NOT IN (SELECT nodeid FROM #temp)

  -- add/update new ones
  WHILE EXISTS (SELECT * FROM #temp)
  BEGIN
	  BEGIN TRANSACTION
	  --Use the commented out one if STRING_AGG is not supported on the version of SQL Server this is on
	  --SELECT TOP 1 @nodeid=nodeid, @PluginData=[Data], @SearchableData='Academic Senate Committee FROM #temp 
	  SELECT TOP 1 @nodeid=nodeid, @PluginData=[Data], @SearchableData='Academic Senate Committee, ' + STRING_AGG(c.title, ', ')  FROM #temp 
			cross apply 
			openjson([Data], '$.committees') with (title nvarchar(500) '$.title') as c
			GROUP BY nodeid, [Data] 	  	  
	  
	  DELETE FROM #temp WHERE NodeID=@nodeid
	  BEGIN TRY
		EXEC [Profile.Module].[GenericRDF.AddEditPluginData] @Name=@PluginName, @NodeID=@nodeid, @Data=@PluginData, @SearchableData=@SearchableData
	  END TRY
	  BEGIN CATCH
	    print 'Error processing nodeid=' + cast(@nodeid as varchar) + ' for AcademicSenate'
		print ERROR_MESSAGE()
	  END CATCH
	  COMMIT 
  END
  -- remove old ones that no longer have data
  WHILE EXISTS (SELECT * FROM #temp2)
  BEGIN
	  BEGIN TRANSACTION	
	  SELECT TOP 1 @nodeid=nodeid FROM #temp2 
	  DELETE FROM #temp2 WHERE NodeID=@nodeid
	  BEGIN TRY
	    EXEC [Profile.Module].[GenericRDF.AddEditPluginData] @Name=@PluginName, @NodeID=@nodeid, @Data=null, @SearchableData=null
	  END TRY
	  BEGIN CATCH
	    print 'Error processing nodeid=' + cast(@nodeid as varchar) + ' for AcademicSenate'
		print ERROR_MESSAGE()
	  END CATCH
	  COMMIT
  END	

END


GO


-- END PLUGGIN STUFF
 -- This section is about putting in the modified gadget 
 
  -- Run below then execute the output
  SELECT 'Exec [ORNG.].[AddAppToAgent] @SubjectID=' + cast(NodeID as varchar) + ', @AppID=132;'  
    FROM [profilesRNS].[UCSF.].[AcademicSenate]
  where
  --isjson(Data) > 0 AND
(select count(*) from openjson([Data], '$.committees')) > 0;
  
 -- stop
 --https://stage.researcherprofiles.org
 -- call SP to add ORNG data with keyname = jsonData
 --[ORNG.].[UpsertAppData](@Uri nvarchar(255),@AppID INT, @Keyname nvarchar(255),@Value nvarchar(4000))
 
 
-- Run below then execute the output
-- TODO lookup URI prefix
	--JSON_QUERY([Data],'$[0]') + ''';'
DECLARE @BaseURI varchar(100)
SELECT @BaseURI = [Value] FROM [Framework.].[Parameter] where ParameterID = 'baseURI' 
SELECT @BaseURI

SELECT 'Exec [ORNG.].[UpsertAppData] @Uri=''' + @baseURI + cast(NodeID as varchar) + ''', @AppID=132, @keyname=''jsonData'', @Value=''' +
	[Data] + ''';'
    FROM [profilesRNS].[UCSF.].[AcademicSenate]
  WHERE
  --isjson(Data) > 0 AND
(select count(*) from openjson([Data], '$.committees')) > 0;