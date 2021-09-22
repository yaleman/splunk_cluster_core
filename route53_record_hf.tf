resource aws_route53_record hec {
    type = "CNAME"
    ttl = 60
    records = [ aws_lb.hec_https.dns_name ]
    zone_id = aws_route53_zone.base_domain.id
    name = "hec"
}

resource aws_route53_record hec_classic {
    type = "CNAME"
    ttl = 60
    records = [ aws_elb.hec_classic.dns_name ]
    zone_id = aws_route53_zone.base_domain.id
    name = "hec-classic"
}

resource aws_route53_record hf {
  count = length(aws_instance.splunk_hf)
  zone_id = aws_route53_zone.base_domain.id
  name = "hf${count.index}"
  type = "CNAME"
  ttl = 60
  records = [aws_instance.splunk_hf[count.index].public_dns]
}
