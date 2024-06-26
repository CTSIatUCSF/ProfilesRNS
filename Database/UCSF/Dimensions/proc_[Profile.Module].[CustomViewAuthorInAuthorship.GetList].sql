/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2016 (13.0.5081)
    Source Database Engine Edition : Microsoft SQL Server Enterprise Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2017
    Target Database Engine Edition : Microsoft SQL Server Standard Edition
    Target Database Engine Type : Standalone SQL Server
*/

USE [ProfilesRNS_Dev]
GO
/****** Object:  StoredProcedure [Profile.Module].[CustomViewAuthorInAuthorship.GetList]    Script Date: 6/5/2019 11:30:59 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






ALTER PROCEDURE  [Profile.Module].[CustomViewAuthorInAuthorship.GetList]
	@NodeID bigint = NULL,
	@SessionID uniqueidentifier = NULL
AS
BEGIN

	DECLARE @SecurityGroupID BIGINT, @HasSpecialViewAccess BIT
	EXEC [RDF.Security].GetSessionSecurityGroup @SessionID, @SecurityGroupID OUTPUT, @HasSpecialViewAccess OUTPUT
	CREATE TABLE #SecurityGroupNodes (SecurityGroupNode BIGINT PRIMARY KEY)
	INSERT INTO #SecurityGroupNodes (SecurityGroupNode) EXEC [RDF.Security].GetSessionSecurityGroupNodes @SessionID, @NodeID


	declare @AuthorInAuthorship bigint
	select @AuthorInAuthorship = [RDF.].fnURI2NodeID('http://vivoweb.org/ontology/core#authorInAuthorship') 
	declare @LinkedInformationResource bigint
	select @LinkedInformationResource = [RDF.].fnURI2NodeID('http://vivoweb.org/ontology/core#linkedInformationResource') 


	select i.NodeID, p.EntityID, i.Value rdf_about, p.EntityName rdfs_label, 
		p.Authors authors, p.Reference prns_informationResourceReference, p.Source,
		p.EntityDate prns_publicationDate,
		year(p.EntityDate) prns_year, p.pmid bibo_pmid, p.pmcid vivo_pmcid, p.mpid prns_mpid, p.URL vivo_webpage, c.AuthorXML authorXML
	from [RDF.].[Triple] t
		inner join [RDF.].[Node] a
			on t.subject = @NodeID and t.predicate = @AuthorInAuthorship
				and t.object = a.NodeID
				and ((t.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (t.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (t.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
				and ((a.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (a.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (a.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
		inner join [RDF.].[Node] i
			on t.object = i.NodeID
				and ((i.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (i.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (i.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
		inner join [RDF.Stage].[InternalNodeMap] m
			on i.NodeID = m.NodeID
		inner join [Profile.Data].[Publication.Entity.Authorship] e
			on m.InternalID = e.EntityID
		inner join [Profile.Data].[Publication.Entity.InformationResource] p
			on e.InformationResourceID = p.EntityID
		left outer join [UCSF.CTSASearch].[Publication.PubMed.CoAuthorXML] c
			on p.pmid = c.PMID
	order by p.EntityDate desc

/*
	select i.NodeID, p.EntityID, i.Value rdf_about, p.EntityName rdfs_label, 
		p.Reference prns_informationResourceReference, p.EntityDate prns_publicationDate,
		year(p.EntityDate) prns_year, p.pmid bibo_pmid, p.mpid prns_mpid
	from [RDF.].[Triple] t
		inner join [RDF.].[Triple] v
			on t.subject = @NodeID and t.predicate = @AuthorInAuthorship
			and t.object = v.subject and v.predicate = @LinkedInformationResource
			and ((t.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (t.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (t.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
			and ((v.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (v.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (v.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
		inner join [RDF.].[Node] a
			on t.object = a.NodeID
			and ((a.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (a.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (a.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
		inner join [RDF.].[Node] i
			on v.object = i.NodeID
			and ((i.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (i.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (i.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
		inner join [RDF.Stage].[InternalNodeMap] m
			on i.NodeID = m.NodeID
		inner join [Profile.Data].[Publication.Entity.InformationResource] p
			on m.InternalID = p.EntityID
	order by p.EntityDate desc
*/

END

