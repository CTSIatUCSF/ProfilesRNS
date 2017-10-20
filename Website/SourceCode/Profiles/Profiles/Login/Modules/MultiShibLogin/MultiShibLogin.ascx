<%@ Control Language="C#" EnableViewState="true" AutoEventWireup="true" CodeBehind="MultiShibLogin.ascx.cs"
    Inherits="Profiles.Login.Modules.MultiShibLogin.MultiShibLogin" %>
<%--
    Copyright (c) 2008-2012 by the President and Fellows of Harvard College. All rights reserved.  
    Profiles Research Networking Software was developed under the supervision of Griffin M Weber, MD, PhD.,
    and Harvard Catalyst: The Harvard Clinical and Translational Science Center, with support from the 
    National Center for Research Resources and Harvard University.


    Code licensed under a BSD License. 
    For details, see: LICENSE.txt 
 --%>
<div class="content_container">
    <div class="tabContainer" style="margin-top: 0px;">
        <div class="searchForm">
        </div>
    </div>
</div>
<div class="content_container">
    <div class="tabContainer" style="margin-top: 0px;">
        <div class="searchForm">
            <table width="100%">
                <tr>
                    <td colspan="3">
                        <div class="searchSection" style="text-align: center; margin: 0px auto;">
                            <table class="searchForm" style="display: inline;">
                                <tr>
                                    <asp:ImageButton ImageUrl="~/login/images/berkeley.edu.png" runat="server" ID="LoginUCB"
                                            EntityID="urn:mace:incommon:berkeley.edu" Text="Login" OnClick="cmdSubmit_Click" alternatetext="Login"/>
                                </tr>
                                <tr>
                                    <asp:ImageButton ImageUrl="~/login/images/ucdavis.edu.png" runat="server" ID="LoginUCD"
                                            EntityID="urn:mace:incommon:ucdavis.edu" Text="Login" OnClick="cmdSubmit_Click" alternatetext="Login"/>
                                </tr>
                                <tr>
                                    <asp:ImageButton ImageUrl="~/login/images/uci.edu.gif" runat="server" ID="LoginUCI"
                                            EntityID="urn:mace:incommon:uci.edu" Text="Login" OnClick="cmdSubmit_Click" alternatetext="Login"/>
                                </tr>
                                <tr>
                                    <asp:ImageButton ImageUrl="~/login/images/ucla.edu.gif" runat="server" ID="LoginUCLA"
                                            EntityID="urn:mace:incommon:ucla.edu" Text="Login" OnClick="cmdSubmit_Click" alternatetext="Login"/>
                                </tr>
                                <tr>
                                    <asp:ImageButton ImageUrl="~/login/images/ucsd.edu.png" runat="server" ID="LoginUCSD"
                                            EntityID="urn:mace:incommon:ucsd.edu" Text="Login" OnClick="cmdSubmit_Click" alternatetext="Login"/>
                                </tr>
                                <tr>
                                    <asp:ImageButton ImageUrl="~/login/images/ucsf.edu.png" runat="server" ID="LoginUCSF"
                                            EntityID="urn:mace:incommon:ucsf.edu" Text="Login" OnClick="cmdSubmit_Click" alternatetext="Login"/>
                                </tr>
                            </table>
                        </div>
                    </td>
                </tr>
            </table>
        </div>
    </div>
</div>
