
variable allowed_ips {
  default = [
      "1.2.3.4/32",
  ]
}

variable aws_account_id {
    type = string
    description = "used for some policy things to configure access to secrets"
}

variable availability_zones {
    type = list(string)
    description = "A list of the AZs that this will be built in"
#     default = [
#     "${local.aws_region}-2a",
#     "${local.aws_region}-2b",
#     "${local.aws_region}-2c",
#   ]
}

variable base_domain {
    type = string
    description = "base domain name for the cluster, eg example.com will get you cluster_master.example.com etc"
}

variable base_cloudflare_domain {
    type = string
    description = "base domain name for things hosted behind cloudflare, eg splunk-clustermaster.base_cloudflare_domain"
}

variable cloudflare_tunnelid_clustermaster {
    type = string
    description = "The tunnel ID for cloudflared to use in the clustermaster"
}

variable data_bucket {
    type = string
    description = "name of the bucket where all the index data goes"
}

variable deployment_name {
    type = string
    description = "used for a load of different tags and things"
    default = "splunk-cluster"
}

variable business_owner_email {
    type = string
    description = "gets put into tags"
}
variable technical_owner_email {
    type = string
    description = "gets put into tags"
}
variable letsencrypt_owner_email {
    type = string
    description = "Email account for letsencrypt certs - don't change this unless you want a bad day."
}

variable git_cluster_config_repo {
    type = string
    description = "Where the cluster master / indexer nodes git-clone their base configuration from"
    default = "git@github.com:/yaleman/splunk_cluster_indexers"
}
