
resource aws_route53_record collector {
  zone_id = aws_route53_zone.base_domain.id
  name = "collector"
  type = "CNAME"
  ttl = 60
  records = [
    aws_instance.collector.public_dns,
    ]
  depends_on = [
    aws_instance.collector
  ]
}