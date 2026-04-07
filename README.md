Project Overview / Background

Project Name: SupplyChain360 Data Engineering & Analytics Platform

Background:
In modern retail and supply chain operations, organizations generate large volumes of transactional, inventory, and supplier data across multiple systems, including cloud storage (Amazon S3), relational databases (PostgreSQL), and collaborative tools (Google Sheets). However, this data is often decentralized, unstructured, and difficult to analyze, making it challenging for decision-makers to monitor supply chain efficiency, track product stockouts, evaluate supplier performance, and optimize regional sales demand.

To address this, the SupplyChain360 project is designed as a fully automated, containerized data engineering pipeline that ingests, cleans, and transforms data from multiple sources into structured analytical models. The platform leverages modern data engineering tools such as Airflow, DBT, Snowflake, Terraform, Docker, and AWS S3 to build a scalable, reproducible, and maintainable solution for data-driven decision-making.

Project Objectives

- Automated Data Extraction:
Collect data from multiple sources including Amazon S3 (raw transactional and product data), Google Sheets (supplementary operational data), and PostgreSQL (sales and inventory systems).
Ensure extraction processes are robust, idempotent, and capable of handling incremental updates.
Data Loading & Storage:
Store raw data in a centralized S3 raw data layer (bronze layer) using Parquet format for efficient storage and retrieval.
Maintain clear separation between raw, cleaned, and transformed data to support the medallion architecture (bronze, silver, gold layers).

- Data Transformation & Modeling:
Transform raw data into cleaned, structured formats in the silver layer using DBT.
Build fact and dimension tables in the gold layer (data marts) to support analytics for:
Product stockout trends
Supplier delivery performance
Warehouse efficiency
Regional sales demand

- Data Orchestration & Automation:
Use Apache Airflow to orchestrate the entire ETL workflow:
Extraction from all sources
Loading into the raw layer
Cleaning and transformation into silver/gold layers
Running DBT models, tests, and documentation generation
Implement retry mechanisms, incremental processing, and failure alerts for reliability.

- Infrastructure as Code & Reproducibility:
Use Terraform to provision and manage Snowflake resources, external tables, and AWS infrastructure (S3 buckets, IAM roles).
Store Terraform state in S3 buckets to ensure remote, secure, and versioned tracking of infrastructure state.

- Containerization & Deployment:
Package the entire pipeline in a Docker image containing all Python scripts, Airflow DAGs, DBT projects, and dependencies.
Enable easy deployment across different environments while ensuring reproducibility.

- Security & Compliance:
Store all credentials, secrets, and sensitive configuration in .env and .tfvars files excluded from Git.
Use S3 remote backends with encryption for Terraform state to prevent exposure of sensitive information.

Tools & Technologies
Layer / Function	Technology Used
Orchestration -	Apache Airflow
Data Transformation & Modeling - DBT (Snowflake)
Cloud Storage - AWS S3
Database / Warehouse -	Snowflake
Relational Data Source -  PostgreSQL
Infrastructure as Code - Terraform
Containerization & Reproducibility - Docker
Monitoring / Logging - Airflow logs + custom logging in Python scripts

Expected Outcomes
. Unified data platform consolidating multiple data sources into a single analytical repository.
. High-quality, analytics-ready data structured into fact and dimension tables.
. Operational dashboards enabling insights into stockouts, supplier performance, and warehouse efficiency.
. Reproducible and automated workflows ensuring reliability and minimal manual intervention.
. Secure, versioned infrastructure managed via Terraform with remote state storage.


PROJECT STRUCTURE

