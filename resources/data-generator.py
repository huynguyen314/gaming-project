import csv
import os
import random
import time
from datetime import datetime, timezone, date
from faker import Faker

# Set up reference
COUNTRIES = ['United States', 'Japan', 'Taiwan', 'Australia', 'South Korea',
             'Hong Kong', 'United Kingdom', 'Canada', 'New Zealand', 'Norway',
             'Germany', 'China', 'Singapore', 'Switzerland', 'South Africa',
             'Denmark', 'Sweden', 'France', 'United Arab Emirates', 'Ireland'
]

eCPM = {country : 5 + round(10*random.random(), 2) for country in COUNTRIES}
BEGIN_TIMESTAMP = 1609459200 # January 1, 2021 12:00:00 AM
NOW_TIME = round(datetime.now().timestamp())
RECORD_COUNT = 1000
OLD_USERS = int(0.3*RECORD_COUNT)
fake = Faker()

dir_path = os.path.dirname(os.path.abspath(__file__))
time_stamp = datetime.now().strftime("%Y_%m_%d-%I_%M_%S_%p")

# Set up file path
old_user_path = f'{dir_path}\\work-folder\\OldUserInfo.csv'
user_table_path = f'{dir_path}\\work-folder\\UserInfo.csv'
user_transaction_path = f'{dir_path}\\work-folder\\Transactions.csv'
country_path = f'{dir_path}\\work-folder\\Country.csv'
membership_path = f'{dir_path}\\work-folder\\Membership.csv'
transaction_table_path = f'{dir_path}\\raw-folder\\DataFromUsers{time_stamp}.csv'
user_snowflake = f'{dir_path}\\data-snowflake\\UserInfoSnowflake.csv'
user_transaction_snowflake = f'{dir_path}\\data-snowflake\\TransactionsSnowflake.csv'
country_snowflake = f'{dir_path}\\data-snowflake\\CountrySnowflake.csv'
membership_snowflake= f'{dir_path}\\data-snowflake\\MembershipSnowflake.csv'
calendar_snowflake = f'{dir_path}\\data-snowflake\\CalendarSnowflake.csv'

def find_countryID(CountryName):
    for i in range(len(COUNTRIES)):
        if CountryName == COUNTRIES[i]:
            return i+1

def create_old_user_data(old_users):
    # Create old user transaction
    if not os.path.isfile(old_user_path):
        with open(old_user_path, 'w', newline='') as oldUserFile:
            fieldnames = ['UserID','UserName', 'RegisterTimestamp', 'RegisteredDateID', 'RegisterDate','CountryName',
                        'Membership', 'Email', 'Age', 'Gender']
            writer = csv.DictWriter(oldUserFile, fieldnames=fieldnames)
            writer.writeheader()
    else:
        with open(old_user_path, 'r') as oldUserFile:
            fieldnames = ['UserID','UserName', 'RegisterTimestamp', 'RegisteredDateID', 'RegisterDate','CountryName',
                        'Membership', 'Email', 'Age', 'Gender']
            reader = csv.DictReader(oldUserFile, fieldnames=fieldnames)
            header = reader.__next__()
            old_users_info = list(reader)
            for _ in range(old_users):
                old_user = random.choice(old_users_info)
                with open(transaction_table_path, 'a', newline='') as csvfile:
                    fieldnames = ['SessionID','UserID', 'UserName', 'CountryID','CountryName', 'Age', 'Email', 'Gender',
                                    'MembershipID', 'Membership', 'Cost','RegisterDate', 'RegisteredDateID',
                                    'StartDateID' , 'StartDate', 'StartTimestamp','EndTimestamp', 
                                    'CashSpend', 'CountImpression', 'eCPM','OS', 'OsVersion']
                    transaction_writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
                    register_timestamp = int(old_user['RegisterTimestamp'])
                    for j in range(random.randint(10, 50)):
                        start_timestamp = register_timestamp + random.randint(1, NOW_TIME - register_timestamp)
                        start_date = date.fromtimestamp(start_timestamp)
                        transaction_writer.writerow(
                            {
                                'SessionID': old_user['UserName'][:5] + str(random.random())[2:],
                                'UserID': old_user['UserID'],
                                'UserName': old_user['UserName'],
                                'CountryID': find_countryID(old_user['CountryName']),
                                'CountryName': old_user['CountryName'],
                                'Age': old_user['Age'],
                                'Email': old_user['Email'],
                                'Gender': old_user['Gender'],
                                'RegisterDate': old_user['RegisterDate'],
                                'RegisteredDateID': old_user['RegisteredDateID'],
                                'MembershipID': 1 if old_user['Membership'] == 'Basic' else 2,
                                'Membership': old_user['Membership'],
                                'Cost': 0 if old_user['Membership'] == 'Basic' else 4.99,
                                'StartDateID': start_date.strftime("%Y%m%d"),  
                                'StartDate': date.fromtimestamp(start_timestamp),
                                'StartTimestamp': start_timestamp,
                                'EndTimestamp': start_timestamp + random.randint(300, 4800),
                                'CashSpend': random.choice([0, round(3 * random.random(), 2)]),
                                'CountImpression': 0 if old_user['Membership'] == 'Professional' else random.randint(3, 10),
                                'eCPM': eCPM[old_user['CountryName']],
                                'OS': random.choice(['Android', 'iOS']),
                                'OsVersion': random.choice([10, 11, 12])
                            }
                        )


