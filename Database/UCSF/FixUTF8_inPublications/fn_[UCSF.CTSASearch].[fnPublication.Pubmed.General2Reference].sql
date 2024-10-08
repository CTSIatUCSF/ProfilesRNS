/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2016 (13.0.5102)
    Source Database Engine Edition : Microsoft SQL Server Enterprise Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2017
    Target Database Engine Edition : Microsoft SQL Server Standard Edition
    Target Database Engine Type : Standalone SQL Server
*/

USE [ProfilesRNS]
GO
/****** Object:  UserDefinedFunction [UCSF.CTSASearch].[fnPublication.Pubmed.General2Reference]    Script Date: 10/14/2020 11:26:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER function [UCSF.CTSASearch].[fnPublication.Pubmed.General2Reference]	(
	@pmid int,
	@ArticleDay varchar(10),
	@ArticleMonth varchar(10),
	@ArticleYear varchar(10),
	@ArticleTitle nvarchar(4000),
	@Issue varchar(255),
	@JournalDay varchar(50),
	@JournalMonth varchar(50),
	@JournalYear varchar(50),
	@MedlineDate varchar(255),
	@MedlinePgn varchar(255),
	@MedlineTA varchar(1000),
	@Volume varchar(255),
	@encode_html bit=0
)

RETURNS NVARCHAR(MAX) 
AS 
BEGIN

	DECLARE @Reference NVARCHAR(MAX)

	SET @Reference = --(case when right(@Authors,5) = 'et al' then @Authors+'. '
					 --			when @AuthorListCompleteYN = 'N' then @Authors+', et al. '
					 --			when @Authors <> '' then @Authors+'. '
					 --			else '' end) +
					 CASE WHEN @encode_html=1 THEN '<a href="'+'http'+'://www.ncbi.nlm.nih.gov/pubmed/'+cast(@pmid as varchar(50))+'" target="_blank">'+coalesce(@ArticleTitle,'')+'</a>' + ' '
								 ELSE coalesce(@ArticleTitle,'') + ' '
						END
					+ coalesce(@MedlineTA,'') + '. '
					+ (case when @JournalYear is not null then rtrim(@JournalYear + ' ' + coalesce(@JournalMonth,'') + ' ' + coalesce(@JournalDay,''))
							when @MedlineDate is not null then @MedlineDate
							when @ArticleYear is not null then rtrim(@ArticleYear + ' ' + coalesce(@ArticleMonth,'') + ' ' + coalesce(@ArticleDay,''))
						else '' end)
					+ (case when coalesce(@JournalYear,@MedlineDate,@ArticleYear) is not null
								and (coalesce(@Volume,'')+coalesce(@Issue,'')+coalesce(@MedlinePgn,'') <> '')
							then '; ' else '' end)
					+ coalesce(@Volume,'')
					+ (case when coalesce(@Issue,'') <> '' then '('+@Issue+')' else '' end)
					+ (case when (coalesce(@MedlinePgn,'') <> '') and (coalesce(@Volume,'')+coalesce(@Issue,'') <> '') then ':' else '' end)
					+ coalesce(@MedlinePgn,'')
					+ '.'

	RETURN @Reference

END

