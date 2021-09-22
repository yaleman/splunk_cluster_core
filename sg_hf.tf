resource aws_security_group i_am_a_hf {
  name = "i_am_a_hf"
  tags = {
    Name = "i_am_a_hf"
  }
  description = "Does not allow access in, but used for tagging Heavy Forwarders for use in other rules"
  vpc_id = aws_vpc.splunk.id
  timeouts {
    # timeout on deletion, default is 10m because of ELBs and so forth
    delete = "1m"
    }
}


resource aws_security_group splunk_hf_8088 {
  name        = "splunk_hf_8088"
  description = "Heavy Forwarder Allow tcp/8088"

  ingress { # allow the ALBs to talk to the HFs on 8088
    from_port   = 8088
    to_port     = 8088
    protocol    = "tcp"
    cidr_blocks = [ for subnet in aws_subnet.splunk[*]: subnet.cidr_block ]
  }
  egress {
    protocol = -1
    from_port = 0
    to_port = 0
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  vpc_id = aws_vpc.splunk.id

  tags = {
    Name = "splunk_hf_8088"
  }
  timeouts {
    # timeout on deletion, default is 10m because of ELBs and so forth
    delete = "1m"
    }
}