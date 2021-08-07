import pyodbc

server_name = 'HUYNGUYEN-PC'

conn = pyodbc.connect('Driver={SQL Server};'
                      'Server=HUYNGUYEN-PC;'
                      'Database=TestDB1;'
                      'Trusted_Connection=yes;')

cursor = conn.cursor()
# cursor.execute('CREATE DATABASE TestDB;')
cursor.execute('''

               CREATE TABLE People
               (
               Name nvarchar(50),
               Age int,
               City nvarchar(50)
               )

               ''')

conn.commit()