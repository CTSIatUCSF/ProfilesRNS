﻿<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="CustomViewConceptSimilarMesh.ascx.cs" Inherits="Profiles.Profile.Modules.CustomViewConceptSimilarMesh" %>

<div class="passiveSectionHead">
    <div id='sectionTitle' runat='server' style="white-space: nowrap; display: inline">
        <%= this.GetModuleParamString("InfoCaption") %> <a href="JavaScript:toggleVisibility('similarConceptDescription');"  style="display: none;">
            <asp:Image runat="server" ID="imgQuestion" alt="expand description"/>
        </a>
    </div>
    <div id="similarConceptDescription" class="passiveSectionHeadDescription" style="display: block;">
        <%= this.GetModuleParamString("Description") %>
    </div>
</div>
<div class="passiveSectionBody">
	<ul>
		<asp:Literal runat="server" ID="lineItemLiteral"></asp:Literal>
	</ul>
</div>
<div class="passiveSectionLine">_</div>
       