<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:prns="http://profiles.catalyst.harvard.edu/ontology/prns#"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:vivo="http://vivoweb.org/ontology/core#"
                exclude-result-prefixes="xsl fo xs fn prns rdf rdfs vivo">
  <xsl:output method="html"/>
  <xsl:param name="searchfor"/>
  <xsl:param name="exactphrase"/>
  <xsl:param name="defaultDomain"/>
  <xsl:param name="root"/>
  <xsl:param name="perpage">15</xsl:param>
  <xsl:param name="page">1</xsl:param>
  <xsl:param name="totalpages">1</xsl:param>
  <xsl:param name="classGrpURIpassedin"/>
  <xsl:param name="classURIpassedin"/>
  <xsl:param name="searchrequest"/>

  <xsl:variable name="classGrpURI" select="rdf:RDF/rdf:Description/prns:matchesClassGroupsList/prns:matchesClassGroup/@rdf:resource"/>
  <xsl:variable name="classURI" select="rdf:RDF/rdf:Description/prns:matchesClassGroupsList/prns:matchesClassGroup/prns:matchesClass/@rdf:resource"/>
  <xsl:variable name="pageLink1">
    <xsl:choose>
      <xsl:when test="/rdf:RDF/rdf:Description/rdf:subject/rdfs:label = 'Search' ">
        <xsl:value-of select="$root"/><![CDATA[/Search/Default.aspx?searchfor=]]><xsl:value-of select="$searchfor"/><![CDATA[&offset=]]>
      </xsl:when>
      <xsl:when test="/rdf:RDF/rdf:Description/rdf:subject/rdfs:label = 'Browse' ">
        <xsl:value-of select="$root"/><![CDATA[/Search/Default.aspx?browsefor=&offset=]]>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="pageLink2">
    <xsl:choose>
      <xsl:when test="/rdf:RDF/rdf:Description/rdf:type/rdfs:label='Network' and rdf:RDF/rdf:Description/rdf:subject/prns:matchesClassGroup ">
        <![CDATA[&classgroupuri=]]><xsl:value-of select="translate($classGrpURI, '#','!')"/><![CDATA[&classuri=]]><xsl:value-of select="translate($classURI, '#','!')"/>
      </xsl:when>
      <xsl:when test="/rdf:RDF/rdf:Description/rdf:subject/rdfs:label = 'Search' ">
        <![CDATA[&classgroupuri=]]><![CDATA[&searchtype=everything]]><![CDATA[&perpage=]]><xsl:value-of select="$perpage"/>
      </xsl:when>
      <xsl:when test="/rdf:RDF/rdf:Description/rdf:subject/rdfs:label = 'Browse' ">
        <![CDATA[&classgroupuri=]]><xsl:value-of select="translate($classGrpURI, '#','!')"/><![CDATA[&classuri=]]><xsl:value-of select="translate($classURI, '#','!')"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="totalPages">
    <xsl:variable name="totalConnections">
      <xsl:choose>
        <xsl:when test="number(rdf:RDF/rdf:Description/prns:numberOfConnections)">
          <xsl:value-of select="number(rdf:RDF/rdf:Description/prns:numberOfConnections)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="number(1)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$totalConnections mod $perpage = 0">
        <xsl:value-of select="($totalConnections div $perpage)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="floor($totalConnections div $perpage) + 1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="number(rdf:RDF/rdf:Description/prns:numberOfConnections)">
        <div class="searchSection" style="margin-bottom:15px;">
          <form id="mainsearch" method="post">
            <input type="hidden" id="classgroupuri" name="classgroupuri" value=""/>
            <input type="hidden" id="classuri" name="classuri" value=""/>
            <input type="hidden" id="searchtype" name="searchtype" value="everything"/>
          </form>
        </div>
