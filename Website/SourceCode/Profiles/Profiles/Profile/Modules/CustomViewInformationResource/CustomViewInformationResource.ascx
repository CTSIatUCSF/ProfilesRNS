﻿<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="CustomViewInformationResource.ascx.cs"
    Inherits="Profiles.Profile.Modules.CustomViewInformationResource.CustomViewInformationResource" %>
<div style="margin-top:12px;">
    <asp:Literal runat="server" ID="litinformationResourceReference"></asp:Literal>
</div>
<br />
<div class="viewIn" runat="server" id="divViewIn">
    <span class="viewInLabel">View in: </span>
    <asp:Literal runat="server" ID="litPublication"></asp:Literal>
</div>
<br />
<asp:Panel runat="server" ID="pnlSubjectAreas" Visible="true">
    <div class="PropertyGroupItem">
        <div class="PropertyItemHeader">
            <a onClick="javascript:toggleBlock('subjectAreaItems'); return false;">
                <img runat="server" id="imgSubjectArea" src="minusSign.gif" style="border: none;
                    text-decoration: none !important" border="0" width="9" height="9"/>
            </a>subject areas
        </div>
        <div class="PropertyGroupData">
            <div id="subjectAreaItems" style="padding-top: 8px;">
                <ul style="padding-left: 0; margin: 0; list-style-type: none;">
                    <asp:Repeater runat="server" ID="rptSubjectAreas" OnItemDataBound="rptSubjectAreas_OnItemDataBound">
                        <ItemTemplate>
                            <li>
                                <asp:Literal runat="server" ID="litAbout"></asp:Literal></li>
                        </ItemTemplate>
                    </asp:Repeater>
                </ul>
            </div>
        </div>
    </div>
    <br/>
</asp:Panel>
<asp:Panel runat="server" ID="pnlAuthors" Visible="true">
<div class="PropertyGroupItem" style="margin-bottom: 10px;">
    <div class="PropertyItemHeader">
        <a onClick="javascript:toggleBlock('authorshipItems'); return false">authors with profiles</a>
            <img runat="server" id="imgAuthor" src="minusSign.gif" style="border: none; text-decoration: none !important"
                border="0" width="9" height="9"/>
        </a>authors with profiles
    </div>
    <div class="PropertyGroupData">
        <div id="authorshipItems" style="padding-top: 8px;">
            <ul style="padding-left: 0; margin: 0; list-style-type: none;">
                <asp:Repeater runat="server" ID="rptAuthors" OnItemDataBound="rptAuthors_OnItemDataBound">
                    <ItemTemplate>
                        <li>
                            <asp:Literal runat="server" ID="litAuthor"></asp:Literal></li>
                    </ItemTemplate>
                </asp:Repeater>
            </ul>
        </div>
    </div>
</div>
<br></br>
</asp:Panel>
