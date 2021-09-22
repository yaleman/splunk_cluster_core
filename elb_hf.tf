# Classic LB for the heavy forwarders, because reasons.

resource aws_elb hec_classic {
    name = "hec-classic"
    subnets = [ for subnet in aws_subnet.splunk: subnet.id ]
    security_groups = [
        aws_security_group.allow_https_global.id
    ]
    listener {
        instance_port = 8088
        instance_protocol = "TCP"
        lb_port = 443
        lb_protocol = "TCP"
    }

    health_check {
        healthy_threshold   = 5
        unhealthy_threshold = 2
        timeout             = 5
        target              = "HTTPS:8088/services/collector/health/1.0"
        interval            = 30
    }

    instances = [ for instance in aws_instance.splunk_hf: instance.id ]
    idle_timeout = 600
    tags = merge(local.common_tags,{
        Name = "hec-classic"
    })
}
