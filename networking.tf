resource aws_route_table splunk {
  vpc_id = aws_vpc.splunk.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.splunk.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.splunk.id
  }

  tags = local.common_tags
}


resource aws_internet_gateway splunk {
  vpc_id = aws_vpc.splunk.id

  tags = merge(local.common_tags, {
    Name = aws_vpc.splunk.tags["Name"]
  })

}