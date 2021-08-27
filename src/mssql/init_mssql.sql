-- Create Database
CREATE DATABASE GamingGroup6;

-- Create Table
USE DATABASE GamingGroup6;
GO

CREATE TABLE Country
(
	CountryID TINYINT NOT NULL PRIMARY KEY,
	CountryName VARCHAR(50) NULL
);

CREATE TABLE Calendar
(
	DateID VARCHAR(50) NOT NULL PRIMARY KEY,
	Date DATE NOT NULL,
	Day TINYINT NOT NULL,
	Month TINYINT NOT NULL,
	Year INT NOT NULL
);

CREATE TABLE Membership
(
	MembershipID TINYINT NOT NULL PRIMARY KEY,
	Membership VARCHAR(50) NOT NULL,
	Cost MONEY NOT NULL
);

CREATE TABLE UserInfo
(
	UserID VARCHAR(50) NOT NULL PRIMARY KEY,
	UserName VARCHAR(50) NOT NULL,
	RegisteredDateID VARCHAR(50),
	RegisterDate DATE NOT NULL,
	CountryName VARCHAR(50) NULL,
	MembershipID TINYINT NOT NULL,
	Email VARCHAR(50) NULL,
	Age TINYINT NULL,
	Gender VARCHAR(50) NULL,
	CONSTRAINT FK_DATEID FOREIGN KEY(RegisteredDateID) REFERENCES Calendar(DateID),
	CONSTRAINT FK_MEMBERSHIPID FOREIGN KEY(MembershipID) REFERENCES Membership(MembershipID)
);

CREATE TABLE Transactions(
	SessionID VARCHAR(50) NOT NULL PRIMARY KEY,
	UserID VARCHAR(50) NOT NULL,
	CountryID TINYINT NOT NULL,
	StartDateID VARCHAR(50) NOT NULL,
	StartDate DATE NOT NULL,
	StartTimestamp INT NOT NULL,
	EndTimestamp INT NOT NULL,
	CashSpend MONEY NULL,
	CountImpression TINYINT NULL,
	eCPM MONEY NULL,
	OS VARCHAR(50) NULL,
	OsVersion VARCHAR(50) NULL,
	CONSTRAINT FK_USERID FOREIGN KEY(UserID) REFERENCES UserInfo(UserID),
	CONSTRAINT FK_COUNTRYID FOREIGN KEY(CountryID) REFERENCES Country(CountryID),
	CONSTRAINT FK_SDATEID FOREIGN KEY(StartDateID) REFERENCES Calendar(DateID)
);

-- Load datetime information into Calendar Table
DECLARE @StartDate  date = '20210101';

DECLARE @CutoffDate date = DATEADD(DAY, -1, DATEADD(YEAR, 2, @StartDate));

;WITH seq(n) AS 
(
  SELECT 0 UNION ALL SELECT n + 1 FROM seq
  WHERE n < DATEDIFF(DAY, @StartDate, @CutoffDate)
),
d(d) AS 
(
  SELECT DATEADD(DAY, n, @StartDate) FROM seq
),
src AS
(
  SELECT
    DateID = CONVERT(date, d),
	TheDate = CONVERT(date, d),
    TheDay = CONVERT(TINYINT, DATEPART(DAY, d)),
    TheMonth = CONVERT(TINYINT, DATEPART(MONTH, d)),
    TheYear = CONVERT(INT, DATEPART(YEAR, d))
  FROM d
)
INSERT INTO Calendar(DateID, Date, Day, Month, Year)
SELECT FORMAT (DateID, 'yyyyMMdd') as DateID, TheDate, TheDay,
TheMonth, TheYear FROM src
  ORDER BY TheDate
  OPTION (MAXRECURSION 0);

-- Create Agent Job / Schedule

USE [msdb]
GO

/****** Object:  Job [Run SSIS Package]    Script Date: 8/18/2021 8:05:36 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 8/18/2021 8:05:36 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Run SSIS Package', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'FSOFT.FPT.VN\LinhTK9', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run SSIS Package]    Script Date: 8/18/2021 8:05:36 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run SSIS Package', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'SSIS', 
		@command=N'/ISSERVER "\"\SSISDB\GamingGroup6\SSIS_GamingGroup6\Package.dtsx\"" /SERVER CVP00204888A /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'SSISSchedule', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20210818, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'786217bc-cacc-4b32-a11d-9dcc865f6a7c'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

-- Create Stored Procedure
