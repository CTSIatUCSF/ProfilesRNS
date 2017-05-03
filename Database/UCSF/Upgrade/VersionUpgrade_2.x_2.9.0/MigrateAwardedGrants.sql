
begin tran 


INSERT INTO [Profile.Data].[Funding.Agreement]
           ([FundingAgreementID]
           ,[FundingID]
           ,[AgreementLabel]
           ,[GrantAwardedBy]
           ,[StartDate]
           ,[EndDate]
           ,[PrincipalInvestigatorName]
           ,[Abstract]
           ,[Source]
           ,[FundingID2])
     
(
select
agp.grantprincipalpk as FundingAgreementID --,agpi.principalinvestigatorpk,ag.grantpk 
,ag.fullprojectnum FundingID, ag.ProjectTitle as AgreementLabel,'NIH' as GrantAwardBy, convert(varchar(10),ProjectStart, 101) as StartDate
,convert(varchar(10),ProjectEnd, 101) as StartDate
,agpi.name PrinciaplInvestigatorName
,'' as Abstract
,'NIH' as Source
,ag.coreprojectnumber as FundingID2
--,* 
from [ORNG.Grant].[agGrant]  ag 
inner join [ORNG.Grant].[agGrantPrincipal] agp on ag.grantpk=agp.grantpk
inner join [ORNG.Grant].[agPrincipalInvestigator] agpi on agpi.principalinvestigatorpk=agp.principalinvestigatorpk
where not exists ( select * from [Profile.Data].[Funding.Agreement] rnsfa where rnsfa.fundingagreementid=agp.grantprincipalpk)
--and ag.grantpk in ( select grantpk from  [ORNG.Grant].[agGrantPrincipal] where principalinvestigatorpk in ( select principalinvestigatorpk from [ORNG.Grant].[agPrincipalInvestigator] where name like '%cabana%'))
)


GO


INSERT INTO [Profile.Data].[Funding.Role]
           ([FundingRoleID]
           ,[PersonID]
           ,[FundingAgreementID]
           ,[RoleLabel]
           ,[RoleDescription])
     
	 (
	 select  newid() as FundingRoleID  --agpi.principalinvestigatorpk
, [UCSF.].fnGeneratePersonID(agpi.employeeid) as Personid, agp.grantprincipalpk as Fundingagreementid,'Principal Investigator' as rolelabel, '' as roledescription
from [ORNG.Grant].[agGrant]  ag 
inner join [ORNG.Grant].[agGrantPrincipal] agp on ag.grantpk=agp.grantpk
inner join [ORNG.Grant].[agPrincipalInvestigator] agpi on agpi.principalinvestigatorpk=agp.principalinvestigatorpk
where
not exists( select * from [Profile.Data].[Funding.Role] rnsfr where rnsfr.personid=[UCSF.].fnGeneratePersonID(agpi.employeeid) and rnsfr.fundingagreementid=agp.grantprincipalpk) 
--and ag.grantpk in ( select grantpk from  [ORNG.Grant].[agGrantPrincipal] where principalinvestigatorpk in ( select principalinvestigatorpk from [ORNG.Grant].[agPrincipalInvestigator] where name like '%cabana%'))
)



commit


-- to remove the filter for the Awarded Grants gadget
DECLARE @PersonFilterID int
select @PersonFilterID=PersonFilterID from [Profile.Data].[Person.Filter] where PersonFilter = 'Awarded Grants'

DELETE FROM [Profile.Import].[PersonFilterFlag] where PersonFilter = 'Awarded Grants'
DELETE FROM [Profile.Data].[Person.FilterRelationship] where PersonFilterID = @PersonFilterID
DELETE FROM [Profile.Data].[Person.Filter] where PersonFilter = 'Awarded Grants'

SELECT @PersonFilterID