def create_new_user_data(record_count):
    # Create user data
    for i in range(1000*NOW_TIME, 1000*NOW_TIME + record_count):
        user = fake.user_name()
        userID = user[:5] + str(i)
        email = user + '@' + fake.free_email_domain()
        age = random.randint(12, 60)
        gender = random.choice(['Male', 'Female', 'Unknown'])
        register_timestamp = random.randint(BEGIN_TIMESTAMP, NOW_TIME)
        register_date = date.fromtimestamp(register_timestamp)
        register_dateID = register_date.strftime("%Y%m%d")
        countryID = random.randint(1, len(COUNTRIES))
        country = COUNTRIES[countryID-1]
        membershipID = random.randint(1, 2)
        membership = ['Basic', 'Professional'][membershipID-1]
        os_name = random.choice(['Android', 'iOS'])
        os_version = random.randint(8, 12) if os_name =='Android' else random.randint(10, 12)

        with open(old_user_path, 'a', newline='') as oldUserFile:
            fieldnames = ['UserID','UserName', 'RegisterTimestamp', 'RegisteredDateID', 'RegisterDate','CountryName',
                        'Membership', 'Email', 'Age', 'Gender']
            writer = csv.DictWriter(oldUserFile, fieldnames=fieldnames)
            writer.writerow(
                {
                    'UserID': userID,
                    'UserName': user,
                    'RegisterTimestamp': register_timestamp,
                    'RegisteredDateID': register_dateID,
                    'RegisterDate': register_date,
                    'CountryName': country,
                    'Membership': membership,
                    'Email': email,
                    'Age': age,
                    'Gender': gender
                }
            )

        # Create user transaction data
        with open(transaction_table_path, 'a', newline='') as csvfile:
            fieldnames = ['SessionID','UserID', 'UserName', 'CountryID','CountryName', 'Age', 'Email', 'Gender',
                            'MembershipID', 'Membership', 'Cost','RegisterDate', 'RegisteredDateID',
                            'StartDateID' , 'StartDate', 'StartTimestamp','EndTimestamp', 
                             'CashSpend', 'CountImpression', 'eCPM','OS', 'OsVersion']
            transaction_writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            for j in range(random.randint(10, 100)):
                start_timestamp = register_timestamp + random.randint(1, NOW_TIME - register_timestamp)
                start_date = date.fromtimestamp(start_timestamp)
                if j == 0:
                    start_timestamp = register_timestamp
                    start_date = date.fromtimestamp(start_timestamp)
                transaction_writer.writerow(
                    {
                        'SessionID': user[:5] + str(random.random())[2:],
                        'UserID': userID,
                        'UserName': user,
                        'CountryID': countryID,
                        'CountryName': country,
                        'Age': age,
                        'Email': email,
                        'Gender': gender,
                        'RegisterDate': register_date,
                        'RegisteredDateID': register_dateID,
                        'MembershipID': membershipID,
                        'Membership': membership,
                        'Cost': 0 if membership == 'Basic' else 4.99,
                        'StartDateID': start_date.strftime("%Y%m%d"),  
                        'StartDate': date.fromtimestamp(start_timestamp),
                        'StartTimestamp': start_timestamp,
                        'EndTimestamp': start_timestamp + random.randint(300, 4800),
                        'CashSpend': random.choice([0, round(3 * random.random(), 2)]),
                        'CountImpression': 0 if membership == 'Professional' else random.randint(3, 10),
                        'eCPM': eCPM[country],
                        'OS': os_name,
                        'OsVersion': os_version
                    }
                )

