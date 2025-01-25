# This data is equivalent to permissions tab on role page
data "aws_iam_policy_document" "s3bucket_read_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:Describe*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "s3bucket_read_policy" {
  name_prefix = "s3bucket-iam-policy-"
  description = "A s3bucket policy"
  policy      = data.aws_iam_policy_document.s3bucket_read_policy.json

  tags = {
    Name = var.tag_name
  }
}
