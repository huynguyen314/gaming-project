#!/usr/bin/env python
import snowflake.connector

# Gets the version
ctx = snowflake.connector.connect(
    user='khanhlinh',
    password='Linhkhanh0408',
    account='kl71581.ap-southeast-1',
    warehouse='COMPUTE_WH',
    database='DEMO_PROJECT',
    schema='public'
    )
cs = ctx.cursor()
try:
    cs.execute("put file://c:\Users\HUYNGUYEN\python-snowflake\work-folder\eCPM-by-Country-Continent2.csv @project_stage;")
    #cs.execute("list @project_stage;")
    one_row = cs.fetchone()
    print(one_row[0])
finally:
    cs.close()
ctx.close()