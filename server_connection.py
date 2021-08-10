import pandas as pd
import pyodbc 

def create_csv_file_from_server():
    conn = pyodbc.connect('Driver={SQL Server};'
                        'Server=HUYNGUYEN-PC;'
                        'Database=TestDB;'
                        'Trusted_Connection=yes;')

    sql_query = pd.read_sql_query(''' 
                                select * from TestDB.dbo.UserInfo
                                '''
                                ,conn) # here, the 'conn' is the variable that contains your database connection information from step 2

    df = pd.DataFrame(sql_query)
    df.to_csv (r'C:\Users\HUYNGUYEN\user.csv', index = False) # place 'r' before the path name to avoid any errors in the path

    return "Step 1"
# create_csv_file_from_server()