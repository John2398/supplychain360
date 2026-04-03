resource "snowflake_stage" "s3_stage" {
  name     = "S3_STAGE"
  database = snowflake_database.db.name
  schema   = snowflake_schema.bronze.name
  url      = "s3://supplychain360-raw/bronze/"

}