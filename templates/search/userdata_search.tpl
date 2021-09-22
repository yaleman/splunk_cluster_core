#!/usr/bin/env bash

${userdata_common}

echo "Creating outputs.conf"
cat > /opt/splunk/etc/system/local/outputs.conf <<- 'EOM'
${outputsconf}
EOM

echo "Creating server.conf"
cat > /opt/splunk/etc/system/local/server.conf <<- 'EOM'
${serverconf}
EOM

echo "Creating deploymentclient.conf"
echo "${deploymentclient_conf}" | base64 -d > /opt/splunk/etc/system/local/deploymentclient.conf
