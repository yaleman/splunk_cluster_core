#!/bin/bash
# chkconfig: 3 20 80

# updates servername in server conf based on instance ID
#
# in the terraform config this needs to be stored as a base64-encoded file so that it can be copied across - when it's written from userdata you don't want it running the curl command

sed -i'.bak' -e 's/\(serverName =.*\)CHANGEME/\1'$(curl -s http://169.254.169.254/latest/meta-data/instance-id)'/' /opt/splunk/etc/system/local/server.conf

SERVERNAME=$(grep serverName /opt/splunk/etc/system/local/server.conf | awk '{ print $NF }')

echo "Updating clientName in deploymentclient.conf to ${SERVERNAME}"
sudo sed -ibak -E "s/clientName.*/clientName = ${SERVERNAME}/g" /opt/splunk/etc/system/local/deploymentclient.conf
