#create ecr
resource "aws_ecr_repository" "supplychain360" {
  name = "supplychain360_repo"
  image_tag_mutability = "MUTABLE"
}

#create s3 bucket
resource "aws_s3_bucket" "supplychain360_raw" {
  bucket = "supplychain360-raw"
}

#create bronze layer in s3 bucket
resource "aws_s3_object" "folder" {
  bucket = aws_s3_bucket.supplychain360_raw.id
  key = "bronze/"
}