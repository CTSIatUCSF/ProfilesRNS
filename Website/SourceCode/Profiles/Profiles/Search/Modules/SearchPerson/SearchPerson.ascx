<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="SearchPerson.ascx.cs"
    Inherits="Profiles.Search.Modules.SearchPerson.SearchPerson" EnableViewState="true"  %>
<%@ Register Src="ComboTreeCheck.ascx" TagName="ComboTreeCheck" TagPrefix="uc1" %>

<style type="text/css">
.profiles .profilesContentMain { width: 584px; }
.profiles .profilesPageColumnLeft { padding: 6px 6px 0 8px;}
.profiles .profilesContentMain .pageTitle h2 { display: none; }
</style>

<script type="text/javascript">


    function runScript(e) {
        if (e.keyCode == 13) {
            search();            
        }
        return false;
    }

    function search() {

        document.getElementById("<%=hdnSearch.ClientID%>").value = "true"
        document.forms[0].submit();
    }

    function showdiv() {
        var divChkList = $('[id$=divChkList]').attr('id');
        var chkListItem = $('[id$=chkLstItem_0]').attr('id');
        document.getElementById(divChkList).style.display = "block";

        document.getElementById(chkListItem).focus()
    }

    function showdivonClick() {
        var objDLL = $('[id$=divChkList]').attr('id');// document.getElementById("divChkList");

        if (document.getElementById(objDLL).style.display  == "block")
            document.getElementById(objDLL).style.display = "none";
        else
            document.getElementById(objDLL).style.display = "block";
    }

    function getSelectedItem(lstValue, lstNo, lstID, ctrlType) {


        var noItemChecked = 0;
        var ddlChkList =  document.getElementById($('[id$=ddlChkList]').attr('id'));
        var selectedItems = "";
        var selectedValues = "";
        var arr = document.getElementById($('[id$=chkLstItem]').attr('id')).getElementsByTagName('input');
        var arrlbl = document.getElementById($('[id$=chkLstItem]').attr('id')).getElementsByTagName('label');
        var objLstId = document.getElementById($('[id$=hidList]').attr('id')); //document.getElementById('hidList');

        for (i = 0; i < arr.length; i++) {
            checkbox = arr[i];
            if (i == lstNo) {
                if (ctrlType == 'anchor') {
                    if (!checkbox.checked) {
                        checkbox.checked = true;
                    }
                    else {
                        checkbox.checked = false;
                    }
                }
            }

            if (checkbox.checked) {                

                var buffer;
                if (arrlbl[i].innerText == undefined)
                    buffer = arrlbl[i].textContent;
                else
                    buffer = arrlbl[i].innerText;

                if (selectedItems == "") {

                    selectedItems = buffer;
                }
                else {
                    selectedItems = selectedItems + "," + buffer;
                }
                noItemChecked = noItemChecked + 1;
            }
        }

        ddlChkList.title = selectedItems;

        if (noItemChecked != "0")
            ddlChkList.options[ddlChkList.selectedIndex].text = selectedItems;
        else
            ddlChkList.options[ddlChkList.selectedIndex].text = "";

		var hidList =  document.getElementById($('[id$=hidList]').attr('id'));
        hidList.value = ddlChkList.options[ddlChkList.selectedIndex].text;


    }

    document.onclick = check;
    function check(e) {
        var target = (e && e.target) || (event && event.srcElement);
        var obj = document.getElementById($('[id$=divChkList]').attr('id'));
        var obj1 = document.getElementById($('[id$=ddlChkList]').attr('id'));
        if (target.id != "alst" && !target.id.match($('[id$=chkLstItem]').attr('id'))) {
            if (!(target == obj || target == obj1)) {
                //obj.style.display = 'none'
            }
            else if (target == obj || target == obj1) {
                if (obj.style.display == 'block') {
                    obj.style.display = 'block';
                }
                else {
                    obj.style.display = 'none';
                    document.getElementById($('[id$=ddlChkList]').attr('id')).blur();
                }
            }
        }
    }
    $(document).ready(function () {
	buildGadgetAds();
    });
</script>

<asp:HiddenField ID="hdnSearch" runat="server" Value="hdnSearch"></asp:HiddenField>
<div class="content_container">
    <div class="tabContainer">
        <div class="searchForm nonavbar">
            <table onkeypress="JavaScript:runScript(event);" width="100%">
                <tbody align="left">
                    <tr>
                        <td colspan='3'>
                            <%-- New class to replace inline heading styles --%>
                            <div class="headings">
                        </td>
                    </tr>
                    <tr>
                        <td colspan="3">
                            <div class="searchSection" id="divSearchSection">
                                <table width="100%" class='searchForm'>
                                    <tr>
                                        <th style="width: 140px">
                                            Research Topics
                                        </th>
                                        <td class="fieldOptions">
                                            <asp:TextBox runat="server" ID="txtSearchFor" CssClass="inputText"></asp:TextBox>
                                            <asp:CheckBox runat="server" ID="chkExactphrase" CssClass="unused" />
                                        </td>
                                       <td align="center">
					    <a href="JavaScript:search();" class="search-button">Search</a>
                                       </td>
