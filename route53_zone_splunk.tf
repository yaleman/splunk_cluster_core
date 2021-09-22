resource aws_route53_zone base_domain {
  name = data.aws_ssm_parameter.dns_zone.value
}
