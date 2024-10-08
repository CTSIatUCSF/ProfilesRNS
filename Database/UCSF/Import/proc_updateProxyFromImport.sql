USE [profilesRNS]
GO
/****** Object:  StoredProcedure [UCSF.].[UpdateProxyFromImport]    Script Date: 12/4/2019 10:47:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [UCSF.].[UpdateProxyFromImport]
AS
BEGIN
	insert into [User.Account].[DefaultProxy]
	select * from
	(
		select u.userid,gpx.Institution,
		case when LOWER(gpx.Department)='all' then NULL
			 else gpx.Department
		end Department,
		NULL as Division,0 as Visible from
		(	
			SELECT [proxyid],[Institution],[Department],[remove]
			FROM [UCSF.].[UpdateGlobalProxies]
			where remove=0 or remove is NULL
		) gpx
		join [profilesRNS].[User.Account].[User] u on u.internalusername=gpx.proxyid
	) newgpy
	where not exists
		(select * from [profilesRNS].[User.Account].[DefaultProxy] gpy
		where gpy.userid=newgpy.userid and (
			gpy.ProxyFordepartment=newgpy.Department or 
			newgpy.Department is NULL and gpy.ProxyForDepartment is NULL
			)
	)

	
END
