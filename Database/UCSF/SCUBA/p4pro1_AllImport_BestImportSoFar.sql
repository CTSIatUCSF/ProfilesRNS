
select 
		sc.UCSFID Individual_ID,
		LegalLastName SURName,
		LegalFirstName GIVEN_Name,
		LegalMiddleName Middle_Name, 
		PreferredFirstName Pref_FRST_NAME,
		LegalFirstName+' '+LegalLastName GIVEN_NAME_SURNAME,
		Substring(LegalNameSuffix,1,4) as Name_Suffix,
		GlobalRelease GLOBAL_RELEASE,
		BuildingCode as[CPUS_BLDG_CODE], 
		--AddressLine3, AddressLine4, BuildingCode, Floor, Room, Cubicle, Box,
		case
			when AddressLine1 like 'Please update%' then ''
			else AddressLine1
		end	as[CPUS_BLDG_ADDR],
		City as[CPUS_BLDG_CITY],
		[StateOrProvinceAbbreviation] as[CPUS_BLDG_ST],
		PostalCode as[CPUS_BLDG_ZIP5],
		Room as[CAMPUS_ROOM],
		EmailAddress [E_MAIL_ADDRESS],
		case 
			when sc.EmailDisclosereFlag like '%No Restriction%' then 1
			else 0
		end
		[E_MAIL_RELEASE],
		NULL [PP_ADDR_LINE1] ,
		AddressLine2  [PP_ADDR_LINE2], 
		null [PP_CITY], 
		null  [PP_STATE],
		null [PP_ZIP_FIVE],
		NULL [PP_ZIP_FOUR],
		case 
			when sc.PhoneDisclosureFlag like '%No Restriction%' then PhoneNumber
			else ''
		end
		PHN_CPS1, 
	    NULL as [PHN_CPS1_EXT],
	    NULL as[PHN_CPS1RF],
	    NULL as [PHN_CPS2],
	    NULL as[PHN_CPS2_EXT],
	    NULL as[PHN_CPSRF2],
	    NULL  [PHN_PAGE],
		NULL as [PHN_PAGERF],
		NULL [PHN_FAX],
		NULL as [PHN_FAXRF],
		NULL  as [PHN_PP],
		NULL  as [PHN_PPRF],
		NULL [PHN_CELL],
		NULL [PHN_CELLRF],
	    NULL as [PHN_DEPT_ITCM],
	    NULL as [CLS_SUPV_ID],
		DEPTID,
		[WorkingDepartmentName] [WORKING_DEPT] ,
		[WorkingTitle] [WORKING_TITLE],
		NULL as [DEG1],
		NULL as [DEG2],
		NULL as [DEG3],	
		'A' [EMP_STATUS],
		case when isWorkingwithoutSalary ='1' then 'Y'
			else 'N'
	    end  [EMP_WOS_IND],
		JobCode [PRIMARY_TITLE] , 
		JobCodeDescription [PRIM_TITLE_NAME],
		PreferredLastName PREF_LAST_NAME
