############################################################
#
# used for the public-facing HTTP event collector via the NLB
#
############################################################

resource acme_certificate certificate_hec {
    for_each = local.hec_certmap
  
    account_key_pem           = acme_registration.letsencrypt.account_key_pem
    common_name               = each.value

    subject_alternative_names = [
        aws_route53_record.hec.fqdn,
        aws_route53_record.hec_classic.fqdn,
    ]

    dns_challenge {
        provider = "route53"
        config = {
            AWS_HOSTED_ZONE_ID = aws_route53_zone.base_domain.id
        }
    }
}

resource aws_ssm_parameter cert_privatekey_hf {
    for_each = local.hec_certmap
    name = "/application/splunk/certificate/${each.key}/privatekey"
    value = acme_certificate.certificate_hec[each.key].private_key_pem
    type = "SecureString"
}
resource aws_ssm_parameter cert_certificate_hf {
    for_each = local.hec_certmap
    name = "/application/splunk/certificate/${each.key}/certificate"
    value = acme_certificate.certificate_hec[each.key].certificate_pem
    type = "SecureString"
}
resource aws_ssm_parameter cert_intermediate_hf {
    for_each = local.hec_certmap
    name = "/application/splunk/certificate/${each.key}/intermediate"
    value = acme_certificate.certificate_hec[each.key].issuer_pem
    type = "SecureString"
}