supplychain360
├──dags
│   └──pipeline.py
├──scripts
│   ├──postgresql_ingestion.py
│   ├──s3_ingestion.py
│   └──sheets_ingestion.py
├──supplychain360_dbt
│   ├──analyses
│   │   └──.gitkeep
│   ├──macros
│   │   └──.gitkeep
│   ├──models
│   │   ├──gold
│   │   │   ├──dimensions
│   │   │   │   ├──products.sql
│   │   │   │   ├──stores.sql
│   │   │   │   ├──suppliers.sql
│   │   │   │   └──warehouses.sql
│   │   │   ├──facts
│   │   │   │   ├──inventory.sql
│   │   │   │   ├──product_stokout_trends.sql
│   │   │   │   ├──regional_sales_demand.sql
│   │   │   │   ├──sales.sql
│   │   │   │   ├──shipments.sql
│   │   │   │   ├──supplier_shipment_performance.sql
│   │   │   │   └──warehouse_efficiency.sql
│   │   │   └──schema.yml
│   │   ├──silver
│   │   │   ├──inventory_cleaned.sql
│   │   │   ├──products_cleaned.sql
│   │   │   ├──sales_cleaned.sql
│   │   │   ├──shipments_cleaned.sql
│   │   │   ├──stores_cleaned.sql
│   │   │   ├──suppliers_cleaned.sql
│   │   │   └──warehouses_cleaned.sql
│   │   └──sources.yml
│   ├──seeds
│   │   └──.gitkeep
│   ├──snapshots
│   │   └──.gitkeep
│   ├──target
│   │   ├──compiled
│   │   │   └──supplychain360_dbt
│   │   │   │   └──models
│   │   │   │   │   ├──example
│   │   │   │   │   │   ├──my_first_dbt_model.sql
│   │   │   │   │   │   └──my_second_dbt_model.sql
│   │   │   │   │   ├──gold
│   │   │   │   │   │   ├──dimensions
│   │   │   │   │   │   │   ├──products.sql
│   │   │   │   │   │   │   ├──stores.sql
│   │   │   │   │   │   │   ├──suppliers.sql
│   │   │   │   │   │   │   └──warehouses.sql
│   │   │   │   │   │   └──facts
│   │   │   │   │   │   │   ├──inventory.sql
│   │   │   │   │   │   │   ├──product_stokout_trends.sql
│   │   │   │   │   │   │   ├──regional_sales_demand.sql
│   │   │   │   │   │   │   ├──sales.sql
│   │   │   │   │   │   │   ├──shipments.sql
│   │   │   │   │   │   │   ├──supplier_shipment_performance.sql
│   │   │   │   │   │   │   ├──warehouse_efficciency.sql
│   │   │   │   │   │   │   └──warehouse_efficiency.sql
│   │   │   │   │   └──silver
│   │   │   │   │   │   ├──inventory_cleaned.sql
│   │   │   │   │   │   ├──products_cleaned.sql
│   │   │   │   │   │   ├──sales_cleaned.sql
│   │   │   │   │   │   ├──shipments_cleaned.sql
│   │   │   │   │   │   ├──stores_cleaned.sql
│   │   │   │   │   │   ├──suppliers_cleaned.sql
│   │   │   │   │   │   └──warehouses_cleaned.sql
│   │   ├──run
│   │   │   └──supplychain360_dbt
│   │   │   │   └──models
│   │   │   │   │   ├──example
│   │   │   │   │   │   ├──my_first_dbt_model.sql
│   │   │   │   │   │   └──my_second_dbt_model.sql
│   │   │   │   │   ├──gold
│   │   │   │   │   │   ├──dimensions
│   │   │   │   │   │   │   ├──products.sql
│   │   │   │   │   │   │   ├──stores.sql
│   │   │   │   │   │   │   ├──suppliers.sql
│   │   │   │   │   │   │   └──warehouses.sql
│   │   │   │   │   │   └──facts
│   │   │   │   │   │   │   ├──inventory.sql
│   │   │   │   │   │   │   ├──product_stokout_trends.sql
│   │   │   │   │   │   │   ├──regional_sales_demand.sql
│   │   │   │   │   │   │   ├──sales.sql
│   │   │   │   │   │   │   ├──shipments.sql
│   │   │   │   │   │   │   ├──supplier_shipment_performance.sql
│   │   │   │   │   │   │   ├──warehouse_efficciency.sql
│   │   │   │   │   │   │   └──warehouse_efficiency.sql
│   │   │   │   │   └──silver
│   │   │   │   │   │   ├──inventory_cleaned.sql
│   │   │   │   │   │   ├──products_cleaned.sql
│   │   │   │   │   │   ├──sales_cleaned.sql
│   │   │   │   │   │   ├──shipments_cleaned.sql
│   │   │   │   │   │   ├──stores_cleaned.sql
│   │   │   │   │   │   ├──suppliers_cleaned.sql
│   │   │   │   │   │   └──warehouses_cleaned.sql
│   │   ├──graph.gpickle
│   │   └──partial_parse.msgpack
│   ├──tests
│   │   └──.gitkeep
│   ├──dbt_project.yml
│   ├──packages.yml
│   ├──README.md
│   └──.gitignore
├──terraform
│   ├──aws
│   │   ├──backend.tf
│   │   ├──main.tf
│   │   ├──outputs.tf
│   │   └──provider.tf
│   └──snowflake
│   │   ├──backend.tf
│   │   ├──database.tf
│   │   ├──external_table.tf
│   │   ├──file_format.tf
│   │   ├──provider.tf
│   │   ├──schema.tf
│   │   ├──stage.tf
│   │   ├──variables.tf
│   │   └──warehouse.tf
├──.github
│   └──workflows
│   │   └──ci_cd.yml
├──Capstone_Project_Architecture.drawio
├──docker-compose.yml
├──Dockerfile
├──README.md
├──requirements.txt
├──setup.cfg
└──.gitignore
```


HOW TO SETUP THE PROJECT

1. Clone Project Structure
mkdir supplychain360 && cd supplychain360
mkdir dags scripts dbt_project terraform logs
touch .env requirements.txt Dockerfile docker-compose.yml

mkdir terraform/aws terraform/snowflake

2. Setup Python Environment
python -m venv venv
source venv/bin/activate       # Linux/Mac
venv\Scripts\activate          # Windows

pip install --upgrade pip
pip install -r requirements.txt

3. Configure Environment Variables
ACCESS_KEY=<source s3>
SECRET_KEY=<source s3>
MY_ACCESS_KEY=<destination s3>
MY_SECRET_KEY=<destination s3>
SNOWFLAKE_USER=<user>
SNOWFLAKE_PASSWORD=<password>
SNOWFLAKE_ACCOUNT=<account>
SNOWFLAKE_WAREHOUSE=<warehouse>

4. Set Up Terraform
Configure AWS backend in terraform/aws/backend.tf:
terraform {
  backend "s3" {
    bucket         = "supplychain360-terraform-state"
    key            = "aws/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
Configure Snowflake backend in terraform/snowflake/backend.tf:
terraform {
  backend "s3" {
    bucket         = "supplychain360-terraform-state"
    key            = "snowflake/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
Initialize Terraform:
cd terraform/aws
terraform init
terraform plan
terraform apply

Repeat for terraform/snowflake.

Your infrastructure (S3 buckets, IAM roles, Snowflake schemas, external tables) will now be provisioned.

5.  Configure DBT
Create dbt_project/profiles.yml (local only):
supplychain360:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: "{{ env_var('SNOWFLAKE_ACCOUNT') }}"
      user: "{{ env_var('SNOWFLAKE_USER') }}"
      password: "{{ env_var('SNOWFLAKE_PASSWORD') }}"
      role: SYSADMIN
      database: SUPPLYCHAIN360
      warehouse: "{{ env_var('SNOWFLAKE_WAREHOUSE') }}"
      schema: silver
      threads: 4
Test DBT connection:
cd dbt_project
dbt debug

6. Set Up Airflow
Initialize Airflow in your project folder:
export AIRFLOW_HOME=$(pwd)/airflow
airflow db init
Copy DAGs into airflow/dags/ or link dags/ folder.
Start Airflow:
airflow scheduler
airflow webserver
DAGs should appear in the UI (localhost:8080).

7.  Dockerize the Project (Optional but Recommended)

Dockerfile Example:

FROM python:3.11-slim

# Set workdir
WORKDIR /opt/project

# Copy project
COPY . /opt/project

# Install dependencies
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Set Airflow home
ENV AIRFLOW_HOME=/opt/project/airflow

docker-compose.yml Example:

version: '3'
services:
  airflow-webserver:
    build: .
    command: airflow webserver
    ports:
      - "8080:8080"
  airflow-scheduler:
    build: .
    command: airflow scheduler

8. Run the Full Pipeline
Make sure Terraform resources exist.
Extract scripts are configured with source keys.
Trigger your DAG (full_pipeline_single_dag) in Airflow UI.
Monitor logs → DBT runs → gold layer analytics tables.