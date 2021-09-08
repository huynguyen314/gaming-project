-- Login name
DECLARE @login_name as nvarchar(max) = N'FSOFT.FPT.VN\KhangNHN'
-- CREATE Reference for deployed package 

Declare @reference_id bigint
EXEC [SSISDB].[catalog].[create_environment_reference] @environment_name=N'DemoEnvironment', @reference_id=@reference_id OUTPUT, @project_name=N'SSIS_GamingGroup6', @folder_name=N'demo_Catalog', @reference_type=R
Select @reference_id
EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'PythonexePath', @object_name=N'SSIS_GamingGroup6', @folder_name=N'demo_Catalog', @project_name=N'SSIS_GamingGroup6', @value_type=R, @parameter_value=N'PythonPath'
EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'ServerName', @object_name=N'SSIS_GamingGroup6', @folder_name=N'demo_Catalog', @project_name=N'SSIS_GamingGroup6', @value_type=R, @parameter_value=N'ServerName'
EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'SnowFlakeFilePath', @object_name=N'SSIS_GamingGroup6', @folder_name=N'demo_Catalog', @project_name=N'SSIS_GamingGroup6', @value_type=R, @parameter_value=N'SnowflakePath'
EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'SnowSQLConfigFilePath', @object_name=N'SSIS_GamingGroup6', @folder_name=N'demo_Catalog', @project_name=N'SSIS_GamingGroup6', @value_type=R, @parameter_value=N'SnowSQLPath'
EXEC [SSISDB].[catalog].[set_object_parameter_value] @object_type=20, @parameter_name=N'WorkingPath', @object_name=N'SSIS_GamingGroup6', @folder_name=N'demo_Catalog', @project_name=N'SSIS_GamingGroup6', @value_type=R, @parameter_value=N'WorkingFolderPath'
print(@reference_id)
-----------------------------------------
-- CREATE Jobs (will create alert here too)
-- Run Main package
USE [msdb];
DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'RunDemoProject02', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=@login_name, 
		@notify_email_operator_name=N'FakeOperator02', @job_id = @jobId OUTPUT
select @jobId
print(@jobId)
EXEC msdb.dbo.sp_add_jobserver @job_name=N'RunDemoProject02', @server_name = @@SERVERNAME
DECLARE @commandtext as nvarchar(max) = N'/ISSERVER "\"\SSISDB\demo_Catalog\SSIS_GamingGroup6\LoadData2SQL.dtsx\"" /SERVER "\"' +''+@@SERVERNAME +''+
'\"" /ENVREFERENCE '+'' + CAST(@reference_id as varchar(10)) + ''+' /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E';
print(@commandtext)
EXEC msdb.dbo.sp_add_jobstep @job_name=N'RunDemoProject02', @step_name=N'run', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=@commandtext,
		@database_name=N'GamingGroup6', 
		@flags=0, 
		@proxy_name=N'DemoProxyProject02'
EXEC msdb.dbo.sp_update_job @job_name=N'RunDemoProject02', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=@login_name, 
		@notify_email_operator_name=N'FakeOperator02', 
		@notify_page_operator_name=N''
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'RunDemoProject02', @name=N'RunWeekly', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20210915, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
select @schedule_id
-- CREATE Alert
EXEC msdb.dbo.sp_add_alert @name=N'FakeAlert02', 
		@message_id=0, 
		@severity=1, 
		@enabled=1, 
		@delay_between_responses=0, 
		@include_event_description_in=0, 
		@database_name=N'SSISDB', 
		@job_id=@jobId
EXEC msdb.dbo.sp_add_notification @alert_name=N'FakeAlert02', @operator_name=N'FakeOperator02', @notification_method = 1

-- Run Backup package
USE [msdb];
DECLARE @jobID_backup BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'RunBackupProject02', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=@login_name, 
		@notify_email_operator_name=N'FakeOperator_Backup02', @job_id = @jobID_backup OUTPUT
select @jobID_backup
print(@jobID_backup)
EXEC msdb.dbo.sp_add_jobserver @job_name=N'RunBackupProject02', @server_name = @@SERVERNAME
DECLARE @commandtext1 as nvarchar(max) = N'/ISSERVER "\"\SSISDB\demo_Catalog\SSIS_GamingGroup6\UnloadFromSnow.dtsx\"" /SERVER "\"' +''+@@SERVERNAME +''+
'\"" /ENVREFERENCE '+'' + CAST(@reference_id as varchar(10)) + ''+' /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E';
print(@commandtext1)
EXEC msdb.dbo.sp_add_jobstep @job_name=N'RunBackupProject02', @step_name=N'run', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=@commandtext1,
		@database_name=N'GamingGroup6', 
		@flags=0, 
		@proxy_name=N'DemoProxyProject02'
EXEC msdb.dbo.sp_update_job @job_name=N'RunBackupProject02', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=@login_name, 
		@notify_email_operator_name=N'FakeOperator_Backup02', 
		@notify_page_operator_name=N''
DECLARE @schedule_id_backup int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'RunBackupProject02', @name=N'RunWeekly', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20210915, 
		@active_end_date=99991231, 
		@active_start_time=1, 
		@active_end_time=235959, @schedule_id = @schedule_id_backup OUTPUT
select @schedule_id_backup


