from dotenv import load_dotenv
import boto3
import psycopg2
import pandas as pd
import io
from dotenv import load_dotenv
import os
import logging
from datetime import datetime

load_dotenv()

SOURCE_ACCESS_KEY = os.getenv("ACCESS_KEY")
SOURCE_SECRET_KEY = os.getenv("SECRET_KEY")
SSM_DB_USER = os.getenv("SSM_DB_USER")
SSM_DB_PASSWORD = os.getenv("SSM_DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")
DESTINATION_BUCKET = os.getenv("MY_BUCKET")
DESTINATION_ACCOUNT_ID = os.getenv("MY_ACCOUNT_ID")

# Create logs directory
log_dir = "logs"
os.makedirs(log_dir, exist_ok=True)

# Configure logging
log_path = os.path.join(log_dir, "postgres_to_s3.log")
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[logging.FileHandler(log_path), logging.StreamHandler()],
)

logger = logging.getLogger(__name__)


def get_ssm_parameter(ssm_client, param_name):
    """Retrieve parameter from AWS Systems Manager Parameter Store."""
    try:
        logger.debug(f"Retrieving SSM parameter: {param_name}")
        response = ssm_client.get_parameter(Name=param_name, WithDecryption=True)
        logger.info(f"Successfully retrieved SSM parameter: {param_name}")
        return response["Parameter"]["Value"]
    except Exception as e:
        logger.error(f"Failed to retrieve SSM parameter '{param_name}': {e}")
        raise


def postgres_to_s3():
    """Extract sales tables from PostgreSQL and upload to S3 as Parquet files."""

    logger.info("=" * 60)
    logger.info("PostgreSQL to S3 Transfer Script Started")
    logger.info(f"Destination Bucket: {DESTINATION_BUCKET}")
    logger.info(f"Database Host: {DB_HOST}")
    logger.info("=" * 60)

    conn = None
    successful_uploads = 0
    failed_uploads = 0
    total_rows_processed = 0

    try:
        # Initialize SSM client
        logger.info("Initializing AWS SSM client...")
        ssm_client = boto3.client(
            "ssm",
            aws_access_key_id=SOURCE_ACCESS_KEY,
            aws_secret_access_key=SOURCE_SECRET_KEY,
            region_name="eu-west-2",
        )
        logger.info("SSM client initialized successfully")

        # Retrieve database credentials
        logger.info("Retrieving database credentials from SSM...")
        db_user = get_ssm_parameter(ssm_client, SSM_DB_USER)
        db_password = get_ssm_parameter(ssm_client, SSM_DB_PASSWORD)
        logger.info("Database credentials retrieved successfully")

        # Connect to PostgreSQL
        logger.info(f"Connecting to PostgreSQL database at {DB_HOST}:{DB_PORT}...")
        conn = psycopg2.connect(
            host=DB_HOST,
            port=DB_PORT,
            database=DB_NAME,
            user=db_user,
            password=db_password,
        )
        logger.info("✓ Successfully connected to PostgreSQL database")

        # Get all sales tables
        logger.info("Querying for sales tables...")
        query = """
            SELECT table_name
            FROM information_schema.tables
            WHERE table_name LIKE 'sales_%'
            ORDER BY table_name;
        """
        tables_df = pd.read_sql(query, conn)
        tables = tables_df["table_name"].to_list()

        logger.info(f"Found {len(tables)} sales tables:")
        for table in tables:
            logger.info(f"  - {table}")

        if not tables:
            logger.warning("No sales tables found in the database")
            return

        # Initialize S3 client
        logger.info("Initializing S3 client...")
        s3_client = boto3.client("s3")
        logger.info("S3 client initialized successfully")

        # Process each table
        logger.info("\nStarting table extraction and upload process...")
        for idx, table in enumerate(tables, 1):
            logger.info(f"\n[{idx}/{len(tables)}] Processing table: {table}")

            try:
                # Extract data from PostgreSQL
                logger.debug(f"Executing SELECT query on {table}")
                start_time = datetime.now()
                df = pd.read_sql(f'SELECT * FROM "{table}";', conn)
                query_duration = (datetime.now() - start_time).total_seconds()

                rows, cols = df.shape
                logger.info(
                    f"  Retrieved {rows:,} rows, {cols} columns in {query_duration:.2f}s"
                )

                if df.empty:
                    logger.warning(f"  Table {table} is empty, skipping upload")
                    continue

                total_rows_processed += rows

                # Convert to Parquet
                logger.debug(f"Converting {table} to Parquet format")
                buffer = io.BytesIO()
                df.to_parquet(buffer, engine="pyarrow", index=False)
                parquet_size = buffer.tell()
                logger.info(
                    f"  Parquet file size: {parquet_size:,} bytes ({parquet_size / 1024 / 1024:.2f} MB)"
                )

                # Upload to S3
                s3_key = f"bronze/postgres/sales/{table}.parquet"
                logger.debug(f"Uploading to s3://{DESTINATION_BUCKET}/{s3_key}")

                s3_client.put_object(
                    Bucket=DESTINATION_BUCKET, Key=s3_key, Body=buffer.getvalue()
                )

                logger.info(
                    f"  ✓ Successfully uploaded to s3://{DESTINATION_BUCKET}/{s3_key}"
                )
                successful_uploads += 1

            except Exception as e:
                logger.error(f"  ✗ Error processing table {table}: {str(e)}")
                logger.error(f"  Error type: {type(e).__name__}")
                failed_uploads += 1

        # Logging Summary
        logger.info("\n" + "=" * 60)
        logger.info("TRANSFER SUMMARY")
        logger.info(f"Total tables found: {len(tables)}")
        logger.info(f"Successful uploads: {successful_uploads}")
        logger.info(f"Failed uploads: {failed_uploads}")
        logger.info(f"Total rows processed: {total_rows_processed:,}")
        logger.info("=" * 60)

    except psycopg2.Error as e:
        logger.error(f"Database error: {e}")
        raise
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        logger.error(f"Error type: {type(e).__name__}")
        raise
    finally:
        if conn:
            try:
                conn.close()
                logger.info("Database connection closed")
            except Exception as e:
                logger.error(f"Error closing database connection: {e}")


if __name__ == "__main__":
    try:
        postgres_to_s3()
        logger.info("Script completed successfully")
    except Exception as e:
        logger.error(f"Script failed with error: {e}")
        raise
