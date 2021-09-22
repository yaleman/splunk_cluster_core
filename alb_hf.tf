resource aws_lb hec_https {
    name               = "hec"
    internal           = false
    load_balancer_type = "application"
    security_groups = [
        aws_security_group.allow_https_global.id
    ]
    subnets            = [for s in aws_subnet.splunk : s.id]
    enable_deletion_protection = false

    tags = merge(local.common_tags,{
        Name = "hec"
        description = "HTTPS ALB for Splunk HTTP Event Collector"
    })
}

resource aws_lb_target_group hec_https {
    name     = "hec"
    port     = 8088
    protocol = "HTTPS"
    vpc_id   = aws_vpc.splunk.id

    health_check {
        interval = 5
        path = "/services/collector/health"
        protocol = "https"
        matcher = "200"
    }
    tags = merge(local.common_tags,{
        Name = "hec"
    })
}


resource aws_lb_target_group_attachment hec {
    count = length(aws_instance.splunk_hf)
    target_group_arn = aws_lb_target_group.hec_https.arn
    target_id = aws_instance.splunk_hf[count.index].id
    port = 8088
}

resource aws_lb_listener hec {
  load_balancer_arn = aws_lb.hec_https.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.hec.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.hec_https.arn
  }

}
