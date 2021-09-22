{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1581559699270",
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": [
        "${var.arn}",
        "${var.arn}/*"
      ]
    }
  ]
}