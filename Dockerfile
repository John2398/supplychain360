FROM apache/airflow:2.7.0-python3.11

# Install Python dependencies
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy project files into Airflow home
COPY dags/ /opt/airflow/dags/
COPY supplychain360_dbt/ /opt/airflow/dbt/
COPY scripts/ /opt/airflow/scripts/
COPY .env /opt/airflow/.env

# Environment for Airflow
ENV AIRFLOW_HOME=/opt/airflow

EXPOSE 8080