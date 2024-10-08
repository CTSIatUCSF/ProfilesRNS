-- Remove Physical Neighbors
update [Ontology.Presentation].[XML] set  PresentationXML =  '<Presentation PresentationClass="network">
  <PageOptions Columns="3" />
  <WindowName>{{{//rdf:RDF/rdf:Description[@rdf:about= ../rdf:Description[1]/rdf:subject/@rdf:resource]/foaf:firstName}}} {{{//rdf:RDF/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/rdf:subject/@rdf:resource]/foaf:lastName}}}''s research topics</WindowName>
  <PageColumns>3</PageColumns>
  <PageTitle>{{{//rdf:RDF/rdf:Description[@rdf:about= ../rdf:Description[1]/rdf:subject/@rdf:resource]/foaf:firstName}}} {{{//rdf:RDF/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/rdf:subject/@rdf:resource]/foaf:lastName}}}</PageTitle>
  <PageBackLinkName>Back to Profile</PageBackLinkName>
  <PageBackLinkURL>{{{//rdf:RDF/rdf:Description/rdf:subject/@rdf:resource}}}</PageBackLinkURL>
  <PageSubTitle>Concepts  ({{{//rdf:RDF/rdf:Description/prns:numberOfConnections}}})</PageSubTitle>
  <PageDescription>Concepts are derived automatically from a person''s publications.</PageDescription>
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
    <Panel Type="main" TabSort="0" TabType="Default" Alias="cloud" Name="Cloud">
      <Module ID="NetworkList">
        <ParamList>
          <Param Name="Cloud">true</Param>
        </ParamList>
      </Module>
    </Panel>
    <Panel Type="main" TabSort="1" Alias="categories" Name="Categories">
      <Module ID="NetworkCategories">
        <ParamList>
          <Param Name="InfoCaption">Concepts listed here are grouped according to their ''semantic'' categories. Within each category, up to ten concepts are shown, in decreasing order of relevance.</Param>
          <Param Name="NetworkListNode">rdf:RDF/rdf:Description[@rdf:about= //rdf:RDF/rdf:Description/prns:hasConnection/@rdf:resource]</Param>
          <Param Name="CategoryPath">//prns:meshSemanticGroupName</Param>
          <Param Name="ItemText">{{{//rdf:Description/rdfs:label}}}</Param>
          <Param Name="ItemURL">{{{//rdf:Description/@rdf:about}}}</Param>
        </ParamList>
      </Module>
    </Panel>
    <Panel Type="main" TabSort="2" Alias="timeline" Name="Timeline">
      <Module ID="NetworkTimeline">
        <ParamList>
          <Param Name="TimelineType">Concept</Param>
          <Param Name="InfoCaption">The timeline below shows the dates (blue tick marks) of publications associated with @SubjectName''s top concepts. The average publication date for each concept is shown as a red circle, illustrating changes in the primary topics that @SubjectName has written about over time.</Param>
        </ParamList>
      </Module>
    </Panel>
    <Panel Type="main" TabSort="3" Alias="details" Name="Details">
      <Module ID="ApplyXSLT">
        <ParamList>
          <Param Name="DataURI">rdf:RDF/rdf:Description/@rdf:about</Param>
          <Param Name="XSLTPath">~/profile/XSLT/ConceptDetail.xslt</Param>
          <Param Name="ExpandRDFList">
            <ExpandRDFOptions ExpandPredicates="false" ClassPropertyCustomTypeID="2" />
            <ExpandRDF Class="http://www.w3.org/2004/02/skos/core#Concept" Property="http://profiles.catalyst.harvard.edu/ontology/prns#numberOfPublications" IsDetail="false" />
          </Param>
        </ParamList>
      </Module>
    </Panel>
    <Panel Type="passive">
      <Module ID="PassiveHeader" />
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
</Presentation>'
where Type= 'N' and  Subject= 'http://xmlns.com/foaf/0.1/Person' and  Predicate= 'http://vivoweb.org/ontology/core#hasResearchArea' and  Object is null

update [Ontology.Presentation].[XML] set  PresentationXML =  N'<Presentation PresentationClass="network">
  <PageOptions Columns="3" />
  <WindowName>{{{rdf:RDF[1]/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/rdf:subject/@rdf:resource]/foaf:firstName}}} {{{rdf:RDF[1]/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/rdf:subject/@rdf:resource]/foaf:lastName}}}''s co-authors</WindowName>
  <PageColumns>3</PageColumns>
  <PageTitle>{{{rdf:RDF[1]/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/rdf:subject/@rdf:resource]/foaf:firstName}}} {{{rdf:RDF[1]/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/rdf:subject/@rdf:resource]/foaf:lastName}}}</PageTitle>
  <PageBackLinkName>Back to Profile</PageBackLinkName>
  <PageBackLinkURL>{{{//rdf:RDF/rdf:Description/rdf:subject/@rdf:resource}}}</PageBackLinkURL>
  <PageSubTitle>Co-Authors ({{{//rdf:RDF/rdf:Description/prns:numberOfConnections}}})</PageSubTitle>
  <PageDescription>Co-Authors are people in Profiles who have published together.</PageDescription>
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
          <Param Name="DataURI">rdf:RDF/rdf:Description/@rdf:about</Param>
          <Param Name="BulletType">disc</Param>
          <Param Name="Columns">2</Param>
          <Param Name="NetworkListNode">rdf:RDF/rdf:Description[@rdf:about= ../rdf:Description[1]/prns:hasConnection/@rdf:resource]</Param>
          <Param Name="ItemURLText">{{{rdf:Description/rdf:object/@rdf:resource}}}</Param>
          <Param Name="ItemText" />
          <Param Name="ItemURL">{{{rdf:Description/rdf:object/@rdf:resource}}}</Param>
          <Param Name="ExpandRDFList">
            <ExpandRDFOptions ExpandPredicates="false" ClassPropertyCustomTypeID="2" />
          </Param>
        </ParamList>
      </Module>
    </Panel>
    <Panel Type="main" TabSort="1" Alias="map" Name="Map" DisplayRule="rdf:RDF/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/rdf:subject/@rdf:resource]/prns:latitude">
      <Module ID="NetworkMap">
        <ParamList>
          <Param Name="MapType">CoAuthor</Param>
        </ParamList>
      </Module>
    </Panel>
    <Panel Type="main" TabSort="2" Alias="radial" Name="Radial">
      <Module ID="NetworkRadial" />
    </Panel>
    <Panel Type="main" TabSort="3" Alias="cluster" Name="Cluster">
      <Module ID="NetworkCluster" />
    </Panel>
    <Panel Type="main" TabSort="4" Alias="timeline" Name="Timeline">
      <Module ID="NetworkTimeline">
        <ParamList>
          <Param Name="TimelineType">CoAuthor</Param>
          <Param Name="InfoCaption">The timeline below shows the dates (blue tick marks) of publications @SubjectName co-authored with other people in Profiles. The average publication date for each co-author is shown as a red circle, illustrating changes in the people that @SubjectName has worked with over time.</Param>
        </ParamList>
      </Module>
    </Panel>
    <Panel Type="main" TabSort="5" Alias="details" Name="Details">
      <Module ID="ApplyXSLT">
        <ParamList>
          <Param Name="DataURI">rdf:RDF/rdf:Description/@rdf:about</Param>
          <Param Name="XSLTPath">~/profile/XSLT/CoAuthorDetail.xslt</Param>
          <Param Name="ExpandRDFList">
            <ExpandRDFOptions ExpandPredicates="false" ClassPropertyCustomTypeID="2" />
            <ExpandRDF Class="http://xmlns.com/foaf/0.1/Person" Property="http://profiles.catalyst.harvard.edu/ontology/prns#fullName" IsDetail="false" />
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
</Presentation>' 
where Type= 'N' and  Subject= 'http://xmlns.com/foaf/0.1/Person' and  Predicate= 'http://profiles.catalyst.harvard.edu/ontology/prns#coAuthorOf' and  Object is null

update [Ontology.Presentation].[XML] set  PresentationXML =  N'<Presentation PresentationClass="network">
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
</Presentation>' 
where Type= 'N' and  Subject= 'http://xmlns.com/foaf/0.1/Person' and  Predicate= 'http://profiles.catalyst.harvard.edu/ontology/prns#similarTo' and  Object is null

update [Ontology.Presentation].[XML] set  PresentationXML =  N'<Presentation PresentationClass="profile">
  <PageOptions Columns="3" />
  <WindowName>{{{rdf:RDF[1]/rdf:Description[1]/foaf:firstName[1]}}} {{{rdf:RDF[1]/rdf:Description[1]/foaf:lastName[1]}}}</WindowName>
  <PageColumns>3</PageColumns>
  <PageTitle>{{{rdf:RDF[1]/rdf:Description[1]/prns:fullName[1]}}}</PageTitle>
  <PageBackLinkName />
  <PageBackLinkURL />
  <PageSubTitle />
  <PageDescription />
  <PanelTabType>Fixed</PanelTabType>
  <PanelList>
    <Panel Type="active">
      <Module ID="MiniSearch" />
      <Module ID="MainMenu">
        <ParamList>
          <Param Name="PageType">Person</Param>
        </ParamList>
      </Module>
    </Panel>
    <Panel Type="main" TabType="Fixed">
      <Module ID="CustomViewPersonGeneralInfo" />
      <Module ID="ApplyXSLT">
        <ParamList>
          <Param Name="XSLTPath">~/profile/XSLT/OtherPositions.xslt</Param>
        </ParamList>
      </Module>
      <Module ID="PropertyList">
        <ParamList />
      </Module>
      <Module ID="HRFooter" />
    </Panel>
    <Panel Type="passive">
      <Module ID="PassiveHeader">
        <ParamList>
          <Param Name="DisplayRule">rdf:RDF/rdf:Description[rdf:predicate/@rdf:resource="http://vivoweb.org/ontology/core#hasResearchArea"][@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:hasNetwork/@rdf:resource]/prns:numberOfConnections</Param>
          <Param Name="DisplayRule">rdf:RDF/rdf:Description[rdf:predicate/@rdf:resource="http://profiles.catalyst.harvard.edu/ontology/prns#coAuthorOf"][@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:hasNetwork/@rdf:resource]/prns:numberOfConnections</Param>
          <Param Name="DisplayRule">rdf:RDF/rdf:Description[rdf:predicate/@rdf:resource="http://profiles.catalyst.harvard.edu/ontology/prns#similarTo"][@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:hasNetwork/@rdf:resource]/prns:numberOfConnections</Param>
        </ParamList>
      </Module>
      <Module ID="PassiveList">
        <ParamList>
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
      <Module ID="Gadgets">
        <ParamList>
          <Param Name="HTML">
            <div id="gadgets-tools" class="gadgets-gadget-parent" />
          </Param>
        </ParamList>
      </Module>
    </Panel>
  </PanelList>
  <ExpandRDFList>
    <ExpandRDFOptions ExpandPredicates="false" ClassPropertyCustomTypeID="1" />
  </ExpandRDFList>
</Presentation>' 
where Type= 'P' and  Subject= 'http://xmlns.com/foaf/0.1/Person' and  Predicate is null and  Object is null



