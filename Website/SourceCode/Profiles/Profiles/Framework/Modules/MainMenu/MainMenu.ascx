<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="MainMenu.ascx.cs"
    Inherits="Profiles.Framework.Modules.MainMenu.MainMenu" %>
<%@ Register TagName="History" TagPrefix="HistoryItem" Src="~/Framework/Modules/MainMenu/History.ascx" %>
<%--
    Copyright (c) 2008-2012 by the President and Fellows of Harvard College. All rights reserved.  
    Profiles Research Networking Software was developed under the supervision of Griffin M Weber, MD, PhD.,
    and Harvard Catalyst: The Harvard Clinical and Translational Science Center, with support from the 
    National Center for Research Resources and Harvard University.


    Code licensed under a BSD License. 
    For details, see: LICENSE.txt 
--%>



<div id="suckerfish-container">
    <div id="suckerfishmenu">
        <div class="content">
            <ul class="menu">
                <li class="item-home"><a href="<%=GetURLDomain()%>">Find People</a></li>
                <li id="about"><a href="<%=GetURLDomain()%>/about/AboutProfiles.aspx">About</a></li>
                <li id="contact"><a href="<%=GetURLDomain()%>/about/Help.aspx">Help / Contact Us</a></li>
            </ul>
        </div>
	</div>
    <div id="navbarsearch">
        <asp:Panel runat="server" ID="pnlNavBarSearch" Visible="true">
            <!--input type="hidden" name="searchtype" id="searchtype" value="people" />
			<input type="hidden" name="exactphrase" value="false" /-->
            <span class="nav-facade-active" id="nav-search-in">
                <span id="nav-search-in-content"></span>
				<div class="searchSelect" id="searchDropdownBox">
					<asp:DropDownList ID="searchTypeDropDown" CssClass="searchSelect" runat="server">
						<asp:ListItem Value="Everything" Text="Everything" />
						<asp:ListItem Value="http://profiles.catalyst.harvard.edu/ontology/prns!ClassGroupResearch" Text="Research" />
						<asp:ListItem Value="http://profiles.catalyst.harvard.edu/ontology/prns!ClassGroupConcepts" Text="Concepts" />
						<asp:ListItem Value="http://profiles.catalyst.harvard.edu/ontology/prns!ClassGroupAwards" Text="Awards" />
						<asp:ListItem Value="People" Text="People" />
					</asp:DropDownList>
				</div>
			<!-- next few tags have > on next line to remove space between -->
            </span
            ><div class="nav-searchfield-outer">
                <input type="text" autocomplete="off" name="mainMenuSearchFor" placeholder="e.g. Smith or HIV" title="Search For" id="nav-searchfield" />
            </div
            ><asp:Button runat="server" Text="Search" OnClick="Submit_Click" />
        </asp:Panel>
    </div>
    <div id="active-nav" class="profiles">
        <span id="signin">
            <a href="<%=GetURLDomain()%>/login/default.aspx?method=login&amp;edit=true" id="signinlink">Sign in</a>
            to edit your profile (add interests, mentoring, photo, etc.)</span>
        <ul id="editmenu"></ul>
    </div>
</div>



<!-- UCSF, this is the Harvard stuff. We might show this and hide it but we should find a better way 
<div class="activeContainer" id="defaultmenu">
    <div class="activeContainerTop"></div>
    <div class="activeContainerCenter">
        <div class="activeSection">
            <div class="activeSectionHead">Menu</div>
            <div class="activeSectionBody">
                <div runat="server" id="panelMenu" visible="true"></div>
            </div>
        </div>
        <HistoryItem:History runat="server" ID="ProfileHistory" Visible="false" />
    </div>
    <div class="activeContainerBottom"></div>
</div>
-->

