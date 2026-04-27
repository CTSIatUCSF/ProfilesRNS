
drop table EmployeeClassesInProfiles
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
 into EmployeeClassesInProfiles
  FROM [import_ucsf].[dbo].[ScubaForStalledPRO1] imp
  join final_person p on p.internalusername=imp.UCSFID
  --where UCSFID not in (select Employee_ID from profilesVIP)
/*
  where
  
  EmployeeClassDescription like 'Academic%'
  --and UCSFID not in (select Employee_ID from profilesVIP)
	or( EmployeeClassDescription like 'Staff%' and isWorkingWithoutSalary=1)
	or UCSFID in (select Employee_ID from profilesVIP)
	or UCSFID in (select internalusername from final_person)
*/
	
	group by EmployeeClassDescription
	

	select * from EmployeeClassesInProfiles
	order by EmployeeClassDescription
	;

/*
EmployeeClassDescription	cnt
Academic: Academic Student	12
Academic: Contingent Worker	39
Academic: Deans/Faculty Admin	7
Academic: Emeriti	438
Academic: Faculty	4765
Academic: Medical Residents	464
Academic: Non Faculty	379
Academic: Post Docs	424
Academic: Recall	314
Staff: Career	1687
Staff: Contingent Worker	2
Staff: Contract	88
Staff: Floater	3
Staff: Limited	206
Staff: Per Diem	12
*/