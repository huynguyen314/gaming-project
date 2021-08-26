import csv
import os
import random
from datetime import datetime, date
from dateutil.relativedelta import relativedelta
from distutils.dir_util import copy_tree
from faker import Faker
 
## DATA PATH ##
os.makedirs('Working-Folder', exist_ok=True)
os.makedirs('Raw-Folder', exist_ok=True)
current_path = os.getcwd()
raw_path = current_path + r'\Raw-Folder'
work_path = current_path+r'\Working-Folder'
# VARIABLE DECLARATIONS
country_list = [[1, 'United States'], [2, 'Japan'], [3, 'Taiwan'], [4, 'Australia'],
                [5, 'South Korea'], [6, 'Hong Kong'], [7, 'United Kingdom'], [8, 'Canada'], 
                [9, 'New Zealand'], [10, 'Norway'], [11, 'Germany'], [12, 'China'],
                [13, 'Singapore'], [14, 'Switzerland'], [15, 'South Africa'], [16, 'Denmark'], 
                [17, 'Sweden'], [18, 'France'], [19, 'United Arab Emirates'], [20, 'Ireland']] #20 id 
game_category = ['Action games', 'Action-adventure games', 'Adventure games',
                'Role-playing games', 'Simulation games', 'Strategy games',
                'Sports games', 'Puzzle games', 'Idle games'] #9 id
game_platform = ['SmartPhone/Tablet', 'PC', 'PlayStation', 'Xbox', 'Nitendo Switch']
game_paymethod = ['Free', 'Purchase']
record_count = 8000
fake = Faker('en')
time_stamp = datetime.now().strftime("%Y_%m_%d-%I_%M_%S_%p")
 
def createRawData(RECORD_COUNT):
    with open(f'{raw_path}\RawData.csv', 'w', newline='') as csvfile:
        fieldnames = ['RecordID', 'DateOfRecord', 'UserID', 'FullName', 'Age', 'Gender', 'EmailAddress', 
                      'Income', 'MarritalStatus', 'CountryID', 'CountryName', 'Region','ZipCode', 
                      'RegisteredDate', 'LastOnline', 'GameID', 'GameName', 'GamePlatForm', 
                      'GameCategories', 'ReleaseDate', 'PaymentType', 'IncomeByAds', 'IncomeByPurchase', 
                      'IncomeBoughtIngameItems', 'ModifiedDate']
        start_release_date = date(year=2015, month=1, day=1)
        start_record_date = date(year=2017, month=1, day=1)
        end_record_date = date(year=2020, month=12, day=31)
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        ##loop
        for i in range(RECORD_COUNT):
            tmp_age = fake.random_int(5,60)
            #condition for parentalStatus
            if tmp_age >=18:
                tmp_income = fake.random_int(10000,200000,5000)
                tmp_parent = fake.random_element(elements=['Married', 'Single'])
            else:
                tmp_parent = 'Single'
                tmp_income = fake.random_int(1000,12000,500)
            tmp_record_date = fake.date_between(start_date=start_record_date, end_date=end_record_date)
            tmp_released_date = fake.date_between(start_date=start_release_date, end_date=tmp_record_date - relativedelta(months=20))
            tmp_registered_date = fake.date_between(start_date=tmp_released_date, end_date=tmp_record_date - relativedelta(months=5))
            tmp_lastonline_date = fake.date_between(start_date=tmp_record_date - relativedelta(months=6), end_date=tmp_record_date - relativedelta(months=1))
            tmp_country = fake.random_element(elements=country_list)
            # assign region to country
            if tmp_country[0] in [2, 3, 5, 6, 12, 13, 19]:
                tmp_region = 'Asia'
            elif tmp_country[0] == 1:
                tmp_region = 'North America'
            elif tmp_country[0] == 4:
                tmp_region = 'Australia'
            else:
                tmp_region = 'Europe'
            tmp_payment = fake.random_element(elements=game_paymethod)
            if tmp_payment == 'Free': 
                tmp_payads = round(random.uniform(10,500),2) # max/min income: 500/100
                tmp_paypurchase = 0.00
            else:
                tmp_payads = 0.00
                tmp_paypurchase = round(random.uniform(100,1000),2) # max/min income: 1000/100
            writer.writerow(
                {
                    'RecordID': fake.random_int(1,92123),
                    'DateOfRecord': tmp_record_date,
                    'UserID': fake.random_int(1,17013),
                    'FullName': fake.name(),
                    'Age': tmp_age,
                    'Gender': fake.random_element(elements=['Male', 'Female']),
                    'EmailAddress': fake.free_email(),
                    'Income': tmp_income,
                    'MarritalStatus': tmp_parent,
                    'CountryID': tmp_country[0],
                    'CountryName': tmp_country[1],
                    'Region': tmp_region,
                    'ZipCode': fake.zipcode(),
                    'RegisteredDate': tmp_registered_date,
                    'LastOnline': tmp_lastonline_date,
                    'GameID': fake.random_int(1,17013),
                    'GameName': fake.bothify(text=fake.company()+' ???_####'),
                    'GamePlatForm': fake.random_element(elements=game_platform),
                    'GameCategories': fake.random_element(elements=game_category),
                    'ReleaseDate': tmp_released_date,
                    'PaymentType': tmp_payment,
                    'IncomeByAds': tmp_payads,
                    'IncomeByPurchase': tmp_paypurchase,
                    'IncomeBoughtIngameItems': round(random.uniform(10,5000),2),
                    'ModifiedDate': time_stamp
                }
            )
    return 
 
if __name__ == '__main__':
    t1 = datetime.now()
    print('Creating data...')
    createRawData(record_count)
    print('Done Generating Data...')
    print('Copy Data to Working Folder')
    copy_tree('./Raw-folder', './Working-folder')
    t2 = datetime.now()
    print(f"Done in time {t2-t1}")