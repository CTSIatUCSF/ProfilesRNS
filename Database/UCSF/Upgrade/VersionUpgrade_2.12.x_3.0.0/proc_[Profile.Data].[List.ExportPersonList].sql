USE [profilesRNS]
GO
/****** Object:  StoredProcedure [Profile.Data].[List.ExportPersonList]    Script Date: 6/22/2021 3:50:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Profile.Data].[List.ExportPersonList] 
	@UserID INT
AS
BEGIN

	DECLARE @IsAdmin INT
	SELECT @IsAdmin=1
		FROM [Profile.Data].[List.Admin] a
		WHERE @UserID IS NOT NULL
			AND a.UserID=@UserID

	SELECT Data 
	FROM (
		SELECT -1 PersonID, 
				'"PersonID","First Name","Last Name","Display Name"'
				+',"Address "'
				+',"Phone","Fax","Institution","Department","Division","Researcher Type"'
				+',"Publications","CoAuthors"'
				+',"Email"' 
				+',"Profiles URL"'
				Data
		UNION ALL
		SELECT m.PersonID, 
				CAST(m.PersonID AS VARCHAR(50)) 
				+ ',"' + REPLACE(FirstName,'"','""') + '"'
				+ ',"' + REPLACE(LastName,'"','""') + '"'
				+ ',"' + REPLACE(DisplayName,'"','""') + '"'
				+ ',' + (CASE WHEN ShowAddress = 'Y' THEN 
								'"' + REPLACE(ISNULL(AddressLine1,''),'"','""') + '"'
								/*
								+ ',"' + REPLACE(ISNULL(AddressLine2,''),'"','""') + '"'
								+ ',"' + REPLACE(ISNULL(AddressLine3,''),'"','""') + '"'
								+ ',"' + REPLACE(ISNULL(AddressLine4,''),'"','""') + '"'
								+ ',"' + REPLACE(ISNULL(AddressString,''),'"','""') + '"'
								+ ',' + ISNULL(CAST(Latitude AS VARCHAR(50)), '')
								+ ',' + ISNULL(CAST(Longitude AS VARCHAR(50)), '')
							*/ 
							ELSE ',,,,,,' END)
				+ ',' + (CASE WHEN ShowPhone = 'Y' THEN '"'+REPLACE(REPLACE(Phone,',','-'),'"','""')+'"' ELSE '' END)
				+ ',' + (CASE WHEN ShowFax = 'Y' THEN '"'+REPLACE(REPLACE(Fax,',','-'),'"','""')+'"' ELSE '' END)
				+ ',"' + REPLACE(ISNULL(InstitutionName,''),'"','""') + '"'
				+ ',"' + REPLACE(ISNULL(DepartmentName,''),'"','""') + '"'
				+ ',"' + REPLACE(ISNULL(DivisionFullName,''),'"','""') + '"'
				+ ',"' + REPLACE(ISNULL(FacultyRank,''),'"','""') + '"'
				+ ',' + (CASE WHEN ShowPublications='Y' THEN 
								CAST(ISNULL(NumPublications,0) AS VARCHAR(50)) 
								+ ',' + CAST(ISNULL(Reach1,0) AS VARCHAR(50))
							ELSE ',' END)
				--+ (CASE WHEN @IsAdmin=1 THEN ',' + (CASE WHEN ShowEmail='Y' AND x.UserID IS NOT NULL THEN '"'
				+ ',"' +REPLACE(ISNULL(EmailAddr,''),'"','""') + '"'
				-- ELSE '""' END) ELSE '' END)
				+ ',"' + na.PrettyURL
				--'https://connects.catalyst.harvard.edu/Profiles/Profile/Person/' + CAST(m.PersonID AS VARCHAR(50)) 
				+ '"'
			FROM [Profile.Data].[List.Member] m 
				INNER JOIN [Profile.Cache].[Person] p 
					ON m.PersonID = p.PersonID AND m.UserID = @UserID
				--UCSF table used for URL
				join [UCSF.].[NameAdditions] na on na.InternalUserName=p.InternalUsername
				OUTER APPLY (
					SELECT MAX(UserID) UserID
					FROM [Profile.Data].[List.Admin] a
					WHERE @UserID IS NOT NULL
						AND a.UserID=@UserID
						AND (CASE WHEN a.AdminForInstitution IS NULL THEN 1 WHEN a.AdminForInstitution=p.InstitutionName THEN 1 ELSE 0 END)=1
						AND (CASE WHEN a.AdminForDepartment IS NULL THEN 1 WHEN a.AdminForDepartment=p.DepartmentName THEN 1 ELSE 0 END)=1
						AND (CASE WHEN a.AdminForDivision IS NULL THEN 1 WHEN a.AdminForDivision=p.DivisionFullName THEN 1 ELSE 0 END)=1
				) x
	) t
	ORDER BY PersonID

END
