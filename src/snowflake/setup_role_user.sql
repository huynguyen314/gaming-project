CREATE OR REPLACE ROLE TRAINER_ROLE;

GRANT ALL ON WAREHOUSE FA_PROJECT02_CLOUDDW to TRAINER_ROLE;
GRANT ALL ON DATABASE FA_PROJECT02_DB TO ROLE TRAINER_ROLE;
GRANT ALL ON ALL SCHEMAS IN DATABASE FA_PROJECT02_DB TO ROLE TRAINER_ROLE;
GRANT ALL ON TABLE FA_PROJECT02_DB.GAMEBI.DIM_COUNTRY TO ROLE TRAINER_ROLE;
GRANT ALL ON TABLE FA_PROJECT02_DB.GAMEBI.DIM_DATE TO ROLE TRAINER_ROLE;
GRANT ALL ON TABLE FA_PROJECT02_DB.GAMEBI.DIM_USER TO ROLE TRAINER_ROLE;
GRANT ALL ON TABLE FA_PROJECT02_DB.GAMEBI.DIM_USER TO ROLE TRAINER_ROLE;
GRANT ALL ON TABLE FA_PROJECT02_DB.GAMEBI.FACT_TRANSACTIONS TO ROLE TRAINER_ROLE;

CREATE OR REPLACE USER LongBV1
PASSWORD = 'Trainers123'
DEFAULT_ROLE = 'TRAINER_ROLE'
DEFAULT_WAREHOUSE = 'FA_PROJECT02_CLOUDDW';
GRANT ROLE TRAINER_ROLE TO USER LongBV1;

CREATE OR REPLACE USER MaiNQ2
PASSWORD = 'Trainers123'
DEFAULT_ROLE = 'TRAINER_ROLE'
DEFAULT_WAREHOUSE = 'FA_PROJECT02_CLOUDDW';
GRANT ROLE TRAINER_ROLE TO USER MaiNQ2;
