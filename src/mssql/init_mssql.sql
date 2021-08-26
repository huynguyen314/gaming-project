/*** Sript to run before creating database ***/
---VARIABLES
DECLARE @identity as nvarchar(50) = N'FSOFT.FPT.VN\KhangNHN';
DECLARE @password as nvarchar(50) = N'***********';
DECLARE @youremail as nvarchar(50) ='nguyenhoangnhatkhang@gmail.com';
DECLARE @youremailsever as nvarchar(50) ='stmp.gmail.com';
--------------------------------------------------------------------
USE [msdb]
--* DROP Everything *
-- Database 
DROP DATABASE IF EXISTS GamingGroup6;
-- Credentials
IF EXISTS (SELECT * FROM sys.credentials WHERE name = 'RunDemoProxy')
    DROP CREDENTIAL RunDemoProxy
-- Mail account
DECLARE @Id binary(16)
SELECT @Id = account_id FROM msdb.dbo.sysmail_account WHERE (name = N'FakeAccount')
IF (@Id IS NOT NULL)
BEGIN
    EXEC msdb.dbo.sysmail_delete_account_sp  @Id
END
-- Mail Profile
SELECT @Id = profile_id FROM msdb.dbo.sysmail_profile WHERE (name = N'FakeProfile')
IF (@Id IS NOT NULL)
BEGIN
    EXEC msdb.dbo.sysmail_delete_profile_sp  @Id
END
-- Environment 
IF EXISTS (SELECT * FROM SSISDB.catalog.environments WHERE name = N'DemoEnvironment')
    EXEC [SSISDB].[catalog].[delete_environment] @environment_name=N'DemoEnvironment', @folder_name=N'demo_Catalog'
-- Project 
IF EXISTS (SELECT * FROM SSISDB.catalog.projects WHERE name = N'SSIS_GamingGroup6')
    EXEC [SSISDB].[catalog].[delete_project] @project_name=N'SSIS_GamingGroup6', @folder_name=N'demo_Catalog'
-- Catalog
IF EXISTS (SELECT * FROM SSISDB.catalog.folders WHERE name = N'demo_Catalog')
    EXEC [SSISDB].[catalog].[delete_folder] @folder_name=N'demo_Catalog'
-- Proxy
SELECT @Id = proxy_id FROM msdb.dbo.sysproxies WHERE (name = N'DemoProxyProject02')
IF (@Id IS NOT NULL)
BEGIN
    EXEC msdb.dbo.sp_delete_proxy @Id
END
-- Operator
IF EXISTS (SELECT * FROM msdb.dbo.sysoperators WHERE name = N'FakeOperator02')
BEGIN
    EXEC msdb.dbo.sp_delete_operator @name=N'FakeOperator02'
END
-- Alert 
IF EXISTS (SELECT * FROM msdb.dbo.sysalerts WHERE name = N'FakeAlert02')
BEGIN
    EXEC msdb.dbo.sp_delete_alert @name=N'FakeAlert02'
END
-- Job
DECLARE @jobId binary(16)
SELECT @jobId = job_id FROM msdb.dbo.sysjobs WHERE (name = N'RunDemoProject02')
IF (@jobId IS NOT NULL)
BEGIN
    EXEC msdb.dbo.sp_delete_job @jobId
