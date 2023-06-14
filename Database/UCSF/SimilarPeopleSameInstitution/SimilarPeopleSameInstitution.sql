/****** Object:  Table [Profile.Cache].[Person.SimilarPersonSameInstitution]    Script Date: 5/31/2023 10:12:08 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [Profile.Cache].[Person.SimilarPersonSameInstitution](
	[PersonID] [int] NOT NULL,
	[SimilarPersonID] [int] NOT NULL,
	[Weight] [float] NULL,
	[CoAuthor] [bit] NULL,
	[numberOfSubjectAreas] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC,
	[SimilarPersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  StoredProcedure [Profile.Cache].[Person.UpdateSimilarPersonSameInstitution]    Script Date: 5/31/2023 10:12:37 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [Profile.Cache].[Person.UpdateSimilarPersonSameInstitution]
AS
BEGIN

	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
 
	DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int,@proc VARCHAR(200),@date DATETIME,@auditid UNIQUEIDENTIFIER,@rows BIGINT 
	SELECT @proc = OBJECT_NAME(@@PROCID),@date=GETDATE() 	
	EXEC [Profile.Cache].[Process.AddAuditUpdate] @auditid=@auditid OUTPUT,@ProcessName =@proc,@ProcessStartDate=@date,@insert_new_record=1
 
	create table #cache_similar_people (personid int, similarpersonid int, weight float, coauthor bit, numberOfSubjectAreas int)
 
 
 
	-- minutes
	select c.*, a.InstitutionID into #cache_user_mesh from [Profile.Cache].[Concept.Mesh.Person] c 
		join [Profile.Data].[Person.Affiliation] a on c.PersonID = a.PersonID and a.IsPrimary = 1
	create unique clustered index idx_pm on #cache_user_mesh(personid,meshheader)
	declare @maxp int
	declare @p int
	select @maxp = max(personid) from [Profile.Cache].[Concept.Mesh.Person]
	set @p = 1
	while @p <= @maxp
	begin
		INSERT INTO #cache_similar_people(personid,similarpersonid,weight,coauthor,numberOfSubjectAreas)
			SELECT personid, similarpersonid, weight, 0 coauthor, numberOfSubjectAreas
			FROM (
				SELECT personid, similarpersonid, weight, numberOfSubjectAreas,
						row_number() over (partition by personid order by weight desc) k
				FROM (
					SELECT a.personid,
						b.personid similarpersonid,
						SUM(a.weight * b.weight) weight,
						count(*) numberOfSubjectAreas
					FROM #cache_user_mesh a inner join #cache_user_mesh b 
						ON a.meshheader = b.meshheader 
							AND a.personid <> b.personid 
							AND a.InstitutionID = b.InstitutionID
							AND a.personid between @p and @p+999
					GROUP BY a.personid, b.personid
				) t
			) t
			WHERE k <= 60
		set @p = @p + 1000
	end
 
	-- Set CoAuthor Flag
	create unique clustered index idx_ps on #cache_similar_people(personid,similarpersonid)
	select distinct a.personid a, b.personid b
		into #coauthors
		from [Profile.Data].[Publication.Person.Include] a, [Profile.Data].[Publication.Person.Include] b
		where a.pmid = b.pmid and a.personid <> b.personid
	create unique clustered index idx_ab on #coauthors(a,b)
	update t 
		set coauthor = 1
		from #cache_similar_people t, #coauthors c
		where t.personid = c.a and t.similarpersonid = c.b
 
	BEGIN TRY
		BEGIN TRAN
			truncate table [Profile.Cache].[Person.SimilarPersonSameInstitution]
			insert into [Profile.Cache].[Person.SimilarPersonSameInstitution](PersonID, SimilarPersonID, Weight, CoAuthor, numberOfSubjectAreas)
				select PersonID, SimilarPersonID, Weight, CoAuthor, numberOfSubjectAreas
				from #cache_similar_people
			select @rows = @@ROWCOUNT
		COMMIT
	END TRY
	BEGIN CATCH
		--Check success
		IF @@TRANCOUNT > 0  ROLLBACK
		SELECT @date=GETDATE()
		EXEC [Profile.Cache].[Process.AddAuditUpdate] @auditid=@auditid OUTPUT,@ProcessName =@proc,@ProcessEndDate =@date,@error = 1,@insert_new_record=0
		-- Raise an error with the details of the exception
		SELECT @ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY()
		RAISERROR(@ErrMsg, @ErrSeverity, 1)
	END CATCH
 
	SELECT @date=GETDATE()
	EXEC [Profile.Cache].[Process.AddAuditUpdate] @auditid=@auditid OUTPUT,@ProcessName =@proc,@ProcessEndDate =@date,@ProcessedRows = @rows,@insert_new_record=0
END
GO

--- Add Job to call SP
  declare @JobIDMax int
  select @JobIDMax = max(JobID) From [Framework.].[Job]
  select @JobIDMax

  UPDATE [Framework.].[Job] SET Step=3 WHERE JobGroup=8 and Step=2

  insert into [Framework.].[Job] (JobID, JobGroup, Step, IsActive, Script)
  VALUES (@JobIDMax+1, 8, 2, 1, 'EXEC [Profile.Cache].[Person.UpdateSimilarPersonSameInstitution]')

  exec [Ontology.].CleanUp @Action = 'UpdateIDs'
  GO
     
-- Add tab to Similar People page
UPDATE [Ontology.Presentation].[XML] SET PresentationXML = N'<Presentation PresentationClass="network">
  <PageOptions Columns="3" />
  <WindowName>{{{rdf:RDF[1]/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/rdf:subject/@rdf:resource]/foaf:firstName}}} {{{rdf:RDF[1]/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/rdf:subject/@rdf:resource]/foaf:lastName}}}''s related authors</WindowName>
  <PageColumns>3</PageColumns>
  <PageTitle>{{{rdf:RDF[1]/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/rdf:subject/@rdf:resource]/foaf:firstName}}} {{{rdf:RDF[1]/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/rdf:subject/@rdf:resource]/foaf:lastName}}}</PageTitle>
  <PageBackLinkName>Back to Profile</PageBackLinkName>
  <PageBackLinkURL>{{{//rdf:RDF/rdf:Description/rdf:subject/@rdf:resource}}}</PageBackLinkURL>
  <PageSubTitle>Similar People ({{{//rdf:RDF/rdf:Description/prns:numberOfConnections}}})</PageSubTitle>
  <PageDescription>Similar people share similar sets of concepts, but are not necessarily co-authors.</PageDescription>
  <PanelTabType>Default</PanelTabType>
  <PanelList>
    <Panel Type="active">
      <Module ID="MiniSearch" />
      <Module ID="MainMenu">
        <ParamList>
          <Param Name="PageType">Person</Param>
        </ParamList>
      </Module>
    </Panel>
    <Panel Type="main" TabSort="0" TabType="Default" Alias="list" Name="List">
      <Module ID="NetworkList">
        <ParamList>
          <Param Name="InfoCaption">The people in this list are ordered by decreasing similarity.     (<font color="red">*</font> These people are also co-authors.)</Param>
          <Param Name="DataURI">rdf:RDF/rdf:Description/@rdf:about</Param>
          <Param Name="BulletType">disc</Param>
          <Param Name="Columns">2</Param>
          <Param Name="NetworkListNode">rdf:RDF/rdf:Description[@rdf:about= ../rdf:Description[1]/prns:hasConnection/@rdf:resource]</Param>
          <Param Name="ItemURLText">{{{rdf:Description/rdf:object/@rdf:resource}}}</Param>
          <Param Name="ItemText" />
          <Param Name="ItemURL">{{{rdf:Description/rdf:object/@rdf:resource}}}</Param>
          <Param Name="SortBy">Weight</Param>
          <Param Name="ExpandRDFList">
            <ExpandRDFOptions ExpandPredicates="false" ClassPropertyCustomTypeID="2" />
          </Param>
        </ParamList>
      </Module>
    </Panel>
    <Panel Type="main" TabSort="1" Alias="map" Name="Map" DisplayRule="rdf:RDF/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/rdf:subject/@rdf:resource]/prns:latitude">
      <Module ID="NetworkMap">
        <ParamList>
          <Param Name="MapType">SimilarTo</Param>
        </ParamList>
      </Module>
    </Panel>
    <Panel Type="main" TabSort="3" Alias="details" Name="Details">
      <Module ID="ApplyXSLT">
        <ParamList>
          <Param Name="DataURI">rdf:RDF/rdf:Description/@rdf:about</Param>
          <Param Name="XSLTPath">~/profile/XSLT/SimilarPeopleDetail.xslt</Param>
          <Param Name="ExpandRDFList">
            <ExpandRDFOptions ExpandPredicates="false" ClassPropertyCustomTypeID="2" />
            <ExpandRDF Class="http://xmlns.com/foaf/0.1/Person" Property="http://profiles.catalyst.harvard.edu/ontology/prns#fullName" IsDetail="false" />
          </Param>
        </ParamList>
      </Module>
    </Panel>
    <Panel Type="main" TabSort="4" Alias="sameInstitution" Name="Same Institution">
      <Module ID="SimilarPeopleSameInstitution">
        <ParamList>
          <Param Name="InfoCaption">The people in this list are ordered by decreasing similarity.     (<font color="red">*</font> These people are also co-authors.)</Param>
          <Param Name="DataURI">rdf:RDF/rdf:Description/@rdf:about</Param>
          <Param Name="BulletType">disc</Param>
          <Param Name="Columns">2</Param>
          <Param Name="NetworkListNode">rdf:RDF/rdf:Description[@rdf:about= ../rdf:Description[1]/prns:hasConnection/@rdf:resource]</Param>
          <Param Name="ItemURLText">{{{rdf:Description/rdf:object/@rdf:resource}}}</Param>
          <Param Name="ItemText" />
          <Param Name="ItemURL">{{{rdf:Description/rdf:object/@rdf:resource}}}</Param>
          <Param Name="SortBy">Weight</Param>
          <Param Name="ExpandRDFList">
            <ExpandRDFOptions ExpandPredicates="false" ClassPropertyCustomTypeID="2" />
          </Param>
        </ParamList>
      </Module>
    </Panel>
    <Panel Type="passive">
      <Module ID="PassiveHeader">
        <ParamList>
          <Param Name="DataURI">rdf:RDF/rdf:Description/rdf:subject/@rdf:resource</Param>
          <Param Name="ExpandRDFList">
            <ExpandRDFOptions ExpandPredicates="false" ClassPropertyCustomTypeID="1" />
          </Param>
        </ParamList>
      </Module>
      <Module ID="PassiveList">
        <ParamList>
          <Param Name="DataURI">rdf:RDF/rdf:Description/rdf:subject/@rdf:resource</Param>
          <Param Name="ExpandRDFList">
            <ExpandRDFOptions ExpandPredicates="false" ClassPropertyCustomTypeID="1" />
          </Param>
          <Param Name="InfoCaption">Concepts</Param>
          <Param Name="TotalCount">{{{rdf:RDF/rdf:Description[rdf:predicate/@rdf:resource="http://vivoweb.org/ontology/core#hasResearchArea"][@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:hasNetwork/@rdf:resource]/prns:numberOfConnections}}}</Param>
          <Param Name="Description">Derived automatically from this person''s publications.</Param>
          <Param Name="MaxDisplay">5</Param>
          <Param Name="ListNode">/rdf:RDF[1]/rdf:Description[1]/vivo:hasResearchArea/@rdf:resource</Param>
          <Param Name="ItemURLText">{{{rdf:Description/rdfs:label}}}</Param>
          <Param Name="ItemText" />
          <Param Name="ItemURL">{{{rdf:Description/@rdf:about}}}</Param>
          <Param Name="MoreURL">{{{rdf:RDF/rdf:Description[rdf:predicate/@rdf:resource="http://vivoweb.org/ontology/core#hasResearchArea"][@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:hasNetwork/@rdf:resource]/@rdf:about}}}</Param>
          <Param Name="MoreText">See all ({{{rdf:RDF/rdf:Description[rdf:predicate/@rdf:resource="http://vivoweb.org/ontology/core#hasResearchArea"][@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:hasNetwork/@rdf:resource]/prns:numberOfConnections}}}) concept(s)</Param>
        </ParamList>
      </Module>
      <Module ID="PassiveList">
        <ParamList>
          <Param Name="DataURI">rdf:RDF/rdf:Description/rdf:subject/@rdf:resource</Param>
          <Param Name="ExpandRDFList">
            <ExpandRDFOptions ExpandPredicates="false" ClassPropertyCustomTypeID="1" />
          </Param>
          <Param Name="InfoCaption">Co-Authors</Param>
          <Param Name="TotalCount">{{{rdf:RDF/rdf:Description[rdf:predicate/@rdf:resource="http://profiles.catalyst.harvard.edu/ontology/prns#coAuthorOf"][@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:hasNetwork/@rdf:resource]/prns:numberOfConnections}}}</Param>
          <Param Name="MaxDisplay">5</Param>
          <Param Name="Description">People in Profiles who have published with this person.</Param>
          <Param Name="ListNode">/rdf:RDF[1]/rdf:Description[1]/prns:coAuthorOf/@rdf:resource</Param>
          <Param Name="ItemURLText">{{{rdf:Description/rdfs:label}}}</Param>
          <Param Name="ItemURL">{{{rdf:Description/@rdf:about}}}</Param>
          <Param Name="MoreURL">{{{rdf:RDF/rdf:Description[rdf:predicate/@rdf:resource="http://profiles.catalyst.harvard.edu/ontology/prns#coAuthorOf"][@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:hasNetwork/@rdf:resource]/@rdf:about}}}</Param>
          <Param Name="MoreText">See all ({{{rdf:RDF/rdf:Description[rdf:predicate/@rdf:resource="http://profiles.catalyst.harvard.edu/ontology/prns#coAuthorOf"][@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:hasNetwork/@rdf:resource]/prns:numberOfConnections}}}) people</Param>
        </ParamList>
      </Module>
      <Module ID="PassiveList">
        <ParamList>
          <Param Name="DataURI">rdf:RDF/rdf:Description/rdf:subject/@rdf:resource</Param>
          <Param Name="ExpandRDFList">
            <ExpandRDFOptions ExpandPredicates="false" ClassPropertyCustomTypeID="1" />
          </Param>
          <Param Name="InfoCaption">Similar People</Param>
          <Param Name="TotalCount">{{{rdf:RDF/rdf:Description[rdf:predicate/@rdf:resource="http://profiles.catalyst.harvard.edu/ontology/prns#similarTo"][@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:hasNetwork/@rdf:resource]/prns:numberOfConnections}}}</Param>
          <Param Name="Description">People who share similar concepts with this person.</Param>
          <Param Name="MaxDisplay">11</Param>
          <Param Name="ListNode">/rdf:RDF[1]/rdf:Description[1]/prns:similarTo/@rdf:resource</Param>
          <Param Name="ItemURLText">{{{rdf:Description/rdfs:label}}}</Param>
          <Param Name="ItemText" />
          <Param Name="ItemURL">{{{rdf:Description/@rdf:about}}}</Param>
          <Param Name="MoreURL">{{{rdf:RDF/rdf:Description[rdf:predicate/@rdf:resource="http://profiles.catalyst.harvard.edu/ontology/prns#similarTo"][@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:hasNetwork/@rdf:resource]/@rdf:about}}}</Param>
          <Param Name="MoreText">See all ({{{rdf:RDF/rdf:Description[rdf:predicate/@rdf:resource="http://profiles.catalyst.harvard.edu/ontology/prns#similarTo"][@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:hasNetwork/@rdf:resource]/prns:numberOfConnections}}}) people</Param>
        </ParamList>
      </Module>
      <Module ID="CustomViewPersonSameDepartment" />
    </Panel>
  </PanelList>
  <ExpandRDFList>
    <ExpandRDFOptions ExpandPredicates="false" ClassPropertyCustomTypeID="2" />
  </ExpandRDFList>
</Presentation>' WHERE [Type] = 'N' and [Subject] = 'http://xmlns.com/foaf/0.1/Person'
  and [Predicate] = 'http://profiles.catalyst.harvard.edu/ontology/prns#similarTo' and [Object] is null
