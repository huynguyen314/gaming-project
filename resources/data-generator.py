import csv
import os
import random
from datetime import datetime, timezone, date
from faker import Faker

# Set up reference
COUNTRIES = ['United States', 'Japan', 'Taiwan', 'Australia', 'South Korea',
             'Hong Kong', 'United Kingdom', 'Canada', 'New Zealand', 'Norway',
             'Germany', 'China', 'Singapore', 'Switzerland', 'South Africa',
             'Denmark', 'Sweden', 'France', 'United Arab Emirates', 'Ireland'
]

BEGIN_TIMESTAMP = 1609459200 # January 1, 2021 12:00:00 AM
NOW_TIME = round(datetime.now().timestamp())
RECORD_COUNT = 5
fake = Faker()

dir_path = os.path.dirname(os.path.abspath(__file__))
time_stamp = datetime.now().strftime("%Y_%m_%d-%I_%M_%S_%p")

# Set up file path
user_table_path = f'{dir_path}\\work-folder\\table-user-{time_stamp}.csv'
transaction_table_path = f'{dir_path}\\work-folder\\table-user-transaction-{time_stamp}.csv'
eCPM_path = f'{dir_path}\\work-folder\\eCPM-{time_stamp}.csv'
membership_path = f'{dir_path}\\work-folder\\membership-{time_stamp}.csv'
date_path = f'{dir_path}\\work-folder\\date-{time_stamp}.csv'

def create_csv_user_data(record_count):
    # Create user data
    with open(user_table_path, 'w', newline='') as csvfile:
        field_names = ['UserID', 'UserName', 'Email', 'Age', 'Gender', 'MembershipID', 'LevelPlayer','RegisteredDate', 'RegisteredDateID', 'CountryID', 'CountryName']
        user_writer = csv.DictWriter(csvfile, fieldnames=field_names)
        user_writer.writeheader()
        for i in range(NOW_TIME, NOW_TIME + record_count):
            user = fake.user_name()
            register_timestamp = random.randint(BEGIN_TIMESTAMP, NOW_TIME)
            register_date = date.fromtimestamp(register_timestamp)
            country_id = random.randint(1, len(COUNTRIES))
            membership =  random.choice([1, 2])
            user_writer.writerow(
                {
                    'UserID': i,
                    'UserName': user,
                    'Email': fake.email(),
                    'Age': random.randint(12, 60),
                    'Gender': random.choice([0, 1]),
                    'MembershipID': membership,
                    'LevelPlayer': random.randint(1, 15),
                    'RegisteredDate': register_date,
                    'RegisteredDateID': int(register_date.strftime("%Y%m%d")),
                    'CountryID': country_id,
                    'CountryName': COUNTRIES[country_id-1]
                }
            )

            # Create user transaction data
            with open(transaction_table_path, 'a', newline='') as csvfile:
                init_log_id = round(datetime.now().timestamp())
                field_names = ['LogID','UserID','CountryID','Date','StartDateID','StartTimestamp','EndTimestamp',  'CashSpend', 'NoImpression', 'OS', 'OS_Version']
                transaction_writer = csv.DictWriter(csvfile, fieldnames=field_names)
                if os.path.getsize(transaction_table_path) == 0:
                    transaction_writer.writeheader()
                for j in range(random.randint(10, 100)):
                    start_timestamp = register_timestamp + random.randint(0, NOW_TIME - register_timestamp)
                    start_date = date.fromtimestamp(start_timestamp)
                    os_name = random.choice(['Android', 'iOS'])
                    os_version = random.randint(8, 12) if os_name =='Android' else random.randint(10, 12)
                    transaction_writer.writerow(
                        {
                            'LogID': user + str(init_log_id + j),
                            'UserID': i,
                            'CountryID': country_id,
                            'Date': start_date,
                            'StartDateID': int(start_date.strftime("%Y%m%d")),
                            'StartTimestamp': start_timestamp,
                            'EndTimestamp': start_timestamp + random.randint(300, 4800),
                            'CashSpend': round(10 * random.random(), 2),
                            'NoImpression': 0 if membership == 2 else random.randint(3, 10),
                            'OS': os_name,
                            'OS_Version': os_version
                        }
                    )


def create_eCPM_table():
    with open(eCPM_path, 'w', newline='') as csvfile:
        field_names = ['CountryID', 'eCPM']
        e_writer = csv.DictWriter(csvfile, fieldnames=field_names)
        e_writer.writeheader()
        for i in range(1, len(COUNTRIES)+1):
            e_writer.writerow(
                {
                    'CountryID': i,
                    'eCPM': round(5 + 10*random.random(), 2)
                }
            )


def create_membership_table():
    with open(membership_path, 'w', newline='') as csvfile:
        field_names = ['MembershipID', 'Level', 'Cost']
        writer = csv.DictWriter(csvfile, fieldnames=field_names)
        writer.writeheader()
        writer.writerow({'MembershipID': 1, 'Level': 'Basic', 'Cost': 0})
        writer.writerow({'MembershipID': 2, 'Level': 'Professional', 'Cost': 4.99})


def create_csv_file_date():
     with open(f'{dir_path}\\work-folder\\date-{time_stamp}.csv', 'w', newline='') as csvfile:
        fieldnames = ['DateID', 'Date','Year','Month', 'Quarter']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
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
                    'DateID': current_date.strftime("%Y%m%d"),   
                    'Date': current_date,
                    'Year': year,
                    'Month': month,
                    'Quarter': quarter
                }
            )
            start_date += 86400

if __name__ == '__main__':
    t1 = datetime.now()
    print('Creating data...')
    create_csv_user_data(RECORD_COUNT)
    create_eCPM_table()
    create_membership_table()
    create_csv_file_date()
    t2 = datetime.now()
    print(f"Done in time {t2-t1}")