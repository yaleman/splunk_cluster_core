resource aws_vpc_endpoint s3 {
  vpc_id       = aws_vpc.splunk.id
  service_name = "com.amazonaws.ap-southeast-2.s3"

  tags = merge(local.common_tags,{
    Name = "ap-southeast-2-s3"
  })

}

