USE [import_ucsf]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_check_badsymbols]    Script Date: 4/24/2018 10:32:09 AM ******/
-- =============================================
-- Author:		Moisey Gruzman
-- CREATE date: 4/24/2018
-- Description:	Function and procedures for import job
-- =============================================
IF object_id('fn_check_badsymbols') IS not NULL
drop function fn_check_badsymbols
go

CREATE FUNCTION [dbo].[fn_check_badsymbols]
(
	-- Add the parameters for the function here,
	@value varchar(max)
)
RETURNS int
AS
BEGIN
	declare @res int=0
	if (select charindex(CHAR(0),@value)) > 0 
	begin
		set @res=-1
	end
	RETURN @res

END
go
--+++++++++++++++++++++++++++++++++++++++++++++++
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
IF object_id('fn_cleanProcedure') IS not NULL
drop function fn_cleanProcedure
go
CREATE FUNCTION [dbo].[fn_cleanProcedure] 
(
	-- Add the parameters for the function here
	@objName varchar(200)
)
RETURNS int
AS
BEGIN
declare @sql nvarchar(max)=''
IF object_id(@objName) IS not NULL
BEGIN
    IF object_id(@objName+'B') IS NULL
		set @sql='sp_rename '+@objName+','+@objName+'B'+';';
	else
		set @sql='drop procedure '+@objName+';';
END
if len(@sql) >0 execute  sp_executesql @sql;;
RETURN 0

END
GO
--++++++++++++++++++++++++++++++++++++++++++++++++
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Moisey Gruzmanle
-- CREATE date: 5/13/2018
-- Adjusts varchar fieds size to be copied correctly into related ProfilesRNS
-- =============================================
exec fn_cleanProcedure 'usp_AdjustFields'
go
CREATE PROCEDURE usp_AdjustFields 
	-- Add the parameters for the stored procedure here
	@BaseName varchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @relatedRNSTable varchar(20)
	declare @column_name varchar(200)
	declare @maxsize int=0 
	declare @column_value varchar(200)
	declare @column_datatype varchar(50)
	declare @column_charmax int 
	declare @column_precision int
	declare @column_scale int
	declare @conversion varchar(30)
	declare @sql nvarchar(max)
	declare @mainsql nvarchar(max)
	declare @lastsym varchar(1)
	declare @tableName varchar(200)='temp_'+@BaseName
	DECLARE @ErrMsg nvarchar(4000)=''
	Declare @ErrCode int=0
	set @mainsql=' '
	if @BaseName = 'person' set @relatedRNSTable='Person'
	if @BaseName = 'person_affiliation' set @relatedRNSTable='PersonAffiliation'
	if @BaseName = 'user' set @relatedRNSTable='User'
	DECLARE process_cursor CURSOR FOR
	select column_name,data_type,IsNull(character_maximum_length,0),isNULL(numeric_precision,0),
		isNULL(numeric_scale,0)
	from information_schema.columns 
	where table_name= @tableName --and table_schema = @tableSchema
		and data_type like '%varchar' 
	DECLARE @updatenum int =0
	OPEN process_cursor;
		FETCH NEXT FROM process_cursor INTO @column_name,@column_datatype,@column_charmax,
			@column_precision,@column_scale
		WHILE (@@FETCH_STATUS <> -1 )
		BEGIN
			print 'processing column='+@column_name
			select @maxsize=IsNull(character_maximum_length,0)
			from profiles_ucsf.information_schema.columns
			where table_name = @relatedRNSTable AND table_schema = 'Profile.Data'
				and column_name=@column_name
			if @column_charmax>@maxsize and @maxsize>0
			BEGIN
				print @column_name+'='+cast(@column_charmax as varchar)+'>'+cast(@maxsize as varchar)
				if @updatenum=0
				begin
					set @updatenum=1 
					set @mainsql=@mainsql+'set '+@column_name+'=substring('+@column_name+',1,'+cast(@maxsize as varchar)+'),'
				end
				else set @mainsql=@mainsql+' '+@column_name+'=substring('+@column_name+',1,'+cast(@maxsize as varchar)+'),'
				
			END
			FETCH NEXT FROM process_cursor INTO @column_name,@column_datatype,@column_charmax,@column_precision,@column_scale
		END
	CLOSE process_cursor;
	DEALLOCATE process_cursor;
	if len(@mainsql)>0
	begin
		set @mainsql=substring(@mainsql,1,len(@mainsql)-1)
		set @mainsql='update '+@tablename+' '+CHAR(13)+CHAR(10)+@mainsql
		print @mainsql;
		execute  sp_executesql @mainsql;
	end
