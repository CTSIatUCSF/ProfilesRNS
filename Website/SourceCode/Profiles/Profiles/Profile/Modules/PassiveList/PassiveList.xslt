<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
  <xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no" />
  <xsl:param name="root"/>  
  <xsl:template match="PassiveList">
    <div class="passiveSectionHead">
      <div style="white-space: nowrap;display:inline">
        <xsl:value-of select="@InfoCaption"/>
        <xsl:text> </xsl:text>
<!--
        <xsl:if test="@Description">
          <a href="JavaScript:toggleVisibility('{@ID}');">
            <img alt="Expand Description" src="{$root}/Framework/Images/info.png" width="11" height="11"/>
          </a>
        </xsl:if>
changed display none to block for next div
-->
      </div> 
      <div id="{@ID}" class="passiveSectionHeadDescription" style="display:block;">
        <xsl:value-of select="@Description"/>
      </div>
    </div>
    <div class="passiveSectionBody">
      <ul>
        <xsl:for-each select="ItemList/Item">
          <li>
            <a href="{@ItemURL}">
              <xsl:if test ="@PersonID!=''">
                <div class="thumbnail">
                  <!--img src="{$root}/PhotoHandler.jpg?person={@PersonID}" width="15" height="30"/-->
                  <img src="{$root}/profile/Modules/CustomViewPersonGeneralInfo/PhotoHandler.ashx?person={@PersonID}&amp;Thumbnail=True&amp;Width=15" width="15" height="30"/>
                </div>
              </xsl:if>
              <xsl:value-of select="@ItemURLText"/><span class="authInst"><xsl:value-of select="@InstitutionAbbreviation"/></span>
            </a>
            <xsl:value-of select="."/>
          </li>
        </xsl:for-each>
      </ul>
    </div>
    <xsl:if test ="@MoreURL!=''">
      <div class="passiveSectionBodyDetails">
        <a href="{@MoreURL}" class="dblarrow">          
          <xsl:value-of select="@MoreText"/>
        </a>
      </div>
    </xsl:if>
    <div class="passiveSectionLine">_</div>
  </xsl:template> 
  
</xsl:stylesheet>
