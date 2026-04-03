from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta

# Import existing extraction scripts
from scripts import s3_ingestion, sheets_ingestion, postgresql_ingestion

# DAG default arguments
default_args = {
    "owner": "dara",
    "depends_on_past": False,
    "email": ["darajohn.fo@gmail.com"],
    "email_on_failure": True,
    "email_on_retry": False,
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
}

# Define the DAG
with DAG(
    dag_id="full_data_pipeline",
    default_args=default_args,
    description="ETL: S3, Google Sheets, Postgres → Raw → Snowflake → dbt Silver/Gold → Tests/Docs",
    start_date=datetime(2026, 4, 1),
    schedule_interval="@daily",
    catchup=False,
    max_active_runs=1,
    tags=["dbt", "snowflake", "etl", "s3"]
) as dag:

    # Extract from S3
    extract_s3 = PythonOperator(
        task_id="extract_s3",
        python_callable=s3_ingestion.transfer_all_objects
    )

    # Extract from Google Sheets
    extract_google_sheets = PythonOperator(
        task_id="extract_google_sheets",
        python_callable=sheets_ingestion.upload_stores_to_s3
    )

    # Extract from Postgres
    extract_postgres = PythonOperator(
        task_id="extract_postgres",
        python_callable=postgresql_ingestion.postgres_to_s3
    )

    # dbt Run (Silver + Gold)
    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command="cd /opt/supplychain360/supplychain360_dbt && dbt run --models +silver_+ +gold_+"
    )

    # dbt Test (Data quality)
    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command="cd /opt/supplychain360/supplychain360_dbt && dbt test"
    )

    # dbt Docs
    dbt_docs = BashOperator(
        task_id="dbt_docs",
        bash_command="cd /opt/supplychain360/supplychain360_dbt && dbt docs generate")

    # DAG Dependencies
    # Run all extractions in parallel, then run dbt
    [extract_s3, extract_google_sheets,
        extract_postgres] >> dbt_run >> dbt_test >> dbt_docs
