<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="EditPropertyList.ascx.cs"
    Inherits="Profiles.Edit.Modules.EditPropertyList.EditPropertyList" %>
<asp:Literal runat="server" ID="litBackLink"></asp:Literal>
<!--
<br />
<br />
Below are the types of content that can be included on this profile. Locked items
<asp:Image runat="server" ID="imgLock" alt=""/>
can be viewed but not edited. Information in the Address section of your profile,
including your titles, affiliations, telephone, fax, and email are managed by your
Human Resources office; however, you may upload a custom photo to your profile using
this website.
<br />
<br />
-->
<h3>
	<span id="editHR" style="display:block; padding-bottom: 20px">
		<asp:Hyperlink runat="server" ID="hypEditHRDataLink" Text="Request a change to your name, address, or email" Target="_blank" Visible="false"/>
	</span>
Components:</h3>
<div id="profile-components">
  <asp:Panel runat="server" ID="pnlShowNameAndDegrees">
      <table style="width:100%;margin-bottom:0;">
        <tr id="namedegreerow">
           <td class="padding" id="namedegree">Name and Degrees</td>
           <td colspan="2">
             <span id="public"><img src="Images/icons_lock.gif" />&nbsp;Always Public</span>
             <span id="cls">This info is drawn from an automatic data feed. <a href="../About/Help.aspx" target="_blank">Learn more</a></span>
           </td>
        </tr>
      </table>
  </asp:Panel>
<asp:Repeater runat="server" ID="repPropertyGroups" OnItemDataBound="repPropertyGroups_OnItemDataBound">
    <ItemTemplate>
        <asp:GridView runat="server" ID="grdSecurityGroups" AutoGenerateColumns="false" OnRowDataBound="grdSecurityGroups_OnDataBound"
            Width="100%">
            <HeaderStyle BorderStyle="None" CssClass="EditMenuTopRow" />
            <RowStyle VerticalAlign="Middle" />
            <AlternatingRowStyle CssClass="evenRow" />
            <Columns>
                <asp:BoundField HeaderStyle-CssClass="padding" ItemStyle-CssClass="padding" HeaderStyle-HorizontalAlign="Left"
                    ItemStyle-HorizontalAlign="Left" DataField="EditLink" HeaderText="Item" HtmlEncode="false" ItemStyle-Width="150px"/>
                <asp:TemplateField HeaderStyle-HorizontalAlign="Center"
                    HeaderText="Items" ItemStyle-Width="50px">
                    <ItemTemplate>
                        <asp:Image runat="server" ID="imgBlank" Visible="false" ImageUrl="~/Edit/Images/icons_blank.gif" AlternateText=" " />
                        <asp:Label runat="server" ID="lblItems"></asp:Label>
                        <asp:Image runat="server" ID="imgLock" Visible="false" ImageUrl="~/Edit/Images/icons_lock.gif" AlternateText="locked" />
                        <asp:Image runat="server" ID="imgAdvance" Visible="false" ImageUrl="~/Edit/Images/advance.ico" AlternateText="Advance section"/>
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
<table id="profile-visibility">
    <tr>
        <td colspan='3'>
            <div class='editPage'>
              <table width="100%">
                <tr>
                    <td>
                        <h2>Visibility Setting Definitions</h2>
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
            </div>
        </td>
    </tr>
</table>
<div class="researcherprofiles--edit-page--explanation-of-icons">
    <asp:Panel runat="server" ID="pnlAdvanceMessage" SkinID="UCSF" Visible="false">
        <p><b>Do you have an Advance CV?</b></p>
        <p>You can now import key parts of your Advance CV directly into your UCSF Profiles page. <i>Note:</i> You must be on the UCSF network or VPN.</p>
        <ul>
            <li><asp:Hyperlink runat="server" ID="hypAdvanceEditLink" Text="Set data sharing preferences" ekVisible="true"/> in Advance before importing. Be sure to choose "Select all Sections" and "Open Transfer" as your options.</li>
            <li>Click any section with the <img style="border-width:0px;" src="Images/advance.ico" /> icon to import that information.</li>
        </ul>
        <p>For more guidance, see <a target="_blank" href="https://ucsfonline.sharepoint.com/:w:/s/CTSIResearchTechnologyprogram/ER8jYF3yGkFHnhbFZn0lGRABbvoM9kqfagrZGJ7j9_qmOg?e=PQNkwg">the detailed instructions</a>.</p>
    </asp:Panel>
</div>
<!-- for testing -->
<asp:Literal runat="server" ID="litGadget" Visible="false"/>