def create_empty_table():
    with open(transaction_table_path, 'a', newline='') as csvfile:
                    fieldnames = ['SessionID','UserID', 'UserName', 'CountryID','CountryName', 'Age', 'Email', 'Gender',
                                    'MembershipID', 'Membership', 'Cost','RegisterDate', 'RegisteredDateID',
                                    'StartDateID' , 'StartDate', 'StartTimestamp','EndTimestamp', 
                                    'CashSpend', 'CountImpression', 'eCPM','OS', 'OsVersion']
                    transaction_writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
                    transaction_writer.writeheader()

    with open(user_table_path, 'w', newline='') as userfile:
        fieldnames = ['UserID','UserName','RegisteredDateID', 'RegisterDate','CountryName',
                      'Membership', 'Email', 'Age', 'Gender']
        writer = csv.DictWriter(userfile, fieldnames=fieldnames)
        writer.writeheader()

    with open(user_snowflake, 'w', newline='') as userfile:
        fieldnames = ['UserID','UserName','RegisteredDateID', 'RegisterDate','CountryName',
                      'MembershipID', 'Email', 'Age', 'Gender']
        writer = csv.DictWriter(userfile, fieldnames=fieldnames)
        writer.writeheader() 

    with open(country_path, 'w', newline='') as countryfile:
        fieldnames = ['CountryID', 'CountryName']
        writer = csv.DictWriter(countryfile, fieldnames=fieldnames)
        writer.writeheader()

    with open(country_snowflake, 'w', newline='') as countryfile:
        fieldnames = ['CountryID', 'CountryName']
        writer = csv.DictWriter(countryfile, fieldnames=fieldnames)
        writer.writeheader()

    with open(membership_path, 'w', newline='') as memberfile:
        fieldnames = ['MembershipID', 'Membership', 'Cost']
        writer = csv.DictWriter(memberfile, fieldnames=fieldnames)
        writer.writeheader()

    with open(membership_snowflake, 'w', newline='') as memberfile:
        fieldnames = ['MembershipID', 'Membership', 'Cost']
        writer = csv.DictWriter(memberfile, fieldnames=fieldnames)
        writer.writeheader()

    with open(user_transaction_path, 'w', newline='') as transactionfile:
        fieldnames = ['SessionID', 'UserID', 'CountryName', 'StartDateID', 'StartDate', 'StartTimestamp', 'EndTimestamp',
                      'CashSpend', 'CountImpression','eCPM','OS', 'OsVersion']
        writer = csv.DictWriter(transactionfile, fieldnames=fieldnames)
        writer.writeheader()

    with open(user_transaction_snowflake, 'w', newline='') as transactionfile:
        fieldnames = ['SessionID', 'UserID', 'CountryID', 'StartDateID', 'StartDate', 'StartTimestamp', 'EndTimestamp',
                      'CashSpend', 'CountImpression','eCPM','OS', 'OsVersion']
        writer = csv.DictWriter(transactionfile, fieldnames=fieldnames)
        writer.writeheader()

    with open(calendar_snowflake, 'w', newline='') as memberfile:
        fieldnames = ['DateID', 'Date', 'Day', 'Month', 'Year']
        writer = csv.DictWriter(memberfile, fieldnames=fieldnames)
        writer.writeheader()
    

if __name__ == '__main__':
    t1 = datetime.now()
    print('Creating data...')
    create_empty_table()
    create_old_user_data(OLD_USERS)
    create_new_user_data(RECORD_COUNT-OLD_USERS)
    t2 = datetime.now()
    print(f"Done in time {t2-t1}")