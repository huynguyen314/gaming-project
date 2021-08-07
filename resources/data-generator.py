import csv
import os
import random
from datetime import datetime, timezone, date
from decimal import Decimal
from faker import Faker
from reference import COUNTRIES, BEGIN_TIMESTAMP

NOW_TIME = round(datetime.now().timestamp())
fake = Faker()

dir_path = os.path.dirname(os.path.abspath(__file__))
time_stamp = datetime.now().strftime("%Y_%m_%d-%I_%M_%S_%p")
def create_csv_file_user_transaction():
    with open(f'{dir_path}\\raw-folder\\user-transaction-{time_stamp}.csv', 'w', newline='') as csvfile:
        fieldnames = ['Date','User_ID','Start_Timestamp','End_Timestamp','Cash spend', 'OS','OS_Version', 'Number_Of_Impression']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        RECORD_COUNT = 10000
        writer.writeheader()
        for _ in range(RECORD_COUNT):
            start_timestamp = random.randint(BEGIN_TIMESTAMP, NOW_TIME)
            os_name = random.choice(['Android', 'iOS'])
            os_version = random.randint(8, 12) if os_name =='Android' else random.randint(10, 12)
            writer.writerow(
                {
                    'Date': date.fromtimestamp(start_timestamp),
                    'User_ID': random.randint(1,RECORD_COUNT),
                    'Start_Timestamp': start_timestamp,
                    'End_Timestamp': start_timestamp + random.randint(300, 3600),
                    'Cash spend': random.randint(1,20),
                    'OS': os_name,
                    'OS_Version': os_version,
                    'Number_Of_Impression': random.randint(1,6)
                }
            )
def create_csv_file_date():
     with open(f'{dir_path}\\work-folder\\date-{time_stamp}.csv', 'w', newline='') as csvfile:
        fieldnames = ['Date','Year','Month', 'Quarter']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        start_date = BEGIN_TIMESTAMP
        while start_date <= NOW_TIME:
            current_date = date.fromtimestamp(start_date)
            year, month = current_date.year, current_date.month
            if month in (1, 2, 3):
                quarter = 1
            elif month in (4, 5, 6):
                quarter = 2
            elif month in (7, 8, 9):
                quarter = 3
            else:
                quarter = 4 
            writer.writerow(
                {
                    'Date': current_date,
                    'Year': year,
                    'Month': month,
                    'Quarter': quarter
                }
            )
            start_date += 86400

if __name__ == '__main__':
    print('Creating a fake data...')
    create_csv_file_user_transaction()
    create_csv_file_date()