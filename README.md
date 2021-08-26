# Decsription of this project

*Domain: Gaming*

Business problem: Analyse user retention and income maximization of a mobile game which was launched on 1st Jan 2021 and available on Apps Store, Google play. Revenue of the game is based on 3 major source: downloading fees, ads display and cash spending on the game.

# Purpose

Building the data pipeline to solve the business problem

# Detail of Work

1. Generate 1 raw flat file related to the domain of project with Python and stored in raw-folder, including: SessionID, UserID, UserName, Country, CountryID, CountryName, Age, Email, Gender, MembershipID, Membership, MembershipCost, RegisterDate, RegisteredDateID, StartDateID, StartDate, StartTimestamp, EndTimestamp, CashSpend, CountImpression, eCPM, OS, OsVersion

2. Create 4 .CSV files UserInfo, Membership, Country, Transactions from Raw flat file and stored in work-folder

3. Design a data pipeline and illustrate the pipeline with Drawio
![architectural-design-data-pipeline](https://user-images.githubusercontent.com/88389982/129834819-2fbc26f1-62fe-4361-b124-bdd1449995a6.jpg)

4. Ingest data from flat file

Create data stage in MSSQL
![database_model_in_mssql](https://user-images.githubusercontent.com/88389982/129836709-37cdc32f-3fe8-4bc1-96d3-81a3967c5c60.jpg)

Build a SSIS solution to do ETL into stage
![image](https://user-images.githubusercontent.com/88389982/129835460-4c3db8a5-0b38-43b4-b82b-c8870ca2a1f6.png)


5. Load data onto Snowflake cloud

Export data in MSSQL to .csv files and store in data-snowflake folder

Load .CSV files from data-snowflake folder up to Snowflake stage with SSIS using snowsql

6. Design dimensional model on Snowflake
![dimensional_model](https://user-images.githubusercontent.com/88389982/129836615-0f65da5d-a321-4250-be51-9b8617a8a1f3.jpg)

7. Store data in dimensional-model into stage and unload to work-folder in local computer

8. Connect Power BI to Snowflake and build proper dashboard
![image](https://user-images.githubusercontent.com/88389982/129837417-18a9b6ea-06ac-4d5a-952a-64ac64f7ceb7.png)

# How to setup
1. Login into MSSQL and run [init_mssql.sql](./src/mssql/init_mssql.sql)

2. Authentication SnowSQL Client

Install SnowSQL

Open .config file (C:/User/localname/.snowsql/config)

Name the connection [connection.example] as you want

Edit content (account name, username, password, warehouse, dbname, schemaname)

Run [init_snowflake.sql](./src/mssql/init_snowfalke.sql)

3. Generate data

Open CMD and run command:pip install -r requirements.txt(./resources/requirements.txt) to install package

Run [data-generator.py] (./resources/data-generator.py)

4. Run SSIS solution:

Reset all connections in connection managers to match your file paths and your database server

Open the last task *Data to Snowflake*, choose Process > Executable > click (...) to choose [snowPut.bat] (./src/ssis/snowPut.bat)

Open [ssisPut.sql] (./src/ssis/ssisPut.sql) and edit local csv file path  in (./gaming-project/resources/data-snowflake)

5. Open Power Bi and connect to Snowflake with your account


#GROUP 8: WORKING ON THE PROJECT FOR FURTHER IMPROVEMENTS 

1. Generating data work
Modify and clean code for flexible folder path

2. SSIS solution work

- Modify parameters, environment
- Create Scripting task
- Load 1 big csv into tables in SQL
- Add/update data flow
- Add Eventlog Table to event handler
- Run python script to connect directly from SQL to snowflake based on dataframe pandas, may take longer time than bulkload and no snowpipe needed
- Add stand-alone package sql script task to auto generate jobs/schedule/email/proxy

3. Snowflake work
- Create stream, stage, tasks, procedures
- Build new data model



4. PBI work
Schedule to update data
