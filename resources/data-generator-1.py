import csv
import os
import random
from datetime import datetime, timezone, timedelta
from decimal import Decimal
from faker import Faker, Factory
import random
import faker
import pandas as pd
 


fake = Faker()
Country = ['United States', 'Japan', 'Taiwan', 'Australia', 'South Korea',
             'Hong Kong', 'United Kingdom', 'Canada', 'New Zealand', 'Norway',
             'Germany', 'China', 'Singapore', 'Switzerland', 'South Africa',
             'Denmark', 'Sweden', 'France', 'United Arab Emirates', 'Ireland'
]

Begin_Timestamp = 1577836800 # January 1, 2020 12:00:00 AM
Now_Timestamp = round(datetime.now().timestamp())
Start_timestamp = random.randint(Begin_Timestamp, Now_Timestamp)

def create_csv_file_User():
    time_stampe = datetime.now().strftime("%Y_%m_%d-%I_%M_%S_%p")
    raw_path = os.path.dirname(__file__)
 
    User_ID=[]
    User_Name =[]
    Buying_Method = []
    Register_Date = []
    Country_Code= []
    Is_Active= []
    RECORD_COUNT = 1000
 
    for i in range(RECORD_COUNT):
        User_ID.append(str(i)),
        User_Name.append(str(fake.user_name())),
        Buying_Method.append(random.choice(['Purchased','Free'])),
        Register_Date.append(datetime.fromtimestamp(random.randint(Begin_Timestamp, Now_Timestamp))),
        Country_Code.append(random.choice(Country)),
        Is_Active.append(random.choice([True,False]))
 
    dict = {
        'User_ID': User_ID,
        'User_Name': User_Name,
        'Buying_Method': Buying_Method,
        'Register_Date': Register_Date,
        'Country_Code' : Country_Code,
        'Is_Active' : Is_Active
    }
    df = pd.DataFrame(dict)
    df.to_csv(f'{raw_path}\data-1-{time_stampe}.csv', index=None, header = True)    #lưu ý dấu ngoặc đơn

print('Creating a fake data...')
create_csv_file_User()