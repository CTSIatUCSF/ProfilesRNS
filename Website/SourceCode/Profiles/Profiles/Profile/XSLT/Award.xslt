<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:prns="http://profiles.catalyst.harvard.edu/ontology/prns#" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:vivo="http://vivoweb.org/ontology/core#">
  <xsl:template match="/">
    <div class="awardsList">
      <table>
        <tbody>
          <tr>
            <td>
              <xsl:value-of select="/rdf:RDF[1]/rdf:Description/prns:awardConferredBy"/>
            </td>
            <td stlye="white-space:nowrap;">
              <xsl:value-of select="/rdf:RDF[1]/rdf:Description/prns:startDate"/> -
            </td>
            <td>
              <xsl:value-of select="/rdf:RDF[1]/rdf:Description/prns:endDate"/>
            </td>
          </tr>
          <tr style="height:5px">
            <td colspan="3"></td>
          </tr>
          <xsl:for-each select="rdf:RDF/rdf:Description/rdf:type[@rdf:resource='http://xmlns.com/foaf/0.1/Person']/..">
              
            <tr>
              <td colspan="3" stlye="white-space:nowrap;">
                Awardee: <a href="{@rdf:about}">
                  <xsl:value-of select="prns:fullName"/>
                </a>
              </td>
            </tr>
          </xsl:for-each>
        </tbody>
      </table>
    </div>
  </xsl:template>
</xsl:stylesheet>
