USE [msdb]
GO

/****** Object:  Job [Profiles PROD uc_DataImport UCD]    Script Date: 5/16/2018 11:05:38 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 5/16/2018 11:05:38 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
declare @Environment varchar(10)='PROD'
declare @DBServer varchar(50)
if @Environment = 'PROD' set @DBServer='SFPRF-PDB01-AG1'
else set @DBServer='SFPRF-QDB01-AG1'
declare @InstitutionAbbreviation varchar(10)='USC'
declare @InstitutionSuffix varchar(20)='usc.edu'
declare @DatabaseSuffix varchar (10) = 'USC'
declare @currentJobName nvarchar(100)=N'Profiles '+@Environment+' from template uc_DataImport '+@DatabaseSuffix
--$DBServer replaced with @DBServer
--$InstitutionAbbreviation replaced with @InstitutionAbbreviation
--$InstitutionSuffix replaced with @InstitutionSuffix
declare @cmd_clean nvarchar(max)=N'exec ['+'$DBServer'+'].[import_'+'$DatabaseSuffix'+'].dbo.usp_cleanImport'
declare @cmd_validate nvarchar(max)=N'exec ['+'$DBServer'+'].[import_'+'$DatabaseSuffix'+'].dbo.usp_validateImport
	exec ['+'$DBServer'+'].[import_'+'$DatabaseSuffix'+'].dbo.usp_validateImportAffiliations'
declare @cmd_rename nvarchar(max)=N'exec ['+'$DBServer'+'].[import_'+'$DatabaseSuffix'+'].dbo.usp_renameImport'
declare @cmd_manual nvarchar(max)=N'exec ['+'$DBServer'+'].[import_'+'$DatabaseSuffix'+'].dbo.usp_manualUpdate'
declare @cmd_2RNS nvarchar(max)=N'exec ['+'$DBServer'+'].[import_profiles].[UCSF.Import].[ImportHRData] @InstitutionAbbreviation = ''$InstitutionAbbreviation'', @LikeSuffix = ''%'+'$InstitutionSuffix'' , @SourceDB = ''import_'+'$DatabaseSuffix'''
set @cmd_clean=replace(replace(replace(replace(@cmd_clean,'$DBServer',@DBServer),'$InstitutionAbbreviation',@InstitutionAbbreviation),'$InstitutionSuffix',@InstitutionSuffix),'$DatabaseSuffix',@DatabaseSuffix)
set @cmd_validate=replace(replace(replace(replace(@cmd_validate,'$DBServer',@DBServer),'$InstitutionAbbreviation',@InstitutionAbbreviation),'$InstitutionSuffix',@InstitutionSuffix),'$DatabaseSuffix',@DatabaseSuffix)
set @cmd_rename=replace(replace(replace(replace(@cmd_rename,'$DBServer',@DBServer),'$InstitutionAbbreviation',@InstitutionAbbreviation),'$InstitutionSuffix',@InstitutionSuffix),'$DatabaseSuffix',@DatabaseSuffix)
set @cmd_manual=replace(replace(replace(replace(@cmd_manual,'$DBServer',@DBServer),'$InstitutionAbbreviation',@InstitutionAbbreviation),'$InstitutionSuffix',@InstitutionSuffix),'$DatabaseSuffix',@DatabaseSuffix)
set @cmd_2RNS=replace(replace(replace(replace(@cmd_2RNS,'$DBServer',@DBServer),'$InstitutionAbbreviation',@InstitutionAbbreviation),
'$InstitutionSuffix',@InstitutionSuffix),'$DatabaseSuffix',@DatabaseSuffix)
print 'cmd_clean='+@cmd_clean
print 'cmd_validate='+@cmd_validate
print 'cmd_rename='+@cmd_rename
print 'cmd_manual='+@cmd_manual
print 'cmd_2RNS='+@cmd_2RNS
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=@currentJobName, 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'profilesjobrunner', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Clean import tables]    Script Date: 5/16/2018 11:05:38 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Clean import tables', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=@cmd_clean, 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [validate import]    Script Date: 5/16/2018 11:05:38 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'validate import', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=@cmd_validate, 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Rename import tables]    Script Date: 5/16/2018 11:05:38 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Rename import tables', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=@cmd_rename, 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Apply manual edits]    Script Date: 5/16/2018 11:05:38 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Apply manual edits', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=@cmd_manual, 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Move to import_profiles]    Script Date: 5/16/2018 11:05:38 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Move to import_profiles', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=@cmd_2RNS,
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


