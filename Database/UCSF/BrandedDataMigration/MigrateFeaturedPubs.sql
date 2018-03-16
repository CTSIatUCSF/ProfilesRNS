

-- create table
CREATE TABLE [dbo].[featuredPubsMigration](
	oldnodeid BIGINT NULL,
	newnodeid BIGINT NULL,
	label [nvarchar](500) NULL,
	pmid [nvarchar](500) NULL,
	orngnodeid BIGINT NULL,
	keyname nvarchar(255) NULL
) ON [PRIMARY]

GO

--  UCSF load up pub nodeis
insert [featuredPubsMigration] (oldnodeid, label, pmid)
select t.subject nodeid , n.value label, n2.value pmid from [RDF.].Triple t
join [profiles_ucsf].[RDF.].Triple t3 on t.subject = t3.subject and t3.predicate =  [profiles_ucsf].[RDF.].fnURI2NOdeID('http://www.w3.org/2000/01/rdf-schema#label')
join [profiles_ucsf].[RDF.].Node n on n.nodeid = t3.object 
left outer join [profiles_ucsf].[RDF.].Triple t2 on t.subject = t2.subject and t2.predicate =  [profiles_ucsf].[RDF.].fnURI2NOdeID('http://purl.org/ontology/bibo/pmid') 
left outer join [profiles_ucsf].[RDF.].Node n2 on n2.nodeid = t2.object
 where t.object = [profiles_ucsf].[RDF.].fnURI2NOdeID('http://vivoweb.org/ontology/core#InformationResource') and t.Predicate = [profiles_ucsf].[RDF.].fnURI2NOdeID('http://www.w3.org/1999/02/22-rdf-syntax-ns#type')