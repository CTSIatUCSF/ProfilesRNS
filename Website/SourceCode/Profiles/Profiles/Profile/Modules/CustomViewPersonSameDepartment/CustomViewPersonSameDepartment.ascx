﻿<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="CustomViewPersonSameDepartment.ascx.cs"
    Inherits="Profiles.Profile.Modules.CustomViewPersonSameDepartment.CustomViewPersonSameDepartment" %>
<asp:Repeater ID='rptSameDepartment' runat="server" OnItemDataBound="SameDepartmentItemBound">
    <HeaderTemplate>
        <div class="passiveSectionHead">
            <div style="white-space: nowrap; display: inline">
                Same Department 
<!--
                <a href="JavaScript:toggleVisibility('sdDescript');">
                </a>
            </div>
            <div id="sdDescript" class="passiveSectionHeadDescription" style="display: none;">
				People who are also in this person's primary department.
-->
	    </div>
        </div>        
        <div class="passiveSectionBody">
            <ul>
    </HeaderTemplate>
    <ItemTemplate>
        <asp:Literal runat="server" ID="litListItem"></asp:Literal>
    </ItemTemplate>
    <FooterTemplate>
         </ul>   
        </div>
            <asp:Literal runat="server" ID="litFooter"></asp:Literal>
        <div class="passiveSectionLine">_</div>
    </FooterTemplate>
</asp:Repeater>
