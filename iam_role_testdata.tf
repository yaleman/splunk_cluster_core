# TODO: create a role that the index tier can grab to pull from the s3 bucket

resource aws_iam_role allow_full_bucket_testdata {
    name = "s3_full_${var.data_bucket}-testdata"

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

resource aws_iam_instance_profile allow_full_bucket_testdata {
  name = "s3_full_${var.data_bucket}-testdata"
  role = aws_iam_role.allow_full_bucket_testdata.name
}

# this policy allows access to the splunk index testdata bucket, should be applied to the indexer which is going to pull the data and ingest it


resource aws_iam_role_policy allow_full_bucket_testdata {
  name        = "s3_full_${var.data_bucket}-testdata"
  role = aws_iam_role.allow_full_bucket_testdata.id
  #description = "Allows full access to the splunk-index-testdata bucket"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1581559699270",
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.data_bucket}-testdata/*"
    }
  ]
}
EOF
}

resource aws_iam_role_policy allow_rw_index_data {
  name        = "s3_full_${var.data_bucket}"
  role = aws_iam_role.allow_full_bucket_testdata.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1581559699270",
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.data_bucket}/*"
    }
  ]
}
EOF
}
