﻿<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="SearchPerson.ascx.cs"
    Inherits="Profiles.Search.Modules.SearchPerson.SearchPerson" EnableViewState="true" %>
<%@ Register Src="ComboTreeCheck.ascx" TagName="ComboTreeCheck" TagPrefix="uc1" %>

<style type="text/css">
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

        if (document.getElementById(objDLL).style.display == "block")
            document.getElementById(objDLL).style.display = "none";
        else
            document.getElementById(objDLL).style.display = "block";
    }

    function getSelectedItem(lstValue, lstNo, lstID, ctrlType) {


        var noItemChecked = 0;
        var ddlChkList = document.getElementById($('[id$=ddlChkList]').attr('id'));
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

        var hidList = document.getElementById($('[id$=hidList]').attr('id'));
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
</script>

<asp:HiddenField ID="hdnSearch" runat="server" Value="hdnSearch"></asp:HiddenField>
<div class="content_container">
    <div class="tabContainer">
        <div class="searchForm">

            <table onkeypress="JavaScript:runScript(event);" width="100%">
                <tbody align="left">
                    <tr>
                        <td colspan='3'>
                            <div class='header'>
                                Find People by Research Topic or Name
							</div>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="3"  style="padding: 0 2px">
                            <div class="searchSection" id="divSearchSection">
                                <table width="100%" class='searchForm'>
                                    <tr>
                                        <th style="width: 140px">
                                            Research Topics
                                        </th>
                                        <td class="fieldOptions">
                                            <asp:TextBox runat="server" ID="txtSearchFor" CssClass="inputText"></asp:TextBox>
                                            <asp:CheckBox runat="server" ID="chkExactphrase" />
                                        </td>
                                       <td align="center">
					    <a href="JavaScript:search();" class="search-button">Search</a>
                                       </td>
                                            Search for exact phrase
<!--  NOTE: checkboxes are hidden in css
                                    </tr>
                                    <tr>
                                        </tr>
                                        <th>
                                        </th>
                                        <td colspan="2">
                                            <div class="search-button-container">
                                                <%--Inline styles on this is no longer needed as the button is now all CSS--%>
                                                <a href="JavaScript:search();" class="search-button">
                                                    <%--    No longer need a search button as an image--%>
                                                        <%--<img src="<%=GetThemedDomain()%>/Search/Images/search.jpg" style="border: 0;" alt="Search" />--%>
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
<!--
                <tr>
                    <td colspan='3'>
                        <div class="headings">
                            Find people by name/organization
                        </div>
                    </td>
                </tr>
-->
                <tr>
                    <td colspan='3' style="padding: 0 2px">
                        <div class="searchSection" id="div1">
							<span id="andor">and/or</span>
                            <table width="100%" class='searchForm'>
                                <asp:Panel ID="ClinicalTrialsUSC" runat="server" SkinID="USC" Visible="false">
								<tr>
                                    <th>
                                        Clinical Trials
                                    </th>
                                    <td colspan="2">
                                        <input type="checkbox" class="trials2" />
                                    </td>
                                </tr>
								<tr>
                                    <th>
                                        Find Mentors
                                    </th>
                                    <td colspan="2">
                                        <input type="checkbox" class="student2" /> Student Mentors
                                        <input type="checkbox" class="faculty2" /> Faculty Mentors
                                    </td>
                                </tr>
							</asp:Panel>
                                <tr>
                                    <th>Last Name
                                    </th>
                                    <td colspan="2">
                                        <asp:TextBox runat="server" ID="txtLname" CssClass="inputText"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <th>First Name
                                    </th>
                                    <td colspan="2">
                                        <asp:TextBox runat="server" ID="txtFname" CssClass="inputText"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr runat="server" id="trInstitution">
                                    <th>Institution
                                    </th>
                                    <td colspan="2">
                                        <asp:Literal runat="server" ID="litInstitution"></asp:Literal>
                                        <asp:CheckBox runat="server" ID="institutionallexcept" />
                                        All <b>except</b> the one selected
                                    </td>
                                </tr>
                                <tr runat="server" id="trDivision">
                                    <th>
                                        School
                                    </th>
                                    <td colspan="2">
                                        <asp:Literal runat="server" ID="litDivision"></asp:Literal>
                                        <asp:CheckBox runat="server" id="divisionallexcept"/>
                                        All <b>except</b> the one selected
                                    </td>
                                </tr>

								<asp:Panel ID="SearchPersonFormHideUCSD" runat="server" SkinID="HideUCSD" Visible="true">
									<tr runat="server" id="trDepartment">
										<th>
											Department
										</th>
										<td colspan="2">
											<asp:Literal runat="server" ID="litDepartment"></asp:Literal>
											<asp:CheckBox runat="server" ID="departmentallexcept" />
											All <b>except</b> the one selected
										</td>
									</tr>
								</asp:Panel>

								<tr runat="server" id="trFacultyType">
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
                                <tr runat="server" id="trOtherOptions">
                                    <th>
                                        More Options
                                    </th>
                                    <td colspan='2'>
                                        <input type="hidden" id="hiddenToggle" value="off" />
                                        <select id="selOtherOptions" style="width: 249px; height: 20px">
                                            <option value="" style="font-size: 1px"></option>
                                        </select>
                                        <table>
                                            <tr>
                                                <td>
                                                    <div id="divOtherOptions" style="padding-top:2px">
                                                        <!-- <br /> -->
                                                        <uc1:ComboTreeCheck ID="ctcFirst" runat="server" Width="255px" />
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
							<asp:Panel ID="ClinicalTrialsUC" runat="server" SkinID="UC" Visible="false">
								<tr>
                                    <th>
                                        Clinical Trials
                                    </th>
                                    <td colspan="2">
                                        <input type="checkbox" class="trials2" />
                                    </td>
                                </tr>
							</asp:Panel>
							<asp:Panel ID="ClinicalTrialsUCSF" runat="server" SkinID="UCSF" Visible="false">
								<tr>
                                    <th>
                                        Clinical Trials
                                    </th>
                                    <td colspan="2">
                                        <input type="checkbox" class="trials2" />
                                    </td>
                                </tr>
							</asp:Panel>
							<asp:Panel ID="StudentProjectUCD" runat="server" SkinID="UCD" Visible="false">
								<tr>
                                    <th>
                                        Student Projects
                                    </th>
                                    <td colspan="2">
                                        <input type="checkbox" class="studentProjects2" />
                                    </td>
                                </tr>
							</asp:Panel>
<!--
                                <tr>
                                    <th>
                                    </th>
                                    <td colspan="2">
                                        <div class="search-button-container">
                                            <%--Inline styles on this is no longer needed as the button is now all CSS--%>
                                            <a href="JavaScript:search();" class="search-button">
                                                <%--<img src="<%=GetThemedDomain()%>/Search/Images/search.jpg" style="border: 0;" alt="Search" />--%>
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
			<asp:Panel ID="DirectSearchUCSF" runat="server" SkinID="UCSF" Visible="false">
				<p style="text-align:right;margin-right:20px;margin-bottom:160px;"><a href="<%=GetThemedDomain()%>/direct" class="dblarrow">Search other institutions</a></p>
			</asp:Panel>
			<asp:Panel ID="DirectSearchUSC" runat="server" SkinID="USC" Visible="false">
				<p style="margin-bottom:160px;"><a href="<%=GetThemedDomain()%>/direct" class="dblarrow">Find Collaborators at other Research Institutions</a></p>
			</asp:Panel>

    </div>
</div>
<script>$(document).ready(function () {
    $("[id*=ddlChkList]").css("width", "249px");
});</script>
