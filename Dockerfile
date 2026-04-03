FROM apache/airflow:2.7.0-python3.11

USER root
RUN apt-get update && apt-get install -y git

USER airflow

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

RUN pip install --no-cache-dir dbt-core dbt-snowflake dbt-utils

COPY dags/ /opt/airflow/dags/
COPY supplychain360_dbt/ /opt/airflow/dbt/
COPY scripts/ /opt/airflow/scripts/

ENV AIRFLOW_HOME=/opt/airflow

EXPOSE 8080