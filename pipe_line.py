import pandas as pd
import pyodbc 
import snowflake.connector
from datetime import datetimei

def create_csv_file_from_server():
    conn = pyodbc.connect('Driver={SQL Server};'
                        'Server=CVP00204888A;'
                        'Database=GamingGroup6;'
                        'Trusted_Connection=yes;')
    tables = ['User1', 'Transactions1']
    for table in tables:
        table_name = 'select * from GamingGroup6.dbo.' + table
        sql_query = pd.read_sql_query(table_name,conn) # here, the 'conn' is the variable that contains your database connection information from step 2

        df = pd.DataFrame(sql_query)
        df.to_csv (r'C:\Users\LinhTK9\{}.csv'.format(table), index = False) # place 'r' before the path name to avoid any errors in the path

def snowflake_connect():
    ctx = snowflake.connector.connect(
        user='thieukhanhlinh',
        password='29p154809S',
        account='iz02671.ap-southeast-1', # kl71581.ap-southeast-1
        warehouse='COMPUTE_WH',
        database='GAMINGGROUP6',
        schema='PUBLIC'
        )
   
    cursor_list = ctx.execute_string(
        "use role ACCOUNTADMIN;"
        "put file://C:\\Users\\LinhTK9\\*.csv @project_stage;"
        "COPY INTO USERS FROM @project_stage/User1.csv.gz;"
        "COPY INTO USER_TRANSACTION FROM @project_stage/Transactions1.csv.gz;"
        "LIST @project_stage;"
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
