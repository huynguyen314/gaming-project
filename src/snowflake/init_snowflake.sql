-- Set up Warehouse
CREATE OR REPLACE WAREHOUSE GAMING_WH WITH
WAREHOUSE_SIZE = 'XSMALL'
MAX_CLUSTER_COUNT = 1
MIN_CLUSTER_COUNT = 1
AUTO_SUSPEND = 600 -- 600s
AUTO_RESUME = TRUE
INITIALLY_SUSPENDED = FALSE
COMMENT = 'This warehouse is used for gaming project demo.';
-- Set up Database

-- set up table
CREATE TABLE Country
(
	CountryID TINYINT PRIMARY KEY,
	CountryName VARCHAR(50) NULL
)

CREATE TABLE Calendar
(
	DateID VARCHAR(50) NOT NULL PRIMARY KEY,
	Date DATE NOT NULL,
	Day TINYINT NOT NULL,
	Month TINYINT NOT NULL,
	Year INT NOT NULL
)

CREATE TABLE Membership
(
	MembershipID TINYINT PRIMARY KEY,
	Membership VARCHAR(50) NOT NULL,
	Cost FLOAT NOT NULL
)


CREATE TABLE UserInfo
(
	UserID VARCHAR(50) NOT NULL PRIMARY KEY,
	UserName VARCHAR(50) NOT NULL,
	RegisteredDateID VARCHAR(50) FOREIGN KEY REFERENCES Calendar(DateID),
	RegisterDate DATE NOT NULL,
	CountryName VARCHAR(50) NULL,
	MembershipID TINYINT FOREIGN KEY REFERENCES Membership(MembershipID),
	Email VARCHAR(50) NULL,
	Age TINYINT NULL,
	Gender VARCHAR(50) NULL
);

CREATE TABLE Transactions(
	SessionID VARCHAR(50) NOT NULL PRIMARY KEY,
	UserID VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES UserInfo(UserID),
	CountryID TINYINT NULL FOREIGN KEY REFERENCES Country(CountryID),
	StartDateID VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES Calendar(DateID),
	StartDate DATE NOT NULL,
	StartTimestamp INT NOT NULL,
	EndTimestamp INT NOT NULL,
	CashSpend FLOAT NULL,
	CountImpression TINYINT NULL,
	eCPM FLOAT NULL,
	OS VARCHAR(50) NULL,
	OsVersion VARCHAR(50) NULL
);


CREATE TABLE DIM_USER
(
USERID VARCHAR(50) NOT NULL PRIMARY KEY,
USERNAME VARCHAR(50) NOT NULL,
EMAIL VARCHAR(50),
AGE TINYINT,
GENDER VARCHAR(50)
)

CREATE TABLE DIM_MEMBERSHIP
(
MEMBERSHIPID TINYINT NOT NULL PRIMARY KEY,
MEMBERSHIP VARCHAR(50) NOT NULL,
COST FLOAT NOT NULL
)

CREATE TABLE DIM_COUNTRY
(
COUNTRYID TINYINT NOT NULL PRIMARY KEY,
COUNTRYNAME VARCHAR(50)
)

CREATE TABLE DIM_CALENDAR
(
DATEID VARCHAR(50) NOT NULL PRIMARY KEY,
DATE DATE NOT NULL,
DAY TINYINT NOT NULL,
MONTH TINYINT NOT NULL,
YEAR TINYINT NOT NULL
)

CREATE TABLE FACT_TRANSACTIONS
(
USERID VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES DIM_USER(USERID),
COUNTRYID TINYINT NOT NULL FOREIGN KEY REFERENCES DIM_COUNTRY(COUNTRYID),
STARTDATEID VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES DIM_CALENDAR(DATEID),
STARTDATE DATE NOT NULL,
REGISTEREDDATEID VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES DIM_CALENDAR(DATEID),
REGISTERDATE DATE NOT NULL,
PLAYINGDURATION INT NOT NULL,
MEMBERSHIPID TINYINT NOT NULL FOREIGN KEY REFERENCES DIM_MEMBERSHIP(MEMBERSHIPID),
MEMBERSHIPCOST FLOAT,
CASHSPEND FLOAT,
COUNTIMPRESSION TINYINT,
UNITCPM FLOAT,
ERNEDFROMAD FLOAT,
TOTALINCOME FLOAT
)
-- Create Trigger

-- Set up stage and Snowpipe
CREATE FILE FORMAT PIPE_DELIM
TYPE = CSV
FIELD_DELIMITER = '|'
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
SKIP_HEADER = 1
DATE_FORMAT = 'YYYY-MM-DD';
--- Creat stage to store files
CREATE STAGE PROJECT_STAGE
FILE_FORMAT = PIPE_DELIM;

--- Create pipe to load data from stage to tables
CREATE PIPE CALENDAR_PIPE AS COPY INTO CALENDAR FROM @PROJECT_STAGE/UPLOAD/CalendarSnowflake.csv.gz;
CREATE PIPE COUNTRY_PIPE AS COPY INTO COUNTRY FROM @PROJECT_STAGE/UPLOAD/CountrySnowflake.csv.gz;
CREATE PIPE MEMBERSHIP_PIPE AS COPY INTO MEMBERSHIP FROM @PROJECT_STAGE/UPLOAD/MembershipSnowflake.csv.gz;
CREATE PIPE USER_PIPE AS COPY INTO USERINFO FROM @PROJECT_STAGE/UPLOAD/UserInfoSnowflake.csv.gz;
CREATE PIPE TRANSACTIONS_PIPE AS COPY INTO TRANSACTIONS FROM @PROJECT_STAGE/UPLOAD/TransactionsSnowflake.csv.gz;

--- Unload data from stage
COPY INTO @PROJECT_STAGE/UNLOAD/ FROM DIM_USER;
COPY INTO @PROJECT_STAGE/UNLOAD/ FROM FACT_TRANSACTIONS;

---- Get data from stage to local
GET @PROJECT_STAGE/UNLOAD/<file name> file://C:\Users\HUYNGUYEN\gaming-project\resources\work-folder;
-- Task
USE DATABASE GAMINGGROUP6;
CREATE TASK update_users_list
    WAREHOUSE = GAMING_WH
	SCHEDULE = '60 MINUTE'
    COMMENT = 'Update the lastest user list from UserInfo'
AS
INSERT OVERWRITE INTO DIM_USER(USERID, USERNAME, EMAIL, AGE, GENDER)
SELECT DISTINCT USERID, USERNAME, EMAIL, AGE, GENDER FROM USERINFO;

CREATE TASK update_transaction_list
	WAREHOUSE = GAMING_WH
	AFTER update_users_list
	COMMENT = 'Add into FACT_TRANSACTIONS from TRANSACTIONS table after UserInfo table is updated.'
AS 
INSERT INTO FACT_TRANSACTIONS(USERID, COUNTRYID, STARTDATEID, STARTDATE, REGISTEREDDATEID,
                              REGISTERDATE, PLAYINGDURATION, MEMBERSHIPID, MEMBERSHIPCOST, CASHSPEND,
                              COUNTIMPRESSION, UNITCPM, ERNEDFROMAD, TOTALINCOME)
SELECT * FROM V_FACT;

GRANT EXECUTE TASK ON ACCOUNT TO ROLE DE_ROLE;


