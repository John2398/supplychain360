terraform {
  required_version = ">= 1.6.0"
  backend "s3" {
    bucket         = "supplychain-360"
    key            = "supplychain360/terraform/aws/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}