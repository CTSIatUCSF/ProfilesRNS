
-- how many bad nodes do we have?
select count(*) from [profiles_ucsf_29].[RDF.].[Node] where ObjectType = 1 and Language is null and DataType is null and ValueHash != [RDF.].fnValueHash(Language, DataType, Value);
-- what are they?
select * from [profiles_ucsf_29].[RDF.].[Node] where ObjectType = 1 and Language is null and DataType is null and ValueHash != [RDF.].fnValueHash(Language, DataType, Value); 
-- 69503156
-- fix them via update or delete
update [profiles_ucsf_29].[RDF.].[Node] set ValueHash = [RDF.].fnValueHash(Language, DataType, Value) where NodeID = 69503156;

-- find hidden literals
select * from [profiles_ucsf_29].[RDF.].[Node] where ObjectType = 1 and ViewSecurityGroup <> -1 order by len(value);
-- remove dupes (should not be any after fix)

-- fix ones that do not look like email address or encryption
update [profiles_ucsf_29].[RDF.].[Node] set ViewSecurityGroup = -1 where NodeID in (1088383,
1088381,
1088387,
1088388,
1088391,
1088393,
1088385);

select * from [profiles_ucsf_29].[RDF.].[Node] where NodeID in (1088383,
1088381,
1088387,
1088388,
1088391,
1088393,
1088385);

-- find people impacted by this
select p.* from [RDF.].[Triple] t join [UCSF.].vwPerson p on p.NodeID = t.subject where t.object in 
(1088394, 1088383,
1088381,
1088387,
1088388,
1088391,
1088393,
1088385);

select 'http://stage-profiles.ucsf.edu/profiles_ucsf_29/' + p.UrlName newProfiles , 'http://stage-profiles.ucsf.edu/profiles_ucsf/' + p.UrlName oldProfiles, 
'http://profiles.ucsf.edu/' + p.UrlName production, p.DisplayName, p.Suffix from [RDF.].[Triple] t join [UCSF.].vwPerson p on p.NodeID = t.subject where t.object in 
(1088394, 1088383,
1088381,
1088387,
1088388,
1088391,
1088393,
1088385);