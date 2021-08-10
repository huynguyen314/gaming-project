#!/usr/bin/env python
import snowflake.connector

# Gets the version
def snowflake_connect():
    ctx = snowflake.connector.connect(
        user='thanhhuy',
        password='passWord123',
        account='iz02671.ap-southeast-1', # kl71581.ap-southeast-1
        warehouse='COMPUTE_WH',
        database='SF_TESTDB',
        schema='public'
        )
    # cs = ctx.cursor()
    # try:
    #     cs.execute("put file://C:\\Users\\HUYNGUYEN\\user.csv @demo_stage")
    #     cs.commit()

    #     # one_row = cs.fetchone()
    #     # print(one_row[0])
    # finally:
    #     cs.close()
    # ctx.close()
    cursor_list = ctx.execute_string(
        "put file://C:\\Users\\HUYNGUYEN\\user.csv @demo_stage;"
        "COPY INTO USERINFO FROM @demo_stage/user.csv.gz;"
        "SELECT * FROM USERINFO;"
    )
    for cursor in cursor_list:
        for row in cursor:
            print(row)

    return "Done"