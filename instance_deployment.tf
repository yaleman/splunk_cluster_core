# Elastic IP for the deployment server's front end, so it doesn't move around and mess up DNS when you rebuild.

resource aws_eip deployment {
    vpc = true
    instance = aws_instance.deployment.id

    tags = merge(local.common_tags, {
        Name = "deployment"
    })
    
    depends_on = [
        aws_internet_gateway.splunk
    ]
}

resource aws_instance deployment {
  ami           = data.aws_ami.splunk_8_1_1.id
  instance_type = local.instance_type_deployment

  iam_instance_profile = aws_iam_instance_profile.generic.name

  key_name = aws_key_pair.keypair.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.i_am_a_search_head.id,
    aws_security_group.global_rules.id,
    aws_security_group.deployment.id,
  ]
  subnet_id = aws_subnet.splunk[0].id
  root_block_device {
    volume_type = "gp2"
    volume_size = local.default_root_disk_size_gb
    delete_on_termination = true
    encrypted = true
  }
  volume_tags = merge(local.common_tags,{
    Name = "deployment"
  })

  tags = merge(local.common_tags,{
    Name = local.instance_name_deployment
  })

  user_data = templatefile("templates/deployment/userdata_deployment.tpl", {
    name = local.instance_name_deployment
    base_domain = var.base_domain
    base_cloudflare_domain = var.base_cloudflare_domain
    deployment_apps_repo = var.deployment_apps_repo
    github_private_key = base64gzip(data.aws_ssm_parameter.deployment_github_private_key.value)
    ssh_config = base64gzip(file("files/deployment/sshconfig"))

    update_splunk_deployment = base64gzip(file("files/deployment/update_splunk_deployment.sh"))
    pull_cloudflare_tunnel_auth_sh = base64gzip(file("files/pull_cloudflare_tunnel_auth.sh"))


    authentication_conf = base64gzip(file("files/authentication.conf"))

    # this comes from the SSO config, if you're using SAML
    # splunk_idpCert = base64gzip(file("files/splunk_idpCert.pem"))
    splunk_idpCert = ""

    userdata_common = templatefile("templates/userdata_common.tpl",{
      name = "deployment"
      pull_splunk_certs = base64encode(file("files/pull_splunk_certs.sh"))
      update_servername = local.update_servername
      disable_python3_warning = local.disable_python3_warning
      web_conf = base64encode(file("files/web.conf"))
    })
    outputsconf = local.userdata_outputsconf

    serverconf = templatefile("templates/deployment/userdata_deployment_serverconf.tpl",{
      splunk_symmkey = data.aws_ssm_parameter.splunk_symmkey.value
      base_domain = var.base_domain
    })
  })

  depends_on = [
    aws_instance.clustermaster,
    aws_eip.deployment,
    ]
}

# output "deployment_tier_data" {
#   value =  templatefile("output_instance_data.tpl", {
#     instance_type = local.instance_name_deployment,
#     var = {
#       public_dns = aws_instance.deployment.public_dns,
#       instance_id = aws_instance.deployment.id,
#       }
#     }
#   )
# }