
resource aws_security_group deployment {
  name        = "deployment"
  description = "Splunk Deployment server rules"

  ingress {
    from_port   = 8089
    to_port     = 8089
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0"]
  }

  egress {
    protocol = -1
    from_port = 0
    to_port = 0
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  vpc_id = aws_vpc.splunk.id

  tags = {
    Name = "deployment"
  }
  timeouts {
    # timeout on deletion, default is 10m because of ELBs and so forth
    delete = "1m"
    }
}