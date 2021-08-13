# Decsription of this project

Gaming Project
Analyse user retention and income maximization of a mobile game which was launched on 1st Jan 2020 and available on Apps Store, Google play. Revenue of the game is based on 3 major source: downloading fees, ads display and cash spending on the game 
# Purpose

Building the data pipeline to solve the business problem

# Detail of Work

1. Generate 3 raw flat files related to the domain of project with Python: Transactions, Users and CPM (Cost Per Impresstion) by country

2. Store these files in Raw-folder and then move to Work-folder 

3. Design a data pipeline and illustrate the pipline with Drawio

4. Ingest data from flat file
Build a SSIS solution to do ETL and stage data in MSSQL
Deploy package into MSSQL
Create job in MSSQL

5. Load data onto Cloud
Load data from MSSQL up to Snowflake stage with SSIS
Pull into Data Warehouse 

6. Connect Snowfake to Power BI and visualize data

# How to setup
1. Login into MSSQL and run [init_mssql.sql](./src/mssql/init_mssql.sql)
2. Authen SnowSQL and run [init_snowflake.sql](./src/mssql/init_snowfalke.sql)
3. Generate data: `python data-generator.py`