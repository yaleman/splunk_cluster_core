
resource aws_vpc splunk {
  tags = {
    Name = var.deployment_name
  }
  cidr_block = local.splunk_internalnet
  enable_dns_hostnames = true
}


resource aws_subnet splunk {
  count = 2
  
  cidr_block = cidrsubnet(local.splunk_internalnet, 1, count.index)
  vpc_id = aws_vpc.splunk.id
  tags = { 
      Name = "splunk${count.index}" 
  }
  availability_zone = var.availability_zones[count.index%length(var.availability_zones)]
}