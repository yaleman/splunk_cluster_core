
resource aws_route53_record deployment {
  zone_id = aws_route53_zone.base_domain.id
  name = "deployment"
  type = "CNAME"
  ttl = 60
  records = [
    aws_eip.deployment.public_dns,
    ]
  depends_on = [
    aws_instance.deployment
  ]
}