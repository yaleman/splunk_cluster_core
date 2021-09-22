
############################################################
#
# used for the internal services
#
############################################################

resource tls_private_key letsencrypt {
  algorithm = "RSA"
}

resource acme_registration letsencrypt {
  account_key_pem = tls_private_key.letsencrypt.private_key_pem
  email_address   = var.letsencrypt_owner_email
}

resource acme_certificate certificate {
    for_each = local.certmap
  
    account_key_pem           = acme_registration.letsencrypt.account_key_pem
    common_name               = each.value

    dns_challenge {
        provider = "route53"
        config = {
            AWS_HOSTED_ZONE_ID = aws_route53_zone.base_domain.id
        }
    }
}

resource aws_ssm_parameter cert_privatekey {
    for_each = local.certmap
    name = "/application/splunk/certificate/${each.key}/privatekey"
    value = acme_certificate.certificate[each.key].private_key_pem
    type = "SecureString"
}

resource aws_ssm_parameter cert_search_certificate {
    for_each = local.certmap
    name = "/application/splunk/certificate/${each.key}/certificate"
    value = acme_certificate.certificate[each.key].certificate_pem
    type = "SecureString"
}

resource aws_ssm_parameter cert_search_intermediate {
    for_each = local.certmap
    name = "/application/splunk/certificate/${each.key}/intermediate"
    value = acme_certificate.certificate[each.key].issuer_pem
    type = "SecureString"
}
