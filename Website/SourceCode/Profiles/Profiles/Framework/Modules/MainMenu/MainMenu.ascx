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
                <a href="<%=ResolveUrl("~/about/AboutProfiles.aspx")%>">About</a>
            </li>
            <li class="main-nav">
                <a href="<%=ResolveUrl("~/about/Help.aspx")%>">Help/FAQs</a>
            </li>
            <HistoryItem:History runat="server" ID="ProfileHistory" Visible="true" />

			<li class="main-nav"><a href="<%=GetThemedDomain()%>/search/">Search Options</a>
				<ul class="drop">
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

            <!-- UCSF search -->
			<li class="nav-facade-active" id="nav-search-in">
				<div id="nav-search-in-content"></div>
				<div class="searchSelect" id="searchDropdownBox">
					<asp:DropDownList ID="searchTypeDropDown" CssClass="searchSelect form-control input-sm" EnableViewState="true" runat="server">
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
			</li>
            <li class="search main-nav" style="width: 492px;">
                <input name="search" id="menu-search" placeholder="e.g. Smith or HIV" type="text" style="padding-left: 5px;" class="form-control input-sm"/>
            </li>
            <li id="search-drop" class="last main-nav" style="float: right !important; width: 25px;">
                <a href="#" style="padding: 0px; padding-top: 9px; margin: 0px;">
                    <img src="<%=ResolveUrl("~/framework/images/arrowDown.png") %>" /></a>
                <ul class="drop" style="top: 39px; left: 835px;">
                    <asp:Literal runat="server" ID="litSearchOptions"></asp:Literal>
                </ul>
            </li>
        </ul>
        <!-- USER LOGIN MSG / USER FUNCTION MENU -->
        <div id="prns-usrnav" class="pub" class-help="class should be [pub|user]">
            <div class="loginbar">
                <asp:Literal runat="server" ID="litLogin"></asp:Literal>
            </div>
            <!-- SUB NAVIGATION MENU (logged on) -->
            <ul class="usermenu">
                <asp:Literal runat="server" ID="litViewMyProfile"></asp:Literal>
                <li style="margin-top: 0px !important;">
                    <div class="divider"></div>
                </li>
                <asp:Literal runat="server" ID="litEditThisProfile"></asp:Literal>
                <li>
                    <div class="divider"></div>
                </li>
                <asp:Literal runat="server" ID="litProxy"></asp:Literal>               
                <li id="ListDivider">
                    <div class="divider"></div>
                </li>
                <asp:Literal runat="server" ID="litDashboard"></asp:Literal>
                <li id="navMyLists">
                   <a href="#">My Person List (<span id="list-count">0</span>)</a>
                    <MyLists:Lists runat="server" ID="MyLists" Visible="false" />
                </li>
                 <li>
                    <div class="divider"></div>
                </li>
                <asp:Literal runat="server" ID="litGroups"></asp:Literal>
                <li id="groupListDivider" visible="false" runat="server">
                    <div class="divider"></div>
                </li>
                <asp:Literal runat="server" ID="litLogOut"></asp:Literal>
            </ul>
        </div>
         <asp:Panel ID="HeroNavbarPanel" runat="server" SkinID="UCSF" Visible="false">
            <!-- UCSF This panelActive navbar div holds the heros photos -->
            <div class="panelActive navbar"/>
        </asp:Panel>
    </nav>
</div>

<asp:Literal runat="server" ID="litJs"></asp:Literal>
<script type="text/javascript">
    $(function () {
        setNavigation();
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
        /** Removed by UCSF
        $("#img-mag-glass").on("click", function () {
            minisearch();
            return true;
        });
        **/
    });
    function minisearch() {
        var keyword = $("#menu-search").val();
        var searchtype = $('#searchDropdownBox select').find("option:selected").attr("searchtype");
        var classgroupuri = $('#searchDropdownBox select').find("option:selected").attr("classgroupuri") || '';
        var institution = $('#searchDropdownBox select').find("option:selected").attr("institution") || '';
        var otherfilters = $('#searchDropdownBox select').find("option:selected").attr("otherfilters") || '';

        document.location.href = '<%=ResolveUrl("~/search/default.aspx")%>?searchtype=' + searchtype + '&searchfor=' + keyword +
            '&classgroupuri=' + classgroupuri + '&institution=' + institution + '&otherfilters=' + otherfilters + '&exactphrase=false&new=true';
        return true;
    }
</script>


