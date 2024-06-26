
select * from [Profile.Data].Person where LastName like 'miercke'

-- Fix those URL's!!
-- real stuff, delete person first
select * from [Profile.Data].Person where UserID <> CAST(left(internalusername,8) as int) + 2569307;

delete from [RDF.].Node where NodeId in (select NodeID from [RDF.Stage].InternalNodeMap where [Class] = 'http://xmlns.com/foaf/0.1/Person'
and InternalID in (select personid from [Profile.Data].Person where UserID <> CAST(left(internalusername,8) as int) + 2569307));

delete from [RDF.].Triple where [Subject] in (select NodeID from [RDF.Stage].InternalNodeMap where [Class] = 'http://xmlns.com/foaf/0.1/Person'
and InternalID in (select personid from [Profile.Data].Person where UserID <> CAST(left(internalusername,8) as int) + 2569307));

delete from [RDF.Stage].InternalNodeMap where [Class] = 'http://xmlns.com/foaf/0.1/Person'
and InternalID in (select personid from [Profile.Data].Person where UserID <> CAST(left(internalusername,8) as int) + 2569307);

delete from [Profile.Data].[Publication.Person.Include] where personid in (select personid from [Profile.Data].Person where UserID <> CAST(left(internalusername,8) as int) + 2569307);

delete from [Profile.Data].[Person.Affiliation] where PersonID  in (select personid from [Profile.Data].Person where UserID <> CAST(left(internalusername,8) as int) + 2569307);

delete from [Profile.Data].[Person.FilterRelationship] where PersonID  in (select personid from [Profile.Data].Person where UserID <> CAST(left(internalusername,8) as int) + 2569307);

delete from [Profile.Data].Person where UserID <> CAST(left(internalusername,8) as int) + 2569307;

-- now delete user
select * from [User.Account].[User] where UserID <> CAST(left(internalusername,8) as int) + 2569307;

delete from [RDF.].Node where NodeId in (select NodeID from [RDF.Stage].InternalNodeMap where [Class] = 'http://profiles.catalyst.harvard.edu/ontology/prns#User'
and InternalID in (select userid from [User.Account].[User] where UserID <> CAST(left(internalusername,8) as int) + 2569307));

delete from [RDF.].Triple where [Subject] in (select NodeID from [RDF.Stage].InternalNodeMap where [Class] = 'http://profiles.catalyst.harvard.edu/ontology/prns#User'
and InternalID in (select userid from [User.Account].[User]  where UserID <> CAST(left(internalusername,8) as int) + 2569307));

delete from [RDF.Stage].InternalNodeMap where [Class] = 'http://profiles.catalyst.harvard.edu/ontology/prns#User'
and InternalID in (select userid from [User.Account].[User]  where UserID <> CAST(left(internalusername,8) as int) + 2569307);

delete from [User.Session].[Session] where userid in  (select userid from [User.Account].[User]  where UserID <> CAST(left(internalusername,8) as int) + 2569307);

delete from [User.Account].[User] where UserID <> CAST(left(internalusername,8) as int) + 2569307;

-- Fix those URL's!!
-- now run first part of weekely
-- skip step 7!