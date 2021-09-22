[general]
serverName = idx-CHANGEME
pass4SymmKey = ${splunk_symmkey}

[replication_port://${splunk_replication_port}]

[clustering]
master_uri = https://${cluster_master_hostname}:${splunk_cluster_master_port}
mode = slave
pass4SymmKey = ${splunk_cluster_symmkey}
register_forwarder_address = FORWARDERADDRESS

[license]
master_uri = https://${cluster_master_hostname}:${splunk_cluster_master_port}
active_group = Enterprise

[sslConfig]
serverCert = /etc/ssl/certs/splunk-fullchain.pem
