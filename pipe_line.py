import pandas as pd
import pyodbc 
import snowflake.connector
from datetime import datetime

def create_csv_file_from_server():
    conn = pyodbc.connect('Driver={SQL Server};'
                        'Server=HUYNGUYEN-PC;'
                        'Database=TestDB;'
                        'Trusted_Connection=yes;')
    tables = ['User', 'Country', 'Date', 'User_Transaction', 'eCPM']
    for table in tables:
        table_name = 'select * from TestDB.dbo.' + table
        sql_query = pd.read_sql_query(table_name,conn) # here, the 'conn' is the variable that contains your database connection information from step 2

        df = pd.DataFrame(sql_query)
        df.to_csv (f'C:\\Users\\HUYNGUYEN\\{table}.csv', index = False) # place 'r' before the path name to avoid any errors in the path

def snowflake_connect():
    ctx = snowflake.connector.connect(
        user='thanhhuy',
        password='passWord123',
        account='iz02671.ap-southeast-1', # kl71581.ap-southeast-1
        warehouse='COMPUTE_WH',
        database='SF_TESTDB',
        schema='public'
        )
   
    cursor_list = ctx.execute_string(
        "put file://C:\\Users\\HUYNGUYEN\\user.csv @demo_stage;"
        "COPY INTO USERINFO FROM @demo_stage/user.csv.gz;"
        "SELECT * FROM USERINFO;"
    )
    for cursor in cursor_list:
        for row in cursor:
            print(row)


if __name__ == '__main__':
    print('Loading data...')
    t1 = datetime.now()
    create_csv_file_from_server()
    print('Step 1')
    snowflake_connect()
    t2 = datetime.now()
    print(f"The time to load: {t2-t1}")
