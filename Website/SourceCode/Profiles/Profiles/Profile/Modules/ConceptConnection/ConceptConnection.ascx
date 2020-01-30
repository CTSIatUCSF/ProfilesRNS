<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ConceptConnection.ascx.cs" Inherits="Profiles.Profile.Modules.ConceptConnection.ConceptConnection" %>
<div class="connectionTable">
    <div class="connectionTableRow">
        <div class="connectionContainerItem">
            <a href="<%= this.Subject.Uri%>"><%= this.Subject.Name %></a>
        </div>
        <div class="connectionContainerLeftArrow">
            <img style="vertical-align: unset;" src="<%=GetRootDomain()%>/Framework/Images/connection_left.gif" alt="" />
        </div>
        <div>
            <div class="connectionSubDescription">Connection Strength</div>
            <div class="connectionLineToArrow">
			<td class="connectionContainerArrow" style="width:150px;">
				<table class="connectionArrowTable" >
            <div class="connectionSubDescription" style="position: relative;"><%= String.Format("{0:0.000}", this.ConnectionStrength) %></div>
        <div class="connectionContainerRightArrow">
        </div>
        <div class="connectionContainerItem">
					<td style="height:6px"><img src="<%= Profiles.Framework.Utilities.Brand.GetDomain() %>/Framework/Images/connection.gif"></td>
<!--
					<td class="connectionLine"><img src="<%= Profiles.Framework.Utilities.Brand.GetDomain() %>/Framework/Images/connection_left.gif"></td>
					<td class="connectionLine"><img src="<%= Profiles.Framework.Utilities.Brand.GetDomain() %>/Framework/Images/connection_right.gif" alt=""></td>
-->
    </div>
</div>
<div class="publications">
    <ol>
        <%  int first = 0;
            this.ConnectionDetails.ForEach(pub =>
            {
            first++;
        %>
        <li <%= (first==1) ? "class='first'" : "" %>>
            <%= pub.Description %>
            <div class='viewIn'>
                <span class="viewInLabel">View in</span>: <a href="//www.ncbi.nlm.nih.gov/pubmed/<%= pub.PMID %>" target="_blank">PubMed</a>
            </div>
            <div class='viewIn'>
                <span class="viewInLabel">Score</span>: <%= String.Format("{0:0.000}", pub.Score)%>
            </div>
        </li>
        <%  });
        %>
    </ol>
</div>
