<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="AdvancedSearch.ascx.cs"
    Inherits="Profiles.Search.Modules.AdvancedSearch.AdvancedSearch" EnableViewState="true" %>

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
                                            Topic
                                        </th>
                                        <td class="fieldOptions">
                                            <asp:TextBox runat="server" ID="txtSearchFor" CssClass="inputText"></asp:TextBox>
											<label><asp:CheckBox runat="server" ID="CheckBox1" />Use exact phrase</label>
                                        </td>
                                       <td align="center">
                                        <a href="JavaScript:search();" class="search-button">Search</a>
                                       </td>
                                    </tr>
                                </table>
                            </div>
                        </td>
                    </tr>
                <tr>
                    <td colspan='3' style="padding: 0 2px">
                        <div class="searchSection" id="div1">
							<span id="andor">and/or</span>
                            <table width="100%" class='searchForm'>
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
                                        <asp:CheckBoxList ID="cblResearcherType" runat="server" Visible="true" CssClass="for-anirvan-advanced-researcher-type"/>
                                    </td>
                                </tr>

								<tr runat="server" id="trSections">
                                    <th>
                                        With these sections
                                    </th>
                                    <td class="pan" colspan="2">
                                        <asp:CheckBoxList ID="cblSections" runat="server" Visible="true" CssClass="for-anirvan-advanced-sections"/>
                                    </td>
                                </tr>

								<tr runat="server" id="trInterests">
                                    <th>
                                        With these interests
                                    </th>
                                    <td class="pan" colspan="2">
                                        <asp:CheckBoxList ID="cblInterests" runat="server" Visible="true" CssClass="for-anirvan-advanced-interests"/>
                                    </td>
                                </tr>
                            </table>

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
