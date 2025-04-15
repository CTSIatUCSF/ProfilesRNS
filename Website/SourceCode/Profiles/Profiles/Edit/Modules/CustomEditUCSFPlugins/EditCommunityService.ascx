<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="EditCommunityService.ascx.cs"
    Inherits="Profiles.Edit.Modules.CustomEditUCSFPlugIns.CommunityService" %>
<%@ Register TagName="Options" TagPrefix="security" Src="~/Edit/Modules/SecurityOptions/SecurityOptions.ascx" %>
<asp:UpdatePanel ID="upnlEditSection" runat="server" UpdateMode="Conditional">
    <ContentTemplate>   
        <asp:UpdateProgress ID="updateProgress" runat="server">
            <ProgressTemplate>
                <div class="modalupdate">
                    <div class="modalcenter">
                        <img alt="Updating..." src="<%=Profiles.Framework.Utilities.Brand.GetThemedDomain()%>/edit/images/loader.gif" />
                        <br />
                        <i>Updating...</i>
                    </div>
                </div>
            </ProgressTemplate>                    
        </asp:UpdateProgress>
        <asp:HiddenField ID="hiddenSubjectID" runat="server" />
        
        <table id="tblEditCommunityService" width="100%">
            <tr>
                <td>
                    <asp:Literal runat="server" ID="litBackLink"></asp:Literal>
                </td>
            </tr>
            <tr>
                <td>
                    <div style="padding: 10px 0px;">
                        <asp:Panel runat="server" ID="pnlSecurityOptions">
                            <security:Options runat="server" ID="securityOptions"></security:Options>
                        </asp:Panel>
                        <br />
                        <asp:Panel runat="server" ID="pnlEditCommunityService">
                            <asp:ImageButton CssClass="EditMenuLinkImg" runat="server" OnClick="btnEditCommunityService_OnClick" ID="imbAddArrow" AlternateText=" " ImageUrl="~/Edit/Images/icon_squareArrow.gif" />
							<asp:LinkButton ID="btnEditCommunityService" runat="server" OnClick="btnEditCommunityService_OnClick" 
                                CssClass="profileHypLinks"> Add Community and Public Service</asp:LinkButton>
                        </asp:Panel>
                        <asp:Panel runat="server" ID="pnlCopyAdvanceCommunityService" SkinID="UCSF" Visible="false">
                                <asp:ImageButton CssClass="EditMenuLinkImg" runat="server" OnClick="btnCopyAdvanceCommunityService_OnClick" ID="imbAdvanceArrow" AlternateText=" " 
                                    ImageUrl="~/Edit/Images/icon_squareArrow.gif" OnClientClick="Javascript:return confirm('Are you sure you want to import CommunityService and Honors from Advance?');"/>
                                <asp:LinkButton ID="btnCopyAdvanceCommunityService" runat="server" OnClick="btnCopyAdvanceCommunityService_OnClick"
                                    OnClientClick="Javascript:return confirm('Are you sure you want to OVERWRITE with Honors and CommunityService from your Advance CV?');">Overwrite these entries with Community and Public Servie from Advance CV</asp:LinkButton>
                                <p class="text-left"><asp:Literal runat="server" ID="litAdvanceMessage" Text="Note: If you have set Prefs in Advance to share data with Profiles, this action overwrites the entries on this page with the Community and Public Service from your Advance CV. Once brought over, the data is independent from your Advance CV. Edits you make here will not affect your Advance CV."/></p>
                        </asp:Panel>
                        <asp:Panel runat="server" ID="pnlSortCommunityService">
                            <asp:ImageButton CssClass="EditMenuLinkImg" runat="server" OnClick="btnSortCommunityService_OnClick" ID="imbSortArrow" AlternateText=" " ImageUrl="~/Edit/Images/icon_squareArrow.gif" />
							<asp:LinkButton ID="btnSortCommunityService" runat="server" OnClick="btnSortCommunityService_OnClick" 
                                CssClass="profileHypLinks"> Sort all Community and Public Service entries</asp:LinkButton> by date, with newest at the top. 
                        </asp:Panel>
                    </div>
                </td>
            </tr>
            <tr>
                <td>                   
                    <asp:Repeater ID="RptrEditCommunityService" runat="server" Visible="false">
                        <ItemTemplate>
                            <asp:Label ID="lblEditCommunityService" runat="server" Text='<%#Eval("CommunityService").ToString() %>' />
                            <br />
                        </ItemTemplate>
                    </asp:Repeater>
                    <asp:Panel ID="pnlInsertCommunityService" runat="server" Style="background-color: #EEE; margin-bottom: 5px;
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
                                        <asp:LinkButton ID="btnInsertCommunityService" runat="server" CausesValidation="False" OnClick="btnInsert_OnClick"
                                            Text="Save and add another" ></asp:LinkButton>
                                        &nbsp;&nbsp;<b>|</b>&nbsp;&nbsp;
                                        <asp:LinkButton ID="btnInsertCommunityService2" runat="server" CausesValidation="False" OnClick="btnInsertClose_OnClick"
                                            Text="Save and Close" ></asp:LinkButton>
                                        &nbsp;&nbsp;<b>|</b>&nbsp;&nbsp;
                                        <asp:LinkButton ID="btnInsertCancel" runat="server" CausesValidation="False" OnClick="btnInsertCancel_OnClick"
                                            Text="Close"></asp:LinkButton>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </asp:Panel>
                    <div>
                        <asp:GridView ID="GridViewCommunityService" runat="server" AutoGenerateColumns="False" CellPadding="4"
                            DataKeyNames="SubjectURI,Predicate, Object" GridLines="Both"
                            OnRowCancelingEdit="GridViewCommunityService_RowCancelingEdit" OnRowDataBound="GridViewCommunityService_RowDataBound"
                            OnRowDeleting="GridViewCommunityService_RowDeleting" OnRowEditing="GridViewCommunityService_RowEditing"
                            OnRowUpdated="GridViewCommunityService_RowUpdated" OnRowUpdating="GridViewCommunityService_RowUpdating"
                            Width="100%">
                            <HeaderStyle CssClass="topRow" BorderStyle="Solid" BorderWidth="1px" />
                            <RowStyle BorderStyle="Solid" BorderWidth="1px" />
                            <Columns>
                                <asp:TemplateField HeaderText="Institution">
                                    <EditItemTemplate>
                                        <asp:TextBox ID="txtCommunityServiceInst" runat="server" MaxLength="100" Text='<%# Bind("Institution") %>' title="Institution"></asp:TextBox>
                                        <asp:HiddenField runat="server" ID="hdURI" />
                                    </EditItemTemplate>
                                    <ItemTemplate>
                                        <asp:Label ID="lblCommunityServiceInst" runat="server" Text='<%# Bind("Institution") %>'></asp:Label>
                                        <asp:HiddenField runat="server" ID="hdURI" />
                                    </ItemTemplate>
                                    <ItemStyle Wrap="true" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Year&nbsp;of Service">
                                    <EditItemTemplate>
                                        <asp:TextBox ID="txtYr1" runat="server" MaxLength="4" Text='<%# Bind("StartDate") %>' title="Year of service"></asp:TextBox>
                                    </EditItemTemplate>
                                    <ItemTemplate>
                                        <asp:Label ID="lblYr1" runat="server" Text='<%# Bind("StartDate") %>'></asp:Label>
                                    </ItemTemplate>
                                    <ControlStyle Width="35px" />
                                    <HeaderStyle HorizontalAlign="Center" />
                                    <ItemStyle HorizontalAlign="Center" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Thru Year">
                                    <EditItemTemplate>
                                        <asp:TextBox ID="txtYr2" runat="server" MaxLength="4" Text='<%# Bind("EndDate") %>' title="Through year"></asp:TextBox>
                                    </EditItemTemplate>
                                    <ItemTemplate>
                                        <asp:Label ID="lblYr2" runat="server" Text='<%# Bind("EndDate") %>'></asp:Label>
                                    </ItemTemplate>
                                    <ControlStyle Width="35px" />
                                    <HeaderStyle HorizontalAlign="Center" />
                                    <ItemStyle HorizontalAlign="Center" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Role">
                                    <EditItemTemplate>
                                        <asp:TextBox ID="txtCommunityServiceRole" runat="server" MaxLength="100" Text='<%# Bind("Role") %>' title="Role"></asp:TextBox>
                                    </EditItemTemplate>
                                    <ItemTemplate>
                                        <asp:Label ID="lblCommunityServiceRole" runat="server" Text='<%# Bind("Role") %>'></asp:Label>
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
                    </div>
                    <i><asp:Label runat="server" ID="lblNoCommunityService" Text="No Community or Public Sevice has been added." Visible ="false"></asp:Label></i>
                </td>
            </tr>
        </table>
    </ContentTemplate>
</asp:UpdatePanel>
