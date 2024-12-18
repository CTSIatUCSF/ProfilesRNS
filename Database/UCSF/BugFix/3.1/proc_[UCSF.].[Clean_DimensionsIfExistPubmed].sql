USE [profilesRNS]
GO
/****** Object:  StoredProcedure [UCSF.].[Clean_DimensionsIfExistPubmed]    Script Date: 10/17/2021 7:03:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [UCSF.].[Clean_DimensionsIfExistPubmed] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/* Updating PublicationAddition table with newly added PubMed publications */
Exec [UCSF.].[GetDoiFromPubmed]

/* Looking for Dimensions publication adeed by Disambiguation from PubMed */
 
IF OBJECT_ID('tempdb..#dupDim') IS NOT NULL drop table #dupDim
select negpa.pmid as negpmid,negpa.doi,pa.pmid 
into #dupDim
from [UCSF.].[PublicationAdditions] negpa
join [UCSF.].[PublicationAdditions] pa on pa.doi=negpa.doi and pa.pmid>0
where negpa.doi in (
select doi from [UCSF.].[PublicationAdditions]
group by DOI
having count(*)>1 
) 
and negpa.pmid<0

IF OBJECT_ID('tempdb..#dupDim4Delete') IS NOT NULL drop table #dupDim4Delete
select prettyURL as 'profile',inc.personid,a.removed,inc.pmid,a.DOI,reference
into #dupDim4Delete
from [Profile.Data].[Publication.Person.Include] inc
join (
select personid,inc.pmid 'removed',doi,#dupDim.pmid 
from [Profile.Data].[Publication.Person.Include] inc
join #dupDim on inc.pmid=#dupDim.negpmid
where inc.pmid in (
	select negpmid  from #dupDim
) 
)a on a.personid=inc.personid and a.pmid=inc.pmid
join [Profile.Data].[Person] p on p.personid=inc.personid
join [UCSF.].[NameAdditions] na on na.internalusername=p.internalusername
join [Profile.Data].[Publication.Entity.InformationResource] ir on ir.pmid=inc.pmid
order by p.internalusername,inc.pmid


select * from #dupDim4Delete

IF OBJECT_ID('tempdb..#dupDimSQL') IS NOT NULL drop table #dupDimSQL
CREATE TABLE #dupDimSQL (
		i INT IDENTITY(0,1) PRIMARY KEY,
		s NVARCHAR(MAX)
	)
insert into #dupDimSQL
select 'delete from [Profile.Data].[Publication.Person.Include] where '+
	'personid='+cast( personid as varchar)+ ' and pmid='+cast(removed as varchar) + '/* deleted '+cast(removed as varchar) +' due to '+profile+' has PubMed ID='+cast(pmid as varchar)+'*/'
from #dupDim4Delete

	DECLARE @s NVARCHAR(MAX)
	WHILE EXISTS (SELECT * FROM #dupDimSQL)
	BEGIN
		SELECT @s = s
			FROM #dupDimSQL
			WHERE i = (SELECT MIN(i) FROM #dupDimSQL)
		print @s
		EXEC sp_executesql @s
		DELETE
			FROM #dupDimSQL
			WHERE i = (SELECT MIN(i) FROM #dupDimSQL)
	END

	
END
