resource "aws_s3_bucket" "test_bucket" {
  # Bucket name is risky as there can be name conflicts.
  # bucket              = "test-bucket-bucket"

  #  Hence avoid and use `bucket_prefix`
  bucket_prefix       = var.user_bucket_prefix
  force_destroy       = true
  object_lock_enabled = false

  tags = {
    Name        = var.tag_name
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_ownership_controls" "test_bucket" {
  bucket = aws_s3_bucket.test_bucket.id

  rule {
    # Default rule (https://docs.aws.amazon.com/AmazonS3/latest/userguide/about-object-ownership.html):
    # A majority of modern use cases in Amazon S3 no longer require the use of ACLs,
    # and we recommend that you keep ACLs disabled except in unusual circumstances
    # where you must control access for each object individually.
    # With ACLs disabled, you can use policies to more easily control access to every object in your bucket,
    # regardless of who uploaded the objects in your bucket.
    object_ownership = "BucketOwnerEnforced"
  }
}

# Since ACLs are disabled in block above, this block is useless
# resource "aws_s3_bucket_acl" "test_bucket" {
#   depends_on = [aws_s3_bucket_ownership_controls.test_bucket]
#   bucket     = aws_s3_bucket.test_bucket.id
#   acl        = "private"
# }

resource "aws_s3_bucket_public_access_block" "test_bucket" {
  bucket = aws_s3_bucket.test_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "versioning_test_bucket" {
  bucket = aws_s3_bucket.test_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "test_bucket" {
  bucket = aws_s3_bucket.test_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "test_bucket" {
  bucket = aws_s3_bucket.test_bucket.id

  rule {
    id = "janitor"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }

    expiration {
      days = 1
    }

    noncurrent_version_expiration {
      newer_noncurrent_versions = 1
      noncurrent_days           = 1
    }

    status = "Enabled"
  }
}
