# This data is equivalent to permissions tab on role page
data "aws_iam_policy_document" "s3bucket_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:*",
      "s3-object-lambda:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "s3bucket_policy" {
  name_prefix = "s3bucket-iam-policy-"
  description = "A s3bucket policy"
  policy      = data.aws_iam_policy_document.s3bucket_policy.json

  tags = {
    Name = var.tag_name
  }
}
