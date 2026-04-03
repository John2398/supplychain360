resource "snowflake_warehouse" "wh" {
  name           = "SUPPLY360_WH"
  warehouse_size = "XSMALL"
  auto_suspend   = 60
  auto_resume    = true
}

