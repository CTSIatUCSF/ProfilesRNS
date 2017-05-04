/*

Run this script to pull data from $(ProfilesSourceDB) into the DB where you are running this scriot


*/

/********** photos ****************************************************************************************/
--- UCSF
INSERT INTO [Profile.Data].[Person.Photo]
           ([PersonID]
           ,[Photo]
           ,[PhotoLink])
SELECT d.PersonID, ph.Photo, ph.PhotoLink FROM [Profile.Data].[Person] d join [profiles_ucsf].[Profile.Data].[Person] s on d.internalusername = SUBSTRING(s.InternalUserName, 3, 6) + '@ucsf.edu'
JOIN [profiles_ucsf].[Profile.Data].[Person.Photo] ph on ph.PersonID = s.PersonID

--- UCSD
INSERT INTO [Profile.Data].[Person.Photo]
           ([PersonID]
           ,[Photo]
           ,[PhotoLink])
SELECT d.PersonID, ph.Photo, ph.PhotoLink FROM [Profile.Data].[Person] d join [profiles_ucsd].[Profile.Data].[Person] s on d.internalusername =  cast(cast(s.InternalUserName as Int) as varchar) + '@ucsd.edu'
JOIN [profiles_ucsd].[Profile.Data].[Person.Photo] ph on ph.PersonID = s.PersonID


-- select * from [RDF.].Triple where predicate = [RDF.].fnURI2NodeID('http://profiles.catalyst.harvard.edu/ontology/prns#mainImage')

/************** Add to RDF *************************/
DECLARE @PersonID INT
DECLARE @NodeID BIGINT
DECLARE @URI VARCHAR(400)
DECLARE @URINodeID BIGINT
WHILE EXISTS (SELECT * FROM [Profile.Data].[vwPerson.Photo] WHERE PersonNodeID NOT IN 
(SELECT Subject FROM [RDF.].Triple where predicate = [RDF.].fnURI2NodeID('http://profiles.catalyst.harvard.edu/ontology/prns#mainImage')))
BEGIN 

	SELECT TOP 1 @PersonID = PersonID FROM [Profile.Data].[vwPerson.Photo] WHERE PersonNodeID NOT IN 
(SELECT Subject FROM [RDF.].Triple where predicate = [RDF.].fnURI2NodeID('http://profiles.catalyst.harvard.edu/ontology/prns#mainImage'))

	SELECT @NodeID = PersonNodeID, @URI = URI
		FROM [Profile.Data].[vwPerson.Photo]
		WHERE PersonID = @PersonID
	IF (@NodeID IS NOT NULL AND @URI IS NOT NULL)
		BEGIN
			EXEC [RDF.].[GetStoreNode] @Value = @URI, @NodeID = @URINodeID OUTPUT
			IF (@URINodeID IS NOT NULL)
				EXEC [RDF.].[GetStoreTriple]	@SubjectID = @NodeID,
												@PredicateURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#mainImage',
												@ObjectID = @URINodeID
		END
 END

 