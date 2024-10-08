﻿<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:geo="http://aims.fao.org/aos/geopolitical.owl#" xmlns:afn="http://jena.hpl.hp.com/ARQ/function#" xmlns:prns="http://profiles.catalyst.harvard.edu/ontology/prns#" xmlns:obo="http://purl.obolibrary.org/obo/" xmlns:dcelem="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:event="http://purl.org/NET/c4dm/event.owl#" xmlns:bibo="http://purl.org/ontology/bibo/" xmlns:vann="http://purl.org/vocab/vann/" xmlns:vitro07="http://vitro.mannlib.cornell.edu/ns/vitro/0.7#" xmlns:vitro="http://vitro.mannlib.cornell.edu/ns/vitro/public#" xmlns:vivo="http://vivoweb.org/ontology/core#" xmlns:pvs="http://vivoweb.org/ontology/provenance-support#" xmlns:scirr="http://vivoweb.org/ontology/scientific-research-resource#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:swvs="http://www.w3.org/2003/06/sw-vocab-status/ns#" xmlns:skco="http://www.w3.org/2004/02/skos/core#" xmlns:owl2="http://www.w3.org/2006/12/owl2-xml#" xmlns:skos="http://www.w3.org/2008/05/skos#" xmlns:foaf="http://xmlns.com/foaf/0.1/"  exclude-result-prefixes="prns rdf bibo skco owl2 swvs rdfs scirr vivo vitro07 event obo pvs foaf skos owl dcterms vann dcelem afn geo vitro xsd">
  <xsl:output method="html"/>
  <xsl:template match="/">


    <script type="text/javascript">
      <xsl:text disable-output-escaping="yes">
      var hasClickedListTable = false;
      function doListTableRowOver(x) {
      //x.className = 'overRow';
      x.style.backgroundColor = '#5A719C';
      x.style.color = '#FFF';
      for (var i = 0; i &lt; x.childNodes.length; i++) {
      if (x.childNodes[i].childNodes.length > 0) {
      if (x.childNodes[i].childNodes[0].className == 'listTableLink') {
      x.childNodes[i].childNodes[0].style.color = '#FFF';
      }
      }
      }
      }
      function doListTableRowOut(x, eo) {
      if (eo == 1) {
      //x.className = 'oddRow';
      x.style.backgroundColor = '#FFFFFF';
      } else {
      //x.className = 'evenRow';
      x.style.backgroundColor = '#F0F4F6';
      }
      x.style.color = '';
      for (var i = 0; i &lt; x.childNodes.length; i++) {
      if (x.childNodes[i].childNodes.length > 0) {
      if (x.childNodes[i].childNodes[0].className == 'listTableLink') {
      x.childNodes[i].childNodes[0].style.color = '#36C';
      }
      }
      }
      }
      function doListTableCellOver(x) {
      //x.className = 'listTableLinkOver';
      x.style.backgroundColor = '#36C';
      }
      function doListTableCellOut(x) {
      //x.className = 'listTableLink';
      x.style.backgroundColor = '';
      }
      function doListTableCellClick(x) {
      hasClickedListTable = true;
      }
      function WhyLink(uri){
      window.location = '/profile/'+uri;
      }

</xsl:text>
    </script>
    <div class="tabInfoText">
      Concepts are listed by decreasing relevance which is based on many factors, including how many publications the person wrote about that topic, how long ago those publications were written, and how many publications other people have written on that same topic.
    </div>
    <br></br>
    <br></br>
    <div class="listTable" style="margin-top: 12px, margin-bottom:8px ">
      <table id="thetable1">
        <tbody>
          <tr>
            <th class="alignLeft" style="width:250px;">Name</th>
            <th style="width: 110px;">
              Number of Publications
            </th>
            <th style="width: 115px;">
              Most Recent Publication
            </th>
            <th style="width: 80px;">
              Publications by All Authors
            </th>
            <th style="text-align: center;">
              Concept Score
            </th>
            <th style="width: 38px;">
              Why?
            </th>
          </tr>
          <xsl:for-each select="rdf:RDF/rdf:Description[rdf:type/@rdf:resource='http://profiles.catalyst.harvard.edu/ontology/prns#Connection']">
            <xsl:sort select="prns:sortOrder" data-type="number"/>
            <xsl:variable name="objectResource" select="./rdf:object/@rdf:resource"/>
            <xsl:variable name="connectionResource" select="./prns:hasConnectionDetails/@rdf:resource"/>
            <xsl:variable name="whyLink" select="./@rdf:about"/>
            <xsl:variable name="detailsResource" select="./prns:hasConnectionDetails/@rdf:resource"/>
            <tr  onclick="doURL('{$objectResource}')" onkeypress="if (event.keyCode == 13) doURL('{$objectResource}')">
              <xsl:choose>
                <xsl:when test="position() mod 2 = 0">
                  <xsl:attribute name="class">
                    <xsl:value-of select="'evenRow'"/>
                  </xsl:attribute>
                  <xsl:attribute name="tabindex">0</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute name="class">
                    <xsl:value-of select="'oddRow'"/>
                  </xsl:attribute>
                  <xsl:attribute name="tabindex">0</xsl:attribute>
                </xsl:otherwise>
              </xsl:choose>
              <td style="text-align: left;" class="alignLeft">
                <a class="listTableLink" href="{$objectResource}">
                  <xsl:value-of select="/rdf:RDF/rdf:Description[@rdf:about=$objectResource]/rdfs:label"/>
                </a>
              </td>
              <td>
                <div  style="text-align:center;">
                  <xsl:value-of select="/rdf:RDF/rdf:Description[@rdf:about=$connectionResource]/prns:numberOfPublications"/>
                </div>
              </td>
              <td>
                <div style="text-align:center;">
                  <xsl:value-of select="substring-before(/rdf:RDF/rdf:Description[@rdf:about=$connectionResource]/prns:endDate,'-')"/>
                </div>
              </td>
              <td>
                <div style="text-align:center;">
                  <xsl:value-of select="/rdf:RDF/rdf:Description[@rdf:about=$objectResource]/prns:numberOfPublications"/>
                </div>
              </td>
              <td>
                <div style="text-align:center;">
                  <xsl:variable name="score" select="/rdf:RDF/rdf:Description/prns:hasConnectionDetails[@rdf:resource=$detailsResource]/../prns:connectionWeight"/>
                  <xsl:value-of select='format-number( round(100*$score) div 100 ,"##0.000" )' />
                </div>
              </td>
              <td style="text-align:center;">
                <a class="listTableLink"  href="{$whyLink}">
                  Why?
                </a>
              </td>
            </tr>
          </xsl:for-each>
        </tbody>
      </table>
    </div>
  </xsl:template>
</xsl:stylesheet>
