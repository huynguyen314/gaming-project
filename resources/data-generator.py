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
def create_csv_file_user_transaction():
    time_stampe = datetime.now().strftime("%Y_%m_%d-%I_%M_%S_%p")
    with open(f'{dir_path}/raw-folder/user-transaction-{time_stampe}.csv', 'w', newline='') as csvfile:
        fieldnames = ['Date','User_ID','Start_Timestamp','End_Timestamp','Cash spend', 'OS','OS_Version', 'Number_Of_Impression']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        RECORD_COUNT = 10
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

if __name__ == '__main__':
    print('Creating a fake data...')
    create_csv_file_user_transaction()