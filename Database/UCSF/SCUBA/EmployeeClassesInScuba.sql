
drop table EmployeeClassesInScuba
SELECT 
/*
[PersonPrimaryAssignmentFactKey]
      ,[UCSFPersonType]
      ,
  
	  [UCSFID]
      ,[PreferredName]
	  ,count(*)

      ,[PreferredFirstName]
      ,[PreferredLastName]
      ,[EmployeeId]
      ,[HireDate]
      ,[EmployeeRecord]
      ,[JobIndicator]
      ,[PrimaryJobIndicatorCalculated]
      ,[PersonPositionStartDate]
      ,[PersonPositionEndDate]
      ,[IsActive]
      ,[JobCode]
      ,[JobCodeDescription]
      ,[AcademicRank]
      ,[AcademicSeriesGrouping]
      ,[NaturalId]
      ,[DepartmentName]
      ,[Step]
      ,[Grade]
      ,[PositionKey]
      ,[EmployeeClass]
*/
      [EmployeeClassDescription]
	  ,count(*) scuba_cnt
/*
      ,[FTE]
      ,[BaseRate]
      ,[ReportsToPersonKey]
      ,[ReportsToPersonDurableKey]
      ,[IsCurrentPosition]
      ,[WorkingTitle]
      ,[WorkingDepartmentName]
      ,[PositionNumber]
      ,[Organization]
      ,[FLSAStatus]
      ,[CurrentDepartmentKey]
      ,[PersonDemographicKey]
      ,[CurrentPersonDemographicKey]
      ,[JobSource]
      ,[AffiliationCode]
      ,[AffiliateStatus]
      ,[AffiliateStartDate]
      ,[AffiliateEndDate]
      ,[AssignmentStartDate]
      ,[AssignmentEndDate]
      ,[SourcePriority]
      ,[SourceOverallRecordRank]
      ,[EmailAddress]
      ,[IsWosVol]
      ,[isWorkingWithoutSalary]
*/
 into EmployeeClassesInScuba
  FROM [import_ucsf].[dbo].[ScubaForAllEmployee] imp
--  where UCSFID not in (select Employee_ID from profilesVIP)
  --join final_person p on p.internalusername=imp.UCSFID
/*
  where
  
  EmployeeClassDescription like 'Academic%'
  --and UCSFID not in (select Employee_ID from profilesVIP)
	or( EmployeeClassDescription like 'Staff%' and isWorkingWithoutSalary=1)
	or UCSFID in (select Employee_ID from profilesVIP)
	or UCSFID in (select internalusername from final_person)
*/
	
	group by EmployeeClassDescription
/*
	select * from EmployeeClassesInScuba
	order by EmployeeClassDescription
*/	

select IsNULL(scimp.EmployeeClassDescription,'Others') EmployeeClassDescription,
	sc.scuba_cnt 'IN UCSF',
	ISNull(scimp.all_cnt,0) 'In Current Import',
	isNULL(scprof.cnt,0) 'In Profiles',isNull(scvip.cnt,0) 'From VIP'
	from EmployeeClassesInScuba sc
left outer join	EmployeeClassesInImport scimp on sc.EmployeeClassDescription=scimp.EmployeeClassDescription
left outer	join EmployeeClassesInProfiles scprof 
		on scimp.EmployeeClassDescription=scprof.EmployeeClassDescription
left outer	join EmployeeClassesInProfilesFromVIP scvip 
		on scimp.EmployeeClassDescription=scvip.EmployeeClassDescription
--where sc.EmployeeClassDescription is not NULL
UNION
select 'Summary',sum(scuba_cnt),sum(scimp.all_cnt),sum(scprof.cnt),sum(scvip.cnt)
from EmployeeClassesInScuba sc
left outer join	EmployeeClassesInImport scimp 
		on sc.EmployeeClassDescription=scimp.EmployeeClassDescription
left outer	join EmployeeClassesInProfiles scprof 
		on scimp.EmployeeClassDescription=scprof.EmployeeClassDescription
left outer	join EmployeeClassesInProfilesFromVIP scvip 
		on scimp.EmployeeClassDescription=scvip.EmployeeClassDescription
--where sc.EmployeeClassDescription is not NULL
--	order by sc.EmployeeClassDescription
	/*
EmployeeClassDescription		In Scuba	In Profiles	From VIP
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Academic: Academic Student		82			12			4
Academic: Contingent Worker		93			39			13
Academic: Deans/Faculty Admin	7			7			4
Academic: Emeriti				722			438			206
Academic: Faculty				6330		4765		1356
Academic: Medical Residents		494			464			27
Academic: Non Faculty			678			379			153
Academic: Post Docs				432			424			41
Academic: Recall				318			314			100
Staff: Career					15901		1687		763
Staff: Contingent Worker		27			2			3
Staff: Contract					285			88			48
Staff: Floater					117			3			1
Staff: Limited					557			206			55
Staff: Per Diem					782			12			7
Student: Casual/Restricted		22			0			0
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	Summery						26847		8840		2781
*/