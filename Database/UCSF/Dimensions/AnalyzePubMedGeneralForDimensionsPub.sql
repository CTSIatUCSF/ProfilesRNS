/****** Script for SelectTopNRows command from SSMS  ******/
select * from 
(SELECT g.pmid,g.journalTitle,[UCSF.].[fn_GetDimensionsPubField] (pd.[Data],'type') pubType,
case 
	when [UCSF.].[fn_GetDimensionsPubField] (pd.[Data],'type')='proceeding' and g.journalTitle='' then [UCSF.].[fn_GetDimensionsPubField] (pd.[Data],'proceedings_title')
	when [UCSF.].[fn_GetDimensionsPubField] (pd.[Data],'type')='chapter' and g.journalTitle='' then [UCSF.].[fn_GetDimensionsPubField] (pd.[Data],'book_title')
end NewSourceTitle,
	pd.*
  FROM [profilesRNS].[Profile.Data].[Publication.PubMed.General] g
  JOIN [Profile.Data].[Publication.Import.PubData] pd on pd.ImportPubID=g.pmid

) a
  where JournalTitle='' and NewSourceTitle is NULL --and pubtype not in ('chapter','proceeding') --
  order by pubType


--  select [UCSF.].[fn_GetDimensionsPubField] (pd.[Data],'proceedings_title')
 --FROM [profilesRNS].[Profile.Data].[Publication.PubMed.General] g
  --JOIN [Profile.Data].[Publication.Import.PubData] pd on pd.ImportPubID=g.pmid
   --where pmid= -66168 