END
GO



/****** Object:  StoredProcedure [dbo].[usp_cleanImport]    Script Date: 4/24/2018 10:27:56 AM ******/
exec fn_cleanProcedure 'usp_cleanImport';
go
-- =============================================
-- Author:		Moisey Gruzman
-- CREATE date: 4/24/2018
-- Description:	Function and procedures for import job
-- =============================================
CREATE PROCEDURE [dbo].[usp_cleanImport] 
AS
BEGIN
	DECLARE @sql nvarchar(max)
	declare @counter int = -1
	declare @ImportName varchar (255)=''
	declare @BaseName varchar(255)
	DECLARE @NameSuffix varchar(255)
	Declare @days_back INT=10
	declare @dropsql nvarchar(max)=''
	SELECT @NameSuffix =convert(varchar, dateadd(day, -@days_back, getdate()), 112); 
	DECLARE import_cursor CURSOR FOR
	SELECT [name] FROM sys.tables
		where [name] like '%_IMPORT'  
	OPEN import_cursor;
	FETCH NEXT FROM import_cursor INTO @ImportName;
	WHILE (@@FETCH_STATUS <> -1 )
		BEGIN
			SELECT @sql='Truncate TABLE ' + @ImportName
			PRINT @sql 
			EXEC (@sql)
			set @BaseName=replace(@ImportName,'_import','')
			SELECT @counter=count([name]) FROM sys.tables
			where [name] like @BaseName+'_%'
				and isnumeric(substring(replace (name,@BaseName+'_',''),1,1))=1
			while ( @counter>6)
			begin
				SELECT TOP 1 @dropsql='drop table '+[name]+';' 
				FROM sys.tables
				where [name] like @BaseName+'_%'
					and isnumeric(substring(replace (name,@BaseName+'_',''),1,1))=1
				order by [name]
				print @dropsql
				exec (@dropsql)
				set @counter=@counter-1
			END
			FETCH NEXT FROM import_cursor INTO @ImportName
		END

	CLOSE import_cursor;
	DEALLOCATE import_cursor;
END
GO

