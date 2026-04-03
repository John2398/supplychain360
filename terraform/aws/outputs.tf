output "aws_ecr_repository_url" {
  value = aws_ecr_repository.supplychain360.repository_url
  description = "URL of the ECR repository"
}

output "s3_bucket_arn" {
  value = "aws_s3_bucket.supplychain360_raw.arn"
  description = "ARN of the created bucket"
}
