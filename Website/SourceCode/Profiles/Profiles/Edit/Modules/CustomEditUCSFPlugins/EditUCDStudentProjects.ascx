﻿<%@ Control Language="C#" AutoEventWireup="true"
    CodeBehind="EditUCDStudentProjects.ascx.cs"
    Inherits="Profiles.Edit.Modules.CustomEditUCSFPlugIns.EditUCDStudentProjects" %>
<%@ Register TagName="Options" TagPrefix="security" Src="~/Edit/Modules/SecurityOptions/SecurityOptions.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<asp:UpdatePanel ID="upnlEditSection" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:UpdateProgress ID="updateProgress" runat="server" DynamicLayout="true" DisplayAfter="1000">
            <ProgressTemplate>
                <div class="modalupdate">
                    <div class="modalcenter">
                        <img alt="Updating..." src="<%=Profiles.Framework.Utilities.Brand.GetThemedDomain()%>/edit/images/loader.gif" /><br />
                        <i>Updating...</i>
                    </div>
                </div>
            </ProgressTemplate>
        </asp:UpdateProgress>
    </ContentTemplate>
</asp:UpdatePanel>

<div class="editBackLink">
    <asp:Literal runat="server" ID="litBackLink"></asp:Literal>
</div>

<asp:Panel ID="phSecuritySettings" runat="server">
    <security:Options runat="server" ID="securityOptions"></security:Options>
</asp:Panel>

