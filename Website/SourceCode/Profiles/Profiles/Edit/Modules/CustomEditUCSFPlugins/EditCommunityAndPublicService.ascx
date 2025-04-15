<%@ Control Language="C#" AutoEventWireup="true" 
    CodeBehind="EditCommunityAndPublicService.ascx.cs"
    Inherits="Profiles.Edit.Modules.CustomEditUCSFPlugIns.CommunityAndPublicService" %>
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
                <asp:LinkButton ID="btnAddEditEdit" runat="server" OnClick="btnAddEdit_OnClick">Manually Add Community and Public Service Entries</asp:LinkButton>
            </div>
        </asp:Panel>

        <asp:Panel runat="server" ID="pnlCopyFromAdvance" SkinID="UCSF" Visible="false">
                <asp:ImageButton CssClass="EditMenuLinkImg" runat="server" OnClick="btnCopyFromAdvance_OnClick" ID="imbAdvanceArrow" AlternateText=" " 
                    ImageUrl="~/Edit/Images/icon_squareArrow.gif" OnClientClick="Javascript:return confirm('Are you sure you want to import Community and Public Service from Advance?');"/>
                <asp:LinkButton ID="btnCopyFromAdvance" runat="server" OnClick="btnCopyFromAdvance_OnClick"
                    OnClientClick="Javascript:return confirm('Are you sure you want to OVERWRITE with Community and Public Service from your Advance CV?');">Overwrite these entries with Community and Public Service from Advance CV</asp:LinkButton>
                <p class="text-left"><asp:Literal runat="server" ID="litAdvanceMessage" Text="Note: If you have set Prefs in Advance to share data with Profiles, this action overwrites the entries on this page with the Community and Public Service from your Advance CV. Once brought over, the data is independent from your Advance CV. Edits you make here will not affect your Advance CV."/></p>
        </asp:Panel>

        <asp:Panel runat="server" ID="pnlSort">
            <asp:ImageButton CssClass="EditMenuLinkImg" runat="server" OnClick="btnSort_OnClick" ID="imbSortArrow" AlternateText=" " ImageUrl="~/Edit/Images/icon_squareArrow.gif" />
	        <asp:LinkButton ID="btnSort" runat="server" OnClick="btnSort_OnClick" 
                CssClass="profileHypLinks"> Sort all Community and Public Service entries</asp:LinkButton> by date, with newest at the top. 
        </asp:Panel>


        <asp:Panel ID="pnlInsert" runat="server" Style="background-color: #EEE; margin-bottom: 5px;
            border: solid 1px #ccc;" Visible="false" >
            <table border="0" cellspacing="2" cellpadding="4">
                <tr>
                    <td colspan="3">
                        <div style="padding-top: 5px;">
                            Enter the institution, year(s) and role.
                        </div>
                    </td>
                </tr>
                <tr>
                    <td>
                    <td>
                        <b>Institution</b><br />
                        <asp:TextBox ID="txtInstitution" runat="server" MaxLength="100" Width="220px" title="institution"></asp:TextBox>
                    </td>
                        <b>Service Year(s)</b><br />
                        <asp:TextBox ID="txtStartYear" runat="server" MaxLength="4" Width="60px" title="start year"></asp:TextBox>
                        &nbsp;<b>-</b>&nbsp;
                        <asp:TextBox ID="txtEndYear" runat="server" MaxLength="4" Width="60px" title="end year"></asp:TextBox>
                    </td>
                    <td>
                        <b>Role</b><br />
                        <asp:TextBox ID="txtRole" runat="server" MaxLength="100" Width="220px" title="role"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td colspan="3">
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
                    DataKeyNames="Institution, StartDate, EndDate, Role" GridLines="Both"
                    OnRowCancelingEdit="GridViewPlugin_RowCancelingEdit" OnRowDataBound="GridViewPlugin_RowDataBound"
                    OnRowDeleting="GridViewPlugin_RowDeleting" OnRowEditing="GridViewPlugin_RowEditing"
                    OnRowUpdated="GridViewPlugin_RowUpdated" OnRowUpdating="GridViewPlugin_RowUpdating"
                    Width="100%">
                    <HeaderStyle CssClass="topRow" BorderStyle="Solid" BorderWidth="1px" />
                    <RowStyle BorderStyle="Solid" BorderWidth="1px" />
                    <Columns>
                        <asp:TemplateField HeaderText="Institution">
                            <EditItemTemplate>
                                <asp:TextBox ID="txtInstitution" runat="server" MaxLength="100" Text='<%# Bind("Institution") %>' title="Institution"></asp:TextBox>
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:Label ID="lblInstitution" runat="server" Text='<%# Bind("Institution") %>'></asp:Label>
                            </ItemTemplate>
                            <ItemStyle Wrap="true" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Year&nbsp;of Service">
                            <EditItemTemplate>
                                <asp:TextBox ID="txtStartDate" runat="server" MaxLength="4" Text='<%# Bind("StartDate") %>' title="Year of service"></asp:TextBox>
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:Label ID="lblStartDate" runat="server" Text='<%# Bind("StartDate") %>'></asp:Label>
                            </ItemTemplate>
                            <ControlStyle Width="35px" />
                            <HeaderStyle HorizontalAlign="Center" />
                            <ItemStyle HorizontalAlign="Center" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Thru Year">
                            <EditItemTemplate>
                                <asp:TextBox ID="txtEndDate" runat="server" MaxLength="4" Text='<%# Bind("EndDate") %>' title="Through year"></asp:TextBox>
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:Label ID="lblEndDate" runat="server" Text='<%# Bind("EndDate") %>'></asp:Label>
                            </ItemTemplate>
                            <ControlStyle Width="35px" />
                            <HeaderStyle HorizontalAlign="Center" />
                            <ItemStyle HorizontalAlign="Center" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Role">
                            <EditItemTemplate>
                                <asp:TextBox ID="txtRole" runat="server" MaxLength="100" Text='<%# Bind("Role") %>' title="Role"></asp:TextBox>
                            </EditItemTemplate>
                            <ItemTemplate>
                                <asp:Label ID="lblRole" runat="server" Text='<%# Bind("Role") %>'></asp:Label>
                            </ItemTemplate>
                            <ItemStyle Wrap="true" />
                        </asp:TemplateField>
                        <asp:TemplateField ItemStyle-HorizontalAlign="Center" ItemStyle-Width="100px" HeaderText="Action"
                            ShowHeader="False">
                            <EditItemTemplate>
                                <table class="actionbuttons">
                                    <tr>
                                        <td>
                                            <asp:ImageButton ID="lnkUpdate" runat="server" ImageUrl="~/Edit/Images/button_save.gif"
                                                CausesValidation="True" CommandName="Update" Text="Update" AlternateText="Update"></asp:ImageButton>
                                        </td>
                                        <td>
                                            <asp:ImageButton ID="lnkCancel" runat="server" ImageUrl="~/Edit/Images/button_cancel.gif"
                                                CausesValidation="False" CommandName="Cancel" Text="Cancel" AlternateText="Cancel"></asp:ImageButton>
                                        </td>
                                    </tr>
                                </table>
                            </EditItemTemplate>
                            <ItemTemplate>
                            </ItemTemplate>
                            <ItemTemplate>
                                <div class="actionbuttons">
                                    <table>
                                        <tr>
                                            <td>
                                                <asp:ImageButton OnClick="ibUp_Click" runat="server" CommandArgument="up" CommandName="action"
                                                    ID="ibUp" ImageUrl="~/Edit/Images/icon_up.gif" AlternateText="Move Up" />
                                            </td>
                                            <td>
                                                <asp:ImageButton runat="server" OnClick="ibDown_Click" ID="ibDown" CommandArgument="down"
                                                    CommandName="action" ImageUrl="~/Edit/Images/icon_down.gif" AlternateText="Move Down" />
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

            <div class="editBody" style="text-align: left;" id="divNoEntries" runat="server">
                <i>
                <asp:Label runat="server" ID="lblNoEntries" Text="No Community or Public Sevice has been added."></asp:Label>
                </i>
            </div>
        </div>
    </ContentTemplate>
</asp:UpdatePanel>

