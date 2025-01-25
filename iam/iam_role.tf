resource "aws_iam_role_policy_attachment" "s3bucket_read" {
  role       = aws_iam_role.s3bucket_read_role.name
  policy_arn = aws_iam_policy.s3bucket_read_policy.arn
}

resource "aws_iam_instance_profile" "s3bucket_read_profile" {
  name_prefix = "s3bucket-iam-instance-profile-"
  role        = aws_iam_role.s3bucket_read_role.name

  tags = {
    Name = var.tag_name
  }
}
