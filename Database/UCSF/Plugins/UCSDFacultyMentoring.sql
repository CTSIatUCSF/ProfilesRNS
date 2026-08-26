-- Add the new one
INSERT [Profile.Module].[GenericRDF.Plugins] ([Name], [EnabledForPerson], [EnabledForGroup], [Label], [PropertyGroupURI], [CustomDisplayModule], [CustomEditModule], [CustomDisplayModuleXML], [CustomEditModuleXML]) VALUES (N'UCSDFacultyMentoring', 1, 0, N'Faculty Mentoring', N'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupFeaturedContent', N'UCSDFacultyMentoring', N'EditUCSDFacultyMentoring', NULL, NULL)

EXEC [Profile.Module].[GenericRDF.AddUpdateOntology] @pluginName='UCSDFacultyMentoring'

-- fix the sort order, put it with Mentoring, make sure SortOrder matches the environment where you are doint this
SELECT *
  FROM [Ontology.].[PropertyGroupProperty] where PropertyURI like '%mentor%' or PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupFeaturedContent' 
  order by SortOrder

UPDATE [Ontology.].[PropertyGroupProperty] set SortOrder = 52 where PropertyURI = 'http://profiles.catalyst.harvard.edu/ontology/plugins#UCSDFacultyMentoring'


 --{"availableToMentor":["Junior Faculty","Medical Fellows","Postdoctoral Trainees","Graduate Students"," Medical and Pharmacy Students","Undergraduate Students"],"contactPreferences":["Email","Phone","Assistant"],"assistantName":"Eric Meeks","assistantEmail":"eric.meeks@ucsf.edu","assistantPhone":"555-555-5555","narrative":"Test of mentoring narrative","lastUpdated":"Wednesday, August 12, 2026"}

-- to xfer data. Do a self join with left outer joins. Start with narrative because everyone has a narrative keyname (151) individuals 
-- and manually build json. Add array entries with trailing eplace ,] with ] to make array building simple 
-- actally make this an exec on the SP, and execute the results
INSERT [Profile.Module].[GenericRDF.Data]
SELECT 'UCSDFacultyMentoringTest', a.nodeid, 
	REPLACE('{"availableToMentor":[' 
	+ case when ISNULL(b.[Value], 'F') = 'T' then '"Junior Faculty",' else '' end  
	+ case when ISNULL(c.[Value], 'F') = 'T' then '"Medical Fellows",' else '' end  
	+ case when ISNULL(d.[Value], 'F') = 'T' then '"Postdoctoral Trainees",' else '' end  
	+ case when ISNULL(e.[Value], 'F') = 'T' then '"Graduate Students",' else '' end  
	+ case when ISNULL(f.[Value], 'F') = 'T' then '"Medical and Pharmacy Students",' else '' end  
	+ case when ISNULL(g.[Value], 'F') = 'T' then '"Undergraduate Students",' else '' end  
	+ '],"contactPreferences":['
	+ case when ISNULL(h.[Value], 'F') = 'T' then '"Email",' else '' end  
	+ case when ISNULL(i.[Value], 'F') = 'T' then '"Phone",' else '' end  
	+ case when ISNULL(j.[Value], 'F') = 'T' then '"Assistant",' else '' end  
	+ '],"assistantName":"' + ISNULL(k.[Value], '') + '"'
	+ ',"assistantEmail":"' + ISNULL(l.[Value], '') + '"'
	+ ',"assistantPhone":"' + ISNULL(m.[Value], '') + '"'
	+ ',"narrative":"' + ISNULL(a.[Value], '') + '"'
	+ ',"lastUpdated":"' + ISNULL(n.[Value], '') + '"}', ',]', ']'),
	'Faculty Mentoring'
  FROM [ORNG.].[AppData] a
  left outer join [ORNG.].[AppData] b on b.nodeid = a.nodeid and b.appid = 102 and b.Keyname = 'juniorFaculty'
  left outer join [ORNG.].[AppData] c on c.nodeid = a.nodeid and c.appid = 102 and c.Keyname = 'medicalFellows'
  left outer join [ORNG.].[AppData] d on d.nodeid = a.nodeid and d.appid = 102 and d.Keyname = 'postdocTrainee'
  left outer join [ORNG.].[AppData] e on e.nodeid = a.nodeid and e.appid = 102 and e.Keyname = 'gradStudents'
  left outer join [ORNG.].[AppData] f on f.nodeid = a.nodeid and f.appid = 102 and f.Keyname = 'medStudents'
  left outer join [ORNG.].[AppData] g on g.nodeid = a.nodeid and g.appid = 102 and g.Keyname = 'underGrads'
  left outer join [ORNG.].[AppData] h on h.nodeid = a.nodeid and h.appid = 102 and h.Keyname = 'contactEmail'
  left outer join [ORNG.].[AppData] i on i.nodeid = a.nodeid and i.appid = 102 and i.Keyname = 'contactPhone'
  left outer join [ORNG.].[AppData] j on j.nodeid = a.nodeid and j.appid = 102 and j.Keyname = 'contactAssistant'
  left outer join [ORNG.].[AppData] k on k.nodeid = a.nodeid and k.appid = 102 and k.Keyname = 'assistantName'
  left outer join [ORNG.].[AppData] l on l.nodeid = a.nodeid and l.appid = 102 and l.Keyname = 'assistantEmeail'
  left outer join [ORNG.].[AppData] m on m.nodeid = a.nodeid and m.appid = 102 and m.Keyname = 'assistantPhone'
  left outer join [ORNG.].[AppData] n on n.nodeid = a.nodeid and n.appid = 102 and n.Keyname = 'lastUpdate'
  where a.appid = 102
  and a.nodeid in (select nodeid from [UCSF.].vwPerson where InstitutionAbbreviation = 'UCSD')
  and a.keyname = 'narrative';--151


