resource "snowflake_external_table" "sales_ext" {
  name     = "SALES_EXT"
  database = snowflake_database.db.name
  schema   = snowflake_schema.bronze.name

  location = "@${snowflake_database.db.name}.${snowflake_schema.bronze.name}.${snowflake_stage.s3_stage.name}/postgres/sales/"

  file_format = "FORMAT_NAME = 'SUPPLYCHAIN360.BRONZE.PARQUET_FORMAT'"

  auto_refresh = false

  column {
    name = "RAW"
    type = "VARIANT"
    as   = "$1"
  }
}


resource "snowflake_external_table" "stores_ext" {
  name     = "STORES_EXT"
  database = snowflake_database.db.name
  schema   = snowflake_schema.bronze.name

  location = "@${snowflake_database.db.name}.${snowflake_schema.bronze.name}.${snowflake_stage.s3_stage.name}/google_sheets/"

  file_format = "FORMAT_NAME = 'SUPPLYCHAIN360.BRONZE.PARQUET_FORMAT'"

  auto_refresh = false

  column {
    name = "RAW"
    type = "VARIANT"
    as   = "$1"
  }
}

resource "snowflake_external_table" "inventory_ext" {
  name     = "INVENTORY_EXT"
  database = snowflake_database.db.name
  schema   = snowflake_schema.bronze.name

  location = "@${snowflake_database.db.name}.${snowflake_schema.bronze.name}.${snowflake_stage.s3_stage.name}/s3/raw/inventory/"

  file_format = "FORMAT_NAME = 'SUPPLYCHAIN360.BRONZE.PARQUET_FORMAT'"

  auto_refresh = false

  column {
    name = "RAW"
    type = "VARIANT"
    as   = "$1"
  }
}

resource "snowflake_external_table" "products_ext" {
  name     = "PRODUCTS_EXT"
  database = snowflake_database.db.name
  schema   = snowflake_schema.bronze.name

  location = "@${snowflake_database.db.name}.${snowflake_schema.bronze.name}.${snowflake_stage.s3_stage.name}/s3/raw/products/"

  file_format = "FORMAT_NAME = 'SUPPLYCHAIN360.BRONZE.PARQUET_FORMAT'"

  auto_refresh = false

  column {
    name = "RAW"
    type = "VARIANT"
    as   = "$1"
  }
}

resource "snowflake_external_table" "shipments_ext" {
  name     = "SHIPMENTS_EXT"
  database = snowflake_database.db.name
  schema   = snowflake_schema.bronze.name

  location = "@${snowflake_database.db.name}.${snowflake_schema.bronze.name}.${snowflake_stage.s3_stage.name}/s3/raw/shipments/"

  file_format = "FORMAT_NAME = 'SUPPLYCHAIN360.BRONZE.PARQUET_FORMAT'"

  auto_refresh = false

  column {
    name = "RAW"
    type = "VARIANT"
    as   = "$1"
  }
}

resource "snowflake_external_table" "suppliers_ext" {
  name     = "SUPPLIERS_EXT"
  database = snowflake_database.db.name
  schema   = snowflake_schema.bronze.name

  location = "@${snowflake_database.db.name}.${snowflake_schema.bronze.name}.${snowflake_stage.s3_stage.name}/s3/raw/suppliers/"

  file_format = "FORMAT_NAME = 'SUPPLYCHAIN360.BRONZE.PARQUET_FORMAT'"

  auto_refresh = false

  column {
    name = "RAW"
    type = "VARIANT"
    as   = "$1"
  }
}

resource "snowflake_external_table" "warehouses_ext" {
  name     = "WAREHOUSES_EXT"
  database = snowflake_database.db.name
  schema   = snowflake_schema.bronze.name

  location = "@${snowflake_database.db.name}.${snowflake_schema.bronze.name}.${snowflake_stage.s3_stage.name}/s3/raw/warehouses/"

  file_format = "FORMAT_NAME = 'SUPPLYCHAIN360.BRONZE.PARQUET_FORMAT'"

  auto_refresh = false

  column {
    name = "RAW"
    type = "VARIANT"
    as   = "$1"
  }
}