/****** Object:  StoredProcedure [dbo].[usp_manualUpdate]    Script Date: 5/13/2018 6:40:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Moisey Gruzman
-- CREATE date: 4/24/2018
-- Description:	Function and procedures for import job
-- =============================================
exec fn_cleanProcedure 'usp_manualUpdate';
go
CREATE PROCEDURE [dbo].[usp_manualUpdate]
as
BEGIN
	declare @sql nvarchar(max)
	declare @ID varchar(9)
	declare @num int
	declare @name varchar(200)
	declare @ErrMsg varchar (max)=''

	if exists (SELECT *
		FROM sys.Tables where [name] ='temp_person')
	BEGIN
		drop table [temp_person]
	END
	if exists (SELECT *
		FROM sys.Tables where [name] ='temp_person_affiliation')
	BEGIN
		drop table [temp_person_affiliation]
	END
	if exists (SELECT *
		FROM sys.Tables where [name] ='temp_user')
	BEGIN
		drop table [temp_user]
	END
	if exists (SELECT *
		FROM sys.Tables where [name] ='temp_nameforlogin')
	BEGIN
		drop table [temp_nameforlogin]
	END
	if exists (SELECT * FROM sys.Tables where [name] ='temp_proxies') drop table temp_proxies

	IF OBJECT_ID('tempdb..#temp_person') IS NOT NULL     DROP TABLE #temp_person
	IF OBJECT_ID('tempdb..#temp_person_affiliation') IS NOT NULL     DROP TABLE #temp_person_affiliation
	IF OBJECT_ID('tempdb..#temp_user') IS NOT NULL     DROP TABLE #temp_user
	print 'starting temp_person'
	select distinct p.* into #temp_person
		from vw_person p
		where p.internalusername is not NULL
	select pa.* into #temp_person_affiliation 
		from vw_person_affiliations pa 
		where pa.internalusername is not NULL
	select u.* into #temp_user
		from vw_users u
		where u.internalusername is not NULL
	select distinct p.* into temp_person
		from #temp_person p
		join #temp_person_affiliation pa on p.internalusername=pa.internalusername;
--select * from temp_person
	if @@ROWCOUNT=0 set @ErrMsg='internalusernames in person table does not have any affiliations'
	print 'copy temp_person_affiliation'
	select pa.* into temp_person_affiliation 
		from #temp_person_affiliation pa
		join #temp_person p on p.internalusername=pa.internalusername  
	update [temp_person_affiliation] set divisionname=institutionname
	IF OBJECT_ID('tempdb..#temp') IS NOT NULL     DROP TABLE #temp
	IF OBJECT_ID('tempdb..#temp_user') IS NOT NULL
		BEGIN
			select u.* into #temp
			from #temp_user u
			left outer join temp_person p on u.internalusername=p.internalusername
			where p.internalusername is NULL;
		END
	if exists (SELECT * FROM sys.Tables where [name] ='manual_users')
	BEGIN
		insert into #temp
		select distinct mu.internalusername
			,mu.firstname
			,mu.lastname
			,mu.firstname+' ' +mu.lastname as displayname
			,ISNULL(mu.institution,'') as institution
			,ISNULL(mu.department,'') as department
			,ISNULL(mu.emailaddr,'') as emailaddr
			,mu.canbeproxy as canbeproxy
		from manual_users mu
		left outer join #temp u on mu.internalusername=u.internalusername
			where u.internalusername is NULL;
	END
	if exists (SELECT * FROM sys.Tables where [name] ='_personlogin_import')
	BEGIN
	print 'processing personlogin_import'
		select * into temp_nameforlogin
		from _personlogin_import
	END
	if exists (SELECT * FROM sys.Tables where [name] ='_userlogin_import')
	BEGIN
		print 'processing userlogin_import'
		insert into temp_nameforlogin
		select * from  _userlogin_import
		where internalusername not in 
		(select internalusername from temp_nameforlogin)
	END
	if exists (SELECT * FROM sys.Tables where [name] ='_userproxy_import')
		BEGIN
		print 'starting userproxy'
			insert into #temp
			select distinct px.proxyid
				,lpx.firstName,lpx.lastName
				,lpx.firstname+' '+lpx.lastname as displayname
				,'' as institution,'' as department,'' as emailaddr
				,lpx.canbeproxy
			from [_userproxy_import] lpx
			join [_userproxy_import] px on lpx.proxyid=px.proxyid
			left outer join #temp u on px.proxyid=u.internalusername
			where u.internalusername is NULL;
			SELECT 	[internalusername] as proxyid
				,cast(NULL as varchar(50)) as Institution
				,cast(NULL as varchar(50)) as Department
				,[proxyid] as userid
				,[Canbeproxy]
			into temp_proxies
			FROM [_userproxy_import];
		print 'ending userproxy'
		END
	if exists (SELECT * FROM sys.Tables where [name] ='_globaluserproxy_import')
		BEGIN
		print 'starting globaluserproxy'
			insert into #temp
			select ugpx.internalusername,ugpx.firstname,ugpx.lastname,ugpx.displayname,
				ugpx.institution,ugpx.department,ugpx.emailaddr,ugpx.canbeproxy
				from
				(select gpx.internalusername
					,gpx.firstName,gpx.lastName,
					gpx.firstname+' '+gpx.lastname as displayname,
					ISNULL(gpx.institution,'') as institution
					,ISNULL(gpx.department,'') as department,
					'' as emailaddr,
					gpx.canbeproxy,
					 ROW_NUMBER() OVER (PARTITION BY internalusername 
                                ORDER BY department) as rn
				from _globaluserproxy_import gpx) ugpx

			left outer join #temp u on ugpx.internalusername=u.internalusername
			where u.internalusername is NULL
			 and rn = 1;
			if not exists (SELECT * FROM sys.Tables where [name] ='temp_proxies')
			begin
				print 'no temp_proxies'
				SELECT  internalusername as proxyid,[Institution]
					,[Department], cast(NULL as varchar(10)) as userid
					,[Canbeproxy]
					into temp_proxies
				FROM [_globaluserproxy_import];
			end
			else
			begin
				print 'found temp_proxies'
				Insert into temp_proxies
				select internalusername as proxyid,[Institution]
					,[Department], cast(NULL as varchar(10)) as userid
					,[Canbeproxy]
				FROM [_globaluserproxy_import]; 
			end
		print 'ending globaluserproxy'
		END
	IF OBJECT_ID('tempdb..#temp') IS NOT NULL  
		BEGIN
			select distinct #temp.* into temp_user
			from #temp
			left outer join temp_person p on #temp.internalusername=p.internalusername
			where p.internalusername is NULL
			drop table #temp
		END
	if exists (SELECT *
		FROM sys.Tables where [name] ='afterImportCLS')
	BEGIN	
		declare manAdj cursor for (
				select fix.* from afterImportCLS fix
				join temp_person p on fix.individualID=p.internalusername
		)
		OPEN manAdj ;
			FETCH NEXT FROM manAdj  INTO @ID, @num, @sql;
			WHILE (@@FETCH_STATUS <> -1)
			BEGIN
				select @name=GIVEN_NAME_SURNAME from vw_UCSFPRO1 where INDIVIDUAL_ID=@ID
				print '******Updating ID='+@ID+'  '+@name+' **********'
				set @sql=replace(@sql,'final_','temp_')
				print 'Query='+@sql
				BEGIN TRY
					--print @sql
					exec sp_executesql @sql
				END TRY
				BEGIN CATCH
					print '***  ERROR ***'+error_message()
					set @ErrMsg=error_message()
				END CATCH
				FETCH NEXT FROM manAdj  INTO @ID, @num, @sql;
				--print @@FETCH_STATUS
				print '+++current error+++'+@ErrMsg
			END;
		CLOSE manAdj ;
		DEALLOCATE manAdj ;
	END
	exec usp_AdjustFields 'person'
	exec usp_AdjustFields 'person_affiliation'
	exec usp_AdjustFields 'user'
	if len(@ErrMsg)>0
		BEGIN
			RAISERROR(@ErrMsg, 16, 1);
		END
	if not exists (SELECT *	FROM sys.Tables where [name] ='final_person')
	Select * Into final_person From temp_person Where 1 = 2
	if not exists (SELECT *	FROM sys.Tables where [name] ='final_person_affiliation')
	Select * Into final_person_affiliation From temp_person_affiliation Where 1 = 2
	if not exists (SELECT *	FROM sys.Tables where [name] ='final_user')
	Select * Into final_user From temp_user Where 1 = 2
	if exists (SELECT * FROM sys.Tables where [name] ='temp_proxies')
	BEGIN
		if not exists (SELECT *	FROM sys.Tables where [name] ='final_proxies')
			Select * Into final_proxies From temp_proxies Where 1 = 2
		BEGIN TRY
			BEGIN TRANSACTION;
				truncate table final_proxies
				insert into final_proxies select * from temp_proxies
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
			print @@TRANCOUNT
			set @ErrMsg=error_message()
			print @ErrMsg
 		END CATCH
	END;
	if exists (SELECT * FROM sys.Tables where [name] ='temp_nameforlogin')
	BEGIN
		if not exists (SELECT *	FROM sys.Tables where [name] ='final_nameforlogin')
			Select * Into final_nameforlogin From temp_nameforlogin Where 1 = 2
		BEGIN TRY
			BEGIN TRANSACTION;
				truncate table final_nameforlogin
				insert into final_nameforlogin select * from temp_nameforlogin
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
			print @@TRANCOUNT
			set @ErrMsg=error_message()
			print @ErrMsg
 		END CATCH
	END;
	BEGIN TRY
	  print 'Starting Transactional copy'
      BEGIN TRANSACTION;
			truncate table final_person
			insert into final_person select * from temp_person
			truncate table final_person_affiliation
			insert into final_person_affiliation select * from temp_person_affiliation
			truncate table final_user
			insert into final_user select * from temp_user
		--DECLARE @Number int = 5 / 0;
			IF @@TRANCOUNT >0 COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
      IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
	  print @@TRANCOUNT
	  set @ErrMsg=error_message()
	  print @ErrMsg
	END CATCH;
	
END
GO

/****** Object:  StoredProcedure [dbo].[usp_renameImport]    Script Date: 4/24/2018 10:30:56 AM ******/
-- =============================================
-- Author:		Moisey Gruzman
-- CREATE date: 4/24/2018
-- Description:	Function and procedures for import job
-- =============================================
/****** Object:  StoredProcedure [dbo].[usp_renameImport]    Script Date: 5/14/2018 11:44:14 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
exec fn_cleanProcedure 'usp_renameImport';
go

CREATE PROCEDURE [dbo].[usp_renameImport]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    DECLARE @sql nvarchar(max)
	declare @dopsql nvarchar(max)
	declare @counter int = -1
	declare @ImportName varchar (255)=''
	declare @BaseName varchar(255)
	DECLARE @NameSuffix varchar(255)
	Declare @days_back INT=10
	declare @dropsql nvarchar(max)=''
	declare @id bigint
	declare @Underscore varchar(1)=''
	SELECT @NameSuffix = convert(varchar, getdate(), 112) + '_' + replace(convert(varchar, getdate(),108), ':', '')
	if exists (SELECT * FROM sys.Tables where [name] ='UCSFPRO1_import')
		set @Underscore='_'
	DECLARE import_cursor CURSOR FOR
	SELECT [name] FROM sys.tables
		where [name] like '%_IMPORT'  
	OPEN import_cursor;
	FETCH NEXT FROM import_cursor INTO @ImportName;
	WHILE (@@FETCH_STATUS <> -1 )
		BEGIN
			set @BaseName=replace(@ImportName,'_import','')
			SELECT @sql='SELECT * INTO '+@BaseName+'_' + @NameSuffix + ' from '+ @ImportName
			PRINT @sql 
			EXEC (@sql)
			select @sql='select @id=OBJECT_ID (''vw'+@Underscore+@BaseName+''')'
			print @sql
			execute sp_executesql @sql, N'@id bigint out', @id output
			print @id
			if (@id is NULL) set @sql='CREATE ' 
			else set @sql='ALTER '
			select @sql=@sql+'View vw'+@Underscore+@baseName+' as select * FROM '+@BaseName+'_' + @NameSuffix
			print @sql
			Exec(@sql)
			FETCH NEXT FROM import_cursor INTO @ImportName
		END
	CLOSE import_cursor;
	DEALLOCATE import_cursor;
END
GO
/****** Object:  StoredProcedure [dbo].[usp_updateProxies]    Script Date: 4/24/2018 10:31:16 AM ******/
-- =============================================
-- Author:		Moisey Gruzman
-- CREATE date: 4/24/2018
-- Description:	Function and procedures for import job
-- =============================================
exec fn_cleanProcedure 'usp_updateProxies';
go
CREATE PROCEDURE [dbo].[usp_updateProxies]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @DBNAME varchar(20)='profiles_ucsd'
	declare @importDB varchar(20) =db_name()
	declare @sql nvarchar(max)
	declare @vsql nvarchar(max)
	declare @vquery nvarchar(max)
	declare @userid int
	declare @institution varchar(200)
	declare @department varchar(200)
	declare @action varchar(20)
	declare @temp varchar(200)
	declare @objcursor as cursor 
	declare @proxyforuserid bigint


	set @vquery='select ''insert'',a.userId, a.proxyforuserid from
		(select  pu.userid userid,u.userid proxyforuserid from '+@importDB+'.[dbo].[vw_userproxy] up
		join '+@DBNAME+'.[User.Account].[User] u on u.InternalUserName=up.internalusername
		join '+@DBNAME+'.[User.Account].[User] pu on pu.InternalUserName=up.proxyid
		)a
		left outer join '+@DBNAME+'.[User.Account].DesignatedProxy b 
			on cast(a.userId as varchar)+''->''+ cast( a.proxyforuserid as varchar) = 
			cast(b.userid as varchar)+''->''+cast(b.ProxyForUserID as varchar) 
		where cast(b.userid as varchar)+''->''+cast(b.ProxyForUserID as varchar) is null
		UNION ALL
		select ''delete'',a.userid, a.proxyforuserid from '+@DBNAME+'.[User.Account].DesignatedProxy a
		left outer join
		(select  pu.userid userid,u.userid proxyforuserid from '+@importDB+'.[dbo].[vw_userproxy] up
		join '+@DBNAME+'.[User.Account].[User] u on u.InternalUserName=up.internalusername
		join '+@DBNAME+'.[User.Account].[User] pu on pu.InternalUserName=up.proxyid
		)b
		on cast(a.userId as varchar)+''->''+ cast( a.proxyforuserid as varchar) = 
		cast(b.userid as varchar)+''->''+cast(b.ProxyForUserID as varchar) 
		where cast(b.userid as varchar)+''->''+cast(b.ProxyForUserID as varchar) is null'
	--print @vquery
	set @vsql = 'set @cursor = cursor forward_only static for ' + @vquery + ' open @cursor;'
 
	exec sys.sp_executesql
    @vsql
    ,N'@cursor cursor output'
    ,@objcursor output
 
