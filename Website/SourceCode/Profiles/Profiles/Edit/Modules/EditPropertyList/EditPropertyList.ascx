<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="EditPropertyList.ascx.cs"
    Inherits="Profiles.Edit.Modules.EditPropertyList.EditPropertyList" %>
<asp:Literal runat="server" ID="litBackLink"></asp:Literal>
<br />
<!--
<br />
Below are the types of content that can be included on this profile. Locked items
<asp:Image runat="server" ID="imgLock" />
can be viewed but not edited. Information in the Address section of your profile,
including your titles, affiliations, telephone, fax, and email are managed by your
Human Resources office; however, you may upload a custom photo to your profile using
this website.
<br />
<br />
-->
<h3>&nbsp;Components:
<span id="editHR" style="display:inline-block;padding-left:50px">
  <asp:Literal runat="server" ID="litEditHRDataLink"></asp:Literal>
</span></h3>
<div id="profile-components">
  <table style="width:100%;margin-bottom:0;">
    <tr style="border-bottom:1px solid #CCC;">
       <td class="padding" id="Xnamedegree" style="width:226px">Name and Degrees</td>
       <td style="width:50px">
<!--         <img src="Images/icons_lock.gif" />   -->
       </td>
       <td style="width:100px">
         <span id="public">Always Public</span>
       </td>
    </tr>
  </table>
<div id="editable-components">
<asp:Repeater runat="server" ID="repPropertyGroups" OnItemDataBound="repPropertyGroups_OnItemDataBound">
    <ItemTemplate>
        <asp:GridView runat="server" ID="grdSecurityGroups" AutoGenerateColumns="false" OnRowDataBound="grdSecurityGroups_OnDataBound"
            Width="100%">
            <HeaderStyle BorderStyle="None" CssClass="EditMenuTopRow" />
            <RowStyle VerticalAlign="Middle" />
            <AlternatingRowStyle CssClass="evenRow" />
            <Columns>
                <asp:BoundField HeaderStyle-CssClass="padding" ItemStyle-CssClass="padding" HeaderStyle-HorizontalAlign="Left"
                    ItemStyle-HorizontalAlign="Left" DataField="item" HeaderText="Item" ItemStyle-Width="150px" />
                <asp:TemplateField HeaderStyle-HorizontalAlign="Center"
                    HeaderText="Items" ItemStyle-Width="50px">
                    <ItemTemplate>
                        <asp:Image runat="server" ID="imgBlank" Visible="false" ImageUrl="~/Edit/Images/icons_blank.gif" />
                        <asp:Label runat="server" ID="lblItems"></asp:Label>
                        <asp:Image runat="server" ID="imgLock" Visible="false" ImageUrl="~/Edit/Images/icons_blank.gif" />
                        <asp:Image runat="server" ID="imgOrng" Visible="false" ImageUrl="~/ORNG/Images/orng-asterisk.png" />
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderStyle-HorizontalAlign="Center" 
                    HeaderText="Privacy" ItemStyle-Width="100px">
                    <ItemTemplate>
                        <asp:HiddenField ID="hfPropertyURI" runat="server" />
                        <asp:DropDownList AutoPostBack="true" Visible="false" OnSelectedIndexChanged="updateSecurity" runat="server"
                            ID="ddlPrivacySettings">
                        </asp:DropDownList>
                        <asp:Literal runat="server" ID="litSetting"></asp:Literal>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
        <br />
    </ItemTemplate>
</asp:Repeater>
</div>
</div>
<table id="profile-visibility">
    <tr>
        <td colspan='3'>
            <div class='editPage'>
              <table width="100%">
                <tr>
                    <td>
                        <h2>Visibility Settings</h2>
                    </td>
                    <td align="right">
                        <%-- <b>Set All</b>&nbsp;
                            <asp:DropDownList runat="server" ID="ddlSetAll" AutoPostBack="true" OnSelectedIndexChanged="ddlSetAll_IndexChanged">
                            </asp:DropDownList>--%>
                    </td>
                </tr>
              </table>
              <div>
                <asp:Literal runat="server" ID="litSecurityKey"></asp:Literal>
              </div>
        </td>
    </tr>
</table>
<p class="orng"><img style="border-width:0px;" src="../ORNG/Images/orng-asterisk.png" /> Components developed by the UCSF <a href="http://www.orng.info/index.html" target="_blank">Open Research Networking Gadgets (ORNG)</a> initiative. 
Have an idea for a new component you would like to see in Profiles, or are you a software developer who knows HTML and Javascript that would like to build 
one yourself? Contact <a href="mailto:profiles@ucsf.edu">profiles@ucsf.edu</a> to let us know!</p>
<!-- for testing -->
<asp:Literal runat="server" ID="litGadget" Visible="false"/>

