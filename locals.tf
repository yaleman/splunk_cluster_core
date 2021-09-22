locals {
  

  common_tags = {
    platform = "splunk"
    environment = "prod"
    billingcode = "splunk"
    technicalowner = var.technical_owner_email
    businessowner = var.business_owner_email
    backuppolicy = "none" # the only thing that actually needs backing up is the search head - everything else is built from userdata on instantiation
    Name = "splunk" # this should be overridden on the instance, but here's a default
    documentation = "https://github.com/yaleman/splunk_cluster_core"
    iac = "terraform"
  }

  # where you want to host things
  aws_region = "ap-southeast-2"

  splunk_internalnet = "10.138.16.0/24"

  # a wildcard search for the splunk version that you want to run
  aws_ami_filter = "splunk_AMI_8.0.1*"
  aws_ami_filter_8_1_1 = "splunk_AMI_8.1.1*"

  # search head instance type
  search_instance_type = "m5a.4xlarge"
  # this'll need checking to see if it scales
  instance_name_collector = "collector"
  instance_name_deployment = "deployment"
  instance_type_deployment = "t3.medium"
  # cluster master instance type, doesn't have to be huge as it does coordination
  cm_instance_type = "t3.medium"
  # indexers - the beefy buddies
  indexer_instance_type = "i3.2xlarge"
  indexer_count = 2
  # heavy forwarders
  hf_instance_type = "t3.micro"
  hf_count = 2


  splunk_api_port = 8089
  splunk_data_port = 9997
  splunk_replication_port = 9887
  splunk_cluster_master_port = 8089

  cluster_master_hostname = "clustermaster"

  cluster_master_fqdn = join(".", [local.cluster_master_hostname, data.aws_ssm_parameter.dns_zone.value])

  # Specify the disk size in Gb
  default_root_disk_size_gb = 40

  disable_python3_warning = file("templates/userdata_user-prefsconf_disable_python3_warning.txt")

  update_servername = templatefile("templates/userdata_install_update_servername.tpl", {
      update_servername_file = base64encode(file("files/update-servername.sh"))  #base64-encoded so it's easier to write it to disk later
    })

  userdata_outputsconf = templatefile("templates/userdata_outputsconf.tpl",{
      clustermasterfqdn = local.cluster_master_fqdn
      clustermasterport = local.splunk_api_port
      splunk_discovery_symmkey = data.aws_ssm_parameter.discovery_symmkey.value
  })
  deploymentclient_conf = base64encode(templatefile("templates/deploymentclient.conf.tpl", {
    deploymentserver = aws_route53_record.deployment.fqdn,
  }))

  # the certificates to issue with letsencrypt, HEC certs are done differently because they need a SAN
  certmap = {
      search = aws_route53_record.search.fqdn,

      clustermaster = aws_route53_record.clustermaster.fqdn,

      collector = aws_route53_record.collector.fqdn,
      deployment = aws_route53_record.deployment.fqdn,
      index-tier0 = aws_route53_record.splunk_index_tier[0].fqdn,
      index-tier1 = aws_route53_record.splunk_index_tier[1].fqdn,


  }
  hec_certmap = {
      hf0 = aws_route53_record.hf[0].fqdn,
      hf1 = aws_route53_record.hf[1].fqdn,
  }

}