fetch next from @objcursor into @action,@userid,@proxyforuserid;
	WHILE (@@FETCH_STATUS <> -1)
	BEGIN
		--set @personid=[UCSF.].fn_LegacyInternalusername2EPPN(@up_internalUserName, 'ucsd')
		--set @userid=[UCSF.].fn_LegacyInternalusername2EPPN(@userid, 'ucsd')
		print @action+cast(@userid as varchar)+','+cast(@proxyforuserid as varchar)
		if @action = 'insert'
		BEGIN
			set @sql=@action+' into '+@DBNAME+'.[User.Account].[DesignatedProxy] values ('+
			cast(@userid as varchar)+','+cast(@proxyforuserid as varchar)+')'
		END
		ELSE
		BEGIN
			set @sql=@action +' from '+@DBNAME+'.[User.Account].[DesignatedProxy] where '+
				'userid='+cast(@userid as varchar)+' and '+
				'proxyforuserid='+cast(@proxyforuserid as varchar)
		END
		print @sql
		exec sp_executesql @sql
		FETCH NEXT FROM @objcursor  INTO @action,@userid,@proxyforuserid;
		print @@FETCH_STATUS	
	END;
	CLOSE @objcursor;
	DEALLOCATE @objcursor;

	--global proxies --
	set @vquery='select ''insert'',a.userId, a.[Institution],a.[Department] from
