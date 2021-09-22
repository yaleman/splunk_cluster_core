
resource aws_security_group global_rules {
  name        = join( "", [local.common_tags.platform, "-global_rules"] )
  description = "Allow ssh from everywhere"
  ingress {
    protocol = "icmp"
    from_port = 0
    to_port = 0
    cidr_blocks = [
      "0.0.0.0/0"
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
    Name = "${var.deployment_name}-global_rules"
  }


  timeouts {
    # timeout on deletion, default is 10m because of ELBs and so forth
    delete = "1m"
    }
  lifecycle {
    create_before_destroy = true
  }
}