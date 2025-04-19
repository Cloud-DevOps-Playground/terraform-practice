output "s3bucket_name" {
  description = "Name of created s3 bucket."
  value       = aws_s3_bucket.test_bucket.bucket
  # sensitive   = true
}
