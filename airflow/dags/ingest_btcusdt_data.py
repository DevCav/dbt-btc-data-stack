from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.utils.dates import days_ago
import glob
import pandas as pd
import os
import tempfile

# Define your default arguments
default_args = {
    'owner': 'airflow',
    'start_date': days_ago(1),
    'retries': 1,
}

# Define the DAG
dag = DAG(
    'btcusdt_data_ingestion',
    default_args=default_args,
    description='Ingest BTCUSDT data into company_dw',
    schedule_interval=None,  # Set to None for manual trigger
)

def create_schema_if_not_exists():
    hook = PostgresHook(postgres_conn_id='company_dw')
    conn = hook.get_conn()
    cursor = conn.cursor()
    cursor.execute("CREATE SCHEMA IF NOT EXISTS raw;")
    conn.commit()
    cursor.close()
    conn.close()

def delete_existing_table(table_name):
    hook = PostgresHook(postgres_conn_id='company_dw')
    conn = hook.get_conn()
    cursor = conn.cursor()
    cursor.execute(f"DROP TABLE IF EXISTS raw.{table_name} CASCADE;")
    conn.commit()
    cursor.close()
    conn.close()

def split_csv(file_path):
    # Ensure the output directory exists
    os.makedirs('data/tmp', exist_ok=True)

    # Step 2: Split the sorted CSV into multiple smaller CSV files
    max_rows = 10000000
    file_prefix = 'data/tmp/split'

    # Read and process the CSV in chunks
    chunk_number = 1
    for chunk in pd.read_csv(file_path, chunksize=max_rows):
        # Clean column names
        chunk.columns = chunk.columns.str.replace(' ', '_').str.lower()
        
        # Write the chunk to a separate CSV file
        split_file_path = f"{file_prefix}_{chunk_number}.csv"
        chunk.to_csv(split_file_path, index=False)
        chunk_number += 1


def ingest_csv_to_postgres(table_name):

    hook = PostgresHook(postgres_conn_id='company_dw')
    conn = hook.get_conn()
    cursor = conn.cursor()

    create_table_query = f"""
    CREATE TABLE IF NOT EXISTS raw.{table_name} (
            open_time TIMESTAMP,
            open NUMERIC,
            high NUMERIC,
            low NUMERIC,
            close NUMERIC,
            volume NUMERIC,
            close_time TIMESTAMP,
            quote_asset_volume NUMERIC,
            number_of_trades NUMERIC,
            taker_buy_base_asset_volume NUMERIC,
            taker_buy_quote_asset_volume NUMERIC,
            ignore NUMERIC
    );
    """

    cursor.execute(create_table_query)
    conn.commit()

    # Step 3: Load each CSV file to Postgres one by one
    split_files = glob.glob('data/tmp/split_*.csv')
    total_files = len(split_files)
    for index, tmp_file_path in enumerate(split_files, start=1):
        print(f"Loading file {index} of {total_files}: {tmp_file_path}")
        
        # Create a new connection to the database for each file
        hook = PostgresHook(postgres_conn_id='company_dw')
        conn = hook.get_conn()
        cursor = conn.cursor()

        # Write data to the target table
        with open(tmp_file_path, 'r') as f:
            cursor.copy_expert(f"COPY raw.{table_name} FROM STDIN WITH CSV HEADER", f)
        conn.commit()

        # Refresh the connection after each file
        cursor.close()
        conn.close()
        print(f"File {index} of {total_files} written to table '{table_name}'")


with dag:
    create_schema = PythonOperator(
        task_id='create_schema',
        python_callable=create_schema_if_not_exists
    )

    delete_btcusdt = PythonOperator(
        task_id='delete_btcusdt',
        python_callable=delete_existing_table,
        op_kwargs={'table_name': 'btcusdt'},
    )

    split_btcusdt = PythonOperator(
        task_id='split_btcusdt',
        python_callable=split_csv,
        op_kwargs={'file_path': '/opt/airflow/data/btcusdt.csv'},
    )

    ingest_btcusdt = PythonOperator(
        task_id='ingest_btcusdt',
        python_callable=ingest_csv_to_postgres,
        op_kwargs={'table_name': 'btcusdt'},
    )

    create_schema >> delete_btcusdt
    delete_btcusdt >> split_btcusdt
    split_btcusdt >> ingest_btcusdt
