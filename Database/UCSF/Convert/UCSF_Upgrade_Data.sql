-- Updates to PresentationXML
Begin tran 
UPDATE [Ontology.Presentation].[XML] SET [PresentationXML]=CONVERT(xml,N'<Presentation PresentationClass="profile">
  <PageOptions Columns="3" />
  <WindowName>{{{rdf:RDF[1]/rdf:Description[1]/rdfs:label[1]}}}</WindowName>
  <PageColumns>3</PageColumns>
  <PageTitle>{{{rdf:RDF[1]/rdf:Description[1]/rdfs:label[1]}}}</PageTitle>
  <PageBackLinkName />
  <PageBackLinkURL />
  <PageSubTitle />
  <PageDescription />
  <PanelTabType>Fixed</PanelTabType>
  <PanelList>
    <Panel Type="active">
      <Module ID="MiniSearch" />
      <Module ID="MainMenu" />
    </Panel>
    <Panel Type="main" TabSort="0" TabType="Default">
      <Module ID="CustomViewConceptMeshInfo">
        <ParamList />
      </Module>
    </Panel>
    <Panel Type="main" TabSort="0" TabType="Default">
      <Module ID="CustomViewConceptPublication">
        <ParamList>
          <Param Name="TimelineCaption">This graph shows the total number of publications written about "@ConceptName" by people in this website by year, and whether "@ConceptName" was a major or minor topic of these publications. &lt;!--In all years combined, a total of [[[TODO:PUBLICATION COUNT]]] publications were written by people in Profiles.--&gt;</Param>
          <Param Name="CitedCaption">Below are the publications written about "@ConceptName" that have been cited the most by articles in Pubmed Central.</Param>
          <Param Name="NewestCaption">Below are the most recent publications written about "@ConceptName" by people in Profiles.</Param>
          <Param Name="OldestCaption">Below are the earliest publications written about "@ConceptName" by people in Profiles.</Param>
        </ParamList>
      </Module>
    </Panel>
    <Panel Type="passive">
      <Module ID="PassiveList">
        <ParamList>
          <Param Name="InfoCaption">People</Param>
          <Param Name="Description">People who have written about this concept.</Param>
          <Param Name="MaxDisplay">5</Param>
          <Param Name="ListNode">rdf:RDF/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/vivo:researchAreaOf/@rdf:resource]</Param>
          <Param Name="ItemURLText">{{{rdf:Description/rdfs:label}}}</Param>
          <Param Name="ItemText" />
          <Param Name="ItemURL">{{{rdf:Description/@rdf:about}}}</Param>
          <Param Name="MoreURL">/search/default.aspx?searchtype=people&amp;searchfor={{{rdf:RDF/rdf:Description/rdfs:label}}}&amp;classuri=http://xmlns.com/foaf/0.1/Person&amp;erpage=15&amp;offset=0&amp;exactPhrase=true</Param>
          <Param Name="MoreText">See all people</Param>
        </ParamList>
      </Module>
      <Module ID="CustomViewConceptSimilarMesh">
        <ParamList>
          <Param Name="InfoCaption">Related Concepts</Param>
          <Param Name="Description">Research concepts that are similar to this concept.</Param>
        </ParamList>
      </Module>
      <Module ID="CustomViewConceptTopJournal">
        <ParamList>
          <Param Name="InfoCaption">Top Journals</Param>
          <Param Name="Description">Top journals in which articles about this concept have been published.</Param>
        </ParamList>
      </Module>
    </Panel>
  </PanelList>
</Presentation>',1) WHERE type='P' and subject='http://www.w3.org/2004/02/skos/core#Concept' and Predicate is null and [object] is null --[PresentationID] = 4


