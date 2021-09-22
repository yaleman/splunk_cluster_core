resource aws_iam_instance_profile generic {
  name = "splunk-generic-role"
  role = aws_iam_role.generic.name
}
resource aws_iam_role generic {
  name = "splunk-generic-role"

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


resource aws_iam_role_policy_attachment generic_ssm {
  role = aws_iam_instance_profile.generic.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource aws_iam_role_policy_attachment get_cloudflare_secrets {
  role = aws_iam_instance_profile.generic.name
  policy_arn = aws_iam_policy.get_cloudflare_secrets.arn
}
resource aws_iam_policy get_cloudflare_secrets {
  name = "get_cloudflare_secrets"
  path = "/"
  description = "Allow access to Secrets Manager Secrets with cloudflare certs"
  policy = <<EOM
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "secretsmanager:GetSecretValue",
            "Resource": "arn:aws:secretsmanager:*:${var.aws_account_id}:secret:cloudflared_*"
        }
    ]
}

EOM

}



resource aws_iam_role_policy_attachment get_clustermaster_git_key {
  role = aws_iam_instance_profile.generic.name
  policy_arn = aws_iam_policy.get_clustermaster_git_key.arn
}
resource aws_iam_policy get_clustermaster_git_key {
  name = "get_clustermaster_git_key"
  path = "/"
  description = "Allow access to the git deploy key"
  policy = <<EOM
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "secretsmanager:GetSecretValue",
            "Resource": "arn:aws:secretsmanager:*:${var.aws_account_id}:secret:clustermaster_git_deploy_key*"
        }
    ]
}

EOM

}