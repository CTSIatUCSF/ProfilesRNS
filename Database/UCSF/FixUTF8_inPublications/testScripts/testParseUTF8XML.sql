exec [Profile.Data].[Publication.Pubmed.ParsePubMedXML] 29128334;
select substring(ArticleTitle,90,50) FROM  [Profile.Data].[Publication.PubMed.General]
where pmid=29128334