UPDATE [Ontology.Presentation].[XML] SET [PresentationXML]=CONVERT(xml,N'<Presentation PresentationClass="profile">

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
      <Module ID="MainMenu" />
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
          <Param Name="Description">Derived automatically from this person''s publications.</Param>
          <Param Name="MaxDisplay">5</Param>
          <Param Name="ListNode">rdf:RDF/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/vivo:hasResearchArea/@rdf:resource]</Param>
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
          <Param Name="MaxDisplay">5</Param>
          <Param Name="Description">People in Profiles who have published with this person.</Param>
          <Param Name="ListNode">rdf:RDF/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:coAuthorOf/@rdf:resource]</Param>
          <Param Name="ItemURLText">{{{rdf:Description/rdfs:label}}}</Param>
          <Param Name="ItemURL">{{{rdf:Description/@rdf:about}}}</Param>
          <Param Name="MoreURL">{{{rdf:RDF/rdf:Description[rdf:predicate/@rdf:resource="http://profiles.catalyst.harvard.edu/ontology/prns#coAuthorOf"][@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:hasNetwork/@rdf:resource]/@rdf:about}}}</Param>
          <Param Name="MoreText">See all ({{{rdf:RDF/rdf:Description[rdf:predicate/@rdf:resource="http://profiles.catalyst.harvard.edu/ontology/prns#coAuthorOf"][@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:hasNetwork/@rdf:resource]/prns:numberOfConnections}}}) people</Param>
        </ParamList>
      </Module>
      <Module ID="Gadgets">
        <ParamList>
          <Param Name="GadgetDiv">gadgets-network</Param>
          <Param Name="GadgetClass">gadgets-gadget-network-parent</Param>
        </ParamList>
      </Module>
      <Module ID="PassiveList">
        <ParamList>
          <Param Name="InfoCaption">Related Authors</Param>
          <Param Name="Description">People who share related concepts with this person.</Param>
          <Param Name="MaxDisplay">11</Param>
          <Param Name="ListNode">rdf:RDF/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:similarTo/@rdf:resource]</Param>
          <Param Name="ItemURLText">{{{rdf:Description/rdfs:label}}}</Param>
          <Param Name="ItemText" />
          <Param Name="ItemURL">{{{rdf:Description/@rdf:about}}}</Param>
          <Param Name="MoreURL">{{{rdf:RDF/rdf:Description[rdf:predicate/@rdf:resource="http://profiles.catalyst.harvard.edu/ontology/prns#similarTo"][@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:hasNetwork/@rdf:resource]/@rdf:about}}}</Param>
          <Param Name="MoreText">See all ({{{rdf:RDF/rdf:Description[rdf:predicate/@rdf:resource="http://profiles.catalyst.harvard.edu/ontology/prns#similarTo"][@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:hasNetwork/@rdf:resource]/prns:numberOfConnections}}}) people</Param>
        </ParamList>
      </Module>
      <!--Module ID="CustomViewPersonSameDepartment" /-->
      <Module ID="Gadgets">
        <ParamList>
          <Param Name="GadgetDiv">gadgets-tools</Param>
          <Param Name="GadgetClass">gadgets-gadget-parent</Param>
        </ParamList>
      </Module>
      <!--Module ID="PassiveList">
        <ParamList>
          <Param Name="InfoCaption">Physical Neighbors</Param>
          <Param Name="Description">People whose addresses are nearby this person.</Param>
          <Param Name="MaxDisplay">11</Param>
          <Param Name="ListNode">rdf:RDF/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:physicalNeighborOf/@rdf:resource]</Param>
          <Param Name="ItemURLText">{{{rdf:Description/rdfs:label}}}</Param>
          <Param Name="ItemText" />
          <Param Name="ItemURL">{{{rdf:Description/@rdf:about}}}</Param>
        </ParamList>
      </Module-->
    </Panel>
  </PanelList>
  <ExpandRDFList>
    <ExpandRDF Class="http://xmlns.com/foaf/0.1/Person" Property="http://vivoweb.org/ontology/core#authorInAuthorship" Limit="1" />
    <ExpandRDF Class="http://xmlns.com/foaf/0.1/Person" Property="http://vivoweb.org/ontology/core#hasResearcherRole" Limit="1" />
  </ExpandRDFList>
</Presentation>',1) WHERE type='P' and subject='http://xmlns.com/foaf/0.1/Person' and Predicate is null and [object] is null --[PresentationID] = 5



