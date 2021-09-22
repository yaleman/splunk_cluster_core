# -> CM on 8089 (local.splunk_cluster_master_port)
resource aws_security_group splunk_allow_all_tcp_8089 {
  name        = "splunk_allow_all_tcp_8089"
  description = "Allow traffic to cluster master on API port"

  ingress {
    from_port   = local.splunk_api_port
    to_port     = local.splunk_api_port
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  egress {
    protocol = -1
    from_port = 0
    to_port = 0
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  vpc_id = aws_vpc.splunk.id

  tags = {
    Name = "splunk_allow_all_tcp_8089"
  }
  timeouts {
    # timeout on deletion, default is 10m because of ELBs and so forth
    delete = "1m"
    }
}