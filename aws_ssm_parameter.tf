# CHECKTHIS - all the things

# cluster communication encryption key
data aws_ssm_parameter cluster_symmkey {
  name = "/application/splunk/cluster/symmkey"
}

# cluster label, becomes cluster_label in server.conf - https://docs.splunk.com/Documentation/Splunk/8.0.2/Admin/Serverconf#High_availability_clustering_configuration
data aws_ssm_parameter cluster_label {
  name = "/application/splunk/cluster/label"
}

# discovery symmkey - used by the nodes to work out indexer discovery
data aws_ssm_parameter discovery_symmkey {
  name = "/application/splunk/discovery/symmkey"
}

# public key for connecting to the instances
data aws_ssm_parameter ssh_public_key {
  name = "/application/splunk/ssh/public_key"
}

# base dns zone (eg, example.com)
data aws_ssm_parameter dns_zone {
    name = "/application/splunk/dns/zone"
    # CHECKTHIS TODO -  this needs to be set somewhere
}

resource aws_ssm_parameter clustermaster_fdqn {
    name = "/application/splunk/clustermaster/fqdn"
    value = local.cluster_master_fqdn
    type = "SecureString"
}

# store the license file in here
data aws_ssm_parameter splunk_licensefile_1 {
  name = "/application/splunk/licensing/file1"
}

# this is used by every client to auth to licensing, deployment, etc
# * Authenticates traffic between:
#   * License master and its license slaves.
#   * Members of a cluster.
#   * Deployment server (DS) and its deployment clients (DCs).
data aws_ssm_parameter splunk_symmkey {
  name = "/application/splunk/global/pass4Symmkey"
}

# used for pulling the deployment-apps
data aws_ssm_parameter deployment_github_private_key {
  name = "/application/splunk/deployment/github_private_key"
}

# this can be pulled by anyone needing outputs.conf
resource aws_ssm_parameter generic_outputs_conf {
    name = "/application/splunk/global/outputs_conf"
    value = local.userdata_outputsconf
    type = "SecureString"
}


###################################################################################################################
# CLUSTERMASTER
###################################################################################################################


resource aws_secretsmanager_secret cloudflared_clustermaster_tunnelfile {
  name = "cloudflared_clustermaster_tunnelfile"
}

# resource aws_secretsmanager_secret_version cloudflared_clustermaster_tunnelfile {
#   secret_id     = aws_secretsmanager_secret.cloudflared_clustermaster_tunnelfile.id
#   secret_string = file("clustermaster-tunnel.json")
# }

resource aws_secretsmanager_secret cloudflared_clustermaster_cert {
  name = "cloudflared_clustermaster_cert"
}
# resource aws_secretsmanager_secret_version cloudflared_clustermaster_cert {
#   secret_id     = aws_secretsmanager_secret.cloudflared_clustermaster_cert.id
#   secret_string = file("clustermaster_cloudflare_cert.pem")

resource aws_secretsmanager_secret clustermaster_git_deploy_key {
  name = "clustermaster_git_deploy_key"
}

# resource aws_secretsmanager_secret_version clustermaster_git_deploy_key {
#   secret_id     = aws_secretsmanager_secret.clustermaster_git_deploy_key.id
#   secret_string = file("files/github_splunk_staging_terraform_indexer_config")
# }


###################################################################################################################
# CLUSTERMASTER
###################################################################################################################

# }

resource aws_secretsmanager_secret cloudflared_deployment_tunnelfile {
  name = "cloudflared_deployment_tunnelfile"
}


# resource aws_secretsmanager_secret_version cloudflared_deployment_tunnelfile {
#   secret_id     = aws_secretsmanager_secret.cloudflared_deployment_tunnelfile.id
#   secret_string = file("deployment-tunnel.json")
# }

resource aws_secretsmanager_secret cloudflared_deployment_cert {
  name = "cloudflared_deployment_cert"
}

# resource aws_secretsmanager_secret_version cloudflared_deployment_cert {
#   secret_id     = aws_secretsmanager_secret.cloudflared_deployment_cert.id
#   secret_string = file("deployment_cloudflare_cert.pem")
# }