UPDATE [Ontology.Presentation].[XML] SET [PresentationXML]=CONVERT(xml,N'<Presentation PresentationClass="network">
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
      <Module ID="MainMenu" />
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
        </ParamList>
      </Module>
    </Panel>
    <Panel Type="passive">
      <Module ID="PassiveHeader">
        <ParamList>
          <Param Name="DataURI">rdf:RDF/rdf:Description/rdf:subject/@rdf:resource</Param>
          <Param Name="ExpandRDFList">
            <ExpandRDF Class="http://xmlns.com/foaf/0.1/Person" Property="http://vivoweb.org/ontology/core#authorInAuthorship" Limit="1" />
            <ExpandRDF Class="http://xmlns.com/foaf/0.1/Person" Property="http://vivoweb.org/ontology/core#hasResearcherRole" Limit="1" />
          </Param>
        </ParamList>
      </Module>
      <Module ID="PassiveList">
        <ParamList>
          <Param Name="DataURI">rdf:RDF/rdf:Description/rdf:subject/@rdf:resource</Param>
          <Param Name="ExpandRDFList">
            <ExpandRDF Class="http://xmlns.com/foaf/0.1/Person" Property="http://vivoweb.org/ontology/core#authorInAuthorship" Limit="1" />
            <ExpandRDF Class="http://xmlns.com/foaf/0.1/Person" Property="http://vivoweb.org/ontology/core#hasResearcherRole" Limit="1" />
          </Param>
          <Param Name="InfoCaption">Related Concepts</Param>
          <Param Name="Description">Derived automatically from this person''s publications.</Param>
          <Param Name="MaxDisplay">5</Param>
          <Param Name="ListNode">rdf:RDF/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/vivo:hasResearchArea/@rdf:resource]</Param>
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
            <ExpandRDF Class="http://xmlns.com/foaf/0.1/Person" Property="http://vivoweb.org/ontology/core#authorInAuthorship" Limit="1" />
            <ExpandRDF Class="http://xmlns.com/foaf/0.1/Person" Property="http://vivoweb.org/ontology/core#hasResearcherRole" Limit="1" />
          </Param>
          <Param Name="InfoCaption">Co-Authors</Param>
          <Param Name="MaxDisplay">5</Param>
          <Param Name="Description">People in Profiles who have published with this person.</Param>
          <Param Name="ListNode">rdf:RDF/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:coAuthorOf/@rdf:resource]</Param>
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
            <ExpandRDF Class="http://xmlns.com/foaf/0.1/Person" Property="http://vivoweb.org/ontology/core#authorInAuthorship" Limit="1" />
            <ExpandRDF Class="http://xmlns.com/foaf/0.1/Person" Property="http://vivoweb.org/ontology/core#hasResearcherRole" Limit="1" />
          </Param>
          <Param Name="InfoCaption">Related Authors</Param>
          <Param Name="Description">People who share similar concepts with this person.</Param>
          <Param Name="MaxDisplay">11</Param>
          <Param Name="ListNode">rdf:RDF/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:similarTo/@rdf:resource]</Param>
          <Param Name="ItemURLText">{{{rdf:Description/rdfs:label}}}</Param>
          <Param Name="ItemText" />
          <Param Name="ItemURL">{{{rdf:Description/@rdf:about}}}</Param>
          <Param Name="MoreURL">{{{rdf:RDF/rdf:Description[rdf:predicate/@rdf:resource="http://profiles.catalyst.harvard.edu/ontology/prns#similarTo"][@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:hasNetwork/@rdf:resource]/@rdf:about}}}</Param>
          <Param Name="MoreText">See all ({{{rdf:RDF/rdf:Description[rdf:predicate/@rdf:resource="http://profiles.catalyst.harvard.edu/ontology/prns#similarTo"][@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:hasNetwork/@rdf:resource]/prns:numberOfConnections}}}) people</Param>
        </ParamList>
      </Module>
      <!--Module ID="CustomViewPersonSameDepartment" /-->
      <Module ID="Gadgets">
        <ParamList>
          <Param Name="GadgetDiv">gadgets-tools</Param>
          <Param Name="GadgetClass">gadgets-gadget-parent</Param>
        </ParamList>
      </Module>
      <!--Module ID="PassiveList">
                <ParamList>
                  <Param Name="DataURI">rdf:RDF/rdf:Description/rdf:subject/@rdf:resource</Param>
                  <Param Name="ExpandRDFList">
                    <ExpandRDF Class="http://xmlns.com/foaf/0.1/Person" Property="http://vivoweb.org/ontology/core#authorInAuthorship" Limit="1" />
            <ExpandRDF Class="http://xmlns.com/foaf/0.1/Person" Property="http://vivoweb.org/ontology/core#hasResearcherRole" Limit="1" />
                  </Param>
                  <Param Name="InfoCaption">Physical Neighbors</Param>
                  <Param Name="Description">People whose addresses are nearby this person.</Param>
                  <Param Name="MaxDisplay">11</Param>
                  <Param Name="ListNode">rdf:RDF/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:physicalNeighborOf/@rdf:resource]</Param>
                  <Param Name="ItemURLText">{{{rdf:Description/rdfs:label}}}</Param>
                  <Param Name="ItemText" />
                  <Param Name="ItemURL">{{{rdf:Description/@rdf:about}}}</Param>
                </ParamList>
              </Module-->
    </Panel>
  </PanelList>
</Presentation>',1) WHERE type='N' and subject='http://xmlns.com/foaf/0.1/Person' and Predicate ='http://profiles.catalyst.harvard.edu/ontology/prns#coAuthorOf' and [object] is null --[PresentationID] = 6


