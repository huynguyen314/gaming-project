		-- Set up Warehouse
		CREATE OR REPLACE WAREHOUSE FA_PROJECT02_STAGEDW WITH
			WAREHOUSE_SIZE = 'XSMALL' 
			WAREHOUSE_TYPE = 'STANDARD' 
			AUTO_SUSPEND = 300 
			AUTO_RESUME = TRUE;
	
		/******* CREATE DATABASE AND TABLE *******/
		-- Create Database
		CREATE OR REPLACE DATABASE FA_PROJECT02_STAGEDB;

		-- Create schema 
		CREATE OR REPLACE SCHEMA StageGameBI;

		-- Create Table

		CREATE OR REPLACE TABLE StageGameBI.CountryDetails
		(
			CountryID TINYINT NOT NULL PRIMARY KEY,
			CountryName VARCHAR(50) NULL,
			ZipCode INT NOT NULL,
			Region VARCHAR(50) NOT NULL, 
			ModifiedDate DATETIME NOT NULL
		);

		CREATE OR REPLACE TABLE StageGameBI.GameDetails
		(
			GameID INT NOT NULL PRIMARY KEY,
			GameName VARCHAR(50) NOT NULL,
			GamePlatform VARCHAR(50) NOT NULL,
			GameCategory VARCHAR(50) NOT NULL,
			ReleasedDate DATE NOT NULL,
			PaymentType VARCHAR(10) NOT NULL,
			ModifiedDate DATETIME NOT NULL
		);

		CREATE OR REPLACE TABLE StageGameBI.UserInfo
		(
			UserID INT NOT NULL PRIMARY KEY,
			UserName VARCHAR(50) NOT NULL,
			Age TINYINT NOT NULL,
			Gender VARCHAR(10) NOT NULL,
			EmailAddress VARCHAR(50) NULL,
			Income INT NOT NULL,
			MarritalStatus VARCHAR(10),
			ModifiedDate DATETIME NOT NULL
		);

		CREATE OR REPLACE TABLE StageGameBI.Transactions
		(
			SessionID INT NOT NULL,
			UserID INT NOT NULL,
			CountryID TINYINT NOT NULL,
			GameID INT NOT NULL,
			DateOfRecord DATE NOT NULL,
			RegisteredDate DATE NOT NULL,
			LastOnline DATE NOT NULL,
			IncomeByAds NUMBER NOT NULL,
			IncomeByPurchase NUMBER NOT NULL,
			IncomeBoughtIngameItems NUMBER NOT NULL,
			ModifiedDate DATETIME NOT NULL,
			CONSTRAINT PK_GameTransaction PRIMARY KEY (SessionID),
			CONSTRAINT FK_User FOREIGN KEY (UserID) REFERENCES StageGameBI.UserInfo(UserID),
			CONSTRAINT FK_Country FOREIGN KEY (CountryID) REFERENCES StageGameBI.CountryDetails(CountryID),
			CONSTRAINT FK_Game FOREIGN KEY (GameID) REFERENCES StageGameBI.GameDetails(GameID)
		);
		

		-- Set up Warehouse
		CREATE OR REPLACE WAREHOUSE FA_PROJECT02_CLOUDDW WITH
			WAREHOUSE_SIZE = 'XSMALL' 
			WAREHOUSE_TYPE = 'STANDARD' 
			AUTO_SUSPEND = 300 
			AUTO_RESUME = TRUE;
		/******* CREATE DATABASE AND TABLE *******/
		-- Create Database
		CREATE OR REPLACE DATABASE FA_PROJECT02_DB;

		-- Create schema 
		CREATE OR REPLACE SCHEMA GameBI;

		-- CREATE DIM/FACT TABLES

		CREATE OR REPLACE TABLE GameBI.Dim_Country
		(	CountryKey INT IDENTITY(1,1) PRIMARY KEY,
			CountryID TINYINT NOT NULL,
			CountryName VARCHAR(50) NULL,
			ZipCode INT NOT NULL,
			Region VARCHAR(50));

		CREATE OR REPLACE TABLE GameBI.Dim_Game
		(	GameKey INT IDENTITY(1,1) PRIMARY KEY,
			GameID INT NOT NULL,
			GameName VARCHAR(50) NOT NULL,
			GamePlatform VARCHAR(50) NOT NULL,
			GameCategory VARCHAR(50) NOT NULL,
			ReleasedDate DATE NOT NULL,
			PaymentType VARCHAR(10) NOT NULL
		);

		CREATE OR REPLACE TABLE GameBI.Dim_User
		(	UserKey INT IDENTITY(1,1) PRIMARY KEY,
			UserID INT NOT NULL,
			UserName VARCHAR(50) NOT NULL,
			Age TINYINT NOT NULL,
			Gender VARCHAR(10) NOT NULL,
			EmailAddress VARCHAR(50) NULL,
			Income INT NOT NULL,
			MarritalStatus VARCHAR(10)
		);

		CREATE OR REPLACE TABLE GameBI.Dim_Date (
		   DATEKEY        int NOT NULL
		   ,DATE          DATE        NOT NULL
		   ,DAYOFMONTH       SMALLINT    NOT NULL
		   ,WEEKDAYNAME    VARCHAR(10) NOT NULL
		   ,WEEK     SMALLINT    NOT NULL
		   ,DAYOFWEEK      VARCHAR(9)  NOT NULL
		   ,MONTH            SMALLINT    NOT NULL
		   ,MONTHNAME       CHAR(3)     NOT NULL
		   ,QUARTER          SMALLINT NOT NULL
		  ,YEAR             SMALLINT    NOT NULL,
		  CONSTRAINT PK_DateDim PRIMARY KEY (DATEKEY)
		)
		AS
		  WITH CTE_MY_DATE AS (
			SELECT DATEADD(DAY, SEQ4(), '2017-01-01') AS DATEKEY
			  FROM TABLE(GENERATOR(ROWCOUNT=>1461))  
		  )
		  SELECT TO_CHAR(DATE(DATEKEY),'YYYYMMDD'),
				 DATE(DATEKEY)
				 ,DAY(DATEKEY),
				 DECODE(DAYNAME(DATEKEY),
			'Mon','Monday','Tue','Tuesday',
			'Wed','Wednesday','Thu','Thursday',
			'Fri','Friday','Sat','Saturday',
				  'Sun','Sunday')
				 ,WEEKOFYEAR(DATEKEY)        
				 ,DAYOFWEEK(DATEKEY)
				 ,MONTH(DATEKEY)
				,MONTHNAME(DATEKEY),
				 QUARTER(DATEKEY)
				,YEAR(DATEKEY)
			FROM CTE_MY_DATE;		


		CREATE OR REPLACE TABLE GameBI.Fact_Transactions(
			DateKey INT NOT NULL,
			UserKey INT NOT NULL,
			CountryKey INT NOT NULL,
			GameKey INT NOT NULL,
			RegisteredDate DATE NOT NULL,
			IncomeByAds FLOAT NOT NULL,
			IncomeByPurchase FLOAT NOT NULL,
			IncomeBoughtIngameItems FLOAT NOT NULL,
			LastSeen FLOAT NOT NULL,
			CONSTRAINT PK_GameTransaction PRIMARY KEY (DateKey,UserKey,CountryKey,GameKey),
			CONSTRAINT FK_User FOREIGN KEY (UserKey) REFERENCES GameBI.Dim_User(UserKey),
			CONSTRAINT FK_Country FOREIGN KEY (CountryKey) REFERENCES GameBI.Dim_Country(CountryKey),
			CONSTRAINT FK_Game FOREIGN KEY (GameKey) REFERENCES GameBI.Dim_Game(GameKey),
			CONSTRAINT FK_Date FOREIGN KEY (DateKey) REFERENCES GameBI.Dim_Date(DateKey)
		);
		------ CREATE INDEXES TO IMPROVE QUERY PERFORMANCE
		ALTER TABLE Dim_User CLUSTER BY (UserKey);
		ALTER TABLE Dim_Game CLUSTER BY (GameKey);
		ALTER TABLE Dim_Country CLUSTER BY (CountryKey);
		ALTER TABLE Dim_Date CLUSTER BY (DateKey);
		ALTER TABLE Fact_Transactions CLUSTER BY (DateKey,UserKey,CountryKey,GameKey);

		---LOAD DATA STREAM
		CREATE OR REPLACE STREAM fact_transact_stream
		ON TABLE FA_PROJECT02_STAGEDB.StageGameBI.Transactions;

		---CREATE A STORED PROCEDURE

		CREATE OR REPLACE PROCEDURE load_data_sp()
		  returns string
		  language javascript
		  as     
		  $$  
		  var result;
		  var trunc_dimcountry = `TRUNCATE TABLE GameBI.Dim_Country;`;
		  var trunc_dimgame = `TRUNCATE TABLE GameBI.Dim_Game;`;
		  var trunc_dimuser = `TRUNCATE TABLE GameBI.Dim_User;`;
		  var trunc_facttransact= `TRUNCATE TABLE GameBI.Fact_Transactions;`;

		  var insert_dimcountry = `INSERT INTO FA_PROJECT02_DB.GameBI.Dim_Country(CountryID,CountryName,ZipCode, Region)
		  SELECT CountryID,CountryName,ZipCode, Region FROM FA_PROJECT02_STAGEDB.StageGameBI.CountryDetails;`;
		  var insert_dimgame = `INSERT INTO FA_PROJECT02_DB.GameBI.Dim_Game (GameID,GameName,GamePlatform,GameCategory, ReleasedDate,PaymentType) 
		  SELECT GameID,GameName,GamePlatform,GameCategory, ReleasedDate,PaymentType FROM FA_PROJECT02_STAGEDB.StageGameBI.GameDetails;`;
		  var insert_dimuser= ` INSERT INTO FA_PROJECT02_DB.GameBI.Dim_User(UserID,UserName,Age,Gender,EmailAddress,Income,MarritalStatus) 
		  SELECT UserID,UserName,Age,Gender,EmailAddress,Income,MarritalStatus FROM FA_PROJECT02_STAGEDB.StageGameBI.UserInfo;`;
		  var insert_facttransact = `INSERT INTO FA_PROJECT02_DB.GameBI.Fact_Transactions(DateKey,UserKey,CountryKey, GameKey,RegisteredDate,IncomeByAds, IncomeByPurchase, IncomeBoughtIngameItems,LastSeen) 
		  SELECT DimDate.DateKey, Users.UserKey, Country.CountryKey, Game.GameKey,Transact.RegisteredDate,Transact.IncomeByAds, Transact.IncomeByPurchase,Transact.IncomeBoughtIngameItems,
				(Transact.DateOfRecord-Transact.LastOnline) as LastSeen
			FROM fact_transact_stream AS Transact
			JOIN GameBI.Dim_Country AS Country ON (Transact.CountryID=Country.CountryID)
			JOIN GameBI.Dim_Game AS Game ON (Transact.GameID=Game.GameID)
			JOIN GameBI.Dim_User AS Users ON (Transact.UserID=Users.UserID)
			JOIN GameBI.Dim_Date AS DimDate ON (Transact.DateOfRecord=DimDate.date)
			WHERE transact.METADATA$ACTION = 'INSERT';`;

		 try {
			snowflake.execute({sqlText: trunc_dimcountry });        
			snowflake.execute({sqlText: trunc_dimgame });
			snowflake.execute({sqlText: trunc_dimuser });
			snowflake.execute({sqlText: trunc_facttransact });
			snowflake.execute({sqlText: insert_dimcountry });
			snowflake.execute({sqlText: insert_dimgame });
			snowflake.execute({sqlText: insert_dimuser });
			snowflake.execute({sqlText: insert_facttransact });
			result = "Succeeded"
		 }
		 catch(err) {
		 result = "Failed" + err;
		 }
		 return result;
		  $$
		;

		CREATE OR REPLACE TASK ETL_To_WH
		WAREHOUSE = FA_PROJECT02_STAGEDW
		SCHEDULE = '8 MINUTE'
		WHEN SYSTEM$STREAM_HAS_DATA('fact_transact_stream')
		AS
		call load_data_sp();
		ALTER TASK ETL_To_WH RESUME;




