USE [msdb]
GO

/****** Object:  Job [PubMedDisambiguation_GetPubs_DEV_COMPLETE]    Script Date: 9/9/2021 8:55:44 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 9/9/2021 8:55:44 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'PubMedDisambiguation_GetPubs_DEV_COMPLETE', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [PubMedDisambiguation_GetPubs.dtsx]    Script Date: 9/9/2021 8:55:44 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'PubMedDisambiguation_GetPubs.dtsx', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/SQL "\"\ProfilesRNS_CallPRNSWebservice\"" /SERVER $(YourProfilesServerName) /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /SET "\"\Package.Variables[ServerName].Value\"";$(YourProfilesServerName) /SET "\"\Package.Variables[DatabaseName].Value\"";"\"$(YourProfilesDatabaseName)\"" /SET "\"\Package.Variables[Job].Value\"";"\"PubMedDisambiguation_GetPubs\"" /REPORTING E', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [PubMedDisambiguation_GetPubMEDXML]    Script Date: 9/9/2021 8:55:44 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'PubMedDisambiguation_GetPubMEDXML', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/SQL "\ProfilesRNS_CallPRNSWebservice" /SERVER $(YourProfilesServerName) /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /SET "\Package.Variables[ServerName].Value";$(YourProfilesServerName) /SET "\Package.Variables[DatabaseName].Value";$(YourProfilesDatabaseName) /SET "\Package.Variables[Job].Value";GetPubMedXML /REPORTING E', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Parse XML]    Script Date: 9/9/2021 8:55:44 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Parse XML', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec  [Profile.Data].[Publication.Pubmed.ParseALLPubMedXML]', 
		@database_name=N'$(YourProfilesDatabaseName)', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Pubs]    Script Date: 9/9/2021 8:55:44 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Pubs', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec  [Profile.Data].[Publication.Pubmed.LoadDisambiguationResults]', 
		@database_name=N'$(YourProfilesDatabaseName)', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Bibliometrics]    Script Date: 9/9/2021 8:55:44 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Bibliometrics', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/SQL "\"\ProfilesRNS_CallPRNSWebservice\"" /SERVER $(YourProfilesServerName) /MAXCONCURRENT " -1 " /CHECKPOINTING OFF /SET "\"\Package.Variables[ServerName].Value\"";$(YourProfilesServerName) /SET "\"\Package.Variables[DatabaseName].Value\"";"\"$(YourProfilesDatabaseName)\"" /SET "\"\Package.Variables[Job].Value\"";Bibliometrics /REPORTING E', 
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


