resource "snowflake_file_format" "parquet_format" {
  name     = "PARQUET_FORMAT"
  database = snowflake_database.db.name
  schema   = snowflake_schema.bronze.name

  format_type = "PARQUET"
}