UPDATE [Ontology.Presentation].[XML] SET [PresentationXML]=CONVERT(xml,N'<Presentation PresentationClass="network">
  <PageOptions Columns="3" />
  <WindowName>{{{rdf:RDF[1]/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/rdf:subject/@rdf:resource]/foaf:firstName}}} {{{rdf:RDF[1]/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/rdf:subject/@rdf:resource]/foaf:lastName}}}''s related authors</WindowName>
  <PageColumns>3</PageColumns>
  <PageTitle>{{{rdf:RDF[1]/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/rdf:subject/@rdf:resource]/foaf:firstName}}} {{{rdf:RDF[1]/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/rdf:subject/@rdf:resource]/foaf:lastName}}}</PageTitle>
  <PageBackLinkName>Back to Profile</PageBackLinkName>
  <PageBackLinkURL>{{{//rdf:RDF/rdf:Description/rdf:subject/@rdf:resource}}}</PageBackLinkURL>
  <PageSubTitle>Related Authors ({{{//rdf:RDF/rdf:Description/prns:numberOfConnections}}})</PageSubTitle>
  <PageDescription>Related authors share similar sets of concepts, but are not necessarily co-authors.</PageDescription>
  <PanelTabType>Default</PanelTabType>
  <PanelList>
    <Panel Type="active">
      <Module ID="MiniSearch" />
      <Module ID="MainMenu" />
    </Panel>
    <Panel Type="main" TabSort="0" TabType="Default" Alias="list" Name="List">
      <Module ID="NetworkList">
        <ParamList>
          <Param Name="InfoCaption">The people in this list are ordered by decreasing similarity.     (<font color="red">*</font> These people are also co-authors.)</Param>
          <Param Name="DataURI">rdf:RDF/rdf:Description/@rdf:about</Param>
          <Param Name="BulletType">disc</Param>
          <Param Name="Columns">2</Param>
          <Param Name="NetworkListNode">rdf:RDF/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:hasConnection/@rdf:resource]</Param>
          <Param Name="ItemURLText">{{{rdf:Description/rdf:object/@rdf:resource}}}</Param>
          <Param Name="ItemText" />
          <Param Name="ItemURL">{{{rdf:Description/rdf:object/@rdf:resource}}}</Param>
          <Param Name="SortBy">Weight</Param>
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
        </ParamList>
      </Module>
    </Panel>
    <Panel Type="passive">
      <Module ID="PassiveHeader">
        <ParamList>
          <Param Name="DataURI">rdf:RDF/rdf:Description/rdf:subject/@rdf:resource</Param>
          <Param Name="ExpandRDFList">
            <ExpandRDF Class="http://xmlns.com/foaf/0.1/Person" Property="http://vivoweb.org/ontology/core#authorInAuthorship" Limit="1" />
            <ExpandRDF Class="http://xmlns.com/foaf/0.1/Person" Property="http://vivoweb.org/ontology/core#hasResearcherRole" Limit="1" />
          </Param>
        </ParamList>
      </Module>
      <Module ID="PassiveList">
        <ParamList>
          <Param Name="DataURI">rdf:RDF/rdf:Description/rdf:subject/@rdf:resource</Param>
          <Param Name="ExpandRDFList">
            <ExpandRDF Class="http://xmlns.com/foaf/0.1/Person" Property="http://vivoweb.org/ontology/core#authorInAuthorship" Limit="1" />
            <ExpandRDF Class="http://xmlns.com/foaf/0.1/Person" Property="http://vivoweb.org/ontology/core#hasResearcherRole" Limit="1" />
          </Param>
          <Param Name="InfoCaption">Related Concepts</Param>
          <Param Name="Description">Derived automatically from this person''s publications.</Param>
          <Param Name="MaxDisplay">5</Param>
          <Param Name="ListNode">rdf:RDF/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/vivo:hasResearchArea/@rdf:resource]</Param>
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
            <ExpandRDF Class="http://xmlns.com/foaf/0.1/Person" Property="http://vivoweb.org/ontology/core#authorInAuthorship" Limit="1" />
            <ExpandRDF Class="http://xmlns.com/foaf/0.1/Person" Property="http://vivoweb.org/ontology/core#hasResearcherRole" Limit="1" />
          </Param>
          <Param Name="InfoCaption">Co-Authors</Param>
          <Param Name="MaxDisplay">5</Param>
          <Param Name="Description">People in Profiles who have published with this person.</Param>
          <Param Name="ListNode">rdf:RDF/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:coAuthorOf/@rdf:resource]</Param>
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
            <ExpandRDF Class="http://xmlns.com/foaf/0.1/Person" Property="http://vivoweb.org/ontology/core#authorInAuthorship" Limit="1" />
            <ExpandRDF Class="http://xmlns.com/foaf/0.1/Person" Property="http://vivoweb.org/ontology/core#hasResearcherRole" Limit="1" />
          </Param>
          <Param Name="InfoCaption">Related Authors</Param>
          <Param Name="Description">People who share similar concepts with this person.</Param>
          <Param Name="MaxDisplay">11</Param>
          <Param Name="ListNode">rdf:RDF/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:similarTo/@rdf:resource]</Param>
          <Param Name="ItemURLText">{{{rdf:Description/rdfs:label}}}</Param>
          <Param Name="ItemText" />
          <Param Name="ItemURL">{{{rdf:Description/@rdf:about}}}</Param>
          <Param Name="MoreURL">{{{rdf:RDF/rdf:Description[rdf:predicate/@rdf:resource="http://profiles.catalyst.harvard.edu/ontology/prns#similarTo"][@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:hasNetwork/@rdf:resource]/@rdf:about}}}</Param>
          <Param Name="MoreText">See all ({{{rdf:RDF/rdf:Description[rdf:predicate/@rdf:resource="http://profiles.catalyst.harvard.edu/ontology/prns#similarTo"][@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:hasNetwork/@rdf:resource]/prns:numberOfConnections}}}) people</Param>
        </ParamList>
      </Module>
      <!--Module ID="CustomViewPersonSameDepartment" /-->
      <Module ID="Gadgets">
        <ParamList>
          <Param Name="GadgetDiv">gadgets-tools</Param>
          <Param Name="GadgetClass">gadgets-gadget-parent</Param>
        </ParamList>
      </Module>
      <!--Module ID="PassiveList">
                <ParamList>
                  <Param Name="DataURI">rdf:RDF/rdf:Description/rdf:subject/@rdf:resource</Param>
                  <Param Name="ExpandRDFList">
                    <ExpandRDF Class="http://xmlns.com/foaf/0.1/Person" Property="http://vivoweb.org/ontology/core#authorInAuthorship" Limit="1" />
            <ExpandRDF Class="http://xmlns.com/foaf/0.1/Person" Property="http://vivoweb.org/ontology/core#hasResearcherRole" Limit="1" />
                  </Param>
                  <Param Name="InfoCaption">Physical Neighbors</Param>
                  <Param Name="Description">People whose addresses are nearby this person.</Param>
                  <Param Name="MaxDisplay">11</Param>
                  <Param Name="ListNode">rdf:RDF/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:physicalNeighborOf/@rdf:resource]</Param>
                  <Param Name="ItemURLText">{{{rdf:Description/rdfs:label}}}</Param>
                  <Param Name="ItemText" />
                  <Param Name="ItemURL">{{{rdf:Description/@rdf:about}}}</Param>
                </ParamList>
              </Module-->
    </Panel>
  </PanelList>
</Presentation>',1) WHERE type='N' and subject='http://xmlns.com/foaf/0.1/Person' and Predicate ='http://profiles.catalyst.harvard.edu/ontology/prns#similarTo' and [object] is null --[PresentationID] = 7


UPDATE [Ontology.Presentation].[XML] SET [PresentationXML]=CONVERT(xml,N'<Presentation PresentationClass="network">
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
      <Module ID="MainMenu" />
    </Panel>
    <Panel Type="main" TabSort="0" TabType="Default" Alias="cloud" Name="Cloud">
      <Module ID="NetworkList">
        <ParamList>
          <Param Name="Cloud">true</Param>
        </ParamList>
      </Module>
      <!--<Module ID="NetworkList">
        <ParamList>
          <Param Name="DataURI">rdf:RDF/rdf:Description[1]/@rdf:about</Param>
          <Param Name="InfoCaption">In this concept ''cloud'', the sizes of the concepts are based not only on the number of corresponding publications, but also how relevant the concepts are to the overall topics of the publications, how long ago the publications were written, whether the person was the first or senior author, and how many other people have written about the same topic. The largest concepts are those that are most unique to this person.</Param>
          <Param Name="BulletType" />
          <Param Name="Columns">2</Param>
          <Param Name="NetworkListNode">rdf:RDF/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:hasConnection/@rdf:resource]</Param>
          <Param Name="CloudWeightNode">prns:connectionWeight</Param>
          <Param Name="ItemURLText">{{{rdf:Description[1]/rdf:object/@rdf:resource}}}</Param>
          <Param Name="ItemText" />
          <Param Name="ItemURL">{{{rdf:Description[1]/rdf:object/@rdf:resource}}}</Param>
        </ParamList>
      </Module>-->
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
        </ParamList>
      </Module>
    </Panel>
    <Panel Type="passive">
      <Module ID="PassiveHeader" />
      <Module ID="PassiveList">
        <ParamList>
          <Param Name="DataURI">rdf:RDF/rdf:Description/rdf:subject/@rdf:resource</Param>
          <Param Name="ExpandRDFList">
            <ExpandRDF Class="http://xmlns.com/foaf/0.1/Person" Property="http://vivoweb.org/ontology/core#authorInAuthorship" Limit="1" />
            <ExpandRDF Class="http://xmlns.com/foaf/0.1/Person" Property="http://vivoweb.org/ontology/core#hasResearcherRole" Limit="1" />
          </Param>
          <Param Name="InfoCaption">Concepts</Param>
          <Param Name="Description">Derived automatically from this person''s publications.</Param>
          <Param Name="MaxDisplay">5</Param>
          <Param Name="ListNode">rdf:RDF/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/vivo:hasResearchArea/@rdf:resource]</Param>
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
            <ExpandRDF Class="http://xmlns.com/foaf/0.1/Person" Property="http://vivoweb.org/ontology/core#authorInAuthorship" Limit="1" />
            <ExpandRDF Class="http://xmlns.com/foaf/0.1/Person" Property="http://vivoweb.org/ontology/core#hasResearcherRole" Limit="1" />
          </Param>
          <Param Name="InfoCaption">Co-Authors</Param>
          <Param Name="MaxDisplay">5</Param>
          <Param Name="Description">People in Profiles who have published with this person.</Param>
          <Param Name="ListNode">rdf:RDF/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:coAuthorOf/@rdf:resource]</Param>
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
            <ExpandRDF Class="http://xmlns.com/foaf/0.1/Person" Property="http://vivoweb.org/ontology/core#authorInAuthorship" Limit="1" />
            <ExpandRDF Class="http://xmlns.com/foaf/0.1/Person" Property="http://vivoweb.org/ontology/core#hasResearcherRole" Limit="1" />
          </Param>
          <Param Name="InfoCaption">Related Authors</Param>
          <Param Name="Description">People who share similar concepts with this person.</Param>
          <Param Name="MaxDisplay">11</Param>
          <Param Name="ListNode">rdf:RDF/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:similarTo/@rdf:resource]</Param>
          <Param Name="ItemURLText">{{{rdf:Description/rdfs:label}}}</Param>
          <Param Name="ItemText" />
          <Param Name="ItemURL">{{{rdf:Description/@rdf:about}}}</Param>
          <Param Name="MoreURL">{{{rdf:RDF/rdf:Description[rdf:predicate/@rdf:resource="http://profiles.catalyst.harvard.edu/ontology/prns#similarTo"][@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:hasNetwork/@rdf:resource]/@rdf:about}}}</Param>
          <Param Name="MoreText">See all ({{{rdf:RDF/rdf:Description[rdf:predicate/@rdf:resource="http://profiles.catalyst.harvard.edu/ontology/prns#similarTo"][@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:hasNetwork/@rdf:resource]/prns:numberOfConnections}}}) people</Param>
        </ParamList>
      </Module>
      <Module ID="CustomViewPersonSameDepartment" />
      <Module ID="PassiveList">
        <ParamList>
          <Param Name="DataURI">rdf:RDF/rdf:Description/rdf:subject/@rdf:resource</Param>
          <Param Name="ExpandRDFList">
            <ExpandRDF Class="http://xmlns.com/foaf/0.1/Person" Property="http://vivoweb.org/ontology/core#authorInAuthorship" Limit="1" />
            <ExpandRDF Class="http://xmlns.com/foaf/0.1/Person" Property="http://vivoweb.org/ontology/core#hasResearcherRole" Limit="1" />
          </Param>
          <Param Name="InfoCaption">Physical Neighbors</Param>
          <Param Name="Description">People whose addresses are nearby this person.</Param>
          <Param Name="MaxDisplay">11</Param>
          <Param Name="ListNode">rdf:RDF/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/prns:physicalNeighborOf/@rdf:resource]</Param>
          <Param Name="ItemURLText">{{{rdf:Description/rdfs:label}}}</Param>
          <Param Name="ItemText" />
          <Param Name="ItemURL">{{{rdf:Description/@rdf:about}}}</Param>
        </ParamList>
      </Module>
    </Panel>
  </PanelList>
