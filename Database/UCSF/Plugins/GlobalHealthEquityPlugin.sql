INSERT [Profile.Module].[GenericRDF.Plugins] ([Name], [EnabledForPerson], [EnabledForGroup], [Label], [PropertyGroupURI], [CustomDisplayModule], [CustomEditModule], [CustomDisplayModuleXML], [CustomEditModuleXML]) VALUES (N'GlobalHealthEquity', 1, 1, N'Global Health Equity', N'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupFeaturedContent', N'GlobalHealthEquity', N'EditGlobalHealthEquity', NULL, NULL)

EXEC [Profile.Module].[GenericRDF.AddUpdateOntology] @pluginName='GlobalHealthEquity'

--- Add fake data to Eric
DECLARE @NodeID bigint;
select @NodeID = nodeid FROM [UCSF.].[vwPerson] where InternalUsername = '569307@ucsf.edu';
SELECT @nodeID;

exec [Profile.Module].[GenericRDF.AddEditPluginData] @Name='GlobalHealthEquity', @NodeID=@NodeID, 
	@Data='{"interests": ["urban health", "substance abuse and mental health", "infectious diseases", "care delivery", "ebola"],"locations": ["Congo", "Liberia", "Africa"]}', 
	@SearchableData='Global Health, urban health, substance abuse and mental health, infectious diseases, care delivery, ebola​, Congo, Liberia, Africa​';


exec [RDF.].GetDataRDF @subject=225751;

-- create table for seed data
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [UCSF.].[GlobalHealthEquitySeedData](
	[internalusername] [nvarchar](50) NULL,
	[jsondata] [nvarchar](max) NULL,
	[searchabledata] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

-- After loading data run this and execute results, but first clean up the 4 instances of womens's health to be women''s health

  select 'exec [Profile.Module].[GenericRDF.AddEditPluginData] @Name=''GlobalHealthEquity'', @NodeID=' + cast(v.nodeid as varchar) +
	', @Data=''' + jsondata + ''', @SearchableData=''' + searchabledata + ''';' FROM [UCSF.].[GlobalHealthEquitySeedData] s 
	JOIN [UCSF.].vwPerson v on v.InternalUsername = s.internalusername;
	

-- EXCEL forumla example to format data 
--=SUBSTITUTE(CONCATENATE("'{""interests"":[","""",TEXTJOIN(""",""", TRUE, E1:N1),"""],""locations"": [""",TEXTJOIN(""",""", TRUE, O1:X1),"""],""centers"": [""",TEXTJOIN(""",""", TRUE, B1:C1),"""]}'"),"""""","")
--'{"interests":["Oncology","Child or adolescent health","Education"],"locations": ["China","Ethiopia","India","Japan"],"centers": ["IGHS - Faculty Affiliate Program"]}'

-- for searchable data 
--=SUBSTITUTE(SUBSTITUTE(CONCATENATE("'",TEXTJOIN(", ", TRUE, E1:N1),", ", TEXTJOIN(", ", TRUE, O1:X1),", ",TEXTJOIN(", ", TRUE, B1:C1),"'"),"',","'")," , ", "")
--'Oncology, Child or adolescent health, Education, China, Ethiopia, India, Japan, IGHS - Faculty Affiliate Program'

-- for internalusername 
--=CONCATENATE("'", MID(A1, 2,6), "@ucsf.edu'")

-- for insert
--=concatenate("INSERT [UCSF.].[GlobalHealthEquitySeedData] VALUES (", AA1, ",", Y1, ",", Z1, ");")
--INSERT [UCSF.].[GlobalHealthEquitySeedData] VALUES ('001640@ucsf.edu','{"interests":["Oncology","Child or adolescent health","Education"],"locations": ["China","Ethiopia","India","Japan"],"centers": ["IGHS - Faculty Affiliate Program"]}','Oncology, Child or adolescent health, Education, China, Ethiopia, India, Japan, IGHS - Faculty Affiliate Program');

--INSERT [UCSF.].[GlobalHealthEquitySeedData] VALUES ('927200@ucsf.edu','{"interests":[],"locations": [],"centers": ["IGHS - Faculty Affiliate Program"]}','IGHS - Faculty Affiliate Program';


