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

<div id="navbarsearch-container">
	<div id="navbarsearch">
		<asp:Panel runat="server" ID="pnlNavBarSearch" Visible="true">
			<!--input type="hidden" name="searchtype" id="searchtype" value="people" />
			<input type="hidden" name="exactphrase" value="false" /-->
			<div class="nav-facade-active" id="nav-search-in">
				<div id="nav-search-in-content"></div>
				<div class="searchSelect" id="searchDropdownBox">
					<asp:DropDownList ID="searchTypeDropDown" CssClass="searchSelect" EnableViewState="true" runat="server">
						<asp:ListItem Value="Everything" Text="Everything" />
						<asp:ListItem Value="http://profiles.catalyst.harvard.edu/ontology/prns!ClassGroupResearch" Text="Research" />
						<asp:ListItem Value="http://profiles.catalyst.harvard.edu/ontology/prns!ClassGroupConcepts" Text="Concepts" />
						<asp:ListItem Value="http://profiles.catalyst.harvard.edu/ontology/prns!ClassGroupAwards" Text="Awards" />
						<asp:ListItem Value="People" Text="People" />
						<asp:ListItem Value="UC" Text="&nbsp;&nbsp;&nbsp;UC Health People" />
						<asp:ListItem Value="UCD" Text="&nbsp;&nbsp;&nbsp;UC Davis People" />
						<asp:ListItem Value="UCI" Text="&nbsp;&nbsp;&nbsp;UCI People" />
						<asp:ListItem Value="UCLA" Text="&nbsp;&nbsp;&nbsp;UCLA People" />
						<asp:ListItem Value="UCSD" Text="&nbsp;&nbsp;&nbsp;UCSD People" />
						<asp:ListItem Value="UCSF" Text="&nbsp;&nbsp;&nbsp;UCSF People" />
						<asp:ListItem Value="USC" Text="&nbsp;&nbsp;&nbsp;USC People" />
					</asp:DropDownList>
				</div>
			<!-- next few tags have > on next line to remove space between -->
			</div
			><div class="nav-searchfield-outer">
				<input type="text" autocomplete="off" name="mainMenuSearchFor" placeholder="e.g. Smith or HIV" title="Search For" id="nav-searchfield" />
			</div
			><asp:Button runat="server" Text="Search" OnClick="Submit_Click" />
		</asp:Panel>
	</div>
</div>
<div id="suckerfish-container">
    <div id="suckerfishmenu">
		<div class="activeContainer" id="defaultmenu">
			<ul class="menu">
				<li id="about"><a href="<%=GetThemedDomain()%>/about/AboutProfiles.aspx">ABOUT</a></li>
				<li id="contact"><a href="<%=GetThemedDomain()%>/about/Help.aspx">HELP</a></li>
				<li class="item-home"><a href="<%=GetThemedDomain()%>">SEARCH OPTIONS</a>
					<ul>
						<li><a href="<%=GetDomainFor("UCD")%>/search/">UC Davis</a></li>
						<li><a href="<%=GetDomainFor("UCI")%>/search/">UCI</a></li>
						<li><a href="<%=GetDomainFor("UCLA")%>/search/">UCLA</a></li>
						<li><a href="<%=GetDomainFor("UCSD")%>/search/">UCSD</a></li>
						<li><a href="<%=GetDomainFor("UCSF")%>/search/">UCSF</a></li>
						<li><a href="<%=GetDomainFor("UC")%>/search/">All UC Health</a></li>
						<li><a href="<%=GetDomainFor("USC")%>/search/">USC</a></li>
						<li><a href="<%=GetDomainFor("Default")%>/search/">All</a></li>
					</ul>
				</li>
			</ul>
			<span runat="server" id="panelMenu" visible="true"></span>
<!--		<HistoryItem:History runat="server" ID="ProfileHistory" Visible="false" />  -->
		</div>
	</div>
</div>