select *, ISJSON([Data]) from [Profile.Module].[GenericRDF.Data] where [Name] = 'UCSDFacultyMentoringTest';
delete from [Profile.Module].[GenericRDF.Data] where [Name] = 'UCSDFacultyMentoringTest';

  -- remove old gadget from all people
-- remove filter
  -- First remove ORNG gadget from everybody. MAKE SURE ONLY UCSD FOLKS SHOW UP!!!
  DECLARE @PropertyNode INT
  SELECT @PropertyNode = _PropertyNode FROM [Ontology.].[ClassProperty] where Property = 'http://orng.info/ontology/orng#hasMentor'
  SELECT @PropertyNode
-- disable gadget

  -- run this and execute the output
  SELECT 'Exec [ORNG.].[RemoveAppFromAgent] @SubjectID=' + cast(Subject as varchar) + ', @AppID=102;' FROM [RDF.].Triple where Predicate = @PropertyNode 
	and Subject in (select NodeID from [UCSF.].vwPerson where InstitutionAbbreviation = 'UCSD');

-- remove the gadget but only for UCSD
 delete FROM [UCSF.ORNG].[InstitutionalizedApps] where AppID = 102 and InstitutionAbbreviation = 'UCSD';
 -- actually remove it for all now? Yes
 
--remove the gadget
EXEC [ORNG.].[RemoveAppFromOntology] @AppID=102
UPDATE [ORNG.].[Apps] SET Enabled=0 WHERE AppID=102


--{"availableToMentor":["Junior Faculty","Medical Fellows","Postdoctoral Trainees","Graduate Students","Medical and Pharmacy Students","Undergraduate Students",],"contactPreferences":["Email","Phone","Assistant",],"assistantName":"Eric Meeks"],"assistantEmail":""],"assistantPhone":"555-555-555"],"narrative":"Test of mentoring narrative"],"lastUpdated":"Wednesday August 12, 2026"}
--{"availableToMentor":["Junior Faculty","Medical Fellows","Postdoctoral Trainees","Graduate Students","Medical and Pharmacy Students","Undergraduate Students"],"contactPreferences":["Email","Phone","Assistant"],"assistantName":"Eric Meeks"],"assistantEmail":""],"assistantPhone":"555-555-555"],"narrative":"Test of mentoring narrative"],"lastUpdated":"Wednesday August 12, 2026"}
--{"availableToMentor":["Junior Faculty","Medical Fellows","Postdoctoral Trainees","Graduate Students","Medical and Pharmacy Students","Undergraduate Students"],"contactPreferences":["Email","Phone","Assistant"],"assistantName":"Eric Meeks","assistantEmail":"","assistantPhone":"555-555-555","narrative":"Test of mentoring narrative","lastUpdated":"Wednesday August 12, 2026"}
--{"availableToMentor":["Medical Fellows","Postdoctoral Trainees","Graduate Students","Medical and Pharmacy Students","Undergraduate Students"],"contactPreferences":["Email","Assistant"],"assistantName":"Gini Roberts","assistantEmail":"","assistantPhone":"","narrative":"My research focuses on:   -Examining effects of epicatechin (a compound present in dark chocolate) on metabolism and exercise capacity in patients with heart failure and diabetes.  I conduct clinical research studies utilizing the technique of skeletal muscle biopsy and exercise testing to assess maximal oxygen consumption (VO2 max)  -Developing new biomarkers (blood tests) for prediction of renal injury in patients undergoing cardiac surgery.  -Understanding mechanisms of statin related muscle complaints and decreases in exercise capacity. ","lastUpdated":"Friday October 3, 2014"}