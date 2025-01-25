# This data is equivalent to Trust Permissions tab on role page
data "aws_iam_policy_document" "s3bucket_read_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "s3bucket_read_role" {
  # name        = "s3_role"
  name_prefix = "s3bucket-iam-role-"
  description = "S3 access role for EC2 instance."

  assume_role_policy = data.aws_iam_policy_document.s3bucket_read_role.json

  tags = {
    Name = var.tag_name
  }
}
