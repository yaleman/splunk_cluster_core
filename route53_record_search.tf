
resource aws_route53_record search {
  zone_id = aws_route53_zone.base_domain.id
  name = aws_route53_zone.base_domain.name
  type = "A"
  ttl = 60
  records = [ aws_eip.search.public_ip]
  depends_on = [
    aws_instance.search,
    aws_eip.search,
  ]
}