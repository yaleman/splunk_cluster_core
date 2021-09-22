
resource aws_key_pair keypair {
  key_name   = var.deployment_name
  public_key = data.aws_ssm_parameter.ssh_public_key.value
}

