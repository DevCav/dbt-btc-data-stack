from datetime import timedelta, datetime
import os
from airflow import DAG
from airflow.sensors.external_task_sensor import ExternalTaskSensor
from airflow.operators.dummy import DummyOperator
from airflow.operators.bash import BashOperator
from custom_sensors import ExternalTaskWithinDaysSensor
from run_dbt_module import create_dbt_tasks
from airflow.utils.dates import days_ago

local_tz = 'America/Los_Angeles'

default_args = {
    'owner': 'airflow',
    'depends_on_past': True,
    'email': ['airflow@example.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
    'start_date': days_ago(1),
}

dag = DAG(
    dag_id="run_dbt_models",
    default_args=default_args,
    description="A dbt wrapper for Airflow - BTCUSDT",
    schedule_interval=None,
    start_date=datetime(2024, 10, 15),
    is_paused_upon_creation=True,
)


wait_for_dbt_init = ExternalTaskWithinDaysSensor(
    task_id='wait_for_dbt_init',
    external_dag_id='run_dbt_init_tasks',
    external_task_id=None,
    days=14,
    mode='poke',
    timeout=3600,
    poke_interval=60,
    dag=dag,
)

generate_dbt_docs = BashOperator(
    task_id='generate_dbt_docs',
    bash_command='dbt docs generate --profiles-dir /opt/airflow/dbt --project-dir /opt/airflow/dbt',
    dag=dag,
)

models_to_run = ['stg_kaggle__btcusdt', 'fct_hourly_trades']  # Specify the models to run for this DAG
schema = 'analytics'

dbt_tasks = create_dbt_tasks(dag, models_to_run, schema)

wait_for_dbt_init >> tuple(dbt_tasks.values()) 
tuple(dbt_tasks.values()) >> generate_dbt_docs