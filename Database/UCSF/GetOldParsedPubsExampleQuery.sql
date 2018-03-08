				SELECT d.pmid, x.ParseDT, datediff(DAY, x.ParseDT, GETDATE())
				  FROM [Profile.Data].[Publication.PubMed.Disambiguation] d
				   LEFT OUTER JOIN [Profile.Data].[Publication.PubMed.AllXML] x on d.pmid = x.pmid
				 WHERE d.pmid IS NOT NULL AND x.ParseDT is null OR datediff(DAY, x.ParseDT, GETDATE()) > 180
				 UNION   
				SELECT i.pmid, x.ParseDT,  datediff(DAY, x.ParseDT, GETDATE())
				  FROM [Profile.Data].[Publication.Person.Include] i
				   LEFT OUTER JOIN [Profile.Data].[Publication.PubMed.AllXML] x on i.pmid = x.pmid
				 WHERE i.pmid IS NOT NULL AND x.ParseDT is null OR datediff(DAY, x.ParseDT, GETDATE()) > 180--310002


select count(*) from [Profile.Data].[Publication.PubMed.General.Stage]
				