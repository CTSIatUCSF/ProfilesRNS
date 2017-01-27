DECLARE @PersonFilterID int
select @PersonFilterID=PersonFilterID from [Profile.Data].[Person.Filter] where PersonFilter = 'More Info'

DELETE FROM [Profile.Import].[PersonFilterFlag] where PersonFilter = 'More Info'
DELETE FROM [Profile.Data].[Person.FilterRelationship] where PersonFilterID = @PersonFilterID
DELETE FROM [Profile.Data].[Person.Filter] where PersonFilter = 'More Info'

SELECT @PersonFilterID