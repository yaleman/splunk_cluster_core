resource aws_security_group i_am_a_search_head {
  name = "i_am_a_search_head"
  tags = {
    Name = "i_am_a_search_head"
  }
  description = "Does not allow access in, but used for tagging search heads for use in other rules"


  timeouts {
    # timeout on deletion, default is 10m because of ELBs and so forth
    delete = "1m"
    }
  
  vpc_id = aws_vpc.splunk.id
}
