USE [msdb]
GO
DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'Parse_SSAS_xEvents', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'TSZDELL2015\szabeszcsi', @job_id = @jobId OUTPUT
select @jobId
GO
EXEC msdb.dbo.sp_add_jobserver @job_name=N'Parse_SSAS_xEvents', @server_name = N'TSZDELL2015\SQL2017'
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'Parse_SSAS_xEvents', @step_name=N'Exec proc', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=5, 
		@retry_interval=2, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec dbo.GetxEventsStat', 
		@database_name=N'SSAS_Stat', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'Parse_SSAS_xEvents', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'TSZDELL2015\szabeszcsi', 
		@notify_email_operator_name=N'', 
		@notify_page_operator_name=N''
GO
USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'Parse_SSAS_xEvents', @name=N'SSAS_xEvents_Check', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=5, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20180528, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO
