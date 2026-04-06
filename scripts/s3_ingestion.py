from dotenv import load_dotenv
import boto3
import os
import pandas as pd
import logging
import time
import io

load_dotenv()

SOURCE_ACCESS_KEY = os.getenv("ACCESS_KEY")
SOURCE_SECRET_KEY = os.getenv("SECRET_KEY")
DESTINATION_AWS_ACCESS_KEY = os.getenv("MY_ACCESS_KEY")
DESTINATION_AWS_SECRET_ACCESS_KEY = os.getenv("MY_SECRET_KEY")
SOURCE_BUCKET_NAME = os.getenv("SOURCE_BUCKET")
DESTINATION_BUCKET_NAME = os.getenv("MY_BUCKET")

log_dir = "logs"
os.makedirs(log_dir, exist_ok=True)

log_path = os.path.join(log_dir, "s3_ingestion.log")
logging.basicConfig(
    filename=log_path,
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
)


source_s3 = boto3.client(
    "s3",
    aws_access_key_id=SOURCE_ACCESS_KEY,
    aws_secret_access_key=SOURCE_SECRET_KEY,
    region_name="eu-west-2",
)

destination_s3 = boto3.client(
    "s3",
    aws_access_key_id=DESTINATION_AWS_ACCESS_KEY,
    aws_secret_access_key=DESTINATION_AWS_SECRET_ACCESS_KEY,
    region_name="eu-north-1",
)


def transfer_s3_object(object_key, max_retries=5, delay=5):
    if object_key.endswith("/"):
        logging.info(f"Skipping folder: {object_key}")
        return

    for attempt in range(max_retries):
        try:
            logging.info(f"Processing {object_key}")

            source_response = source_s3.get_object(
                Bucket=SOURCE_BUCKET_NAME, Key=object_key
            )

            file_body = source_response["Body"]

            # Handling different formats
            if object_key.endswith(".csv"):
                df = pd.read_csv(file_body)

            elif object_key.endswith(".json"):
                df = pd.read_json(file_body)

            else:
                logging.info(f"Skipping unsupported file: {object_key}")
                return

            if df.empty:
                logging.info(f"Empty file: {object_key}")
                return

            parquet_buffer = io.BytesIO()
            df.to_parquet(parquet_buffer, engine="pyarrow", index=False)

            parquet_key = f"bronze/s3/{object_key.rsplit('.', 1)[0]}.parquet"

            destination_s3.put_object(
                Bucket=DESTINATION_BUCKET_NAME,
                Key=parquet_key,
                Body=parquet_buffer.getvalue(),
            )

            logging.info(f"Successfully converted and uploaded '{parquet_key}'")
            break

        except Exception as e:
            logging.error(f"Error processing '{object_key}' on attempt {attempt}: {e}")

            if attempt < max_retries:
                time.sleep(delay)
            else:
                logging.error(f"Failed after {max_retries} attempts: {object_key}")


def transfer_all_objects():
    response = source_s3.list_objects_v2(Bucket=SOURCE_BUCKET_NAME)

    if "Contents" in response:
        for obj in response["Contents"]:
            transfer_s3_object(obj["Key"])
    else:
        logging.warning("No objects found in the source bucket")
