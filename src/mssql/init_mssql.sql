-- Set up Database


--- Create Country Audit Table

CREATE TABLE dbo.CountryAudit 
(
  CountryAuditID INT IDENTITY(1,1) NOT NULL,
  CountryID INT NULL,
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


---Create trigger after delete in dbo.country and audit in CountryAudit

USE [GamingGroup6]
GO

/****** Object:  Trigger [dbo].[D_TriggerCountry]    Script Date: 8/8/2021 1:06:17 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TRIGGER [dbo].[D_TriggerCountry] 
   ON  [dbo].[Country] 
   AFTER DELETE
AS
BEGIN
  
    DECLARE @CountryID INT

	SELECT @CountryID = CountryID FROM deleted

    INSERT INTO dbo.CountryAudit
           (CountryID, CountryName, Continent, Operation, UserName, SystemName, UpdatedOn)
  SELECT CountryID, CountryName, Continent, 'Deleted', SUSER_SNAME(), HOST_NAME(), GETDATE() 
  FROM  dbo.Country c WHERE CountryID = @CountryID 
  
END
GO

ALTER TABLE [dbo].[Country] ENABLE TRIGGER [D_TriggerCountry]
GO
-- set up Schema

-- Create Table

-- Create Agent Job / Schedule

-- Create Stored Procedure