<asp:UpdatePanel ID="upnlEditUCDStudentProjects" runat="server" class="EditPanel researcherprofiles--ucdstudentprojects-edit--container" UpdateMode="Conditional">
    <ContentTemplate>

        <div class="researcherprofiles--ucdstudentprojects-edit--header">
            <h2 class="researcherprofiles--ucdstudentprojects-edit--heading">
                Student Projects. 
            </h2>

            <asp:Panel runat="server" ID="pnlAdd" Visible="true">
                <div class="EditMenuItem">
                    <asp:LinkButton ID="btnAdd" runat="server" OnClick="btnAdd_OnClick">Add Student Projects to Your Profile</asp:LinkButton>
                </div>
            </asp:Panel>
        </div>

        <asp:Panel runat="server" ID="pnlEdit" Visible="false">
            <section class="researcherprofiles--ucdstudentprojects-edit--section">

                <p class="researcherprofiles--ucdstudentprojects-edit--last-updated">
                    Last Updated: <asp:Literal ID="litLastUpdated" runat="server" />
                </p>
                <div class="researcherprofiles--ucdstudentprojects-edit--available-group">
                    <p class="researcherprofiles--ucdstudentprojects-edit--subhead">
                        <strong>Type of research</strong> (check all that apply)
                    </p>

                    <div class="researcherprofiles--ucdstudentprojects-edit--checkbox-group">
                        <div class="researcherprofiles--ucdstudentprojects-edit--option-row">
                            <asp:CheckBox ID="cbClinicalResearch" runat="server" OnCheckedChanged="itmChanged"
                                Text="Clinical Research" />
                        </div>
                        <div class="researcherprofiles--ucdstudentprojects-edit--option-row">
                            <asp:CheckBox ID="cbBasicScience" runat="server" OnCheckedChanged="itmChanged"
                                Text="Basic Science" />
                        </div>
                        <div class="researcherprofiles--ucdstudentprojects-edit--option-row">
                            <asp:CheckBox ID="cbHealthDeliverPolicy" runat="server" OnCheckedChanged="itmChanged"
                                Text="Health Delivery/Policy" />
                        </div>
                        <div class="researcherprofiles--ucdstudentprojects-edit--option-row">
                            <asp:CheckBox ID="cbOther" runat="server" OnCheckedChanged="itmChanged"
                                Text="Other" />
                            <label class="researcherprofiles--ucdstudentprojects-edit--other-field">
                                <span class="researcherprofiles--ucdstudentprojects-edit--assistant-field-label">Name</span>
                                <asp:TextBox ID="txtOther" runat="server" OnTextChanged="itmChanged" CssClass="researcherprofiles--ucdstudentprojects-edit--text-input"></asp:TextBox>
                            </label>
                        </div>
                    </div>
                    <div class="EditMenuItem">
                        <asp:LinkButton ID="btnSaveResearchType" runat="server" OnClick="btnSaveResearchType_OnClick" CausesValidation="false">Save Type of Research</asp:LinkButton>
                    </div>
                </div>

                <div class="researcherprofiles--ucdstudentprojects-edit--project-fields" id="projectFields">
                    <p class="researcherprofiles--ucdstudentprojects-edit--subhead">
                        Add/Edit Student Projects
                    </p>
                    <asp:HiddenField ID="hdnProjectKey" runat="server" />
                    <div class="researcherprofiles--ucdstudentprojects-edit--project-field-row">
                        <label class="researcherprofiles--ucdstudentprojects-edit--project-field">
                            <span class="researcherprofiles--ucdstudentprojects-edit--project-field-label">Project Name:</span>
                            <asp:TextBox ID="txtProjectName" runat="server" CssClass="researcherprofiles--ucdstudentprojects-edit--text-input"></asp:TextBox>
                        </label>
                        <label class="researcherprofiles--ucdstudentprojects-edit--project-field">
                            <span class="researcherprofiles--ucdstudentprojects-edit--project-field-label">Location:</span>
                            <asp:TextBox ID="txtProjectLocation" runat="server" CssClass="researcherprofiles--ucdstudentprojects-edit--text-input"></asp:TextBox>
                        </label>
                        <label class="researcherprofiles--ucdstudentprojects-edit--project-field">
                            <span class="researcherprofiles--ucdstudentprojects-edit--assisprojecttant-field-label">Objectives:</span>
                            <asp:TextBox ID="txtProjectObjectives" runat="server" CssClass="researcherprofiles--ucdstudentprojects-edit--text-input"></asp:TextBox>
                        </label>
                        <label class="researcherprofiles--ucdstudentprojects-edit--project-field">
                            <span class="researcherprofiles--ucdstudentprojects-edit--assisprojecttant-field-label">Student Responsibilities:</span>
                            <asp:TextBox ID="txtStudentResponsibilities" runat="server" CssClass="researcherprofiles--ucdstudentprojects-edit--text-input"></asp:TextBox>
                        </label>

                        <label class="researcherprofiles--ucdstudentprojects-edit--project-field">
                            <span class="researcherprofiles--ucdstudentprojects-edit--assisprojecttant-field-label">Estimated Start Date:</span>
                            <asp:TextBox ID="txtStartDate" runat="server" CssClass="researcherprofiles--ucdstudentprojects-edit--text-input" TextMode="Date"></asp:TextBox>
                        </label>
                        <label class="researcherprofiles--ucdstudentprojects-edit--project-field">
                            <span class="researcherprofiles--ucdstudentprojects-edit--assisprojecttant-field-label">Estimated End Data:</span>
                            <asp:TextBox ID="txtEndDate" runat="server" CssClass="researcherprofiles--ucdstudentprojects-edit--text-input" TextMode="Date"></asp:TextBox>
                        </label>

                        <label class="researcherprofiles--ucdstudentprojects-edit--project-field">
                            <span class="researcherprofiles--ucdstudentprojects-edit--assisprojecttant-field-label">Link to related information:</span>
                            <asp:TextBox ID="txtLink" runat="server" CssClass="researcherprofiles--ucdstudentprojects-edit--text-input"></asp:TextBox>
                        </label>
                        <label class="researcherprofiles--ucdstudentprojects-edit--project-field">
                            <span class="researcherprofiles--ucdstudentprojects-edit--assisprojecttant-field-label">Optional Contact information if different than UC Davis Profile:</span>
                            <asp:TextBox ID="txtContactInfo" runat="server" CssClass="researcherprofiles--ucdstudentprojects-edit--text-input"></asp:TextBox>
                        </label>

                        <div style="padding-bottom: 5px; text-align: left;">
                            <asp:LinkButton ID="btnAddProject" runat="server" CausesValidation="False" OnClick="btnAddProject_OnClick"
                                Text="Add Student Project" ></asp:LinkButton>
                            &nbsp;&nbsp;<b>|</b>&nbsp;&nbsp;
                            <asp:LinkButton ID="btnCancel" runat="server" CausesValidation="False" OnClick="btnCancel_OnClick"
                                Text="Cancel"></asp:LinkButton>
                        </div>

                    </div>
                </div>

                <p class="researcherprofiles--ucdstudentprojects-edit--subhead">
                    Current Student Projects
                </p>

                <asp:GridView ID="GridViewPlugin" runat="server" AutoGenerateColumns="False" CellPadding="4"
                    DataKeyNames="Name, Location" GridLines="Both"
                    OnRowCancelingEdit="GridViewPlugin_RowCancelingEdit" OnRowDataBound="GridViewPlugin_RowDataBound"
                    OnRowDeleting="GridViewPlugin_RowDeleting" OnRowEditing="GridViewPlugin_RowEditing"
                    OnRowUpdated="GridViewPlugin_RowUpdated" OnRowUpdating="GridViewPlugin_RowUpdating"
                    Width="100%">
                    <HeaderStyle CssClass="topRow" BorderStyle="Solid" BorderWidth="1px" />
                    <RowStyle BorderStyle="Solid" BorderWidth="1px" />
                    <Columns>
                        <asp:TemplateField HeaderText="Project Name">
                            <ItemTemplate>
                                <asp:Label ID="lblName" runat="server" Text='<%# Bind("Name") %>'></asp:Label>
                            </ItemTemplate>
                            <ItemStyle Wrap="true" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Location">
                            <ItemTemplate>
                                <asp:Label ID="lblLocation" runat="server" Text='<%# Bind("Location") %>'></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField ItemStyle-HorizontalAlign="Center" ItemStyle-Width="100px" HeaderText="Action"
                            ShowHeader="False">
                            <ItemTemplate>
                                <div class="actionbuttons">
                                    <table>
                                        <tr>
                                            <td>
                                                <asp:ImageButton OnClick="ibUp_Click" runat="server" CommandArgument="up" CommandName="action"
                                                    ID="ibUp" ImageUrl="~/Edit/Images/icon_up.gif" AlternateText="Move Up" />
                                                <asp:ImageButton runat="server" ID="ibUpGray" Enabled="false" Visible="false" ImageUrl="~/Edit/Images/Icon_rounded_ArrowGrayUp.png" AlternateText="Move Up" />
                                            </td>
                                            <td>
                                                <asp:ImageButton runat="server" OnClick="ibDown_Click" ID="ibDown" CommandArgument="down"
                                                    CommandName="action" ImageUrl="~/Edit/Images/icon_down.gif" AlternateText="Move Down" />
                                                <asp:ImageButton runat="server" ID="ibDownGray" Enabled="false" Visible="false" ImageUrl="~/Edit/Images/Icon_rounded_ArrowGrayDown.png" AlternateText="Move Down" />
                                            </td>
                                            <td>
                                                <asp:ImageButton ID="lnkEdit" runat="server" ImageUrl="~/Edit/Images/icon_edit.gif"
                                                    CausesValidation="False" CommandName="Edit" Text="Edit" AlternateText="Edit"></asp:ImageButton>
                                            </td>
                                            <td>
                                                <asp:ImageButton ID="lnkDelete" runat="server" ImageUrl="~/Edit/Images/icon_delete.gif"
                                                    CausesValidation="False" CommandName="Delete" OnClientClick="Javascript:return confirm('Are you sure you want to delete this entry?');"
                                                    Text="X" AlternateText="Delete"></asp:ImageButton>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>      

            </section>
        </asp:Panel>

        <asp:Panel runat="server" ID="pnlDeleteAll" Visible="false">
            <div class="EditMenuItem">
                <asp:LinkButton ID="btnDeleteAll" runat="server" OnClick="btnDeleteAll_OnClick" CausesValidation="false" 
                    OnClientClick="Javascript:return confirm('Are you sure you want to delete all Student Project data?');" >Delete All Student Project data from Your Profile</asp:LinkButton>
            </div>
        </asp:Panel>

        <div class="editBody researcherprofiles--ucdstudentprojects-edit--message" id="divMessage" runat="server"
                role="status" aria-live="polite" aria-atomic="true">
            <asp:Label runat="server" ID="lblMessage"></asp:Label>
        </div>

    </ContentTemplate>
</asp:UpdatePanel>
