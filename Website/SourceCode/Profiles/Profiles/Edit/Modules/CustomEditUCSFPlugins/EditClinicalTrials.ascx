<%@ Control Language="C#" AutoEventWireup="true" 
    CodeBehind="EditClinicalTrials.ascx.cs"
    Inherits="Profiles.Edit.Modules.CustomEditUCSFPlugIns.ClinicalTrials" %>
<%@ Register TagName="Options" TagPrefix="security" Src="~/Edit/Modules/SecurityOptions/SecurityOptions.ascx" %>

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

        <div class="editBackLink">
            <asp:Literal runat="server" ID="litBackLink"></asp:Literal>
        </div>

        <asp:Panel ID="phSecuritySettings" runat="server">
            <security:Options runat="server" ID="securityOptions"></security:Options>
        </asp:Panel>

        <asp:Panel runat="server" ID="pnlAddEdit">
            <div class="EditMenuItem">
                <asp:ImageButton CssClass="EditMenuLinkImg" OnClick="btnAddEdit_OnClick" runat="server" ID="imbAddArrow" AlternateText=" " ImageUrl="~/Edit/Images/icon_squareArrow.gif" />
                <asp:LinkButton ID="btnAddEditEdit" runat="server" OnClick="btnAddEdit_OnClick">Add Clinical Trial by NCT Number</asp:LinkButton>
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlInsert" runat="server" Style="background-color: #EEE; margin-bottom: 5px;
            border: solid 1px #ccc;" Visible="false" >
            <table border="0" cellspacing="2" cellpadding="4">
                <tr>
                    <td>
                        <div style="padding-top: 5px;">
                            Please make sure the recruiting status and contact information are correct for this trial at <a href="https://clinicaltrials.gov">clinicaltrials.gov</a>.
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>
                        <b>NCT Number</b>
                        <asp:TextBox ID="txtNct" runat="server" MaxLength="100" Width="220px" title="nct"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td>
                        <div style="padding-bottom: 5px; text-align: left;">
                            <asp:LinkButton ID="btnSaveAndAdd" runat="server" CausesValidation="False" OnClick="btnSaveAndAdd_OnClick"
                                Text="Save and add another" ></asp:LinkButton>
                            &nbsp;&nbsp;<b>|</b>&nbsp;&nbsp;
                            <asp:LinkButton ID="btnSaveAndClose" runat="server" CausesValidation="False" OnClick="btnSaveAndClose_OnClick"
                                Text="Save and Close" ></asp:LinkButton>
                            &nbsp;&nbsp;<b>|</b>&nbsp;&nbsp;
                            <asp:LinkButton ID="btnSaveCancel" runat="server" CausesValidation="False" OnClick="btnSaveCancel_OnClick"
                                Text="Close"></asp:LinkButton>
                        </div>
                    </td>
                </tr>
            </table>
        </asp:Panel>

        <div class="editPage">
                <asp:GridView ID="GridViewPlugin" runat="server" AutoGenerateColumns="False" CellPadding="4"
                    DataKeyNames="Id, SourceUrl, Title, StartDate, CompletionDateLabel, CompletionDateValue, Conditions, Status" GridLines="Both"
                    OnRowDataBound="GridViewPlugin_RowDataBound"
                    OnRowDeleting="GridViewPlugin_RowDeleting" 
                    Width="100%">
                    <HeaderStyle CssClass="topRow" BorderStyle="Solid" BorderWidth="1px" />
                    <RowStyle BorderStyle="Solid" BorderWidth="1px" />
                    <Columns>
                        <asp:TemplateField HeaderText="NCT">
                            <ItemTemplate>
								<asp:HyperLink ID="hypNCT" runat="server" Target="_blank" NavigateUrl='<%# Bind("SourceUrl") %>' Text='<%# Bind("Id") %>'></asp:HyperLink>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Description">
                           <ItemTemplate>
                                Title: <asp:Label ID="lblDescription" runat="server" Text='<%# Bind("Title") %>'></asp:Label></br>
                                Start Date: <asp:Label ID="lblStartDate" runat="server" Text='<%# Bind("StartDate") %>'></asp:Label></br>
                                <asp:Label ID="lblCompletionDateLabel" runat="server" Text='<%# Bind("CompletionDateLabel") %>'></asp:Label>:&nbsp;
								<asp:Label ID="lblCompletionDateValue" runat="server" Text='<%# Bind("CompletionDateValue") %>'></asp:Label></br>
                                Condition(s): <asp:Label ID="lblConditions" runat="server" Text='<%# Bind("Conditions") %>'></asp:Label></br>
                                Status: <asp:Label ID="lblStatus" runat="server" Text='<%# Bind("Status") %>'></asp:Label>
                            </ItemTemplate>
                            <ItemStyle Wrap="true" />
                        </asp:TemplateField>
                        <asp:TemplateField ItemStyle-HorizontalAlign="Center" ItemStyle-Width="100px" HeaderText="Action"
                            ShowHeader="False">
                            <ItemTemplate>
                                <div class="actionbuttons">
                                    <table>
                                        <tr>
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

            <div class="editBody" style="text-align: left;" id="divNoEntries" runat="server">
                <i>
                <asp:Label runat="server" ID="lblNoEntries" Text="No Clinical Trials been found or added."></asp:Label>
                </i>
            </div>
        </div>
    </ContentTemplate>
</asp:UpdatePanel>

