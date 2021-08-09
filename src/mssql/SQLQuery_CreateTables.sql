USE GamingGroup6
GO


-- Alter table CPM
)
ALTER TABLE CPM
ADD Modified_Date DATETIME 
CONSTRAINT D_PriceCPM_ModifiedDate
DEFAULT GETDATE()
WITH VALUES

ALTER TABLE CPM
ADD CONSTRAINT FK_CPM FOREIGN KEY (CountryID) REFERENCES Country(CountryID)

-- Alter table Country

ALTER TABLE Country
ADD Modified_Date DATETIME 
CONSTRAINT D_Country_ModifiedDate
DEFAULT GETDATE()
WITH VALUES


ALTER TABLE Country
ALTER COLUMN CountryID TINYINT NOT NULL
ALTER TABLE Country
ALTER COLUMN CountryName VARCHAR(50) NOT NULL
ALTER TABLE Country
ADD CONSTRAINT PK_Country PRIMARY KEY (CountryID)


-- Alter table User

ALTER TABLE Users
ADD Modified_Date DATETIME NOT NULL
CONSTRAINT D_User_ModifiedDate
DEFAULT GETDATE()
WITH VALUES

ALTER TABLE Users
ALTER COLUMN UserID INT NOT NULL
ALTER TABLE Users
ALTER COLUMN UserName VARCHAR(50) NOT NULL
ALTER TABLE Users
ALTER COLUMN Register_Date DATETIME NOT NULL
ALTER TABLE Users
ALTER COLUMN Country_Code TINYINT NOT NULL
ALTER TABLE Users
ALTER COLUMN Download_Method VARCHAR(50) NOT NULL

ALTER TABLE Users
ADD CONSTRAINT PK_Users PRIMARY KEY (UserID)
ALTER TABLE Users
ADD CONSTRAINT FK_Country_Code FOREIGN KEY (Country_Code) REFERENCES Country(CountryID)

-- Alter Table Transaction

ALTER TABLE Transactions
ADD Modified_Date DATETIME 
CONSTRAINT D_Transaction_ModifiedDate
DEFAULT GETDATE()
WITH VALUES

ALTER TABLE Transactions
ALTER COLUMN TransactionDate DATETIME NOT NULL
ALTER TABLE Transactions
ALTER COLUMN UserID INT NOT NULL
ALTER TABLE Transactions
ALTER COLUMN Start_Timestamp NUMERIC(20,0) NOT NULL
ALTER TABLE Transactions
ALTER COLUMN End_Timestamp NUMERIC(20,0) NOT NULL

ALTER TABLE Transactions
ADD CONSTRAINT PK_Transation PRIMARY KEY (Start_Timestamp, End_Timestamp)
ALTER TABLE Transactions
ADD CONSTRAINT FK_UserID FOREIGN KEY (UserID) REFERENCES Users(UserID)







-- Create Country Audit Table
CREATE TABLE Country_Audit 
(
  CountryAuditID INT IDENTITY(1,1) NOT NULL,
  CountryID TINYINT NULL,
  CountryName VARCHAR(50) NULL,
  Continent VARCHAR(50) NULL,
  Operation VARCHAR(10) NOT NULL,
  UserName VARCHAR(100) NOT NULL,
  SystemName VARCHAR(100) NOT NULL,
  UpdatedOn datetime NOT NULL,
  CONSTRAINT PK_CountryAudit PRIMARY KEY CLUSTERED
(
  CountryAuditID ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, 
  ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]  
GO

-- Creat CPM Audit Table

CREATE TABLE CPM_Audit 
(
  CPMAuditID INT IDENTITY(1,1) NOT NULL,
  CountryID TINYINT NULL,
  Operation VARCHAR(10) NOT NULL,
  UserName VARCHAR(100) NOT NULL,
  SystemName VARCHAR(100) NOT NULL,
  UpdatedOn datetime NOT NULL,
  CONSTRAINT PK_CPMAudit PRIMARY KEY CLUSTERED
(
  CPMAuditID ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, 
  ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]  
GO


-- Creat CPM User Table
CREATE TABLE User_Audit 
(
  UserAuditID INT IDENTITY(1,1) NOT NULL,
  UserID TINYINT NULL,
  UserName VARCHAR(50) NULL,
  Operation VARCHAR(10) NOT NULL,
  SystemName VARCHAR(100) NOT NULL,
  UpdatedOn datetime NOT NULL,
  CONSTRAINT PK_UserAudit PRIMARY KEY CLUSTERED
(
  UserAuditID ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, 
  ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]  
GO
