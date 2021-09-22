[general]
serverName = cl-CHANGEME
pass4SymmKey = ${splunk_symmkey}

[license]
master_uri = https://clustermaster.${base_domain}:8089
active_group = Enterprise

[sslConfig]
serverCert = /etc/ssl/certs/splunk-fullchain.pem
