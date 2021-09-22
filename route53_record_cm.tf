
resource aws_route53_record clustermaster {
  zone_id = aws_route53_zone.base_domain.id
  name = local.cluster_master_hostname
  type = "CNAME"
  ttl = 60
  records = [
    aws_eip.clustermaster.public_dns
  ]
  depends_on = [
    aws_instance.clustermaster
  ]
}
