
resource aws_route53_record splunk_index_tier {
  count = local.indexer_count
  zone_id = aws_route53_zone.base_domain.id
  name = "index-tier${count.index}"
  type = "CNAME"
  ttl = 60
  records = [aws_eip.index_tier[count.index].public_dns]
  
}