(select  u.userid, ugp.institution,ugp.department from '+@IMPORTDB+'.dbo.[vw_globaluserproxy] ugp
join '+@DBNAME+'.[User.Account].[User] u on u.InternalUserName=ugp.internalusername
)a
left outer join '+
	@DBNAME+'.[User.Account].[DefaultProxy] b 
	on cast(a.userId as varchar)+''->''+ IsNull(a.institution,''ALL'') +'':''+IsNull(a.department,''ALL'') = 
	cast(b.userid as varchar)+''->''+IsNULL(b.ProxyForInstitution,''ALL'')+'':''+IsNull(b.proxyForDepartment,''ALL'') 
where b.userid is NULL
UNION ALL
select ''delete'',a.userid, a.proxyforInstitution, a.ProxyForDepartment 
from '+@DBNAME+'.[User.Account].DefaultProxy a
left outer join
(select  u.userid, up.institution,up.Department from '+@IMPORTDB+'.dbo.[vw_globaluserproxy] up
join '+
	@DBNAME+'.[User.Account].[User] u on u.InternalUserName=up.internalusername
)b
on cast(a.userId as varchar)+''->''+ IsNull(a.ProxyForinstitution,''ALL'') +'':''+IsNull(a.ProxyForDepartment,''ALL'') = 
	cast(b.userid as varchar)+''->''+IsNull(b.institution,''ALL'') +'':''+IsNull(b.department,''ALL'')