--into [import_ucsf].[dbo].[PRO1_AllFromScuba]
from (
select * from 
(
	SELECT 
		[UCSFID]  , 
		LegalFirstName,LegalMiddleName, LegalLastName,LivedFirstName as PreferredFirstName ,LivedLastName as PreferredLastName ,
		[EmployeeId] ,LegalNameSuffix ,
		ppaf.PersonKey, per.IsWorkingWithoutSalary,
		[IsActive] ,JobCode , JobCodeDescription , AcademicRank , AcademicSeriesGrouping ,
		dept.NaturalId deptid , dept.DepartmentName ,
		[IsCurrentPosition] ,[WorkingTitle] ,[WorkingDepartmentName] ,[PositionNumber] ,dept.Organization,name.GlobalRelease 

--		AddressLine1, AddressLine2, City, StateOrProvinceAbbreviation, 
	--	StateOrProvince, PostalCode, AddressLine3, AddressLine4, BuildingCode, Floor, Room, Cubicle, Box ,
	--	PhoneNumber ,PhoneExtension,phoneDisclosureFlag, 
	--	EmailAddress, EmailDisclosereFlag,
	--[Step] ,[Grade] ,[PositionKey] ,[EmployeeClass] ,[EmployeeClassDescription] ,[FTE] ,[BaseRate] ,
	--[ReportsToPersonKey],[ReportsToPersonDurableKey] ,
	--[HireDate] ,[EmployeeRecord] ,[JobIndicator] ,[PrimaryJobIndicatorCalculated] ,
	--[PersonPositionStartDate] ,[PersonPositionEndDate] ,	
	--[FLSAStatus] ,[CurrentDepartmentKey] ,[PersonDemographicKey] ,[CurrentPersonDemographicKey] ,[JobSource] ,
	--[AffiliationCode] ,[AffiliateStatus] ,[AffiliateStartDate] ,[AffiliateEndDate] ,[AssignmentStartDate] ,[AssignmentEndDate] ,
	--[SourcePriority] ,[SourceOverallRecordRank] 
	 
	FROM [EnterpriseDW].[PeopleP4View].[PersonPrimaryAssignmentFact] ppaf 
	left JOIN EnterpriseDW.PeopleP4View.PersonContactFact pcf 
		on ppaf.PersonKey = pcf.PersonKey and pcf.ContactMethodKey = 389 and pcf.ContactTypeKey = 392 and pcf.IsPrimarySourceFlag = 1 
	inner join Enterprisedw.PeopleP4View.PersonNameDim name on ppaf.PersonDurableKey = name.PersonDurableKey 
	inner join (
		select PersonKey, UcsfPersontype, PersonStatus,IsWorkingWithoutSalary 
		from EnterpriseDW.PeopleP4View.PersonDim
		) per 
			on ppaf.PersonKey =per.PersonKey 
		inner join EnterpriseDW.baseview.JobCodeDim job on ppaf.JobKey = job.JobKey 
		left join EnterpriseDW.baseview.DepartmentDim dept on dept.DepartmentKey = ppaf.CurrentDepartmentKey 
	where  	((IsActive IN ('A','W','L','P') and ppaf._EffectiveEndDate >= CAST(GetDate() AS DATE)			
			) OR AffiliateStatus = 'A'
		)
		-- to recognize VCP, and note that the Description will be %VOL in all cases
		--and  JobCode in ('002017','002037','002057','002077')
		--and UCSFID='028713402'
) IAM
left join (
		SELECT	
		per.UCSFID addrID, 
		--per.UCSFPersonType,per.PersonStatus, ContactMethodKey, 
		--class.Description, ContactTypeKey, class2.Description, 
		--a.ContactSubTypeKey, class3.Description, 
			a.AddressKey, ADDR.AddressLine1, ADDR.AddressLine2, ADDR.City, ADDR.StateOrProvinceAbbreviation, 
		    ADDR.StateOrProvince, ADDR.PostalCode, a.AddressLine3, a.AddressLine4, BuildingCode, Floor, Room, Cubicle, Box 
		FROM EnterpriseDW.PeopleP4View.PersonContactFact a 
		LEFT JOIN EnterpriseDW.PeopleP4View.PersonDim per 
			ON a.PersonKey = per.PersonKey 
		LEFT JOIN EnterpriseDW.baseview.ClassificationDim class 
			ON a.ContactMethodKey = class.ClassificationKey 
		LEFT JOIN EnterpriseDW.baseview.ClassificationDim class2 
		ON a.ContactTypeKey = class2.ClassificationKey 
		LEFT JOIN EnterpriseDW.baseview.ClassificationDim class3 
			ON a.ContactSubTypeKey = class3.ClassificationKey 
		LEFT JOIN EnterpriseDW.baseview.AddressDim ADDR 
			ON a.AddressKey = ADDR.AddressKey 
		WHERE a.ContactMethodKey = 388 AND a.ContactTypeKey = 392 
			AND a.IsPrimarySourceFlag = 1 AND per._IsCurrent = 1 AND per.PersonStatus = 'A'
			--and per.UCSFID='028713402'

) address on IAM.UCSFID=ADDRess.addrID
left  join (
		SELECT 
			per.UCSFID emailID, 
			--per.UCSFPersonType, per.PersonStatus, ContactMethodKey,	ContactTypeKey,
			--a.ContactSubTypeKey, class3.Description, 
			a.EmailAddressType, a.EmailAddress,a.DisclosureFlag EmailDisclosereFlag
		FROM EnterpriseDW.PeopleP4View.PersonContactFact a
		LEFT JOIN EnterpriseDW.PeopleP4View.PersonDim per 
			ON a.PersonKey = per.PersonKey 
		LEFT JOIN EnterpriseDW.baseview.ClassificationDim class 
			ON a.ContactMethodKey = class.ClassificationKey 
		LEFT JOIN EnterpriseDW.baseview.ClassificationDim class2 
			ON a.ContactTypeKey = class2.ClassificationKey 
		LEFT JOIN EnterpriseDW.baseview.ClassificationDim class3 
			ON a.ContactSubTypeKey = class3.ClassificationKey 
		WHERE a.ContactMethodKey = 389 AND a.ContactTypeKey = 392 
			AND a.IsPrimarySourceFlag = 1 AND per._IsCurrent = 1 AND per.PersonStatus = 'A'
		--and per.UCSFID='028713402'
) EML on EML.emailID=IAM.UCSFID
left join (
		SELECT 
			per.UCSFID telID, 
		--per.UCSFPersonType, per.PersonStatus, ContactMethodKey,ContactTypeKey,
		--a.ContactSubTypeKey, class3.Description, 
			a.PhoneNumber, a.DisclosureFlag PhoneDisclosureFlag
		FROM EnterpriseDW.PeopleP4View.PersonContactFact a
		LEFT JOIN EnterpriseDW.PeopleP4View.PersonDim per ON a.PersonKey = per.PersonKey 
		LEFT JOIN EnterpriseDW.baseview.ClassificationDim class 
			ON a.ContactMethodKey = class.ClassificationKey 
		LEFT JOIN EnterpriseDW.baseview.ClassificationDim class2 
			ON a.ContactTypeKey = class2.ClassificationKey 
		LEFT JOIN EnterpriseDW.baseview.ClassificationDim class3 
			ON a.ContactSubTypeKey = class3.ClassificationKey 
		WHERE a.ContactMethodKey = 387 AND a.ContactTypeKey = 392 AND a.IsPrimarySourceFlag = 1
			AND per._IsCurrent = 1 AND per.PersonStatus = 'A' 
			--and isRestricted=0 
			--and per.UCSFID='028713402'
) TEL on TEL.telID=IAM.UCSFID

where GlobalRelease=1 
) sc
order by PRIMARY_TITLE
--LegalLastName, 
--sc.WorkingTitle  --022396139



