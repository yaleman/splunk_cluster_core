[general]
serverName = c0m1-CHANGEME
pass4SymmKey = ${splunk_symmkey}

[clustering]
mode = master
replication_factor = 2
search_factor = 2
pass4SymmKey = ${splunk_cluster_symmkey}
cluster_label = ${splunk_cluster_label}


[indexer_discovery]
pass4SymmKey = ${splunk_discovery_symmkey}

[sslConfig]
serverCert = /etc/ssl/certs/splunk-fullchain.pem
