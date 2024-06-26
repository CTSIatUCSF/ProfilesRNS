﻿<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="SearchConnection.ascx.cs"
    Inherits="Profiles.Search.Modules.SearchConnection" %>
<div>
    <div class="connectionContainer">
        <table class="connectionContainerTable">
            <tbody>
                <tr>
                    <td class="connectionContainerItem">
                        <div>
                            <asp:Literal runat="server" ID="litSearchURL"></asp:Literal>
                        </div>
                    </td>
                    <td class="connectionContainerArrow" style="vertical-align: middle">
                        <img src="<%=GetThemedDomain()%>/Framework/Images/connection.gif" />
<!--
                        <table class="connectionArrowTable">
                            <tbody>
                                <tr>
                                    <td />
                                    <td>
                                        <div class="connectionDescription">
                                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div>
                                    </td>
                                    <td />
                                </tr>
                                <tr>
                                    <td class="connectionLine">
                                        <img src="<%=GetThemedDomain()%>/Framework/Images/connection_left.gif" alt=""/>
                                    </td>
                                    <td class="connectionLine">
                                        <div>
                                        </div>
                                    </td>
                                    <td class="connectionLine">
                                        <img src="<%=GetThemedDomain()%>/Framework/Images/connection_right.gif" alt=""/>
                                    </td>
                                </tr>
                                <tr>
                                    <td />
                                    <td>
                                        <div class="connectionSubDescription">
                                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                        </div>
                                    </td>
                                    <td />
                                </tr>
                            </tbody>
                        </table>
-->
                    </td>
                    <td class="connectionContainerItem">
                        <div>
                            <asp:Literal runat="server" ID="litNodeURI"></asp:Literal>
                        </div>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>    
    <asp:Panel runat="server" ID="pnlDirectConnection" Visible="false">
    <br />
        One or more search terms matched the following properties of
        <asp:Literal runat="server" ID="litPersonURI"></asp:Literal>
        <br />
        <br />
        <div>
            <asp:GridView Width="100%" ID="gvConnectionDetails" AutoGenerateColumns="false" GridLines="Both"
                CellSpacing="-1" runat="server" OnRowDataBound="gvConnectionDetails_OnRowDataBound">
                <HeaderStyle CssClass="topRow" BorderStyle="None" />
                
                <AlternatingRowStyle CssClass="evenRow" />
                <Columns>
                    <asp:TemplateField ItemStyle-CssClass="connectionTableRow" HeaderText="Property"
                        HeaderStyle-Width="200px">
                        <ItemTemplate>
                            <asp:Literal runat="server" ID="litProperty"></asp:Literal>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField ItemStyle-CssClass="connectionTableRow" HeaderText="Value">
                        <ItemTemplate>
                            <asp:Literal runat="server" ID="litValue"></asp:Literal>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </asp:Panel>    
    <asp:Panel runat="server" ID="pnlIndirectConnection" Visible="false">
    <br />
        One or more search terms matched the following items that are connected to
        <asp:Literal runat="server" ID="litSubjectName"></asp:Literal>
        <br />
        <br />
        <div>
            <asp:GridView Width="100%" ID="gvIndirectConnectionDetails" AutoGenerateColumns="false"
                GridLines="Both" CellSpacing="-1" runat="server" OnRowDataBound="gvIndirectConnectionDetails_OnRowDataBound">
                <HeaderStyle CssClass="topRow" BorderStyle="None" />
                
                <AlternatingRowStyle CssClass="evenRow" />
                <Columns>
                    <asp:TemplateField ItemStyle-CssClass="connectionTableRow" HeaderText="Item Type"
                        HeaderStyle-Width="200px">
                        <ItemTemplate>
                            <asp:Literal runat="server" ID="litProperty"></asp:Literal>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField ItemStyle-CssClass="connectionTableRow" HeaderText="Name">
                        <ItemTemplate>
                            <asp:Literal runat="server" ID="litValue"></asp:Literal>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </asp:Panel>
</div>
<br />