where b.userid is NULL'
--print @vquery
set @vsql = 'set @cursor = cursor forward_only static for ' + @vquery + ' open @cursor;'

--set @sql='select @lstkey=max(defaultProxyID) from '+@DBNAME+'.[User.Account].DefaultProxy'
--execute sp_executesql @sql, N'@lstkey int out', @pkid output



exec sys.sp_executesql
    @vsql
    ,N'@cursor cursor output'
    ,@objcursor output
 
fetch next from @objcursor into @action,@userid,@institution,@department;
while (@@fetch_status <> -1)
begin
	if @action = 'insert'
		BEGIN
			set @sql=@action+' into '+@DBNAME+'.[User.Account].[DefaultProxy] '+
			 'values ('+cast(@userid as varchar)+','
			set @temp=isNULL(@institution,'')
			if (@temp !='') 
				begin
					set @sql=@sql+''''+@temp+''''+','
				end
				else
				begin
					set @sql=@sql+'NULL,'
				end
			set @temp=isNULL(@department,'')
			if (@temp !='') 
				begin
					set @sql=@sql+''''+@temp+''''+',NULL,0)'
				end
				else
				begin
					set @sql=@sql+'NULL,NULL,0)'
				end

		END
	if @action = 'delete'
		BEGIN
			set @sql=@action +' from '+@DBNAME+'.[User.Account].[DefaultProxy] where '+
				'userid='+cast(@userid as varchar)+' and '
			set @temp=isNULL(@institution,'')
			if (@temp !='') 
				begin
					set @sql=@sql+'proxyforinstitution='+''''+@temp+''''+' and '
				end
				else
				begin
					set @sql=@sql+'proxyforinstitution is NULL and '
				end
			set @temp=isNULL(@department,'')
			if (@temp != '') 
				begin
					set @sql=@sql+'proxyfordepartment='+''''+@temp+''''
				end
				else
				begin
					set @sql=@sql+'proxyfordepartment=NULL'
				end
		END
	print @sql
	exec sp_executesql @sql
    fetch next from @objcursor into @action,@userid,@institution,@department
end
 
close @objcursor
deallocate @objcursor

