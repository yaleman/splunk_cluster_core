resource aws_iam_role index_tier {
  name = "s3_full_splunk-index_tier"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": "ec2.amazonaws.com"
            },
        "Effect": "Allow",
        "Sid": ""
        }
    ]
}
EOF
}

resource aws_iam_instance_profile index_tier {
  name = "s3_full_splunk-index_tier"
  role = aws_iam_role.index_tier.name
}

# resource aws_iam_role_policy_attachment index_tier_testbucket {
#   role = aws_iam_role.index_tier.name
#   policy_arn = aws_iam_policy.allow_full_bucket_testbucket.arn
# }

resource aws_iam_role_policy_attachment index_tier_testdata {
  role = aws_iam_role.index_tier.name
  policy_arn = aws_iam_policy.allow_full_bucket_testdata.arn
}

resource aws_iam_role_policy_attachment index_tier_index_data {
  role = aws_iam_role.index_tier.name
  policy_arn = aws_iam_policy.allow_full_bucket_index_data.arn
}

resource aws_iam_role_policy_attachment indexer_ssm {
  role = aws_iam_instance_profile.index_tier.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}