END
--------------------------------------------------------------------
-- CREATE CREDENTIALS
USE [master];
EXEC ('CREATE CREDENTIAL [RunDemoProxy] WITH IDENTITY = ''' + @identity + ''',
SECRET = ''' + @password + ''';')
--------------------------------------------------------------------
-- CREATE DATABASE MAIL 
-- Mail account
USE [msdb];
EXECUTE msdb.dbo.sysmail_add_account_sp  
    @account_name = 'FakeAccount',  
    @description = 'Mail account for use by all database users.',  
    @email_address = @youremail,  
    @replyto_address = @youremail,  
    @display_name = 'Demo Automated Mailer',  
    @mailserver_name = @youremailsever ;  
-- Mail profile  
EXECUTE msdb.dbo.sysmail_add_profile_sp  
    @profile_name = 'FakeProfile',  
    @description = 'Profile used for administrative mail.' ; 
-- Add account to the profile  
EXECUTE msdb.dbo.sysmail_add_profileaccount_sp  
    @profile_name = 'FakeProfile',  
    @account_name = 'FakeAccount',  
    @sequence_number =1 ;  
-- Grant access to the profile to all users in the msdb database  
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp  
    @profile_name = 'FakeProfile',  
    @principal_name = 'public',  
    @is_default = 1 ;  
--------------------------------------------------------------
-- CREATE catalog folder, default name = demo_catalog
EXEC [SSISDB].[catalog].[create_folder] @folder_name=N'demo_Catalog';
--------------------------------------------------------------
-- CREATE Environment and variable, user need to modIFy by themselves 
EXEC [SSISDB].[catalog].[create_environment] @environment_name=N'DemoEnvironment', @environment_description=N'', @folder_name=N'demo_Catalog'
DECLARE @var sql_variant = N'temp'
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'PythonPath', @sensitive=False, @description=N'Path WHERE you have your python.exe', @environment_name=N'DemoEnvironment', @folder_name=N'demo_Catalog', @value=@var, @data_type=N'String';
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'ServerName', @sensitive=False, @description=N'Your Server Name', @environment_name=N'DemoEnvironment', @folder_name=N'demo_Catalog', @value=@var, @data_type=N'String';
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'SnowflakePath', @sensitive=False, @description=N'Path WHERE you store snowflake source file', @environment_name=N'DemoEnvironment', @folder_name=N'demo_Catalog', @value=@var, @data_type=N'String';
EXEC [SSISDB].[catalog].[create_environment_variable] @variable_name=N'WorkingFolderPath', @sensitive=False, @description=N'Path to working folder', @environment_name=N'DemoEnvironment', @folder_name=N'demo_Catalog', @value=@var, @data_type=N'String';
---------------------------------------------------------------
-- CREATE Proxy
USE [msdb];
EXEC msdb.dbo.sp_add_proxy @proxy_name=N'DemoProxyProject02',@credential_name=N'RunDemoProxy', 
		@enabled=1;
EXEC msdb.dbo.sp_grant_proxy_to_subsystem @proxy_name=N'DemoProxyProject02', @subsystem_id=11
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name=N'DemoProxyProject02', @msdb_role=N'DatabaseMailUserRole'
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name=N'DemoProxyProject02', @msdb_role=N'db_accessadmin'
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name=N'DemoProxyProject02', @msdb_role=N'db_backupoperator'
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name=N'DemoProxyProject02', @msdb_role=N'db_datareader'
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name=N'DemoProxyProject02', @msdb_role=N'db_datawriter'
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name=N'DemoProxyProject02', @msdb_role=N'db_ddladmin'
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name=N'DemoProxyProject02', @msdb_role=N'db_denydatareader'
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name=N'DemoProxyProject02', @msdb_role=N'db_denydatawriter'
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name=N'DemoProxyProject02', @msdb_role=N'db_owner'
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name=N'DemoProxyProject02', @msdb_role=N'db_securityadmin'
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name=N'DemoProxyProject02', @msdb_role=N'db_ssisadmin'
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name=N'DemoProxyProject02', @msdb_role=N'db_ssisltduser'
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name=N'DemoProxyProject02', @msdb_role=N'db_ssisoperator'
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name=N'DemoProxyProject02', @msdb_role=N'dc_admin'
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name=N'DemoProxyProject02', @msdb_role=N'dc_operator'
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name=N'DemoProxyProject02', @msdb_role=N'dc_proxy'
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name=N'DemoProxyProject02', @msdb_role=N'PolicyAdministratorRole'
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name=N'DemoProxyProject02', @msdb_role=N'public'
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name=N'DemoProxyProject02', @msdb_role=N'ServerGroupAdministratorRole'
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name=N'DemoProxyProject02', @msdb_role=N'ServerGroupReaderRole'
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name=N'DemoProxyProject02', @msdb_role=N'SQLAgentOperatorRole'
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name=N'DemoProxyProject02', @msdb_role=N'SQLAgentReaderRole'
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name=N'DemoProxyProject02', @msdb_role=N'SQLAgentUserRole'
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name=N'DemoProxyProject02', @msdb_role=N'TargetServersRole'
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name=N'DemoProxyProject02', @msdb_role=N'UtilityCMRReader'
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name=N'DemoProxyProject02', @msdb_role=N'UtilityIMRReader'
EXEC msdb.dbo.sp_grant_login_to_proxy @proxy_name=N'DemoProxyProject02', @msdb_role=N'UtilityIMRWriter'
-------------------------------------------------------------------------------
-- CREATE Operator
USE [msdb];
EXEC msdb.dbo.sp_add_operator @name=N'FakeOperator02', 
		@enabled=1, 
		@pager_days=0, 
		@email_address=@youremail, 
		@pager_address=@youremail
-------------------------------------------------------------------------------
/******* CREATE DATABASE AND TABLE *******/
-- Create Database
CREATE DATABASE GamingGroup6;
GO
USE GamingGroup6;
GO
-- Create schema 
CREATE SCHEMA GameBI;
GO
-- Create Table


CREATE TABLE GameBI.CountryDetails
(
	CountryID TINYINT NOT NULL PRIMARY KEY,
	CountryName VARCHAR(50) NULL,
	ZipCode INT NOT NULL,
	Region VARCHAR(50), 
	ModifedDate DATE NOT NULL
);

CREATE TABLE GameBI.GameDetails
(
	GameID INT NOT NULL PRIMARY KEY,
	GameName VARCHAR(50) NOT NULL,
	GamePlatform VARCHAR(50) NOT NULL,
	GameCategory VARCHAR(50) NOT NULL,
	ReleasedDate DATE NOT NULL,
	PaymentType VARCHAR(10) NOT NULL,
	ModifedDate DATE NOT NULL
);

CREATE TABLE GameBI.UserInfo
(
	UserID INT NOT NULL PRIMARY KEY,
	UserName VARCHAR(50) NOT NULL,
	Age TINYINT NOT NULL,
	Gender VARCHAR(10) NOT NULL,
	EmailAddress VARCHAR(50) NULL,
	Income INT NOT NULL,
	MarritalStatus VARCHAR(10),
	RegisteredDate DATE NOT NULL,
	LastOnline DATE NOT NULL,
	ModifedDate DATE NOT NULL
);

CREATE TABLE GameBI.Transactions(
	SessionID INT NOT NULL,
	UserID INT NOT NULL,
	CountryID TINYINT NOT NULL,
	GameID INT NOT NULL,
	DateOfRecord DATE NOT NULL,
	IncomeByAds MONEY NOT NULL,
	IncomeByPurchase MONEY NOT NULL,
	IncomeBoughtIngameItems MONEY NOT NULL,
	ModifedDate DATE NOT NULL,
	CONSTRAINT PK_GameTransaction PRIMARY KEY (SessionID),
	CONSTRAINT FK_User FOREIGN KEY (UserID) REFERENCES GameBI.UserInfo(UserID),
	CONSTRAINT FK_Country FOREIGN KEY (CountryID) REFERENCES GameBI.CountryDetails(CountryID),
	CONSTRAINT FK_Game FOREIGN KEY (GameID) REFERENCES GameBI.GameDetails(GameID)
);

/********************CREATE LOGEVENT***************************/
CREATE TABLE GameBI.EventLog(
	[IDlog] [int] IDENTITY(1,1) NOT NULL,
	[Package] [nvarchar] (100) NOT NULL,
	[Task] [nvarchar] (100) NOT NULL,
	[EventDescription] [nvarchar] (max) NOT NULL,
	[Timelog] [date] NULL,
);
/********************CREATE VIEW***************************/






