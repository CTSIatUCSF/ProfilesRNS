/****** Object:  View [Profile.Data].[vwGroup.Member]    Script Date: 1/8/2024 1:35:56 PM ******/
-- Be sure to add permissions to Profiles and Bot users in DB!!!!
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [UCSF.].[vwGroup.MemberWithPhoto] AS 
	SELECT m.MemberRoleID, m.GroupID, m.UserID, u.PersonID, m.IsActive, m.IsApproved, m.IsVisible, m.Title, m.IsFeatured, m.SortOrder, g.ViewSecurityGroup, -40 EditSecurityGroup, t.ViewSecurityGroup PhotoViewSecurityGroup, u.PrettyURL
	FROM [Profile.Data].[Group.Member] m
		INNER JOIN [Profile.Data].[Group.General] g
			ON g.GroupID = m.GroupID
		INNER JOIN [UCSF.].vwPerson u
			ON m.UserID = u.UserID
		INNER JOIN [Profile.Data].[Person.Photo] p
			ON u.PersonID = p.PersonID
		INNER JOIN [Ontology.].ClassProperty o
			ON o.Property = 'http://profiles.catalyst.harvard.edu/ontology/prns#mainImage' and o.Class = 'http://xmlns.com/foaf/0.1/Person'
		INNER JOIN [RDF.].Triple t 
			ON t.Subject = u.nodeid AND t.Predicate = o._PropertyNode
	WHERE (m.IsActive=1) AND (m.IsApproved=1) AND (m.IsVisible=1) AND (u.PersonID IS NOT NULL) and (g.ViewSecurityGroup <> 0) and (t.ViewSecurityGroup=-1 OR t.ViewSecurityGroup=-10)
GO

--[UCSF.].[Group.Member.GetMembersWithPhoto]
/****** Object:  StoredProcedure [Profile.Data].[Group.Member.GetMembers]    Script Date: 1/8/2024 1:44:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [UCSF.].[Group.Member.GetMembersWithPhoto]
	@GroupName VARCHAR(400)=NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @GroupID INT
	SELECT @GroupID = GroupID 
		FROM [Profile.Data].[Group.General] WHERE GroupName = @GroupName

	-- Validate GroupID
	IF (@GroupID IS NULL)
		RETURN;

	-- List the Members
	SELECT m.GroupID, u.UserID, u.PersonID, i.NodeID, m.IsApproved, m.IsVisible, m.Title,
			p.FirstName, p.LastName, p.DisplayName, p.InstitutionName, p.DepartmentName, p.DivisionFullName, p.FacultyRank, p.FacultyRankSort
		FROM [UCSF.].[vwGroup.MemberWithPhoto] m
			INNER JOIN [User.Account].[User] u
				ON m.UserID = u.UserID
			INNER JOIN [Profile.Cache].[Person] p
				ON u.PersonID = p.PersonID
			INNER JOIN [RDF.Stage].InternalNodeMap i
				ON i.Class = 'http://xmlns.com/foaf/0.1/Person' AND i.InternalType = 'Person' AND i.InternalID = u.PersonID
		WHERE m.GroupID = @GroupID AND m.IsActive = 1 AND m.IsApproved = 1 AND m.IsVisible = 1
		ORDER BY p.LastName, p.FirstName, p.DisplayName, p.UserID

END
GO

--exec [UCSF.].[Group.Member.GetMembersWithPhoto] @GroupName='OB-GYN Test'
GRANT EXECUTE ON [UCSF.].[Group.Member.GetMembersWithPhoto] TO 'App_Profiles10';
-- also do for BOT user