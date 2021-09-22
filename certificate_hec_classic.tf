# generates the certificates for the hec-classic ELB and does DNS validation

resource aws_acm_certificate hec_classic {
  domain_name       = "hec-classic.${var.base_domain}"
  validation_method = "DNS"

  tags = merge(local.common_tags,{
    Name = "hec-classic"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource aws_route53_record hec_classic_cert_validation {
  for_each = {
    for dvo in aws_acm_certificate.hec_classic.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.base_domain.zone_id
}


resource aws_acm_certificate_validation hec_classic {
  certificate_arn         = aws_acm_certificate.hec_classic.arn
  validation_record_fqdns = [for record in aws_route53_record.hec_classic_cert_validation : record.fqdn]
}