<!--  NOTE: checkboxes are hidden in css
                                            Search for exact phrase
                                    </tr>
                                    <tr>
                                        <tr>
                                            <th>
                                            </th>
                                            <td colspan="2">
                                                <div class="search-button-container">
                                                    <%--Inline styles on this is no longer needed as the button is now all CSS--%>
                                                    <a href="JavaScript:search();" class="search-button">
                                                    <%--    No longer need a search button as an image--%>
                                                        <%--<img src="<%=GetURLDomain()%>/Search/Images/search.jpg" style="border: 0;" alt="Search" />--%>
                                                        Search
						    </a>
                                                </div>
                                            </td>
                                        </tr>     (cp end comment out)-->
                                    </tr>
                                </table>
                            </div>
                        </td>
                    </tr>
            </table>
            <div id="andor"><span>and/or</span></div>
            <table width="100%" id="searchOptions">
<!--
                <tr>
                    <td colspan='3'>
                        <div class="headings">
                            Find people by name/organization</div>
                    </td>
                </tr>
-->
                <tr>
                    <td colspan='3'>
                        <div class="searchSection" id="div1">
                            <table width="100%" class='searchForm'>
                                <tr>
                                    <th>
                                        Last Name
                                    </th>
                                    <td colspan="2">
                                        <asp:TextBox runat="server" ID="txtLname" CssClass="inputText"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <th>
                                        First Name
                                    </th>
                                    <td colspan="2">
                                        <asp:TextBox runat="server" ID="txtFname" CssClass="inputText"></asp:TextBox>
                                    </td>
                                </tr>
<!--
                                <tr runat="server" id="trInstitution">
                                    <th>
                                        School
                                    </th>
                                    <td colspan="2">
                                        <asp:Literal runat="server" ID="litInstitution"></asp:Literal>
                                        <asp:CheckBox runat="server" ID="institutionallexcept" CssClass="unused" />
                                        All <b>except</b> the one selected
                                    </td>
                                </tr>
-->
                                <tr runat="server" id="trDepartment">
                                    <th>
                                        Department
                                    </th>
                                    <td colspan="2">
                                        <asp:Literal runat="server" ID="litDepartment"></asp:Literal>
                                        <asp:CheckBox runat="server" ID="departmentallexcept" CssClass="unused" />
<!--
                                        All <b>except</b> the one selected
-->
                                    </td>
                                </tr>
<!--
                                <tr runat="server" id="trDivision">
                                    <th>
                                        Division
                                    </th>
                                    <td colspan="2">
                                        <asp:Literal runat="server" ID="litDivision"></asp:Literal>
                                        <asp:CheckBox runat="server" id="divisionallexcept" />
                                        All <b>except</b> the one selected
                                    </td>
                                </tr>
-->
                                <tr runat="server" id="trFacultyType" Visible="false">
                                    <th>
                                        Researcher Type
                                    </th>
                                    <td class="pan" colspan="2">
                                        <table cellpadding="0">
                                            <tr>
                                                <td>
                                                    <asp:PlaceHolder ID="phDDLCHK" runat="server"></asp:PlaceHolder>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:PlaceHolder ID="phDDLList" runat="server"></asp:PlaceHolder>
                                                </td>
                                            </tr>
                                        </table>
                                        <asp:Label ID="lblSelectedItem" runat="server"></asp:Label>
                                        <asp:HiddenField ID="hidList" runat="server" />
                                        <asp:HiddenField ID="hidURIs" runat="server" />
                                    </td>
                                </tr>
                                <tr runat="server" id="trMoreOptions" Visible="false">
                                    <th>
                                        More Options
                                    </th>
                                    <td colspan='2'>
                                        <input type="hidden" id="hiddenToggle" value="off" />
                                        <select id="selOtherOptions" style="width: 249px; height: 20px">
                                            <option value=""></option>
                                        </select>
                                        <table>
                                            <tr>
                                                <td>
                                                    <div id="divOtherOptions">
                                                    <div id="divOtherOptions" style="position: absolute; margin-top: -2px; margin-left: -2px;
                                                        width: 255px; border-right: solid 1px #000000; border-bottom: solid 1px #000000;
                                                        border-left: solid 1px gray; padding-left: 3px; height: 150; width: 243px; overflow: auto;
                                                        background-color: #ffffff;">
                                                        <br />
                                                        <uc1:ComboTreeCheck ID="ctcFirst" runat="server" Width="255px" />
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
<!--
                                <tr>
                                    <th>
                                    </th>
                                    <td colspan="2">
                                        <div class="search-button-container"><%--Inline styles on this is no longer needed as the button is now all CSS--%>
                                            <a href="JavaScript:search();" class="search-button">
                                                <%--<img src="<%=GetURLDomain()%>/Search/Images/search.jpg" style="border: 0;" alt="Search" />--%>
                                                Search
                                            </a>
                                        </div>
                                    </td>
                                </tr>
-->
                            </table>
                            <asp:Literal runat="server" ID="litFacRankScript"></asp:Literal>
                            
                        </div>
                    </td>
                </tr>
            </table>
        </div>
            <p><img src="<%=GetURLDomain()%>/Search/Images/icon_squareArrow.gif" /> <a href="<%=GetURLDomain()%>/direct">Search other institutions</a></p>
	    <p><span class="notice">Important Note: </span>
If you are a faculty member within Health Sciences and your profile page is not found, it is most likely that your title in Blink is not listed with your academic faculty title. For example, if you listed your department name as your title in blink, you would have to change blink to reflect either Professor, Research Scientists etc. Blink updates have to be initiated either by the UCSD employee directly or their home department. Once blink is updated, your profile will be automatically generated with the next refresh cycle.</p>
    </div>
</div>