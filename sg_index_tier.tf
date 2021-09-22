# this file set up security groups for traffic between the various cluster bits

# Indexers to each other on 9887 (local.splunk_replication_port)
resource aws_security_group index_tier_replication {
  name        = "index_tier_replication"
  description = "Allows replication traffic between cluster peers"

  ingress {
    from_port   = local.splunk_api_port
    to_port     = local.splunk_api_port
    protocol    = "tcp"
    # this allows members to talk to each other - which is what we want
    self = true
  }  
  ingress {
    from_port     = local.splunk_replication_port
    to_port     = local.splunk_replication_port
    protocol    = "tcp"
    # this allows members to talk to each other - which is what we want
    self = true
  }

  ingress {
    from_port   = local.splunk_api_port
    to_port     = local.splunk_api_port
    protocol    = "tcp"
    # this allows members to talk to each other - which is what we want
    security_groups = [
      aws_security_group.i_am_a_search_head.id,
    ]
  }  
  ingress {
    from_port     = local.splunk_replication_port
    to_port     = local.splunk_replication_port
    protocol    = "tcp"
    # this allows members to talk to each other - which is what we want
    security_groups = [
      aws_security_group.i_am_a_search_head.id,
    ]
  }

  egress {
    protocol = -1
    from_port = 0
    to_port = 0
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  tags = {
    Name = "index_tier_replication"
  }
  timeouts {
    # timeout on deletion, default is 10m because of ELBs and so forth
    delete = "1m"
    }
  vpc_id = aws_vpc.splunk.id
}

resource aws_security_group index_tier_8089 {
  name        = "index_tier_8089"
  description = "Allows instance to talk to indexers on API port"
  ingress {
    from_port = local.splunk_api_port
    to_port = local.splunk_api_port
    protocol = "tcp"
    security_groups = [
     # aws_security_group.splunk_allow_all_tcp_8089.id,
      aws_security_group.i_am_a_search_head.id
    ]
  }
  tags = {
    Name = "index_tier_8089"
  }
  timeouts {
    # timeout on deletion, default is 10m because of ELBs and so forth
    delete = "1m"
    }
  vpc_id = aws_vpc.splunk.id
}

resource aws_security_group splunk_allow_all_tcp_9997 {
  name        = "splunk_allow_all_tcp_9997"
  description = "Allows everyone to connect on tcp/9997"
  ingress {
    from_port = local.splunk_data_port
    to_port = local.splunk_data_port
    protocol = "tcp"
    # security_groups = [
    #   aws_security_group.cm_8089.id,
    #   aws_security_group.i_am_a_search_head.id,
    #   aws_security_group.i_am_a_hf.id

    # ]
    cidr_blocks = [
      "0.0.0.0/0",
      ]
  }
  tags = {
    Name = "splunk_allow_all_tcp_9997"
  }
  timeouts {
    # timeout on deletion, default is 10m because of ELBs and so forth
    delete = "1m"
    }
  vpc_id = aws_vpc.splunk.id
}