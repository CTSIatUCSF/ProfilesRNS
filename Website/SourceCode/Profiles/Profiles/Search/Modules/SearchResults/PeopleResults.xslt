<?xml version="1.0" encoding="UTF-8"?>
<?altova_samplexml SearchResults.xml?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:prns="http://profiles.catalyst.harvard.edu/ontology/prns#"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:vivo="http://vivoweb.org/ontology/core#"
                xmlns:foaf="http://xmlns.com/foaf/0.1/"
                exclude-result-prefixes="fo xs fn prns rdf rdfs vivo foaf">
  <xsl:output method="html"/>
  <xsl:param name="searchfor"/>
  <xsl:param name="exactphrase"/>
  <xsl:param name="root"/>
  <xsl:param name="perpage">15</xsl:param>
  <xsl:param name="page">1</xsl:param>
  <xsl:param name="totalpages">1</xsl:param>
  <xsl:param name="searchrequest"/>
  <xsl:param name="offset"/>
  <xsl:param name="why"  />
  <xsl:param name="showcolumns"  />
  <xsl:param name="currentsort"  />
  <xsl:param name="currentsortdirection"  />

  <xsl:param name="facrank"></xsl:param>
  <xsl:param name="institution"></xsl:param>
  <xsl:param name="department"></xsl:param>

  <xsl:param name="ShowFacRank"/>
  <xsl:param name="ShowInstitutions"  />

  <xsl:param name="ShowDepartments"  />

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

    <input type="hidden" id="txtSearchFor" value="{$searchfor}"/>
    <input type="hidden" id="txtExactPhrase" value="{$exactphrase}"/>
    <input type="hidden" id="txtSearchRequest" name="txtSearchRequest" value="{$searchrequest}"/>
    <input type="hidden" id="txtRoot" value="{$root}"/>
    <input type="hidden" id="txtPerPage" value="{$perpage}"/>
    <input type="hidden" id="txtOffset" value="{$offset}"/>
    <input type="hidden" id="txtTotalPages" value="{$totalpages}"/>
    <input type="hidden" id="txtCurrentSort"  value="{$currentsort}"/>
    <input type="hidden" id="txtCurrentSortDirection" value="{$currentsortdirection}"/>
    <input type="hidden" name="showcolumns" id="showcolumns" value="{$showcolumns}"/>

    <xsl:choose>
      <xsl:when test="number(rdf:RDF/rdf:Description/prns:numberOfConnections)">
        <xsl:variable name="document" select="rdf:RDF"></xsl:variable>

        <table>
          <tr>
            <td style="width:33%;vertical-align:middle;">
              <div style="float:right">
                Sort&#160;<select id="selSort" title="Query Relevance" onchange="JavaScript:DropdownSort();">
                  <option value="">Query Relevance</option>
                  <xsl:choose>
                    <xsl:when test="$currentsort='name'">
                      <xsl:choose>
                        <xsl:when test="$currentsortdirection='desc'">
                          <option selected="true" value="name_desc">Name (A-Z)</option>
                          <option value="name_asc">Name (Z-A)</option>
                        </xsl:when>
                        <xsl:otherwise>
                          <option value="name_desc">Name (A-Z)</option>
                          <option selected="true" value="name_asc">Name (Z-A)</option>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                      <option value="name_desc">Name (A-Z)</option>
                      <option value="name_asc">Name (Z-A)</option>
                    </xsl:otherwise>
                  </xsl:choose>


                  <xsl:if test="$institution='true'">
                    <xsl:choose>
                      <xsl:when test="$currentsort='institution'">
                        <xsl:choose>
                          <xsl:when test="$currentsortdirection='desc'">
                            <option selected="true" value="institution_desc">Institution (A-Z)</option>
                            <option value="institution_asc">Institution (Z-A)</option>
                          </xsl:when>
                          <xsl:otherwise>
                            <option value="institution_desc">Institution (A-Z)</option>
                            <option selected="true" value="institution_asc">Institution (Z-A)</option>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:when>
                      <xsl:otherwise>
                        <option value="institution_desc">Institution (A-Z)</option>
                        <option value="institution_asc">Institution (Z-A)</option>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:if>

                  <xsl:if test="$department='true'">
                    <xsl:choose>
                      <xsl:when test="$currentsort='department'">
                        <xsl:choose>
                          <xsl:when test="$currentsortdirection='desc'">
                            <option selected="true" value="department_desc">Department (A-Z)</option>
                            <option value="department_asc">Department (Z-A)</option>
                          </xsl:when>
                          <xsl:otherwise>
                            <option value="department_desc">Department (A-Z)</option>
                            <option selected="true" value="department_asc">Department (Z-A)</option>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:when>
                      <xsl:otherwise>
                        <option value="department_desc">Department (A-Z)</option>
                        <option value="department_asc">Department (Z-A)</option>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:if>


                  <xsl:if test="$facrank='true'">
                    <xsl:choose>
                      <xsl:when test="$currentsort='facrank'">
                        <xsl:choose>
                          <xsl:when test="$currentsortdirection='desc'">
                            <option selected="true" value="facrank_desc">Researcher Type(high-low)</option>
                            <option value="facrank_asc">Researcher Type(low-high)</option>
                          </xsl:when>
                          <xsl:otherwise>
                            <option value="facrank_desc">Researcher Type(high-low)</option>
                            <option selected="true" value="facrank_asc">Researcher Type(low-high)</option>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:when>
                      <xsl:otherwise>
                        <option value="facrank_desc">Researcher Type(high-low)</option>
                        <option value="facrank_asc">Researcher Type(low-high)</option>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:if>

                </select>
              </div>
            </td>
            <td style="width:33%;vertical-align:middle;">
              <div style="float: right;">
                <input type="hidden" id="hiddenToggle" value="off" />
                Show&#160;
                <select id="selColSelect" title="choose columns" style="width: 149px">
                  <option value="">(choose columns)</option>
                </select>
                <table>
                  <tr>
                    <td style="padding-left:45px">
                      <div id="divColSelect" style="border-right: solid 1px gray; border-bottom: solid 1px gray;
                                                border-left: solid 1px silver; padding-left:3px; margin-left: -5px; margin-top: -1px; height: 100; width: 144px; overflow: auto;
                                                background-color: #ffffff;z-index:5;position: absolute;">
                        <xsl:if test="$ShowInstitutions='true'">
                          <br />
                          <input type="checkbox" id="chkInstitution" name="chkInstitution" value="Institution" class="otherOptionCheckBox" title="Institution"/>
                          <span>Institution</span>
                        </xsl:if>
                        <xsl:if test="$ShowDepartments='true'">
                          <br></br>
                          <input type="checkbox" id="chkDepartment" name="chkDepartment" value="Department" class="otherOptionCheckBox" title="Department"/>
                          <span>Department</span>
                        </xsl:if>

                        <xsl:if test="$ShowFacRank='true'">
                          <br></br>
                          <input type="checkbox" id="chkFacRank" name="chkFacRank" value="Faculty Rank" class="otherOptionCheckBox" title="Faculty Rank"/>
                          <span>Researcher Type</span>
                        </xsl:if>
                      </div>
                    </td>
                  </tr>
                </table>
              </div>
            </td>
            <td style="width:33%;vertical-align:middle;">
              <xsl:choose>
                <xsl:when test="$why">
                  <div id="why">
                    Click <b>Why?</b> to see a researcher's relevant publications.
                  </div>
                </xsl:when>
                <xsl:otherwise>
                  <div style="width:150px"></div>
                </xsl:otherwise>
              </xsl:choose>
            </td>
          </tr>
          <tr>
            <td colspan="3" height="10">
              <xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>nbsp;
            </td>
          </tr>

          <tr>
            <td colspan="3">
              <div class="listTable" style="margin-top:0px;">
                <table id="tblSearchResults" class="SearchResults">
                  <tbody>
                    <tr>
                      <th class="alignLeft">
                        <a href="JavaScript:Sort('name');">
                          Name
                          <xsl:choose>
                            <xsl:when test="$currentsort='name'">
                              <xsl:choose>
                                <xsl:when test="$currentsortdirection='desc'">
                                  <img src="{$root}/framework/images/sort_desc.gif" border="0" alt="sort descending"/>
                                </xsl:when>
                                <xsl:otherwise>
                                  <img src="{$root}/framework/images/sort_asc.gif" border="0" alt="sort ascending"/>
                                </xsl:otherwise>
                              </xsl:choose>
                            </xsl:when>
                          </xsl:choose>
                        </a>
                      </th>
                      <xsl:if test="$institution='true'">
                        <th class="alignLeft">
                          <a href="JavaScript:Sort('institution');">
                            Institution
                            <xsl:choose>
                              <xsl:when test="$currentsort='institution'">
                                <xsl:choose>
                                  <xsl:when test="$currentsortdirection='desc'">
                                    <img src="{$root}/framework/images/sort_desc.gif" border="0" alt="sort descending"/>
                                  </xsl:when>
                                  <xsl:otherwise>
                                    <img src="{$root}/framework/images/sort_asc.gif" border="0" alt="sort ascending"/>
                                  </xsl:otherwise>
                                </xsl:choose>
                              </xsl:when>
                            </xsl:choose>
                          </a>
                        </th>
                      </xsl:if>
                      <xsl:if test="$department='true'">
                        <th class="alignLeft">
                          <a href="JavaScript:Sort('department');">
                            Department
                            <xsl:choose>
                              <xsl:when test="$currentsort='department'">
                                <xsl:choose>
                                  <xsl:when test="$currentsortdirection='desc'">
                                    <img src="{$root}/framework/images/sort_desc.gif" border="0" alt="sort descending"/>
                                  </xsl:when>
                                  <xsl:otherwise>
                                    <img src="{$root}/framework/images/sort_asc.gif" border="0" alt="sort ascending"/>
                                  </xsl:otherwise>
                                </xsl:choose>
                              </xsl:when>
                            </xsl:choose>
                          </a>
                        </th>
                      </xsl:if>

                      <xsl:if test="$facrank='true'">
                        <th class="alignLeft">
                          <a href="JavaScript:Sort('facrank');">
                            Researcher Type
                            <xsl:choose>
                              <xsl:when test="$currentsort='facrank'">
                                <xsl:choose>
                                  <xsl:when test="$currentsortdirection='desc'">
                                    <img src="{$root}/framework/images/sort_desc.gif" border="0" alt="sort descending"/>
                                  </xsl:when>
                                  <xsl:otherwise>
                                    <img src="{$root}/framework/images/sort_asc.gif" border="0" alt="sort ascending"/>
                                  </xsl:otherwise>
                                </xsl:choose>
                              </xsl:when>
                            </xsl:choose>
                          </a>
                        </th>
                      </xsl:if>
                      <xsl:choose>
                        <xsl:when test="$why">
                          <th class="alignCenter">Why</th>
                        </xsl:when>
                      </xsl:choose>
                    </tr>
                    <xsl:for-each select="/rdf:RDF/rdf:Description/prns:hasConnection">
                      <xsl:variable name="nodeID" select="@rdf:nodeID"/>
                      <xsl:variable name="weight" select="/rdf:RDF/rdf:Description[@rdf:nodeID=$nodeID]/prns:connectionWeight"/>
                      <xsl:variable name="position" select="position()"/>
                      <xsl:for-each select="/rdf:RDF/rdf:Description[@rdf:nodeID=$nodeID]">
                        <xsl:variable name="nodeURI" select="rdf:object/@rdf:resource"/>
                        <tr>
                          <xsl:for-each select="/rdf:RDF/rdf:Description[@rdf:about=$nodeURI]">
                            <xsl:choose>
                              <xsl:when test="($position mod 2 = 1)">
                                <xsl:attribute name="class">oddRow</xsl:attribute>
                                <xsl:attribute name="onmouseout">HideDetails(this,1)</xsl:attribute>
                                <xsl:attribute name="onblur">HideDetails(this,1)</xsl:attribute>
                                <xsl:attribute name="onmouseover">
                                  ShowDetails('<xsl:value-of select="$nodeURI"/>',this)
                                  </xsl:attribute>
                                <xsl:attribute name="onfocus">
                                  ShowDetails('<xsl:value-of select="$nodeURI"/>',this)
                                  </xsl:attribute>
                                <xsl:attribute name="tabindex">0</xsl:attribute>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:attribute name="class">evenRow</xsl:attribute>
                                <xsl:attribute name="onmouseout">HideDetails(this,0)</xsl:attribute>
                                <xsl:attribute name="onblur">HideDetails(this,0)</xsl:attribute>
                                <xsl:attribute name="onmouseover">
                                  ShowDetails('<xsl:value-of select="$nodeURI"/>',this)
                                </xsl:attribute>
                                <xsl:attribute name="onFocus">
                                  ShowDetails('<xsl:value-of select="$nodeURI"/>',this)
                                </xsl:attribute>
                                <xsl:attribute name="tabindex">0</xsl:attribute>
                              </xsl:otherwise>
                            </xsl:choose>
                            <xsl:choose>
                              <xsl:when test="$why">
                                <xsl:call-template name="whyColumn">
                                  <xsl:with-param name="doc" select="$document"></xsl:with-param>
                                  <xsl:with-param name="nodeURI" select="$nodeURI"></xsl:with-param>
                                  <xsl:with-param name="weight" select ="$weight"></xsl:with-param>
                                  <xsl:with-param name="searchfor" select ="$searchfor"></xsl:with-param>
                                  <xsl:with-param name="exactphrase" select ="$exactphrase"></xsl:with-param>
                                  <xsl:with-param name="perpage" select ="$perpage"></xsl:with-param>
                                  <xsl:with-param name="offset" select ="$offset"></xsl:with-param>
                                  <xsl:with-param name="page" select ="$page"></xsl:with-param>
                                  <xsl:with-param name="totalpages" select ="$totalpages"></xsl:with-param>
                                  <xsl:with-param name="searchrequest" select ="$searchrequest"></xsl:with-param>
                                  <xsl:with-param name="sortby" select ="$currentsort"></xsl:with-param>
                                  <xsl:with-param name="sortdirection" select ="$currentsortdirection"></xsl:with-param>
                                  <xsl:with-param name="showcolumns" select ="$showcolumns"></xsl:with-param>
                                  <xsl:with-param name="root" select ="$root"></xsl:with-param>

                                </xsl:call-template>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:call-template name="threeColumn">
                                  <xsl:with-param name="doc" select="$document"></xsl:with-param>
                                  <xsl:with-param name="nodeURI" select ="$nodeURI"></xsl:with-param>
                                  <xsl:with-param name="weight" select ="$weight"></xsl:with-param>
                                </xsl:call-template>
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:for-each>
                        </tr>
                      </xsl:for-each>
                    </xsl:for-each>
                  </tbody>
                </table>
              </div>
            </td>
          </tr>
        </table>

        <div class="listTablePagination" style="float: left; margin-left: 1px;">
          <table>
            <tbody>
              <tr>
                <td>
                  Per Page&#160;<select id="ddlPerPage" title="Results per page" onchange="javascript:ChangePerPage()">
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
                  &#160;&#160;Page&#160;<input size="1" type="textbox" value="{$page}" id="txtPageNumber" onchange="ChangePage()" onkeypress="JavaScript:changePage(event);" title="select page"/>&#160;of&#160;<xsl:value-of select="$totalpages"/>
                </td>
                <td>
                  <xsl:choose>
                    <xsl:when test="$page&lt;$totalpages">
                      <a href="JavaScript:GotoLastPage();" class="listTablePaginationFL listTablePaginationA">
                        <img src="{$root}/framework/images/arrow_last.gif" border="0" alt="last"/>
                      </a>
                      <a href="javascript:GotoNextPage();" class="listTablePaginationPN listTablePaginationN listTablePaginationA">
                        Next<img src="{$root}/framework/images/arrow_next.gif" border="0" alt="next"/>
                      </a>
                    </xsl:when>
                    <xsl:otherwise>
                      <div class="listTablePaginationFL">
                        <img src="{$root}/framework/images/arrow_last_d.gif" border="0" alt=""/>
                      </div>
                      <div class="listTablePaginationPN listTablePaginationN">
                        Next<img src="{$root}/framework/images/arrow_next_d.gif" border="0" alt=""/>
                      </div>
                    </xsl:otherwise>
                  </xsl:choose>
                  <xsl:choose>
                    <xsl:when test="$page&gt;1">
                      <a href="JavaScript:GotoPreviousPage();" class="listTablePaginationPN listTablePaginationP listTablePaginationA">
                        <img src="{$root}/framework/images/arrow_prev.gif" border="0" alt="previous"/>Prev
                      </a>
                      <a href="JavaScript:GotoFirstPage();" class="listTablePaginationFL listTablePaginationA">
                        <img src="{$root}/framework/images/arrow_first.gif" border="0" alt="first"/>
                      </a>
                    </xsl:when>
                    <xsl:otherwise>
                      <div class="listTablePaginationPN listTablePaginationP">
                        <img src="{$root}/framework/images/arrow_prev_d.gif" border="0" alt=""/>Prev
                      </div>
                      <div class="listTablePaginationFL">
                        <img src="{$root}/framework/images/arrow_first_d.gif" border="0" alt=""/>
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

    <script language="JavaScript">


      var perpage = 0;
      var root = "";
      var searchfor =  "";
      var exactphrase = "";
      var classgroupuri = "";
      var classgroup = "";
      var page = 0;
      var totalpages = 0;
      var searchrequest = "";
      var sortby = "";
      var sortdirection = "";
      var institution ="";
      var department ="";

      var facrank = "";
      var offset = "";
      var sortbydropdown = false;

      SetupColCheckboxes();



      function changePage(e) {
      if (e.keyCode == 13) {
      ChangePage();
      }
      return false;
      }




      function SetupColCheckboxes(){

      if(document.getElementById("chkInstitution")!=null){
      if((document.getElementById("showcolumns").value <xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text> 1)){
      document.getElementById("chkInstitution").checked = true;
      }else{
      document.getElementById("chkInstitution").checked = false;
      }
      }

      if(document.getElementById("chkDepartment")!=null){
      if((document.getElementById("showcolumns").value <xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text> 2)){
      document.getElementById("chkDepartment").checked = true;
      }else{
      document.getElementById("chkDepartment").checked = false;
      }

      }


      if(document.getElementById("chkFacRank")!=null){
      if((document.getElementById("showcolumns").value <xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text> 8)){
      document.getElementById("chkFacRank").checked = true;
      }else{
      document.getElementById("chkFacRank").checked = false;
      }
      }


      }

      function DropdownSort(){

      var dropdown = document.getElementById("selSort");
      var val = dropdown.options[dropdown.selectedIndex].value;

      if(val!=''){
      this.Sort(val);
      }

      }

      function GetPageData(){


      perpage = document.getElementById("ddlPerPage").value;
      root = document.getElementById("txtRoot").value;
      searchfor = document.getElementById("txtSearchFor").value;
      exactphrase = document.getElementById("txtExactPhrase").value;
      page = document.getElementById("txtPageNumber").value;
      totalpages = document.getElementById("txtTotalPages").value;
      searchrequest = document.getElementById("txtSearchRequest").value;

      if(document.getElementById("selSort").value==''){
      sortby = document.getElementById("txtCurrentSort").value;
      }else{
      sortby = document.getElementById("selSort").value;

      if(sortby.indexOf("_")!=-1){
      var mySplitResult = sortby.split("_");
      sortby = mySplitResult[0];
      }

      }

      sortdirection = document.getElementById("txtCurrentSortDirection").value;
      offset = document.getElementById("txtOffset").value;

      if(page==0){
      page = 1;
      }


      if(document.getElementById("chkInstitution")!=null){
      institution = document.getElementById("chkInstitution").checked;
      }

      if(document.getElementById("chkDepartment")!=null){
      department = document.getElementById("chkDepartment").checked;
      }




      if(document.getElementById("chkFacRank")!=null){
      facrank = document.getElementById("chkFacRank").checked;
      }



      }

      function Sort(sort){

      GetPageData();

      if(sort.indexOf("_")==-1){

      if(sortby.indexOf("_")!=-1){
      var mySplitResult = sortby.split("_");
      sortby = mySplitResult[0];
      }

      if(sort==sortby){

      if(sortdirection=="desc"){
      sortdirection = "asc";
      }else{
      sortdirection = "desc";
      }

      }else{

      sortdirection = "desc";
      sortby = sort;
      }

      }else{

      var items = sort.split("_");

      sortby = items[0];
      sortdirection = items[1];


      }


      NavToPage();

      }

      function NavToPage(){

      var showcolumns = 0;

      if(institution){
      showcolumns = 1;
      }
      if(department){
      showcolumns = showcolumns | 2;
      }



      if(facrank){
      showcolumns = showcolumns | 8;
      }

      window.location = root + '/search/default.aspx?searchtype=people<xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>searchfor=' + searchfor + '<xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>exactphrase=' + exactphrase + '<xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>perpage=' + perpage + '<xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>offset=' + offset + '<xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>page=' + page + '<xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>totalpages=' + totalpages + '<xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>searchrequest=' + searchrequest +  '<xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>sortby=' + sortby+ '<xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>sortdirection=' + sortdirection + '<xsl:text disable-output-escaping="yes"><![CDATA[&]]></xsl:text>showcolumns=' + showcolumns;
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

      function ShowDetails(nodeURI,obj){
        doListTableRowOver(obj);
//      debugger;
        document.getElementById('divItemDetails').innerHTML = document.getElementById(nodeURI).value;
      }

      function HideDetails(obj,ord){
        doListTableRowOut(obj,ord);
        document.getElementById('divItemDetails').innerHTML = '';
      }



      <!--// create global code object if not already created-->
      if (undefined==ProfilesRNS) var ProfilesRNS = {};


      var $defaultColumns = null;

      <!--Reloads page only if new columns are selected-->
      function reloadColumns()
      {
      var reload = false;
      var $colToShow = $('#divColSelect input:checked');

      // Check column count first.
      if ($colToShow.length != $defaultColumns.length)
      {
      GetPageData();
      NavToPage();
      return;
      }

      // See if column selection have changed from default
      $colToShow.each(function(idx, item){
      if ($defaultColumns.filter("#"+$(this).get(0).id).length != 1)
      {
      GetPageData();
      NavToPage();
      return false; // exit loop
      }
      });
      }

      <!--// <START::SHOW/HIDE OTHER OPTIONS DROPDOWN LIST>-->
      $(document).ready(function() {

      // initially hide the other options DIV
      $("#divColSelect").hide();

      // hide/show event occurs on click of dropdown
      $("#selColSelect").focus(function() {
	  $("#selColSelect").click();
      if ($("#divColSelect").is(":visible")) {
      $("#divColSelect").hide();

      reloadColumns();

      $("//*[@id='divSearchSection']/descendant::input[@type='submit']").focus();

      } else {
      $("#divColSelect").show();

      // Set default columns to show
      $defaultColumns = $('#divColSelect input:checked');

      $("*[id*=institution]").focus();
      }
      });

      // hide the other options DIV when a click occurs outside of the DIV while it's shown
      $(document).click(function(evt) {
      if ($("#divColSelect").is(":visible")) {
      switch (evt.target.id) {
      case "selColSelect":
      case "divColSelect":
      break;
      default:
      var tmp = evt.target;
      while (tmp.parentNode) {
      tmp = tmp.parentNode;
      if (tmp.id == "divColSelect") { return true; }
      }
      $("#divColSelect").hide();

      reloadColumns()
      }
      }
      });

      });


      $('#divColSelect span')
      .hover(
      function(){ // Mouse in
      $(this).css('cursor', 'pointer');
      },
      function(){ // Mouse out
      $(this).css('cursort', 'default');
      })
      .click(function(){ // select checkbox when checkbox label is clicked
      var $checkbox = $(this).prev('input');
      $checkbox.attr('checked', !$checkbox.attr('checked'));
      });
      <!--// <END::SHOW/HIDE OTHER OPTIONS DROPDOWN LIST>-->


    </script>

  </xsl:template>


  <xsl:template name="threeColumn">
    <xsl:param name="doc"></xsl:param>
    <xsl:param name="nodeURI"></xsl:param>
    <xsl:param name="weight"></xsl:param>
    <xsl:variable name="positon" select="prns:personInPrimaryPosition/@rdf:resource"></xsl:variable>
    <xsl:variable name="institutionlabel" select="$doc/rdf:Description[@rdf:about=$positon]/vivo:positionInOrganization/@rdf:resource"></xsl:variable>

    <xsl:variable name="titlelink">
      <xsl:choose>
        <xsl:when test="vivo:preferredTitle!=''">
          &lt;br/&gt;&lt;br/&gt;&lt;u&gt;Title&lt;/u&gt; &lt;br/&gt;<xsl:value-of select="vivo:preferredTitle"/>
        </xsl:when>
        <xsl:otherwise>

        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="institutionlink">
      <xsl:choose>
        <xsl:when test="$doc/rdf:Description[@rdf:about=$institutionlabel]!=''">
          &lt;br/&gt;&lt;br/&gt;&lt;u&gt;Institution&lt;/u&gt;&lt;br/&gt;<xsl:value-of select="$doc/rdf:Description[@rdf:about=$institutionlabel]"/>
        </xsl:when>
        <xsl:otherwise>

        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="departmentlink">
      <xsl:choose>
        <xsl:when test="$doc/rdf:Description[@rdf:about=$doc/rdf:Description[@rdf:about=$positon]/prns:positionInDepartment/@rdf:resource]/rdfs:label!=''">
          &lt;br/&gt;&lt;br/&gt;&lt;u&gt;Department&lt;/u&gt;&lt;br/&gt;<xsl:value-of select="$doc/rdf:Description[@rdf:about=$doc/rdf:Description[@rdf:about=$positon]/prns:positionInDepartment/@rdf:resource]/rdfs:label"/>
        </xsl:when>
        <xsl:otherwise>

        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="divisionlink">
      <xsl:choose>
        <xsl:when test="$doc/rdf:Description[@rdf:about=$doc/rdf:Description[@rdf:about=$positon]/prns:positionInDivision/@rdf:resource]/rdfs:label!=''">
          &lt;br/&gt;&lt;br/&gt;&lt;u&gt;Division&lt;/u&gt;&lt;br/&gt;<xsl:value-of select="$doc/rdf:Description[@rdf:about=$doc/rdf:Description[@rdf:about=$positon]/prns:positionInDivision/@rdf:resource]/rdfs:label"/>
        </xsl:when>
        <xsl:otherwise>

        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="facranklink">
      <xsl:choose>
        <xsl:when test="$doc/rdf:Description[@rdf:about=$doc/rdf:Description[@rdf:about=$nodeURI]/prns:hasFacultyRank/@rdf:resource]/rdfs:label">
          &lt;br/&gt;&lt;br/&gt;&lt;u&gt;Researcher Type&lt;/u&gt;&lt;br/&gt;<xsl:value-of select="$doc/rdf:Description[@rdf:about=$doc/rdf:Description[@rdf:about=$nodeURI]/prns:hasFacultyRank/@rdf:resource]/rdfs:label"/>
        </xsl:when>
        <xsl:otherwise>

        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>


    <input type="hidden" id="{$nodeURI}" value="&lt;div style='font-size:13px;font-weight:bold'&gt;{foaf:firstName} {foaf:lastName}&lt;/div&gt;{$titlelink}{$institutionlink}{$departmentlink}{$divisionlink}{$facranklink}"></input>




    <td class="alignLeft" style="width:200px" onclick="javascript:GoTo('{$nodeURI}')">
      <xsl:value-of select="prns:fullName"/>
     
    </td>

    <xsl:if test="$institution='true'">
      
      <td class="alignLeft" style="width:250px" onclick="javascript:GoTo('{$nodeURI}')">
        <xsl:value-of select ="$doc/rdf:Description[@rdf:about=$institutionlabel]"/>
      </td>
    </xsl:if>

    <xsl:if test="$department='true'">
      <td class="alignLeft" style="width:250px">

        <xsl:value-of select ="$doc/rdf:Description[@rdf:about=$doc/rdf:Description[@rdf:about=$positon]/prns:positionInDepartment/@rdf:resource]/rdfs:label"/>

      </td>
    </xsl:if>


    <xsl:if test="$facrank='true'">
      <td class="alignLeft" style="width:250px;">
        <xsl:choose>
          <xsl:when test ="$doc/rdf:Description[@rdf:about=$doc/rdf:Description[@rdf:about=$nodeURI]/prns:hasFacultyRank/@rdf:resource]/rdfs:label!=''">

            <xsl:value-of select ="$doc/rdf:Description[@rdf:about=$doc/rdf:Description[@rdf:about=$nodeURI]/prns:hasFacultyRank/@rdf:resource]/rdfs:label"/>

          </xsl:when>
          <xsl:otherwise>
            <center>

              --

            </center>
          </xsl:otherwise>
        </xsl:choose>
      </td>
    </xsl:if>



  </xsl:template>

  <xsl:template name="whyColumn">
    <xsl:param name="doc"></xsl:param>
    <xsl:param name="nodeURI"></xsl:param>
    <xsl:param name="weight"></xsl:param>
    <xsl:param name="searchfor"></xsl:param>
    <xsl:param name="exactphrase"></xsl:param>
    <xsl:param name="perpage"></xsl:param>
    <xsl:param name="offset"></xsl:param>
    <xsl:param name="page"></xsl:param>
    <xsl:param name="totalpages"></xsl:param>
    <xsl:param name="searchrequest"></xsl:param>
    <xsl:param name="sortby"></xsl:param>
    <xsl:param name="sortdirection"></xsl:param>
    <xsl:param name="showcolumns"></xsl:param>
    <xsl:param name="root"></xsl:param>


    <xsl:variable name="positon" select="prns:personInPrimaryPosition/@rdf:resource"></xsl:variable>
    <xsl:variable name="bpositon" select="$doc/rdf:Description[@rdf:about=$positon]/vivo:positionInOrganization/@rdf:resource"></xsl:variable>

    <xsl:variable name="institutionlabel" select="$doc/rdf:Description[@rdf:about=$positon]/vivo:positionInOrganization/@rdf:resource"></xsl:variable>
    <td class="alignLeft" style="width:200px">
      <a class="listTableLink" href="{$nodeURI}">
        <xsl:value-of select="prns:fullName"/>
      </a>

    </td>
    <xsl:if test="$institution='true'">
      <td class="alignLeft" style="width:250px">

        <xsl:value-of select ="$doc/rdf:Description[@rdf:about=$institutionlabel]"/>

      </td>
    </xsl:if>
    <xsl:if test="$department='true'">
      <td class="alignLeft" style="width:250px">

        <xsl:value-of select ="$doc/rdf:Description[@rdf:about=$doc/rdf:Description[@rdf:about=$positon]/prns:positionInDepartment/@rdf:resource]/rdfs:label"/>

      </td>
    </xsl:if>


    <xsl:if test="$facrank='true'">
      <td class="alignLeft" style="width:250px">
        <xsl:choose>
          <xsl:when test ="$doc/rdf:Description[@rdf:about=$doc/rdf:Description[@rdf:about=$nodeURI]/prns:hasFacultyRank/@rdf:resource]/rdfs:label!=''">

            <xsl:value-of select ="$doc/rdf:Description[@rdf:about=$doc/rdf:Description[@rdf:about=$nodeURI]/prns:hasFacultyRank/@rdf:resource]/rdfs:label"/>

          </xsl:when>
          <xsl:otherwise>
            <center>

              --

            </center>
          </xsl:otherwise>
        </xsl:choose>
      </td>
    </xsl:if>



    <td valign="middle" style="width:100px" >
      <a class="listTableLink"  href="{$root}/search/default.aspx?searchtype=whypeople&amp;nodeuri={$nodeURI}&amp;searchfor={$searchfor}&amp;exactphrase={$exactphrase}&amp;perpage={$perpage}&amp;offset={$offset}&amp;page={$page}&amp;totalpages={$totalpages}&amp;searchrequest={$searchrequest}&amp;sortby={$sortby}&amp;sortdirection={$sortdirection}&amp;showcolumns={$showcolumns}">
        Why?
      </a>

      <xsl:variable name="titlelink">
        <xsl:choose>
          <xsl:when test="vivo:preferredTitle!=''">
            &lt;br/&gt;&lt;br/&gt;&lt;u&gt;Title:&lt;/u&gt; &lt;br/&gt;<xsl:value-of select="vivo:preferredTitle"/>
          </xsl:when>
          <xsl:otherwise>

          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="institutionlink">
        <xsl:choose>
          <xsl:when test="$doc/rdf:Description[@rdf:about=$institutionlabel]!=''">
            &lt;br/&gt;&lt;br/&gt;&lt;u&gt;Institution&lt;/u&gt;&lt;br/&gt;<xsl:value-of select="$doc/rdf:Description[@rdf:about=$institutionlabel]"/>
          </xsl:when>
          <xsl:otherwise>

          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="departmentlink">
        <xsl:choose>
          <xsl:when test="$doc/rdf:Description[@rdf:about=$doc/rdf:Description[@rdf:about=$positon]/prns:positionInDepartment/@rdf:resource]/rdfs:label!=''">
            &lt;br/&gt;&lt;br/&gt;&lt;u&gt;Department&lt;/u&gt;&lt;br/&gt;<xsl:value-of select="$doc/rdf:Description[@rdf:about=$doc/rdf:Description[@rdf:about=$positon]/prns:positionInDepartment/@rdf:resource]/rdfs:label"/>
          </xsl:when>
          <xsl:otherwise>

          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="divisionlink">
        <xsl:choose>
          <xsl:when test="$doc/rdf:Description[@rdf:about=$doc/rdf:Description[@rdf:about=$positon]/prns:positionInDivision/@rdf:resource]/rdfs:label!=''">
            &lt;br/&gt;&lt;br/&gt;&lt;u&gt;Division&lt;/u&gt;&lt;br/&gt;<xsl:value-of select="$doc/rdf:Description[@rdf:about=$doc/rdf:Description[@rdf:about=$positon]/prns:positionInDivision/@rdf:resource]/rdfs:label"/>
          </xsl:when>
          <xsl:otherwise>

          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="facranklink">
        <xsl:choose>
          <xsl:when test="$doc/rdf:Description[@rdf:about=$doc/rdf:Description[@rdf:about=$nodeURI]/prns:hasFacultyRank/@rdf:resource]/rdfs:label">
            &lt;br/&gt;&lt;br/&gt;&lt;u&gt;Researcher Type&lt;/u&gt;&lt;br/&gt;<xsl:value-of select="$doc/rdf:Description[@rdf:about=$doc/rdf:Description[@rdf:about=$nodeURI]/prns:hasFacultyRank/@rdf:resource]/rdfs:label"/>
          </xsl:when>
          <xsl:otherwise>

          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>


      <input type="hidden" id="{$nodeURI}" value="&lt;div style='font-size:13px;font-weight:bold'&gt;{foaf:firstName} {foaf:lastName}&lt;/div&gt;{$titlelink}{$institutionlink}{$departmentlink}{$divisionlink}{$facranklink}"></input>



    </td>
  </xsl:template>

</xsl:stylesheet>
