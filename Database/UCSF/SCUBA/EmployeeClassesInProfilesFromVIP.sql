
drop table EmployeeClassesInProfilesFromVIP
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
	  ,count(*) cnt
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
 into EmployeeClassesInProfilesFromVIP
  FROM [import_ucsf].[dbo].[ScubaForStalledPRO1] imp
  where UCSFID in (select Employee_ID from profilesVIP)
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

select * from EmployeeClassesInProfilesFromVIP
order by EmployeeClassDescription
	
/*
select sc.*,scprof.cnt prof
	from EmployeeClassesInSCUBA sc
left outer	join EmployeeClassesInProfiles scprof 
		on sc.EmployeeClassDescription=scprof.EmployeeClassDescription
	order by sc.EmployeeClassDescription


EmployeeClassDescription	all_cnt		prof
NULL							3038	NULL
Academic: Academic Student		78		12
Academic: Contingent Worker		80		39
Academic: Deans/Faculty Admin	3		7
Academic: Emeriti				516		438
Academic: Faculty				4974	4765
Academic: Medical Residents		467		464
Academic: Non Faculty			525		379
Academic: Post Docs				391		424
Academic: Recall				218		314
Staff: Career					15138	1687
Staff: Contingent Worker		24		2
Staff: Contract					237		88
Staff: Floater					116		3
Staff: Limited					502		206
Staff: Per Diem					775		12
Student: Casual/Restricted		22		NULL
*/