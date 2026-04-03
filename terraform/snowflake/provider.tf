terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.100.0"
    }
  }
}

# A simple configuration of the provider with private key authentication.
provider "snowflake" {
  organization_name      = "zifzyaj"             # required if not using profile. Can also be set via SNOWFLAKE_ORGANIZATION_NAME env var
  account_name           = var.SNOWFLAKE_ACCOUNT # required if not using profile. Can also be set via SNOWFLAKE_ACCOUNT_NAME env var
  user                   = var.SNOWFLAKE_USER    # required if not using profile or token. Can also be set via SNOWFLAKE_USER env var
  authenticator          = "SNOWFLAKE_JWT"
  private_key            = file("${path.module}/rsa_key.p8")
  private_key_passphrase = var.private_key_passphrase
  role                   = "ACCOUNTADMIN"

  #preview_features_enabled = ["snowflake_external_table_resource", "snowflake_file_format_resource"]
}

# Remember to provide the passphrase securely.
variable "private_key_passphrase" {
  type      = string
  sensitive = true
}