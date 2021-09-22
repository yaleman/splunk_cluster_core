
# TODO: rename this resource
resource aws_instance splunk_index_tier {

  lifecycle {
    ignore_changes = [
      user_data, # don't kill a platform for a build step
    ]
  }
  count = local.indexer_count
  ami = data.aws_ami.splunk.id
  instance_type = local.indexer_instance_type
  key_name = aws_key_pair.keypair.key_name
  associate_public_ip_address = true
  subnet_id = aws_subnet.splunk[count.index%2].id
  vpc_security_group_ids = [ 
    # set in sg_index_cluster_traffic.tf - allow cluster nodes to talk to each other
    aws_security_group.index_tier_replication.id,
    # set in sg_index_cluster_traffic.tf - allows various things to talk to the indexers on 9997
    aws_security_group.splunk_allow_all_tcp_9997.id,
    ]
  root_block_device {
  	volume_type = "gp2"
  	volume_size = local.default_root_disk_size_gb
  	delete_on_termination = true
  	encrypted = true
  }
  tags = merge(local.common_tags,{
    Name = "index-tier${count.index}"
  })

  volume_tags = merge(local.common_tags,{
    Name = "index-tier${count.index}"
  })
  
  iam_instance_profile = aws_iam_instance_profile.index_tier.name

  user_data = templatefile("templates/index_tier/userdata_index_tier.tpl", {
    #copy_test_data = file("templates/userdata_copy_test_data.txt")
    index_tier_init_instance_storage = file("files/index_tier_init_instance_storage.sh")
    updateforwarderaddress= base64encode(file("files/update-forwarderaddress.sh"))
    server_conf = templatefile("templates/index_tier/userdata_index_tier_serverconf.tpl", {
      splunk_cluster_symmkey = data.aws_ssm_parameter.cluster_symmkey.value
      cluster_master_hostname = aws_route53_record.clustermaster.fqdn
    
      splunk_symmkey = data.aws_ssm_parameter.splunk_symmkey.value
      splunk_replication_port = local.splunk_replication_port
      splunk_cluster_master_port = local.splunk_cluster_master_port

    })
    userdata_common = templatefile("templates/userdata_common.tpl",{
      name = "index-tier${count.index}"
      pull_splunk_certs = base64encode(file("files/pull_splunk_certs.sh"))
      update_servername = local.update_servername
      disable_python3_warning = local.disable_python3_warning
      web_conf = base64encode(file("files/web.conf"))
    })
  })


  depends_on = [

  ]


}

# Elastic IPs for the indexers

resource aws_eip index_tier {
    count = length(aws_instance.splunk_index_tier)
    vpc = true
    instance = aws_instance.splunk_index_tier[count.index].id

    tags = merge(local.common_tags,{
        Name = "index-tier${count.index}"
    })
    depends_on = [
        aws_internet_gateway.splunk
    ]
}
