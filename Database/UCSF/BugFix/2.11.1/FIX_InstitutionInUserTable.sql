/****** Script for SelectTopNRows command from SSMS  ******/
SELECT distinct Institution FROM [User.Account].[User]

select * from [User.Account].[User] u JOIN [Profile.Data].[Organization.Institution] i on u.Institution = i.InstitutionAbbreviation;
update u set u.Institution = i.InstitutionName FROM [User.Account].[User] u JOIN [Profile.Data].[Organization.Institution] i on u.Institution = i.InstitutionAbbreviation;
