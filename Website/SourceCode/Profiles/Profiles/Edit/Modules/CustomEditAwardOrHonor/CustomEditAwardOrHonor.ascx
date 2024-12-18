﻿<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="CustomEditAwardOrHonor.ascx.cs"
    Inherits="Profiles.Edit.Modules.CustomEditAwardOrHonor.CustomEditAwardOrHonor" %>
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
        
        <table id="tblEditAwardsHonors" width="100%">
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
                        <asp:Panel runat="server" ID="pnlEditAwards">
                            <asp:ImageButton CssClass="EditMenuLinkImg" runat="server" OnClick="btnEditAwards_OnClick" ID="imbAddArrow" AlternateText=" " ImageUrl="~/Edit/Images/icon_squareArrow.gif" />
							<asp:LinkButton ID="btnEditAwards" runat="server" OnClick="btnEditAwards_OnClick" 
                                CssClass="profileHypLinks"> Add Award(s)</asp:LinkButton>
                        </asp:Panel>
                        <asp:Panel runat="server" ID="pnlCopyAdvanceAwards" SkinID="UCSF" Visible="false">
                                <asp:ImageButton CssClass="EditMenuLinkImg" runat="server" OnClick="btnCopyAdvanceAwards_OnClick" ID="imbAdvanceArrow" AlternateText=" " 
                                    ImageUrl="~/Edit/Images/icon_squareArrow.gif" OnClientClick="Javascript:return confirm('Are you sure you want to import Awards and Honors from Advance?');"/>
                                <asp:LinkButton ID="btnCopyAdvanceAwards" runat="server" OnClick="btnCopyAdvanceAwards_OnClick"
                                    OnClientClick="Javascript:return confirm('Are you sure you want to OVERWRITE with Honors and Awards from your Advance CV?');">Overwrite these entries with Honors and Awards from Advance CV</asp:LinkButton>
                                <p class="text-left"><asp:Literal runat="server" ID="litAdvanceMessage" Text="Note: If you have set Prefs in Advance to share data with Profiles, this action overwrites the Awards and Honors on this page with the Honors and Awards from your Advance CV. Once brought over, the data is independent from your Advance CV. Edits you make here will not affect your Advance CV."/></p>
                        </asp:Panel>
                        <asp:Panel runat="server" ID="pnlSortAwards">
                            <asp:ImageButton CssClass="EditMenuLinkImg" runat="server" OnClick="btnSortAwards_OnClick" ID="imbSortArrow" AlternateText=" " ImageUrl="~/Edit/Images/icon_squareArrow.gif" />
							<asp:LinkButton ID="btnSortAwards" runat="server" OnClick="btnSortAwards_OnClick" 
                                CssClass="profileHypLinks"> Sort all Awards</asp:LinkButton> by date, with newest at the top. 
                        </asp:Panel>
                    </div>
                </td>
            </tr>
            <tr>
                <td>                   
                    <asp:Repeater ID="RptrEditAwards" runat="server" Visible="false">
                        <ItemTemplate>
                            <asp:Label ID="lblEditAwards" runat="server" Text='<%#Eval("AwardsHonors").ToString() %>' />
                            <br />
                        </ItemTemplate>
                    </asp:Repeater>
                    <asp:Panel ID="pnlInsertAward" runat="server" Style="background-color: #EEE; margin-bottom: 5px;
                        border: solid 1px #ccc;" Visible="false" >
                        <table border="0" cellspacing="2" cellpadding="4">
                            <tr>
                                <td colspan="3">
                                    <div style="padding-top: 5px;">
                                        Enter the year(s), name and institution.
                                    </div>
                                    <div style="padding-top: 3px;">
                                        For Award Year(s), enter both fields only if awarded for consecutive years.
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <b>Award Year(s)</b><br />
                                    <asp:TextBox ID="txtStartYear" runat="server" MaxLength="4" Width="60px" title="start year"></asp:TextBox>
                                    &nbsp;<b>-</b>&nbsp;
                                    <asp:TextBox ID="txtEndYear" runat="server" MaxLength="4" Width="60px" title="end year"></asp:TextBox>
                                </td>
                                <td>
                                    <b>Name (required)</b><br />
                                    <asp:TextBox ID="txtAwardName" runat="server" MaxLength="100" Width="220px" title="award name"></asp:TextBox>
                                </td>
                                <td>
                                    <b>Institution</b><br />
                                    <asp:TextBox ID="txtInstitution" runat="server" MaxLength="100" Width="220px" title="institution"></asp:TextBox>
                                </td>
                            </tr>
                            <tr>
                                <td colspan="3">
                                    <div style="padding-bottom: 5px; text-align: left;">
                                        <asp:LinkButton ID="btnInsertAward" runat="server" CausesValidation="False" OnClick="btnInsert_OnClick"
                                            Text="Save and add another" ></asp:LinkButton>
                                        &nbsp;&nbsp;<b>|</b>&nbsp;&nbsp;
                                        <asp:LinkButton ID="btnInsertAward2" runat="server" CausesValidation="False" OnClick="btnInsertClose_OnClick"
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
                        <asp:GridView ID="GridViewAwards" runat="server" AutoGenerateColumns="False" CellPadding="4"
                            DataKeyNames="SubjectURI,Predicate, Object" GridLines="Both"
                            OnRowCancelingEdit="GridViewAwards_RowCancelingEdit" OnRowDataBound="GridViewAwards_RowDataBound"
                            OnRowDeleting="GridViewAwards_RowDeleting" OnRowEditing="GridViewAwards_RowEditing"
                            OnRowUpdated="GridViewAwards_RowUpdated" OnRowUpdating="GridViewAwards_RowUpdating"
                            Width="100%">
                            <HeaderStyle CssClass="topRow" BorderStyle="Solid" BorderWidth="1px" />
                            <RowStyle BorderStyle="Solid" BorderWidth="1px" />
                            <Columns>
                                <asp:TemplateField HeaderText="Year&nbsp;of Award">
                                    <EditItemTemplate>
                                        <asp:TextBox ID="txtYr1" runat="server" MaxLength="4" Text='<%# Bind("StartDate") %>' title="Year of award"></asp:TextBox>
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
                                <asp:TemplateField HeaderText="Name">
                                    <EditItemTemplate>
                                        <asp:TextBox ID="txtAwardName" runat="server" MaxLength="100" Text='<%# Bind("Name") %>' title="Name"></asp:TextBox>
                                    </EditItemTemplate>
                                    <ItemTemplate>
                                        <asp:Label ID="lblAwardName" runat="server" Text='<%# Bind("Name") %>'></asp:Label>
                                    </ItemTemplate>
                                    <ItemStyle Wrap="true" />
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Institution">
                                    <EditItemTemplate>
                                        <asp:TextBox ID="txtAwardInst" runat="server" MaxLength="100" Text='<%# Bind("Institution") %>' title="Institution"></asp:TextBox>
                                        <asp:HiddenField runat="server" ID="hdURI" />
                                    </EditItemTemplate>
                                    <ItemTemplate>
                                        <asp:Label ID="lblAwardInst" runat="server" Text='<%# Bind("Institution") %>'></asp:Label>
                                        <asp:HiddenField runat="server" ID="hdURI" />
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
                    <i><asp:Label runat="server" ID="lblNoAwards" Text="No awards have been added." Visible ="false"></asp:Label></i>
                </td>
            </tr>
        </table>
    </ContentTemplate>
</asp:UpdatePanel>
