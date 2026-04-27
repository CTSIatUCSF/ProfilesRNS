drop table ScubaForAllEmployee
SELECT 
	[PersonPrimaryAssignmentFactKey] , UCSFPersonType ,[UCSFID] , LivedName as PreferredName , LivedFirstName as PreferredFirstName ,
	LivedLastName as PreferredLastName ,[EmployeeId] ,[HireDate] ,[EmployeeRecord] ,[JobIndicator] ,[PrimaryJobIndicatorCalculated] ,
	[PersonPositionStartDate] ,[PersonPositionEndDate] ,[IsActive] ,JobCode , JobCodeDescription , AcademicRank , AcademicSeriesGrouping ,
	dept.NaturalId , dept.DepartmentName ,[Step] ,[Grade] ,[PositionKey] ,[EmployeeClass] ,[EmployeeClassDescription] ,[FTE] ,[BaseRate] ,
	[ReportsToPersonKey],[ReportsToPersonDurableKey] ,[IsCurrentPosition] ,[WorkingTitle] ,[WorkingDepartmentName] ,[PositionNumber] ,
	dept.Organization ,[FLSAStatus] ,[CurrentDepartmentKey] ,[PersonDemographicKey] ,[CurrentPersonDemographicKey] ,[JobSource] ,
	[AffiliationCode] ,[AffiliateStatus] ,[AffiliateStartDate] ,[AffiliateEndDate] ,[AssignmentStartDate] ,[AssignmentEndDate] ,
	[SourcePriority] ,[SourceOverallRecordRank] , EmailAddress,IsWosVol,isWorkingWithoutSalary
into  ScubaForAllEmployee
FROM [SCUBA-DB-PRD.UCSFMEDICALCENTER.ORG].[EnterpriseDW].[PeopleP4View].[PersonPrimaryAssignmentFact] ppaf 
left JOIN [SCUBA-DB-PRD.UCSFMEDICALCENTER.ORG].EnterpriseDW.PeopleP4View.PersonContactFact pcf 
	on ppaf.PersonKey = pcf.PersonKey and pcf.ContactMethodKey = 389 and pcf.ContactTypeKey = 392 and pcf.IsPrimarySourceFlag = 1 
inner join [SCUBA-DB-PRD.UCSFMEDICALCENTER.ORG].Enterprisedw.PeopleP3View.PersonNameDim name on ppaf.PersonDurableKey = name.PersonDurableKey 
inner join (
	select PersonKey, UcsfPersontype, PersonStatus ,isWorkingWithoutSalary
	from [SCUBA-DB-PRD.UCSFMEDICALCENTER.ORG].EnterpriseDW.PeopleP3View.PersonDim
	) per 
	on ppaf.PersonKey =per.PersonKey 
inner join [SCUBA-DB-PRD.UCSFMEDICALCENTER.ORG].EnterpriseDW.baseview.JobCodeDim job on ppaf.JobKey = job.JobKey 
left join [SCUBA-DB-PRD.UCSFMEDICALCENTER.ORG].EnterpriseDW.baseview.DepartmentDim dept on dept.DepartmentKey = ppaf.CurrentDepartmentKey 

--inner join UCSFPRO1_beforeSCUBA on ppaf.UCSFID=INDIVIDUAL_ID

WHERE		((IsActive IN ('A','W','L','P') and ppaf._EffectiveEndDate >= CAST(GetDate() AS DATE))			
				OR AffiliateStatus = 'A')

/*
where EmployeeClassDescription like 'Academic%'
or UCSFID in (
select internalusername from [import_ucsf].[dbo].[final_person]
)
--isWorkingWithoutSalary=1 and AcademicSeriesGrouping not like'%vol%' 
--and JobCodeDescription not like '%Adj%'
--AcademicSeriesGrouping like'%vol%'
--JobCodeDescription like '%vol%'
 


UCSFID in ('027597160',
				  '021083712',
				  '021246293',
				  '022847933',
				  '026477695',
				  '026594325',
				  '029139623'
				  )
*/

order by JobCodeDescription