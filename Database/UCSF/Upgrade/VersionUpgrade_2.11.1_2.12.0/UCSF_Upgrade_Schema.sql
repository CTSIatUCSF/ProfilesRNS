PRINT N'Altering [Ontology.].[AddProperty]...';


GO
ALTER PROCEDURE [Ontology.].[AddProperty]
	@OWL nvarchar(100),
	@PropertyURI varchar(400),
	@PropertyName varchar(max),
	@ObjectType bit,
	@PropertyGroupURI varchar(400) = null,
	@SortOrder int = null,
	@ClassURI varchar(400) = null,
	@NetworkPropertyURI varchar(400) = null,
	@IsDetail bit = null,
	@Limit int = null,
	@IncludeDescription bit = null,
	@IncludeNetwork bit = null,
	@SearchWeight float = null,
	@CustomDisplay bit = null,
	@CustomEdit bit = null,
	@ViewSecurityGroup bigint = null,
	@EditSecurityGroup bigint = null,
	@EditPermissionsSecurityGroup bigint = null,
	@EditExistingSecurityGroup bigint = null,
	@EditAddNewSecurityGroup bigint = null,
	@EditAddExistingSecurityGroup bigint = null,
	@EditDeleteSecurityGroup bigint = null,
	@MinCardinality int = null,
	@MaxCardinality int = null,
	@CustomEditModule xml = null,
	@ReSortClassProperty bit = 1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	---------------------------------------------------
	-- [Ontology.Import].[Triple]
	---------------------------------------------------

	DECLARE @LoadRDF BIT
	SELECT @LoadRDF = 0

	-- Get Graph
	DECLARE @Graph BIGINT
	SELECT @Graph = (SELECT Graph FROM [Ontology.Import].[OWL] WHERE Name = @OWL)

	-- Insert Type record
	IF NOT EXISTS (SELECT *
					FROM [Ontology.Import].[Triple]
					WHERE OWL = @OWL and Subject = @PropertyURI and Predicate = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type')
	BEGIN
		INSERT INTO [Ontology.Import].[Triple] (OWL, Graph, Subject, Predicate, Object)
			SELECT @OWL, @Graph, @PropertyURI,
				'http://www.w3.org/1999/02/22-rdf-syntax-ns#type',
				(CASE WHEN @ObjectType = 1 THEN 'http://www.w3.org/2002/07/owl#DatatypeProperty'
						ELSE 'http://www.w3.org/2002/07/owl#ObjectProperty' END)
		SELECT @LoadRDF = 1
	END
	
	-- Insert Label record
	IF NOT EXISTS (SELECT *
					FROM [Ontology.Import].[Triple]
					WHERE OWL = @OWL and Subject = @PropertyURI and Predicate = 'http://www.w3.org/2000/01/rdf-schema#label')
	BEGIN
		INSERT INTO [Ontology.Import].[Triple] (OWL, Graph, Subject, Predicate, Object)
			SELECT @OWL, @Graph, @PropertyURI,
				'http://www.w3.org/2000/01/rdf-schema#label',
				@PropertyName
		SELECT @LoadRDF = 1
	END

	-- Load RDF
	IF @LoadRDF = 1
	BEGIN
		EXEC [RDF.Stage].[LoadTriplesFromOntology] @OWL = @OWL, @Truncate = 1
		EXEC [RDF.Stage].[ProcessTriples]
	END
	
	---------------------------------------------------
	-- [Ontology.].[PropertyGroupProperty]
	---------------------------------------------------

	IF NOT EXISTS (SELECT * FROM [Ontology.].PropertyGroupProperty WHERE PropertyURI = @PropertyURI)
	BEGIN
	
		-- Validate the PropertyGroupURI
		SELECT @PropertyGroupURI = IsNull((SELECT TOP 1 PropertyGroupURI 
											FROM [Ontology.].PropertyGroup
											WHERE PropertyGroupURI = @PropertyGroupURI
												AND @PropertyGroupURI IS NOT NULL
											),'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupOverview')
		
		-- Validate the SortOrder
		DECLARE @MaxSortOrder INT
		SELECT @MaxSortOrder = IsNull((SELECT MAX(SortOrder)
										FROM [Ontology.].PropertyGroupProperty
										WHERE PropertyGroupURI = @PropertyGroupURI),0)
		SELECT @SortOrder = (CASE WHEN @SortOrder IS NULL THEN @MaxSortOrder+1
									WHEN @SortOrder > @MaxSortOrder THEN @MaxSortOrder+1
									ELSE @SortOrder END)

		-- Shift SortOrder of existing records
		UPDATE [Ontology.].PropertyGroupProperty
			SET SortOrder = SortOrder + 1
			WHERE PropertyGroupURI = @PropertyGroupURI AND SortOrder >= @SortOrder
		
		-- Insert new property
		INSERT INTO [Ontology.].PropertyGroupProperty (PropertyGroupURI, PropertyURI, SortOrder, _NumberOfNodes)
			SELECT @PropertyGroupURI, @PropertyURI, @SortOrder, 0

	END

	---------------------------------------------------
	-- [Ontology.].[ClassProperty]
	---------------------------------------------------

	IF (@ClassURI IS NOT NULL) AND NOT EXISTS (
		SELECT *
		FROM [Ontology.].[ClassProperty]
		WHERE Class = @ClassURI AND Property = @PropertyURI
			AND ( (NetworkProperty IS NULL AND @NetworkPropertyURI IS NULL) OR (NetworkProperty = @NetworkPropertyURI) )
	)
	BEGIN

		-- Get the ClassPropertyID	
		DECLARE @ClassPropertyID INT
		SELECT @ClassPropertyID = IsNull((SELECT MAX(ClassPropertyID)
											FROM [Ontology.].ClassProperty),0)+1
		-- Insert the new property
		INSERT INTO [Ontology.].[ClassProperty] (
				ClassPropertyID,
				Class, NetworkProperty, Property,
				IsDetail, Limit, IncludeDescription, IncludeNetwork, SearchWeight,
				CustomDisplay, CustomEdit, ViewSecurityGroup,
				EditSecurityGroup, EditPermissionsSecurityGroup, EditExistingSecurityGroup, EditAddNewSecurityGroup, EditAddExistingSecurityGroup, EditDeleteSecurityGroup,
				MinCardinality, MaxCardinality, CustomEditModule,
				_NumberOfNodes, _NumberOfTriples		
			)
			SELECT	@ClassPropertyID,
					@ClassURI, @NetworkPropertyURI, @PropertyURI,
					IsNull(@IsDetail,1), @Limit, IsNull(@IncludeDescription,0), IsNull(@IncludeNetwork,0),
					IsNull(@SearchWeight,(CASE WHEN @ObjectType = 0 THEN 0 ELSE 0.5 END)),
					IsNull(@CustomDisplay,0), IsNull(@CustomEdit,0), IsNull(@ViewSecurityGroup,-1),
					IsNull(@EditSecurityGroup,-40),
					Coalesce(@EditPermissionsSecurityGroup,@EditSecurityGroup,-40),
					Coalesce(@EditExistingSecurityGroup,@EditSecurityGroup,-40),
					Coalesce(@EditAddNewSecurityGroup,@EditSecurityGroup,-40),
					Coalesce(@EditAddExistingSecurityGroup,@EditSecurityGroup,-40),
					Coalesce(@EditDeleteSecurityGroup,@EditSecurityGroup,-40),
					IsNull(@MinCardinality,0),
					@MaxCardinality,
					@CustomEditModule,
					0, 0

		-- Re-sort the table
		IF @ReSortClassProperty = 1
		BEGIN
			update x
				set x.ClassPropertyID = y.k
				from [Ontology.].ClassProperty x, (
					select *, row_number() over (order by (case when NetworkProperty is null then 0 else 1 end), Class, NetworkProperty, IsDetail, IncludeNetwork, Property) k
						from [Ontology.].ClassProperty
				) y
				where x.Class = y.Class and x.Property = y.Property
					and ((x.NetworkProperty is null and y.NetworkProperty is null) or (x.NetworkProperty = y.NetworkProperty))

					
			update x 
				set x._ClassPropertyID = b.ClassPropertyID 
				from [Ontology.].ClassPropertyCustom x join [Ontology.].ClassProperty b
					on x.Class=b.Class and x.Property=b.Property
					and ((x.NetworkProperty is null and b.NetworkProperty is null) or (x.NetworkProperty = b.NetworkProperty))
		END
	END

	---------------------------------------------------
	-- Update Derived Fields
	---------------------------------------------------

	EXEC [Ontology.].UpdateDerivedFields
	
	
	/*
	
	-- Example
	exec [Ontology.].AddProperty
		@OWL = 'PRNS_1.0',
		@PropertyURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#emailEncrypted',
		@PropertyName = 'email encrypted',
		@ObjectType = 1,
		@PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupAddress',
		@SortOrder = 20,
		@ClassURI = 'http://xmlns.com/foaf/0.1/Person',
		@NetworkPropertyURI = null,
		@IsDetail = 0,
		@SearchWeight = 0,
		@CustomDisplay = 1,
		@CustomEdit = 1

	*/
	
END
GO
PRINT N'Altering [Profile.Module].[CustomViewAuthorInAuthorship.GetGroupList]...';


GO
ALTER PROCEDURE [Profile.Module].[CustomViewAuthorInAuthorship.GetGroupList]
	@NodeID bigint = NULL,
	@SessionID uniqueidentifier = NULL
AS
BEGIN

	DECLARE @SecurityGroupID BIGINT, @HasSpecialViewAccess BIT
	EXEC [RDF.Security].GetSessionSecurityGroup @SessionID, @SecurityGroupID OUTPUT, @HasSpecialViewAccess OUTPUT
	CREATE TABLE #SecurityGroupNodes (SecurityGroupNode BIGINT PRIMARY KEY)
	INSERT INTO #SecurityGroupNodes (SecurityGroupNode) EXEC [RDF.Security].GetSessionSecurityGroupNodes @SessionID, @NodeID


	declare @AssociatedInformationResource bigint
	select @AssociatedInformationResource = [RDF.].fnURI2NodeID('http://profiles.catalyst.harvard.edu/ontology/prns#associatedInformationResource') 


	select i.NodeID, p.EntityID, i.Value rdf_about, p.EntityName rdfs_label, p.Authors authors,
		p.Reference prns_informationResourceReference, p.EntityDate prns_publicationDate,
		year(p.EntityDate) prns_year, p.pmid bibo_pmid, p.pmcid vivo_pmcid, p.mpid prns_mpid, p.URL vivo_webpage,  c.AuthorXML authorXML,
		isnull(b.PMCCitations, -1) as PMCCitations, isnull(Fields, '') as Fields, isnull(TranslationHumans , 0) as TranslationHumans, isnull(TranslationAnimals , 0) as TranslationAnimals, 
		isnull(TranslationCells , 0) as TranslationCells, isnull(TranslationPublicHealth , 0) as TranslationPublicHealth, isnull(TranslationClinicalTrial , 0) as TranslationClinicalTrial
	from [RDF.].[Triple] t
		inner join [RDF.].[Node] a
			on t.subject = @NodeID and t.predicate = @AssociatedInformationResource
				and t.object = a.NodeID
				and ((t.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (t.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (t.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
				and ((a.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (a.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (a.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
		inner join [RDF.].[Node] i
			on t.object = i.NodeID
				and ((i.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (i.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (i.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
		inner join [RDF.Stage].[InternalNodeMap] m
			on i.NodeID = m.NodeID
		inner join [Profile.Data].[Publication.Entity.InformationResource] p
			on m.InternalID = p.EntityID
		left join [Profile.Data].[Publication.Pubmed.Bibliometrics] b on p.PMID = b.PMID
		left outer join [UCSF.CTSASearch].[Publication.PubMed.CoAuthorXML] c
			on p.pmid = c.PMID	order by p.EntityDate desc
END
GO
PRINT N'Altering [Profile.Module].[CustomViewAuthorInAuthorship.GetList]...';


GO
ALTER PROCEDURE [Profile.Module].[CustomViewAuthorInAuthorship.GetList]
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
		p.Authors authors, p.Reference prns_informationResourceReference,  p.Source, p.EntityDate prns_publicationDate,
		year(p.EntityDate) prns_year, p.pmid bibo_pmid, p.pmcid vivo_pmcid, p.mpid prns_mpid, p.URL vivo_webpage, c.AuthorXML authorXML,
		isnull(b.PMCCitations, -1) as PMCCitations, isnull(Fields, '') as Fields, isnull(TranslationHumans , 0) as TranslationHumans, isnull(TranslationAnimals , 0) as TranslationAnimals, 
		isnull(TranslationCells , 0) as TranslationCells, isnull(TranslationPublicHealth , 0) as TranslationPublicHealth, isnull(TranslationClinicalTrial , 0) as TranslationClinicalTrial
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
		left join [Profile.Data].[Publication.Pubmed.Bibliometrics] b on p.PMID = b.PMID
		left outer join [UCSF.CTSASearch].[Publication.PubMed.CoAuthorXML] c
			on p.pmid = c.PMID
	order by p.EntityDate desc

END
GO
PRINT N'Update complete.';


GO
