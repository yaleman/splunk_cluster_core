# Elastic IP for the cluster master's front end, so it doesn't move around and mess up DNS when you rebuild.

resource aws_eip clustermaster {
    vpc = true
    instance = aws_instance.clustermaster.id

    tags = merge(local.common_tags,{
        Name = "clustermaster"
    })
    depends_on = [
        aws_internet_gateway.splunk
    ]
}

# the instance itself

resource aws_instance clustermaster {
  ami           = data.aws_ami.splunk_8_1_1.id
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.generic.name

  # set in config.tf
  instance_type = local.cm_instance_type
  # set in key_pair.tf
  key_name = aws_key_pair.keypair.key_name
  vpc_security_group_ids = [
    # set in sg_allowed_access.tf
    aws_security_group.allowed_access.id,
    # set in sg_index_cluster_traffic.tf
    aws_security_group.splunk_allow_all_tcp_8089.id,
    # set in sg_index_cluster_traffic.tf - allow cluster nodes to talk to each other
    aws_security_group.index_tier_replication.id,
    ]

  subnet_id = aws_subnet.splunk[0].id
  root_block_device {
    volume_type = "gp2"
    volume_size = local.default_root_disk_size_gb
    delete_on_termination = true
    encrypted = true
  }

  tags = merge(local.common_tags,{
    Name = "clustermaster"
  })

  volume_tags = merge(local.common_tags,{
    Name = "clustermaster"
  })

  user_data = templatefile("templates/cm/userdata_cm.tpl", {

    authentication_conf = base64gzip(file("files/authentication.conf"))
    git_indexer_repo = var.git_cluster_config_repo
    
    base_cloudflare_domain = var.base_cloudflare_domain
    base_domain = var.base_domain
    
    # this comes from the SSO config, if you're using SAML
    # splunk_idpCert = base64gzip(file("files/splunk_idpCert.pem"))
    splunk_idpCert = ""
    
    cloudflare_tunnelid = var.cloudflare_tunnelid_clustermaster
    pull_cloudflare_tunnel_auth_sh = base64gzip(file("files/pull_cloudflare_tunnel_auth.sh"))

    userdata_common = templatefile("templates/userdata_common.tpl",{
      name = "clustermaster",
      pull_splunk_certs = base64encode(file("files/pull_splunk_certs.sh"))
      disable_python3_warning = local.disable_python3_warning
      update_servername = local.update_servername
      web_conf = base64encode(file("files/web.conf"))
    })

    splunk_licensefile_1 = base64gzip(data.aws_ssm_parameter.splunk_licensefile_1.value)
    server_conf = base64gzip(templatefile("templates/cm/userdata_cm_serverconf.tpl", {
      splunk_cluster_label = data.aws_ssm_parameter.cluster_label.value
      splunk_cluster_symmkey = data.aws_ssm_parameter.cluster_symmkey.value
      splunk_symmkey = data.aws_ssm_parameter.splunk_symmkey.value


      splunk_discovery_symmkey = data.aws_ssm_parameter.discovery_symmkey.value
    }))
    # this can't use local.userdata_outputsconf because it helps set it
    outputsconf = base64gzip(local.userdata_outputsconf)

    })

  depends_on = [
    aws_secretsmanager_secret.cloudflared_clustermaster_tunnelfile,
    ]


}
