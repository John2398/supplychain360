FROM apache/airflow:2.9.3-python3.11

USER root
RUN apt-get update && apt-get install -y git

USER airflow

COPY requirements.txt .
RUN pip install --no-cache-dir \
    --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.9.3/constraints-3.11.txt" \
    -r requirements.txt

RUN pip install --no-cache-dir dbt-core dbt-snowflake

COPY dags/ /opt/airflow/dags/
COPY supplychain360_dbt/ /opt/airflow/dbt/
COPY scripts/ /opt/airflow/scripts/

ENV AIRFLOW_HOME=/opt/airflow

EXPOSE 8080