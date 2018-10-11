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
 <div class="login_container">
	<row>
		<div>
			<asp:ImageButton ImageUrl="~/login/images/ucdavis.edu.png" runat="server" ID="LoginUCD"
                InstitutionAbbreviation="UC Davis" Text="Login" OnClick="cmdSubmit_Click" alternatetext="Login to UC Davis"/>
		</div>
		<div>
			<asp:ImageButton ImageUrl="~/login/images/uci.edu.gif" runat="server" ID="LoginUCI"
					InstitutionAbbreviation="UCI" Text="Login" OnClick="cmdSubmit_Click" alternatetext="Login to UCI"/>
		</div>
		<div class="plus-size">
			<asp:ImageButton ImageUrl="~/login/images/ucsd.edu.png" runat="server" ID="LoginUCSD"
					InstitutionAbbreviation="UCSD" Text="Login" OnClick="cmdSubmit_Click" alternatetext="Login to UCSD"/>
		</div>
		<div>
			<asp:ImageButton ImageUrl="~/login/images/ucsf.edu.png" runat="server" ID="LoginUCSF"
					InstitutionAbbreviation="UCSF" Text="Login" OnClick="cmdSubmit_Click" alternatetext="Login to UCSF"/>
		</div>
	</row>
	<row>		
		<div class="plus-size">
			<asp:ImageButton ImageUrl="~/login/images/usc.edu.png" runat="server" ID="LoginUSC"
					InstitutionAbbreviation="USC" Text="Login" OnClick="cmdSubmit_Click" alternatetext="Login to USC"/>
		</div>
	</row>
<!--
	<row>
		<div>
			<asp:ImageButton ImageUrl="~/login/images/lbnl.gov.png" runat="server" ID="LoginLBNL"
					InstitutionAbbreviation="LBNL" Text="Login" OnClick="cmdSubmit_Click" alternatetext="Login to LBNL"/>
		</div>
		<div>
			<asp:ImageButton ImageUrl="~/login/images/ucla.edu.gif" runat="server" ID="LoginUCLA"
                InstitutionAbbreviation="UCLA" Text="Login" OnClick="cmdSubmit_Click" alternatetext="Login to UCLA"/>
		</div>
	</row>
-->	
</div>

