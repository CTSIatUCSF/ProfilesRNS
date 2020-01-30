<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="MainMenu.ascx.cs" Inherits="Profiles.Framework.Modules.MainMenu.MainMenu" %>
<%@ Register TagName="History" TagPrefix="HistoryItem" Src="~/Framework/Modules/MainMenu/History.ascx" %>
<%@ Register TagName="Lists" TagPrefix="MyLists" Src="~/Framework/Modules/MainMenu/MyLists.ascx" %>
<div id="prns-nav">
    <!-- MAIN NAVIGATION MENU -->
    <nav>
        <ul class="prns-main">
            <li class="main-nav">
                <a href="<%=ResolveUrl("~/search")%>">Home</a>
            </li>
            <li class="main-nav">
--%>
                <ul class="drop">
                    <li>
                        <a id="about" style="border-left: 1px solid  #999; border-right: 1px solid  #999; border-bottom: 1px solid #999; width: 200px !important" href="<%=ResolveUrl("~/about/default.aspx?tab=overview")%>">Overview</a>
                    </li>
                    <li>
                        <a id="data" style="border-left: 1px solid  #999; border-right: 1px solid  #999; border-bottom: 1px solid #999; width: 200px !important" href="<%=ResolveUrl("~/about/default.aspx?tab=data")%>">Sharing Data</a>
                    </li>
                    <li>
                        <a id="orcid" style="border-left: 1px solid  #999; border-right: 1px solid  #999; border-bottom: 1px solid #999; width: 200px !important" href="<%=ResolveUrl("~/about/default.aspx?tab=orcid")%>">ORCID</a>
                    </li>
                </ul>

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
				<li id="contact"><a href="<%=GetThemedDomain()%>/about/Help.aspx">HELP / FAQ</a></li>
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
                    <asp:Literal ID="litDashboard" runat="server" /></li>
                <li>
                    <div class="divider"></div>
                </li>--%>
                <asp:Literal runat="server" ID="litGroups"></asp:Literal>
                <li id="groupListDivider" visible="false" runat="server">
                    <div class="divider"></div>
                </li>
                <asp:Literal runat="server" ID="litLogOut"></asp:Literal>
            </ul>
        </div>
	</div>
</div>





    });

    function setNavigation() {
        var path = $(location).attr('href');
        path = path.replace(/\/$/, "");
        path = decodeURIComponent(path);

        $(".prns-main li").each(function () {

            var href = $(this).find("a").attr('href');
            var urlParams = window.location.search;

            if ((path + urlParams).indexOf(href) >= 0) {
                $(this).addClass('landed');
            }
        });


        return true;
    }
    $(document).ready(function () {
        $("#menu-search").on("keypress", function (e) {
            if (e.which == 13) {
                minisearch();
                return false;
            }
            return true;
        });

        $("#img-mag-glass").on("click", function () {
            minisearch();
            return true;
        });
    });
    function minisearch() {
        var keyword = $("#menu-search").val();
        var classuri = 'http://xmlns.com/foaf/0.1/Person';
        document.location.href = '<%=ResolveUrl("~/search/default.aspx")%>?searchtype=people&searchfor=' + keyword + '&classuri=' + classuri;
        return true;
    }

</script>


