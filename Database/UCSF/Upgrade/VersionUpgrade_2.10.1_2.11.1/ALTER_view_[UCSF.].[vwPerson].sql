USE [ProfilesRNS_Dev]
GO

ALTER view [UCSF.].[vwPerson]
as
SELECT p.[PersonID]
      ,p.[UserID]
      ,n.nodeid
      ,na.PrettyURL
      ,p.[FirstName]
      ,isnull(na.[PublishingFirst], isnull(na.[GivenName], p.[FirstName])) [PublishingFirst]
	  ,isnull(na.[PublishingLast], isnull(na.CleanLast, p.[LastName])) [PublishingLast]
      ,p.[LastName]
      ,p.[MiddleName]
      ,p.[DisplayName]
      ,p.[Suffix]
      ,p.[IsActive]
      ,p.[EmailAddr]
      ,p.[Phone]
      ,p.[Fax]
      ,p.[AddressLine1]
      ,p.[AddressLine2]
      ,p.[AddressLine3]
      ,p.[AddressLine4]
      ,p.[City]
      ,p.[State]
      ,p.[Zip]
      ,p.[Building]
      ,p.[Floor]
      ,p.[Room]
      ,p.[AddressString]
      ,p.[Latitude]
      ,p.[Longitude]
      ,p.[GeoScore]
      ,p.[FacultyRankID]
      ,p.[InternalUsername]
      ,p.[Visible]
	  ,i.InstitutionAbbreviation
  FROM [Profile.Data].[Person] p 
	JOIN [Profile.Data].[Person.Affiliation] a on p.PersonID = a.PersonID and a.IsPrimary = 1
	JOIN [Profile.Data].[Organization.Institution] i on a.InstitutionID = i.InstitutionID
	JOIN [UCSF.].[NameAdditions] na on na.internalusername = p.internalusername
	JOIN [RDF.Stage].internalnodemap n on n.internalid = p.personId AND n.[class] = 'http://xmlns.com/foaf/0.1/Person' 

GO





