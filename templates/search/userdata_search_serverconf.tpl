[general]
serverName = sh-CHANGEME
pass4SymmKey = ${splunk_symmkey}

[clustering]
master_uri = https://${clustermasterfqdn}:${clustermasterport}
pass4SymmKey = ${splunk_cluster_symmkey}
mode = searchhead

[license]
master_uri = https:///${clustermasterfqdn}:${clustermasterport}
active_group = Enterprise
