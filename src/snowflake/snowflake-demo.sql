CREATE DATABASE demo-project;
GO
USE demo-project;
GO
CREATE TABLE USER_TRANSACTION 
(
    Date_Event DATE ,
    User_ID INT NOT NULL,
    Start_Timestamp INT NOT NULL,
    End_Timestamp INT NOT NULL,
    Cash_spend INT NOT NULL,
    OS STRING NOT NULL,
    OS_Version INT NOT NULL,
    Number_Of_Impression INT NOT NULL
);

CREATE TABLE DIM_DATE
(
    DATE_COL DATE NOT NULL,
    YEAR INT NOT NULL,
    MONTH INT NOT NULL,
    QUARTER INT NOT NULL
);

CREATE TABLE CUSTOMER
(
    User_ID INT NOT NULL,
    User_Name VARCHAR(50) NOT NULL,
    Buying_Method VARCHAR(50) NOT NULL,
    Register_Date DATE NOT NULL,
    Country_Code INT NOT NULL,
    Is_Active BOOLEAN NOT NULL
);
-- Create Stage and put files
CREATE OR REPLACE STAGE project_stage
file_format = (type = 'CSV' field_delimiter = ',' skip_header=1);

put file://c:\Users\HUYNGUYEN\python-snowflake\work-folder\user.csv @project_stage;
put file://c:\Users\HUYNGUYEN\python-snowflake\work-folder\user_transaction.csv @project_stage;
put file://c:\Users\HUYNGUYEN\python-snowflake\work-folder\date.csv @project_stage;
put file://c:\Users\HUYNGUYEN\python-snowflake\work-folder\eCPM-by-Country-Continent.csv @project_stage;

-- Copy data from stage into table
copy into <table name> 
from @project_stage/<csv file>

-- Create a Pipe
create pipe mydb.myschema.mypipe if not exists as copy into mydb.myschema.mytable from @mydb.myschema.mystage;


-- Configure Security
-- Create a role to contain the Snowpipe privileges
use role securityadmin;

create or replace role snowpipe1;

-- Grant the required privileges on the database objects
grant usage on database mydb to role snowpipe1;

grant usage on schema mydb.myschema to role snowpipe1;

grant insert, select on mydb.myschema.mytable to role snowpipe1;

grant usage, read on stage mydb.myschema.mystage to role snowpipe1;

-- Grant the OWNERSHIP privilege on the pipe object
grant ownership on pipe mydb.myschema.mypipe to role snowpipe1;

-- Grant the role to a user
grant role snowpipe1 to user jsmith;

-- Set the role as the default role for the user
alter user jsmith set default_role = snowpipe1;