</Presentation>',1) WHERE type='N' and subject='http://xmlns.com/foaf/0.1/Person' and Predicate ='http://vivoweb.org/ontology/core#hasResearchArea' and [object] is null --[PresentationID] = 8



UPDATE [Ontology.Presentation].[XML] SET [PresentationXML]=CONVERT(xml,N'<Presentation PresentationClass="connection">
  <PageOptions Columns="3" />
  <WindowName>{{{//rdf:RDF/rdf:Description[@rdf:about= ../rdf:Description[1]/rdf:subject/@rdf:resource]/foaf:firstName}}} {{{//rdf:RDF/rdf:Description[@rdf:about= /rdf:RDF[1]/rdf:Description[1]/rdf:subject/@rdf:resource]/foaf:lastName}}}</WindowName>
  <PageColumns>3</PageColumns>
  <PageTitle>Connection</PageTitle>
  <PageBackLinkName>Back to Details</PageBackLinkName>
  <PageBackLinkURL>{{{//rdf:RDF/rdf:Description[1]/prns:connectionInNetwork/@rdf:resource}}}/details</PageBackLinkURL>
  <PageSubTitle>Related Author</PageSubTitle>
  <PageDescription>
	This is a "connection" page, showing concepts shared by  
	{{{//rdf:RDF/rdf:Description[@rdf:about=/rdf:RDF/rdf:Description[1]/rdf:subject/@rdf:resource]/foaf:firstName}}} {{{//rdf:RDF/rdf:Description[@rdf:about=/rdf:RDF/rdf:Description[1]/rdf:subject/@rdf:resource]/foaf:lastName}}} and 
	{{{//rdf:RDF/rdf:Description[@rdf:about=/rdf:RDF/rdf:Description[1]/rdf:object/@rdf:resource]/foaf:firstName}}} {{{//rdf:RDF/rdf:Description[@rdf:about=/rdf:RDF/rdf:Description[1]/rdf:object/@rdf:resource]/foaf:lastName}}}.
  </PageDescription>
  <PanelTabType>Fixed</PanelTabType>
  <PanelList>
    <Panel Type="active">
      <Module ID="MiniSearch" />
      <Module ID="MainMenu" />
    </Panel>
    <Panel Type="main" TabSort="0" TabType="Default">
      <Module ID="SimilarConnection">
        <ParamList>
          <Param Name="SubjectName">//rdf:RDF/rdf:Description/rdfs:label</Param>
          <Param Name="SubjectURI">//rdf:RDF/rdf:Description/rdf:subject/@rdf:resource</Param>
          <Param Name="ObjectName">//rdf:RDF/rdf:Description[@rdf:about=/rdf:RDF/rdf:Description[1]/rdf:object/@rdf:resource]/rdfs:label</Param>
          <Param Name="ObjectURI">//rdf:RDF/rdf:Description/rdf:object/@rdf:resource</Param>
        </ParamList>
      </Module>
    </Panel>
    <Panel Type="passive">
      <Module ID="HTMLBlock">
        <ParamList>
          <Param Name="HTML">
            <div class="passiveSectionHead">
              Connection Strength
            </div>
            <br />
            <div class="passiveSectonBody"> The connection strength for related authors is the <u>sum</u> of the scores for each shared concept.<p>A shared concept score is the <u>product</u> of the concept scores for each person.</p><p>Click any person''s concept score value to show details.</p></div>
          </Param>
        </ParamList>
      </Module>
    </Panel>
  </PanelList>
</Presentation>
',1) WHERE type='C' and subject='http://xmlns.com/foaf/0.1/Person' and Predicate ='http://profiles.catalyst.harvard.edu/ontology/prns#similarTo' and [object] ='http://xmlns.com/foaf/0.1/Person' --[PresentationID] = 10

commit

--- UCWide Branding work
INSERT INTO [UCSF.].[Theme] (Theme, BasePath, Shared) VALUES ('UC', 'http://stage-profiles.ucsf.edu/profiles_uc', 1);
INSERT INTO [UCSF.].[Theme] (Theme, BasePath, Shared) VALUES ('UCSF', 'http://stage-profiles.ucsf.edu/ucsf', 0);
INSERT INTO [UCSF.].[Theme] (Theme, BasePath, Shared) VALUES ('UCSD', 'http://stage-profiles.ucsf.edu/ucsd', 0);
INSERT INTO [UCSF.].[Theme] (Theme, BasePath, Shared) VALUES ('USC', 'http://stage-profiles.ucsf.edu/usc', 0);

INSERT INTO [UCSF.].[InstitutionAbbreviation2Theme] (InstitutionAbbreviation, Theme) VALUES ('UCI', 'UC');
INSERT INTO [UCSF.].[InstitutionAbbreviation2Theme] (InstitutionAbbreviation, Theme) VALUES ('UCSF', 'UCSF');
INSERT INTO [UCSF.].[InstitutionAbbreviation2Theme] (InstitutionAbbreviation, Theme) VALUES ('UCSD', 'UCSD');
INSERT INTO [UCSF.].[InstitutionAbbreviation2Theme] (InstitutionAbbreviation, Theme) VALUES ('USC', 'USC');

--rollback
--commit
---EXEC [Framework.].[LoadXMLFile] @FilePath = '$(ProfilesRNSRootPath)\Data\PRNS_1.2.owl', @TableDestination = '[Ontology.Import].owl', @DestinationColumn = 'DATA', @NameValue = 'PRNS_1.2'
-- just to be safe
DELETE FROM [Ontology.Import].OWL WHERE name like 'UCSF_%'
DELETE FROM [Ontology.Import].Triple WHERE OWL like 'UCSF_%'

INSERT [Ontology.Import].OWL VALUES ('UCSF_1.2', N'<rdf:RDF xmlns:geo="http://aims.fao.org/aos/geopolitical.owl#" xmlns:afn="http://jena.hpl.hp.com/ARQ/function#" xmlns:catalyst="http://profiles.catalyst.harvard.edu/ontology/catalyst#" xmlns:ucsf="http://profiles.ucsf.edu/ontology/ucsf#" xmlns:prns="http://profiles.catalyst.harvard.edu/ontology/prns#" xmlns:obo="http://purl.obolibrary.org/obo/" xmlns:dcelem="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:event="http://purl.org/NET/c4dm/event.owl#" xmlns:bibo="http://purl.org/ontology/bibo/" xmlns:vann="http://purl.org/vocab/vann/" xmlns:vitro07="http://vitro.mannlib.cornell.edu/ns/vitro/0.7#" xmlns:vitro="http://vitro.mannlib.cornell.edu/ns/vitro/public#" xmlns:vivo="http://vivoweb.org/ontology/core#" xmlns:pvs="http://vivoweb.org/ontology/provenance-support#" xmlns:scirr="http://vivoweb.org/ontology/scientific-research-resource#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:swvs="http://www.w3.org/2003/06/sw-vocab-status/ns#" xmlns:skco="http://www.w3.org/2004/02/skos/core#" xmlns:owl2="http://www.w3.org/2006/12/owl2-xml#" xmlns:skos="http://www.w3.org/2008/05/skos#" xmlns:foaf="http://xmlns.com/foaf/0.1/">
  <rdf:Description rdf:about="http://xmlns.com/foaf/0.1/workplaceHomepage">
    <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#DatatypeProperty" />
    <rdfs:label rdf:resource="workplace homepage" />
    <rdfs:domain rdf:resource="http://xmlns.com/foaf/0.1/Person" />
    <vitro:descriptionAnnot rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
      A workplace homepage of some person; the homepage of an organization they work for. 
    </vitro:descriptionAnnot>
  </rdf:Description>
  <rdf:Description rdf:about="http://profiles.ucsf.edu/ontology/ucsf#hmsPubCategory">
    <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#DatatypeProperty" />
    <rdfs:label rdf:resource="HMS publication category" />
    <rdfs:domain rdf:resource="http://vivoweb.org/ontology/core#InformationResource" />
    <vitro:descriptionAnnot rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
      The publication category used by HMS for recoginizing various types of publications.
    </vitro:descriptionAnnot>
  </rdf:Description>
  <rdf:Description rdf:about="http://profiles.ucsf.edu/ontology/ucsf#hasClaimedPublication">
    <rdf:type rdf:resource="http://www.w3.org/2002/07/owl#DatatypeProperty" />
    <rdfs:label rdf:resource="Person has claimed publications" />
    <rdfs:domain rdf:resource="http://vivoweb.org/ontology/core#Authorship" />
    <vitro:descriptionAnnot rdf:datatype="http://www.w3.org/2001/XMLSchema#boolean">
      A flag indicating that this person has verified being an author for this publication.
    </vitro:descriptionAnnot>
  </rdf:Description>
</rdf:RDF>', 100)

-- Import the Updated PRNS ontology into Profiles. This should not eliminate any customizations unless additional 
-- classes have been added to the PRNS ontology

IF NOT EXISTS(SELECT * FROM [Ontology.].[Namespace] WHERE Prefix='ucsf')
BEGIN
	INSERT INTO [Ontology.].[Namespace] (URI, Prefix) VALUES ('http://profiles.ucsf.edu/ontology/ucsf#', 'ucsf')
END

UPDATE [Ontology.Import].OWL SET Graph = 5 WHERE name = 'UCSF_1.2'
EXEC [Ontology.Import].[ConvertOWL2Triple] @OWL = 'UCSF_1.2'

EXEC [RDF.Stage].[LoadTriplesFromOntology] @Truncate = 1
EXEC [RDF.Stage].[ProcessTriples]

-- see if work needs to be done to get the ClassProperty items correct!  Compare to old DB


-- these existing ones should be fine
--SELECT * FROM [Ontology.].[DataMap] WHERE Property in ('http://xmlns.com/foaf/0.1/workplaceHomepage','http://profiles.ucsf.edu/ontology/ucsf#hmsPubCategory');
DELETE FROM [Ontology.].[ClassProperty] WHERE Property in ('http://xmlns.com/foaf/0.1/workplaceHomepage',
	'http://profiles.ucsf.edu/ontology/ucsf#hmsPubCategory', 'http://profiles.ucsf.edu/ontology/ucsf#hasClaimedPublication')

DELETE FROM [Ontology.].[DataMap] WHERE Property in ('http://xmlns.com/foaf/0.1/workplaceHomepage',
	'http://profiles.ucsf.edu/ontology/ucsf#hmsPubCategory', 'http://profiles.ucsf.edu/ontology/ucsf#hasClaimedPublication')

-- Workplace Homepage
EXEC [Ontology.].[AddProperty]	@OWL = 'UCSF_1.2',
								@PropertyURI = 'http://xmlns.com/foaf/0.1/workplaceHomepage',
								@PropertyName = 'workplace homepage',
								@ObjectType = 1,
								@PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupAddress',
								@ClassURI = 'http://xmlns.com/foaf/0.1/Person',
								@IsDetail = 0,
								@IncludeDescription = 0;
								
UPDATE [Ontology.].[ClassProperty] SET CustomDisplay = 1 WHERE Property = 'http://xmlns.com/foaf/0.1/workplaceHomepage';

INSERT INTO [Ontology.].[DataMap] (DataMapID, DataMapGroup, IsAutoFeed, Graph, 
		Class, NetworkProperty, Property, 
		MapTable, 
		sInternalType, sInternalID, 
		oValue,
		oObjectType, Weight, OrderBy, ViewSecurityGroup, EditSecurityGroup)
	VALUES (1000, 1, 1, 1,
		'http://xmlns.com/foaf/0.1/Person', NULL, 'http://xmlns.com/foaf/0.1/workplaceHomepage',
		'[UCSF.].[vwPerson]',
		'Person', 'PersonID',
		'PrettyURL',
		1, 1, NULL, -1, -40)

-- HMS Pub Category
EXEC [Ontology.].[AddProperty]	@OWL = 'UCSF_1.2',
								@PropertyURI = 'http://profiles.ucsf.edu/ontology/ucsf#hmsPubCategory',
								@PropertyName = 'hmsPubCategory',
								@ObjectType = 1,
								@PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupBibobscure',
								@ClassURI = 'http://vivoweb.org/ontology/core#InformationResource',
								@IsDetail = 0,
								@IncludeDescription = 0;
								
INSERT INTO [Ontology.].[DataMap] (DataMapID, DataMapGroup, IsAutoFeed, Graph, 
		Class, NetworkProperty, Property, 
		MapTable, 
		sInternalType, sInternalID, 
		oClass, oInternalType, oInternalID, oValue, oDataType, oLanguage, 
		oObjectType, Weight, OrderBy, ViewSecurityGroup, EditSecurityGroup)
	VALUES (1001, 1, 1, 1,
		'http://vivoweb.org/ontology/core#InformationResource', NULL, 'http://profiles.ucsf.edu/ontology/ucsf#hmsPubCategory',
		'[UCSF.].[vwPublication.MyPub.General]',
		'InformationResource', 'EntityID',
		NULL, NULL, NULL, 'HmsPubCategory', NULL, NULL,
		1, 1, NULL, -1, -40);

-- Claimed Publications
EXEC [Ontology.].[AddProperty]	@OWL = 'UCSF_1.2',
								@PropertyURI = 'http://profiles.ucsf.edu/ontology/ucsf#hasClaimedPublication',
								@PropertyName = 'hasClaimedPublication',
								@ObjectType = 1,
								@PropertyGroupURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#PropertyGroupOverview',
								@ClassURI = 'http://vivoweb.org/ontology/core#Authorship',
								@IsDetail = 0,
								@IncludeDescription = 0,
								@SearchWeight = 0

-- add new one
INSERT INTO [Ontology.].[DataMap] (DataMapID, DataMapGroup, IsAutoFeed, Graph, 
		Class, NetworkProperty, Property, 
		MapTable, 
		sInternalType, sInternalID, 
		oClass, oInternalType, oInternalID, oValue, oDataType, oLanguage, 
		oObjectType, Weight, OrderBy, ViewSecurityGroup, EditSecurityGroup)
	VALUES (1002, 1, 1, 1,
		'http://vivoweb.org/ontology/core#Authorship', NULL, 'http://profiles.ucsf.edu/ontology/ucsf#hasClaimedPublication',
		'[UCSF.].[vwPublication.Entity.Claimed]',
		'Authorship', 'EntityID',
		NULL, NULL, NULL, 'Claimed', 'http://www.w3.org/2001/XMLSchema#boolean', NULL,
		1, 1, NULL, -1, -40);
		
		
EXEC [Ontology.].UpdateDerivedFields;

EXEC [RDF.Stage].[ProcessDataMap] @DataMapID = 1000, @ShowCounts = 1
EXEC [RDF.Stage].[ProcessDataMap] @DataMapID = 1001, @ShowCounts = 1
EXEC [RDF.Stage].[ProcessDataMap] @DataMapID = 1002, @ShowCounts = 1

EXEC [Ontology.].[CleanUp] @Action = 'UpdateIDs';