END
GO
-- =============================================
-- Author:		Moisey Gruzman
-- CREATE date: 4/24/2018
-- Description:	Function and procedures for import job
-- =============================================
/****** Object:  StoredProcedure [dbo].[usp_validateImport]    Script Date: 5/23/2018 5:36:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
exec fn_cleanProcedure 'usp_validateImport';
go

CREATE PROCEDURE [dbo].[usp_validateImport] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    Declare	@BaseName varchar (255)='_person',
		@IDColumn varchar(255) ='internalusername',
		@MaxDiff int =1200
	DECLARE @NameSuffix varchar(255)
	Declare @CheckName varchar (255)
	Declare @ImportName varchar(255) 
	Declare @CompareName varchar(255)
	Declare @SQL nvarchar(255)
	Declare @DiffNum int
	Declare @LastCount int
	DECLARE @RawCount int, @DistinctCount int
	Declare @cnt int
	DECLARE @ErrMsg nvarchar(4000)=''
	Declare @ErrCode int=0
	if exists (SELECT * FROM sys.Tables where [name] ='UCSFPRO1_import')
	begin
		set @BaseName ='UCSFPRO1'
		set @IDColumn ='individual_id'
	end
	set @ImportName =@Basename+'_import'
	set @CompareName =@ImportName

	SELECT @NameSuffix = SUBSTRING(CONVERT(VARCHAR, GETDATE(), 112),1,2) 
	select @Checkname=@BaseName+'_'+@NameSuffix
	select @cnt = count(*) FROM sys.tables
		where [name] like @BaseName+'_'+@NameSuffix+'%' 
	if @cnt > 0
	BEGIN
		SELECT top 1 @CheckName=[name] 
		FROM sys.tables
			where [name] like @BaseName+'_'+@NameSuffix+'%' 
			order by [name] desc
		set @SQL=N'select @cnt=count('+@IDColumn+') from '+@CheckName
		EXEC sp_executesql @sql, N'@cnt int  OUTPUT', @cnt = @LastCount OUTPUT
		print 'LastCount='+cast(@LastCount as varchar)
		set @MaxDiff=@LastCount*0.05
		print 'MaxDiff='+cast(@MaxDiff as varchar)
		set @SQL = N'select @cnt=count('+@IDColumn+') from '+@CheckName
			+ ' where '+@IDColumn+' not in 
			(select '+@IDColumn+' from '+@ImportName +')' 
		--print @SQL
		EXEC sp_executesql @sql, N'@cnt int  OUTPUT', @cnt = @DiffNum OUTPUT
		print STR(@DiffNum)+' Employee IDs from table '+@Checkname+
				' not been seen in '+@Importname
		if @DiffNum > @MaxDiff
		BEGIN
			set @ErrCode=16
			SELECT @ErrMsg = 'Import been stopped due to big difference'+
				CHAR(13)+CHAR(10)+ '('+
				cast(@DiffNum as varchar)+
				') between the number of just imported Employee IDs '+CHAR(10)+
				 'and Emploee IDs, imported '+
				Replace(@CheckName,@Basename+'_','')
		END
		set @SQL = N'SELECT @RawCount = count(*) from '+@ImportName
		+' where '+@IDColumn+' is not NULL'
		--print @SQL
		EXEC sp_executesql @sql, N'@RawCount int  OUTPUT', @RawCount OUTPUT
		--print 'RawCount='+STR(@RawCount)
		set @SQL = N'select @DistinctCount = count(distinct('+@IDColumn+')) from  '+@ImportName
			+' where '+@IDColumn+' is not NULL' 
		--print @SQL
		EXEC sp_executesql @sql, N'@DistinctCount int  OUTPUT', @DistinctCount OUTPUT
		--print 'DistinctCount='+STR(@DistinctCount) 
		IF @RawCount <> @DistinctCount
		BEGIN
			set @ErrCode=16
			select @cnt=ABS(@RawCount - @DistinctCount)
			SELECT @ErrMsg = @ErrMsg+
			CHAR(13)+CHAR(10)+
			' There are ('+ cast(@cnt as varchar)+ ') duplicated Employee IDs ' 
		END
		if @ErrCode >0
		BEGIN
			---Declare @Subject varchar(255)=@@SERVERNAME+' Warning!' 
			set @ErrMsg=db_NAME()+' can not use HR Data due to errors:'+CHAR(10)+@ErrMsg 
			-- Raise an error with the details of the exception
			--EXEC msdb.dbo.sp_send_dbmail    @profile_name = 'moisey',
            --                    @recipients = 'moisey.gruzman@ucsf.edu',
            --                    @subject = @Subject,
            --                    @body = @ErrMsg
			RAISERROR(@ErrMsg, 16, 1);
		END
	END
END
GO
/****** Object:  StoredProcedure [dbo].[usp_validateImportAffiliations]    Script Date: 4/24/2018 10:31:28 AM ******/
-- =============================================
-- Author:		Moisey Gruzman
-- CREATE date: 4/24/2018
-- Description:	Function and procedures for import job
-- =============================================
exec fn_cleanProcedure 'usp_validateImportAffiliations';
go