<!--
-->
        <div class="listTable" style="margin-top:0px;float: left;z-index:1;">
          <table id="tblSearchResults" class="SearchResults" style="width:775px;">
            <tbody>
              <tr>
                <th class="alignLeft">Match</th>
                <th class="alignCenter">Type</th>
                <th class="alignCenter">Why</th>
              </tr>
              <xsl:for-each select="/rdf:RDF/rdf:Description/prns:hasConnection">
                <xsl:variable name="nodeID" select="@rdf:nodeID"/>
                <xsl:variable name="position" select="position()"/>
                <xsl:choose>
                  <xsl:when test="contains($classGrpURIpassedin,'ClassGroupPeople')">
                    <xsl:for-each select="/rdf:RDF/rdf:Description[@rdf:nodeID=$nodeID]">
                      <xsl:variable name="nodeURI" select="rdf:object/@rdf:resource"/>
                      <tr>
                        <xsl:choose>
                          <xsl:when test="($position mod 2 = 1)">
                            <xsl:attribute name="class">oddRow</xsl:attribute>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:attribute name="class">evenRow</xsl:attribute>
                          </xsl:otherwise>
                        </xsl:choose>
                        <xsl:call-template name="threeColumn"/>
                      </tr>
                    </xsl:for-each>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:for-each select="/rdf:RDF/rdf:Description[@rdf:nodeID=$nodeID]">
                      <xsl:variable name="nodeURI" select="rdf:object/@rdf:resource"/>
                      <tr>
                        <xsl:choose>
                          <xsl:when test="($position mod 2 = 1)">
                            <xsl:attribute name="class">oddRow</xsl:attribute>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:attribute name="class">evenRow</xsl:attribute>
                          </xsl:otherwise>
                        </xsl:choose>
                        <xsl:call-template name="threeColumn"/>
                      </tr>
                    </xsl:for-each>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </tbody>
          </table>
        </div>

        <input type="hidden" id="txtSearchFor" value="{$searchfor}"/>
        <input type="hidden" id="txtClassGroupURI">
          <xsl:attribute name="value">
            <xsl:value-of select="translate($classGrpURIpassedin, '#','!')"/>
          </xsl:attribute>
        </input>
        <input type="hidden" id="txtClassGroup">
          <xsl:attribute name="value">
            <xsl:value-of select="translate($classURIpassedin, '#','!')"/>
          </xsl:attribute>
        </input>
        <input type="hidden" id="txtRoot" value="{$root}"/>
        <input type="hidden" id="txtPerPage" value="{$perpage}"/>
        <input type="hidden" id="txtTotalPages" value="{$totalpages}"/>
        <input type="hidden" id="txtSearchRequest" name="txtSearchRequest" value="{$searchrequest}"/>
        <input type="hidden" id="txtExactPhrase" name="txtExactPhrase" value="{$exactphrase}"/>
        <script language="JavaScript">


          var perpage = 0;
          var root = "";
          var searchfor =  "";
          var classgroupuri = "";
          var classgroup = "";
          var page = 0;
          var totalpages = 0;
          var searchrequest = "";
          var exactphrase = "";



          function GetPageData(){

          perpage = document.getElementById("ddlPerPage").value;
          root = document.getElementById("txtRoot").value;
          searchfor = document.getElementById("txtSearchFor").value;
          classgroupuri = document.getElementById("txtClassGroupURI").value;
          classgroup = document.getElementById("txtClassGroup").value;
          page = document.getElementById("txtPageNumber").value;
          totalpages = document.getElementById("txtTotalPages").value;
          searchrequest = document.getElementById("txtSearchRequest").value;
          exactphrase = document.getElementById("txtExactPhrase").value;

          }
          function NavToPage(){

          window.location = root + "/search/default.aspx?searchtype=everything" + "<xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>searchfor=" + searchfor + "<xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>exactphrase=" + exactphrase + '<xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>classgroupuri=' + classgroupuri + '<xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>classgroup=' + classgroup + '<xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>perpage=' + perpage + '<xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>page=' + page + '<xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>totalpages=' + totalpages;
          }

          function ChangePerPage(){

          GetPageData();
          //always reset the starting page to 1 if the sort or per page count changes
          page = 1;
          NavToPage();

          }

          function ChangePage(){
          GetPageData();
          //its set from the dropdown list
          NavToPage();
          }

          function GotoNextPage(){

          GetPageData();
          page++;
          NavToPage();
          }

          function GotoPreviousPage(){
          GetPageData();
          page--;
          NavToPage();
          }

          function GotoFirstPage(){
          GetPageData();
          page = 1;
          NavToPage();
          }

          function GotoLastPage(){
          GetPageData();
          page = totalpages;
          NavToPage();
          }

          function WhyLink(uri){
          GetPageData();
          window.location = root + '/search/default.aspx?exactphrase=true<xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>searchtype=whyeverything<xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>nodeuri=' + uri + '<xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>searchfor=' + searchfor + '<xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>perpage=' + perpage + '<xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>page=' + page + '<xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>totalpages=' + totalpages + '<xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>searchrequest=' + searchrequest;
          }

        </script>
        
        <div class="listTablePagination" style="float: left;">
          <table>
            <tbody>
              <tr>
                <td>
                  Per Page&#160;<select id="ddlPerPage" onchange="javascript:ChangePerPage()">
                    <xsl:choose>
                      <xsl:when test="$perpage='15'">
                        <option value="15" selected="true">15</option>
                      </xsl:when>
                      <xsl:otherwise>
                        <option value="15">15</option>
                      </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                      <xsl:when test="$perpage='25'">
                        <option value="25" selected="true">25</option>
                      </xsl:when>
                      <xsl:otherwise>
                        <option value="25">25</option>
                      </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                      <xsl:when test="$perpage='50'">
                        <option value="50" selected="true">50</option>
                      </xsl:when>
                      <xsl:otherwise>
                        <option value="50">50</option>
                      </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                      <xsl:when test="$perpage='100'">
                        <option value="100" selected="true">100</option>
                      </xsl:when>
                      <xsl:otherwise>
                        <option value="100">100</option>
                      </xsl:otherwise>
                    </xsl:choose>
                  </select>
                </td>
                <td>
                  &#160;&#160;Page&#160;<input size="1" type="textbox" value="{$page}" id="txtPageNumber" onchange="ChangePage()"/>&#160;of&#160;<xsl:value-of select="$totalpages"/>
                </td>
                <td>
                  <xsl:choose>
                    <xsl:when test="$page&lt;$totalpages">
                      <a href="JavaScript:GotoLastPage();" class="listTablePaginationFL listTablePaginationA">
                        <img src="{$root}/framework/images/arrow_last.gif" border="0"/>
                      </a>
                      <a href="javascript:GotoNextPage();" class="listTablePaginationPN listTablePaginationN listTablePaginationA">
                        Next<img src="{$root}/framework/images/arrow_next.gif" border="0"/>
                      </a>
                    </xsl:when>
                    <xsl:otherwise>
                      <div class="listTablePaginationFL">
                        <img src="{$root}/framework/images/arrow_last_d.gif" border="0"/>
                      </div>
                      <div class="listTablePaginationPN listTablePaginationN">
                        Next<img src="{$root}/framework/images/arrow_next_d.gif" border="0"/>
                      </div>
                    </xsl:otherwise>
                  </xsl:choose>
                  <xsl:choose>
                    <xsl:when test="$page&gt;1">
                      <a href="JavaScript:GotoPreviousPage();" class="listTablePaginationPN listTablePaginationP listTablePaginationA">
                        <img src="{$root}/framework/images/arrow_prev.gif" border="0"/>Prev
                      </a>
                      <a href="JavaScript:GotoFirstPage();" class="listTablePaginationFL listTablePaginationA">
                        <img src="{$root}/framework/images/arrow_first.gif" border="0"/>
                      </a>
                    </xsl:when>
                    <xsl:otherwise>
                      <div class="listTablePaginationPN listTablePaginationP">
                        <img src="{$root}/framework/images/arrow_prev_d.gif" border="0"/>Prev
                      </div>
                      <div class="listTablePaginationFL">
                        <img src="{$root}/framework/images/arrow_first_d.gif" border="0"/>
                      </div>
                    </xsl:otherwise>
                  </xsl:choose>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>No matching results.</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="threeColumn">
    <td onclick="javascript:GoToBranded('{rdf:object/@rdf:resource}', '{$defaultDomain}', '{$root}')" class="alignLeft">
      <xsl:choose>
        <xsl:when test="rdfs:label != ''">
          <xsl:value-of select="rdfs:label"/>
        </xsl:when>
        <xsl:otherwise>
          <a href="{rdf:object/@rdf:resource}">
            <xsl:value-of select="rdf:object/@rdf:resource"/>
          </a>
        </xsl:otherwise>
      </xsl:choose>
    </td>
    <td onclick="javascript:GoToBranded('{rdf:object/@rdf:resource}', '{$defaultDomain}', '{$root}')">
      <xsl:value-of select="vivo:overview"/>
    </td>
    <td>
      <a class="listTableLink"   href="Javascript:WhyLink('{rdf:object/@rdf:resource}');">
        Why?
      </a>
    </td>
  </xsl:template>
</xsl:stylesheet>


<!--<xsl:variable name="rawweight" select="prns:connectionWeight"/>
<xsl:variable name="weight">
  <xsl:value-of select="($rawweight * 1000) div 10"/>
</xsl:variable>
<xsl:value-of select="format-number($weight, '00.00')" />
<xsl:text disable-output-escaping="yes"><![CDATA[%]]></xsl:text>-->
