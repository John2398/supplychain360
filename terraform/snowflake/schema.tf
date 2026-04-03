resource "snowflake_schema" "bronze" {
  name     = "BRONZE"
  database = snowflake_database.db.name
}

resource "snowflake_schema" "silver" {
  name     = "SILVER"
  database = snowflake_database.db.name
}

resource "snowflake_schema" "gold" {
  name     = "GOLD"
  database = snowflake_database.db.name
}