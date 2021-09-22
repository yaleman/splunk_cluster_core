
resource aws_instance splunk_hf {
  count = local.hf_count

  ami           = data.aws_ami.splunk.id
  instance_type = local.hf_instance_type
  key_name = aws_key_pair.keypair.key_name
  associate_public_ip_address = true

  iam_instance_profile = aws_iam_instance_profile.generic.name

  vpc_security_group_ids = [ 
    aws_security_group.splunk_hf_8088.id,
    aws_security_group.i_am_a_hf.id
    ]
  subnet_id = aws_subnet.splunk[count.index%2].id

  root_block_device {
  	volume_type = "gp2"
  	volume_size = local.default_root_disk_size_gb
  	delete_on_termination = true
  	encrypted = true
  }
  
  tags = merge(local.common_tags, {
    Name = "hf${count.index}"
  })

  volume_tags = merge(local.common_tags,{
    Name = "hf${count.index}"
  })

  user_data = templatefile("templates/hf/userdata_hf.tpl", {
    # common userdata things
    userdata_common = templatefile("templates/userdata_common.tpl",{
      name = "hf${count.index}"
      pull_splunk_certs = base64encode(file("files/pull_splunk_certs.sh"))
      update_servername = local.update_servername
      disable_python3_warning = local.disable_python3_warning
      web_conf = base64encode(file("files/web.conf"))
    })
    # config files
    deploymentclient_conf = local.deploymentclient_conf
    outputsconf = local.userdata_outputsconf
    serverconf = templatefile("templates/hf/userdata_hf_serverconf.tpl", {
      splunk_symmkey = data.aws_ssm_parameter.splunk_symmkey.value
    })
  })

  depends_on = [
    aws_instance.clustermaster
    ]

}

# output "hf_data" {
#   value =  templatefile("templates/index_tier/output_index_instance_data.tpl", { 
#     instance_type = "Heavy Forwarder",
#     instances = aws_instance.splunk_hf[*]
#     }
#   )
# }