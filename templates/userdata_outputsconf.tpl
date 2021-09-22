[indexer_discovery:splunk-indexer]
master_uri = https://${clustermasterfqdn}:${clustermasterport}
pass4SymmKey = ${splunk_discovery_symmkey}

[tcpout:indexers]
indexerDiscovery = splunk-indexer
