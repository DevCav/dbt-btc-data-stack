from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.utils.dates import days_ago
import pandas as pd
import os

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

def ingest_csv_to_postgres(file_path, table_name):
    hook = PostgresHook(postgres_conn_id='company_dw')
    conn = hook.get_conn()
    cursor = conn.cursor()

    df = pd.read_csv(file_path)
    df_columns = list(df.columns)
    columns = ",".join(df_columns)

    create_table_query = f"""
    CREATE TABLE IF NOT EXISTS raw.{table_name} (
        {", ".join([f'{col} TEXT' for col in df_columns])}
    );
    """
    cursor.execute(create_table_query)
    conn.commit()

    # Inserting DataFrame to SQL Database
    for i, row in df.iterrows():
        sql = f"INSERT INTO raw.{table_name} ({columns}) VALUES ({'%s, ' * (len(row) - 1)}%s)"
        cursor.execute(sql, tuple(row))

    conn.commit()
    cursor.close()
    conn.close()

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

    ingest_btcusdt = PythonOperator(
        task_id='ingest_btcusdt',
        python_callable=ingest_csv_to_postgres,
        op_kwargs={'file_path': '/opt/airflow/data/btcusdt_dev.csv', 'table_name': 'btcusdt'},
    )

    create_schema >> delete_btcusdt
    delete_btcusdt >> ingest_btcusdt
