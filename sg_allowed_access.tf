
resource aws_security_group allowed_access {
  name        = join( "", [local.common_tags.platform, "-allow_from_ips"] )
  description = "Allow direct access to the frontends."

  vpc_id = aws_vpc.splunk.id

  # ingress {
  #   protocol = 6
  #   from_port = 8000
  #   to_port = 8000
  #   cidr_blocks = var.allowed_ips
  # }

  # ingress {
  #   protocol = 6
  #   from_port = 443
  #   to_port = 443
  #   cidr_blocks = var.allowed_ips
  # }

  ingress {
    protocol = 6
    from_port = 22
    to_port = 22
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = var.allowed_ips
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  timeouts {
    # timeout on deletion, default is 10m because of ELBs and so forth
    delete = "1m"
    }

  lifecycle {
    create_before_destroy = true
  }
}