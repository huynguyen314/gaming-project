
-- Create Table
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
	Cost MONEY NOT NULL
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

CREATE TABLE Transactions
(
	SessionID VARCHAR(50) NOT NULL PRIMARY KEY,
	UserID VARCHAR(50) FOREIGN KEY REFERENCES UserInfo(UserID),
	CountryID TINYINT FOREIGN KEY REFERENCES Country(CountryID),
	StartDateID VARCHAR(50) NOT NULL,
	StartDate DATE NOT NULL,
	StartTimestamp INT NOT NULL,
	EndTimestamp INT NOT NULL,
	CashSpend MONEY NOT NULL,
	CountImpression TINYINT NULL,
	eCPM MONEY NULL,
	OS VARCHAR(50) NULL,
	OsVersion VARCHAR(50) NULL
)

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
    DateID          = CONVERT(date, d),
	TheDate         = CONVERT(date, d),
    TheDay          = CONVERT(TINYINT, DATEPART(DAY,       d)),
    TheMonth        = CONVERT(TINYINT, DATEPART(MONTH,     d)),
    TheYear         = CONVERT(INT, DATEPART(YEAR,      d))
  FROM d
)
INSERT INTO Calendar(DateID, Date, Day, Month, Year)
SELECT FORMAT (DateID, 'yyyyMMdd') as DateID, TheDate, TheDay,
TheMonth, TheYear FROM src
  ORDER BY TheDate
  OPTION (MAXRECURSION 0);
-- Create Agent Job / Schedule

-- Create Stored Procedure
