# this is used for the HEC LB's

resource aws_security_group allow_https_global {
    name = "allow_https_global"
    description = "Allow HTTPS from anywhere"
    vpc_id = aws_vpc.splunk.id
    ingress {
        protocol = "tcp"
        from_port = 443
        to_port = 443
        cidr_blocks = [ "0.0.0.0/0" ]
    }
  egress {
    protocol = -1
    from_port = 0
    to_port = 0
    cidr_blocks = [ "0.0.0.0/0" ]
  }
    tags = {
        Name = "allow_https_global"
    }

}
