# Elastic IP for the search head, because changing it makes things less fun.

resource aws_eip search {
    vpc = true
    instance = aws_instance.search.id

    tags = merge(local.common_tags,{
        name = "search"
    })

    depends_on = [
        aws_internet_gateway.splunk
    ]
}

resource aws_instance search {

  lifecycle {
    ignore_changes = [
      user_data, # don't kill a platform for a build step
    ]
  }


  ami           = data.aws_ami.splunk.id
  instance_type = local.search_instance_type
  # enable termination protection
  disable_api_termination = true
  iam_instance_profile = aws_iam_instance_profile.generic.name

  key_name = aws_key_pair.keypair.key_name
  associate_public_ip_address = true
  vpc_security_group_ids = [ 
    aws_security_group.i_am_a_search_head.id,
    aws_security_group.global_rules.id,
    ]
  root_block_device {
  	volume_type = "gp2"
  	volume_size = local.default_root_disk_size_gb
    # CHECKTHIS - this is a super safe mode step to avoid things blowing up when you accidentally break the search head
  	delete_on_termination = false 
  	encrypted = true
  }
  subnet_id = aws_subnet.splunk[0].id

  tags = merge(local.common_tags, {
    Name = "search"
    backuppolicy = "silver"
  })
  volume_tags = merge(local.common_tags, {
    Name = "search"
    backuppolicy = "silver"
  })

  user_data = templatefile("templates/search/userdata_search.tpl", {
    userdata_common = templatefile("templates/userdata_common.tpl",{
      name = "search"
      pull_splunk_certs = base64encode(file("files/pull_splunk_certs.sh"))
      update_servername = local.update_servername
      disable_python3_warning = local.disable_python3_warning
      web_conf = base64encode(file("files/web.conf"))
    })
    outputsconf = local.userdata_outputsconf
    deploymentclient_conf = local.deploymentclient_conf
    serverconf = templatefile("templates/search/userdata_search_serverconf.tpl",{
      basedomain = var.base_domain
      clustermasterfqdn = aws_route53_record.clustermaster.fqdn
      clustermasterport = local.splunk_api_port
      splunk_cluster_symmkey = data.aws_ssm_parameter.cluster_symmkey.value
      splunk_symmkey = data.aws_ssm_parameter.splunk_symmkey.value
    })    
    })

  depends_on = [
    aws_instance.clustermaster
    ]

}

# output "search_tier_data" {
#   value =  templatefile("output_instance_data.tpl", { 
#     instance_type = "Search",
#     var = {
#       public_dns = aws_instance.search.public_dns,
#       instance_id = aws_instance.search.id,
#       }
#     }
#   )
# }

# this volume stores the user-related data of splunk
resource aws_ebs_volume splunk_search_userdata {
  availability_zone = aws_instance.search.availability_zone
  size              = 20
  encrypted   = true
  tags = merge(local.common_tags, {
    Name = "search"
    backuppolicy = "silver"
  })
}
resource aws_volume_attachment splunk_search_userdata {
  device_name = "/dev/sdu"
  instance_id = aws_instance.search.id
  volume_id = aws_ebs_volume.splunk_search_userdata.id
}

# this volume stores apps in splunk
resource aws_ebs_volume splunk_search_apps {
  availability_zone = aws_instance.search.availability_zone
  size              = 20
  encrypted   = true
  tags = merge(local.common_tags, {
    Name = "search"
    backuppolicy = "silver"
  })
}

resource aws_volume_attachment splunk_search_apps {
  device_name = "/dev/sdp"
  instance_id = aws_instance.search.id
  volume_id = aws_ebs_volume.splunk_search_apps.id
}