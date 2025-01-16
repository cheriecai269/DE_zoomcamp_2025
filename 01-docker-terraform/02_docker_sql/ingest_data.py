#!/usr/bin/env python
# coding: utf-8


# Libraries
import argparse
import os
import pandas as pd
import warnings
import sqlalchemy 
from time import time
warnings.filterwarnings('ignore')


def main(params):
    # Parameters
    user = params.user
    password = params.password
    host = params.host
    port = params.port
    db = params.db
    table_name = params.table_name
    url = params.url 
    #url for 2025 cohort: https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-10.csv.gz
    

    # the backup files are gzipped, and it's important to keep the correct extension
    # for pandas to be able to open the file
    if url.endswith('.csv.gz'):
        csv_name = 'green_taxi_data_downloaded.csv.gz'
    else:
        csv_name = 'green_taxi_data_downloaded.csv'

    # Download csv using os and wget
    os.system(f'wget {url} -O {csv_name}')

    # Connect to Postgres
    engine = sqlalchemy.create_engine(f'postgresql://{user}:{password}@{host}:{port}/{db}')
    connection = engine.connect()
    print('connection is succssful')

    # User iterator to ingest data iteratively by a smaller chunksize

    df_iter = pd.read_csv(csv_name, iterator=True, chunksize=100000)
    df = next(df_iter)
    df['lpep_dropoff_datetime'] = pd.to_datetime(df.lpep_dropoff_datetime)
    df['lpep_pickup_datetime'] = pd.to_datetime(df.lpep_pickup_datetime)


    # Create a table with columns, do not want to insert anything yet
    df.head(n=0).to_sql(name='green_taxi_data', con=engine, if_exists='replace')
    print('successfully created table')

    # Load data in batches
    df_iter = pd.read_csv(csv_name, iterator=True, chunksize=100000)

    try:
      while True:
        start = time()
        df = next(df_iter)
        df['lpep_dropoff_datetime'] = pd.to_datetime(df.lpep_dropoff_datetime)
        df['lpep_pickup_datetime'] = pd.to_datetime(df.lpep_pickup_datetime)
        df.to_sql(name=table_name, con=engine, if_exists='append')
        end = time()
        print(f'Successfully inserted {len(df)} data for {end-start:.2f} seconds')
    except:
      print("No more data to insert")

    # Check data amount is correct
    csv_data = pd.read_csv('dataset/green_tripdata_2019-10.csv')
    sql_data = pd.read_sql_query(sqlalchemy.text('select count(*) from green_taxi_data'), connection)
    print(f'CSV data has {len(csv_data)} rows. SQL data has {sql_data.iloc[0,0]} rows')


if __name__ == '__main__':
    # Parse arguments
    parser = argparse.ArgumentParser(description='Ingest CSV data to Postgres')
    # We need user, password, host, port, database, table name
    parser.add_argument('--user', help='Postgres username')
    parser.add_argument('--password', help='Postgres password')
    parser.add_argument('--host', help='Postgres host')
    parser.add_argument('--port', help='Postgres port')
    parser.add_argument('--db', help='Postgres database name')
    parser.add_argument('--table_name', help='Postgres table name where we will write data to')
    parser.add_argument('--url', help='url to the CSV file')

    args = parser.parse_args()

    # Run main function
    main(args)






