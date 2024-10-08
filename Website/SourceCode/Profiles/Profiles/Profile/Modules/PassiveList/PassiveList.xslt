﻿<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
  <xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no" />
  <xsl:param name="root"/>  
  <xsl:template match="PassiveList">
    <div class="passiveSectionHead editBody">
      <div style="white-space: nowrap;display:inline">
        <xsl:value-of select="@InfoCaption"/>
        <xsl:text> </xsl:text>
        <xsl:if test="@Description">
          <div id="{@ID}" class="passiveSectionHeadDescription" style="display:block;">
            <xsl:value-of select="@Description"/>
          </div>
        </xsl:if>
      </div>
    </div>
    <div class="passiveSectionBody">
      <ul>
        <xsl:for-each select="ItemList/Item">
          <li>
            <a href="{@ItemURL}">
              <xsl:if test="@NodeID">
                <div class="thumbnail">
                  <img src="{$root}/profile/Modules/CustomViewPersonGeneralInfo/PhotoHandler.ashx?NodeId={@NodeID}&amp;Thumbnail=True&amp;Width=15" width="15" height="30"/>
                </div>
              </xsl:if>                
              <xsl:value-of select="@ItemURLText"/>
              <xsl:if test="@ItemInst">
                <span class="researcherprofiles--institution-name-associated-with-researcher">
                  <xsl:value-of select="@ItemInst"/>
                </span>
              </xsl:if>
            </a>
            <xsl:value-of select="."/>
          </li>
        </xsl:for-each>
      </ul>
    </div>
    <xsl:if test ="@MoreURL!=''">
      <div class="passiveSectionBodyDetails editBody">
        <a href="{@MoreURL}">
          <img alt=" " style="margin-right:5px;position:relative;top:1px;border:0"  src="{$root}/Framework/Images/icon_squareArrow.gif"  />
          <xsl:value-of select="@MoreText"/>
        </a>
      </div>
    </xsl:if>
    <div class="passiveSectionLine">_</div>
  </xsl:template> 
  
</xsl:stylesheet>