CREATE PROCEDURE [dbo].[usp_validateImportAffiliations] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @BaseName varchar (255)
	declare @IDColumn varchar(255)
    declare @column_name varchar(200)
	declare @column_value varchar(200)
	declare @column_datatype varchar(50)
	declare @column_charmax int 
	declare @column_precision int
	declare @column_scale int
	declare @conversion varchar(30)
	declare @sql nvarchar(max)
	declare @mainsql nvarchar(max)
	declare @lastsym varchar(1)
	declare @tableName varchar(200)
	DECLARE @ErrMsg nvarchar(4000)
	Declare @ErrCode int
	
	if exists (SELECT * FROM sys.Tables where [name] ='UCSFPRO2_import')
	begin
		set @tableName = 'vw_person_affiliations'
		set @IDColumn = 'internalusername'

	end
	else
	begin
		set @tableName ='_person_affiliations_import'
		set @IDColumn ='internalusername'
	end
	
	
	set @ErrMsg=''
	set @ErrCode=0
	
	set @mainsql='set @id=''''; select @id=@id+'',''+'+@IDColumn+' from '+@tableName+' where '
	DECLARE process_cursor CURSOR FOR
		select column_name,data_type,IsNull(character_maximum_length,0),isNULL(numeric_precision,0),
			isNULL(numeric_scale,0)
		from information_schema.columns 
		where table_name= @tableName --and table_schema = @tableSchema
			and data_type like '%varchar'
	OPEN process_cursor;
	FETCH NEXT FROM process_cursor INTO @column_name,@column_datatype,@column_charmax,@column_precision,@column_scale
	WHILE (@@FETCH_STATUS <> -1 )
	BEGIN
		set @mainsql=@mainsql+'dbo.fn_check_badsymbols('+@column_name+') <0 or ' 
		FETCH NEXT FROM process_cursor INTO @column_name,@column_datatype,@column_charmax,@column_precision,@column_scale
	END
	CLOSE process_cursor;
	DEALLOCATE process_cursor;
	set @mainsql=substring(@mainsql,1,LEN(@mainsql)-LEN(' or '))+';print @id'
	--print(@mainsql)
	declare @badid varchar(500)
	execute  sp_executesql @mainsql, N'@id varchar(100) out',@badid output
	--print 'wrong rows=<'+@badid+'>'
	if (LEN(@badid) > 0)
	BEGIN
		set @ErrCode=16
		SELECT @ErrMsg = 'Import been stopped due fields with not XML allowing symbols'+
				CHAR(13)+CHAR(10)+ 'in the table '+@tableName+
				' check '+@IDColumn+'(s) <'+@badid+'>'
		--RAISERROR(@ErrMsg, 16, 1);
	END
	declare @lst varchar(1000) = ''
	set @mainsql='set @lst='''';	select @lst=@lst+''''+bbb.[internalusername]+'','' from '
		+CHAR(13)+CHAR(10)+
			'(SELECT aaa.* from '
		+CHAR(13)+CHAR(10)+
			'(SELECT (pa.internalusername+''/''+cast(affiliationorder as varchar)) as internalusername, '
		+CHAR(13)+CHAR(10)+
			' count(*) as num '
		+CHAR(13)+CHAR(10)+
			' FROM '+@tableName+' pa '
		 +CHAR(13)+CHAR(10)+
			' GROUP BY ROLLUP (pa.internalusername,cast(affiliationorder as varchar)) '
		 +CHAR(13)+CHAR(10)+
			') aaa '
		 +CHAR(13)+CHAR(10)+
 			'where internalusername != ''NULL'''
		 +CHAR(13)+CHAR(10)+	
			' and aaa.num>1 '
		 +CHAR(13)+CHAR(10)+
			') bbb '

--print @mainsql	
		execute sp_executesql @mainsql, N'@lst varchar(1000) out', @lst output
		print '<'+@lst+'>'
		if len(@lst) >0 
			set @ErrMsg=@ErrMsg+CHAR(13)+CHAR(10)+'internalusernames with dup affiliationorder '+@lst
		if LEN(@ErrMsg)>0 RAISERROR(@ErrMsg, 16, 1);
END
GO

--+++++++++++++++++++++++++++