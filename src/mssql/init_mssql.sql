
-- Create Table
CREATE TABLE Country
(
	CountryID INT IDENTITY(1,1) PRIMARY KEY,
	CountryName VARCHAR(50) NULL
);

CREATE TABLE Calendar
(
	DateID INT NOT NULL PRIMARY KEY,
	Date DATE NOT NULL,
	Day TINYINT NOT NULL,
	Month TINYINT NOT NULL,
	Year TINYINT NOT NULL
);

CREATE TABLE Membership
(
	MembershipID INT IDENTITY(1,1) PRIMARY KEY,
	MembershipName VARCHAR(50) NOT NULL,
	Cost MONEY NOT NULL
)


CREATE TABLE UserInfo
(
	UserID VARCHAR(50) NOT NULL PRIMARY KEY,
	UserName VARCHAR(50) NOT NULL,
	RegisterDateID INT FOREIGN KEY REFERENCES Calendar(DateID),
	RegisterDate DATE NOT NULL,
	CountryID INT FOREIGN KEY REFERENCES Country_eCPM(CountryID),
	CountryName VARCHAR(50) NULL,
	MembershipID INT FOREIGN KEY REFERENCES Membership(MembershipID),
	Email VARCHAR(50) NULL,
	Age TINYINT NULL,
	Gender VARCHAR(10) NULL
);

CREATE TABLE Transactions
(
	SessionID VARCHAR(70) NOT NULL PRIMARY KEY,
	UserID VARCHAR(50) FOREIGN KEY REFERENCES UserInfo(UserID),
	CountryID INT FOREIGN KEY REFERENCES Country(CountryID),
	StartDateID INT NOT NULL,
	SessionStartDate DATE NOT NULL,
	StartTimestamp INT NOT NULL,
	EndTimestamp INT NOT NULL,
	SestionCashSpend MONEY NOT NULL,
	eCPM MONEY NULL,
	CountImpression TINYINT NULL,
	OS VARCHAR(50) NULL,
	OsVersion TINYINT NULL
)
-- Create Agent Job / Schedule

-- Create Stored Procedure
