resource aws_instance collector {
  ami           = data.aws_ami.splunk.id
  instance_type = local.instance_type_deployment

  iam_instance_profile = aws_iam_instance_profile.generic.name

  associate_public_ip_address = true
  vpc_security_group_ids = [ 
    aws_security_group.i_am_a_search_head.id,
    aws_security_group.global_rules.id,
  ]
  subnet_id = aws_subnet.splunk[0].id
  root_block_device {
    volume_type = "gp2"
    volume_size = local.default_root_disk_size_gb
    delete_on_termination = true 
    encrypted = true
  }

  tags = merge(local.common_tags,{
    Name = local.instance_name_collector
  })
  
  volume_tags = merge(local.common_tags,{
    Name = "collector"
  })

  user_data = templatefile("templates/collector/userdata_collector.tpl", {
    name = local.instance_name_collector
    base_domain = var.base_domain
    base_cloudflare_domain = var.base_cloudflare_domain
    authentication_conf = base64encode(file("files/authentication.conf"))
    
    # this comes from the SSO config, if you're using SAML
    # splunk_idpCert = base64gzip(file("files/splunk_idpCert.pem"))
    splunk_idpCert = ""

    userdata_common = templatefile("templates/userdata_common.tpl",{
      name = "collector"
      pull_splunk_certs = base64encode(file("files/pull_splunk_certs.sh"))
      update_servername = local.update_servername
      disable_python3_warning = local.disable_python3_warning
      web_conf = base64encode(file("files/web.conf"))
    })
    outputsconf = local.userdata_outputsconf

    serverconf = templatefile("templates/collector/userdata_collector_serverconf.tpl",{
      splunk_symmkey = data.aws_ssm_parameter.splunk_symmkey.value
      base_domain = var.base_domain
    })
  })

  depends_on = [
    aws_instance.clustermaster
    ]
}

# output "collector_tier_data" {
#   value =  templatefile("output_instance_data.tpl", { 
#     instance_type = local.instance_name_collector,
#     var = {
#       public_dns = aws_instance.collector.public_dns,
#       instance_id = aws_instance.collector.id,
#       }
#     }
#   )
# }