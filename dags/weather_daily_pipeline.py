from datetime import timedelta
import sys

import pendulum

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator

sys.path.insert(0, "/opt/airflow")

from ingestion.extract import extract_all_cities
from ingestion.load import load_weather



def extract_weather_for_date(logical_date: str):
    return extract_all_cities(logical_date)


def load_weather_for_date(logical_date: str, ti):
    extracted_data = ti.xcom_pull(task_ids="extract")

    return load_weather(
        extracted_data,
        logical_date,
    )


with DAG(
    dag_id="weather_daily_pipeline",
    description="Daily Open-Meteo weather ingestion and transformation pipeline",
    start_date=pendulum.datetime(2026, 1, 1, tz="UTC"),
    schedule="@daily",
    catchup=False,
    max_active_runs=1,
    default_args={
        "retries": 2,
        "retry_delay": timedelta(minutes=1),
        "execution_timeout": timedelta(minutes=10),
    },
    tags=["weather"],
) as dag:

    extract = PythonOperator(
        task_id="extract",
        python_callable=extract_weather_for_date,
        op_kwargs={
            "logical_date": "{{ ds }}",
        },
    )

    load = PythonOperator(
        task_id="load",
        python_callable=load_weather_for_date,
        op_kwargs={
            "logical_date": "{{ ds }}",
        },
    )

    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command="""
            cd /opt/airflow/dbt &&
            dbt run
        """,
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command="""
            cd /opt/airflow/dbt &&
            dbt test
        """,
    )

    extract >> load >> dbt_run >> dbt_test