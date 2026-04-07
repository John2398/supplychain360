import sys

sys.path.append("/opt/airflow/scripts")

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta
import s3_ingestion
import postgresql_ingestion
import sheets_ingestion

default_args = {
    "owner": "dara",
    "depends_on_past": False,
    "email": ["darajohn.fo@gmail.com"],
    "email_on_failure": True,
    "email_on_retry": False,
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
}

with DAG(
    dag_id="full_data_pipeline",
    default_args=default_args,
    description="ETL: S3, Google Sheets, Postgres → Snowflake → dbt Silver/Gold",
    start_date=datetime(2026, 4, 1),
    schedule_interval="@daily",
    catchup=False,
    max_active_runs=1,
    tags=["dbt", "snowflake", "etl"],
) as dag:

    extract_s3 = PythonOperator(
        task_id="extract_s3",
        python_callable=s3_ingestion.transfer_all_objects,
    )

    extract_google_sheets = PythonOperator(
        task_id="extract_google_sheets",
        python_callable=sheets_ingestion.upload_stores_to_s3,
    )

    extract_postgres = PythonOperator(
        task_id="extract_postgres",
        python_callable=postgresql_ingestion.postgres_to_s3,
    )

    dbt_deps = BashOperator(
        task_id='dbt_deps',
        bash_command="""
            cd /opt/airflow/dbt_project &&
            dbt deps --profiles-dir /opt/airflow/dbt_project
        """,
    )

    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command="""
        cd /opt/airflow/dbt_project &&
        dbt run --select silver gold --profiles-dir /opt/airflow/dbt_project
        """,
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command="""
        cd /opt/airflow/dbt_project &&
        dbt test
        """,
    )

    dbt_docs = BashOperator(
        task_id="dbt_docs",
        bash_command="""
        cd /opt/airflow/dbt_project &&
        dbt docs generate
        """,
    )

    [extract_s3, extract_google_sheets, extract_postgres] >> dbt_deps >> dbt_run >> dbt_test >> dbt_docs
