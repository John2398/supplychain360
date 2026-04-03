import pandas as pd
import boto3
from google.oauth2.service_account import Credentials
import gspread
import logging
import os

SHEET_ID = "11wSeCppCJzTRuPLlkIWADJs4vehjxJUkKSDnvCsGGVo"

# Setup logging
log_dir = "logs"
os.makedirs(log_dir, exist_ok=True)

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(os.path.join(log_dir, "gsheets_to_s3.log")),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)


def upload_stores_to_s3():
    """Extract stores data from Google Sheets and upload to S3 as Parquet."""

    logger.info("Starting Google Sheets to S3 transfer")

    try:
        # Authenticate with Google Sheets
        logger.info("Authenticating with Google Sheets API")
        creds = Credentials.from_service_account_file(
            "service_account.json",
            scopes=["https://www.googleapis.com/auth/spreadsheets.readonly"]
        )

        gc = gspread.authorize(creds)
        sheet = gc.open_by_key(SHEET_ID).sheet1
        logger.info(f"Connected to sheet: {sheet.title}")

        # Extract data
        logger.info("Extracting data from Google Sheets")
        df = pd.DataFrame(sheet.get_all_records())

        if df.empty:
            logger.error("DataFrame is empty, aborting upload")
            raise ValueError("Dataframe is empty, aborting upload")

        rows, cols = df.shape
        logger.info(f"Retrieved {rows} rows, {cols} columns")

        # Convert to Parquet
        logger.info("Converting to Parquet format")
        df.to_parquet("stores_data.parquet", engine="pyarrow", index=False)

        # Upload to S3
        logger.info("Uploading to S3")
        s3 = boto3.client('s3')
        s3.upload_file(
            "stores_data.parquet",
            "supplychain360-raw",
            "bronze/google_sheets/stores_data.parquet"
        )

        logger.info(
            "✓ Successfully uploaded to s3://supplychain360-raw/bronze/google_sheets/stores_data.parquet")

    except FileNotFoundError:
        logger.error("service_account.json not found")
        raise
    except Exception as e:
        logger.error(f"Transfer failed: {e}")
        raise
    finally:
        # Clean up local file
        if os.path.exists("stores_data.parquet"):
            os.remove("stores_data.parquet")
            logger.info("Cleaned up local Parquet file")


if __name__ == "__main__":
    try:
        upload_stores_to_s3()
        logger.info("Script completed successfully")
    except Exception as e:
        logger.error(f"Script failed: {e}")
        raise
