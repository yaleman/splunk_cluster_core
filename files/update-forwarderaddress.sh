#!/bin/bash
# chkconfig: 3 20 80

# this fixes the register_forwarder_address in server.conf, it's used because splunk typically uses the "internal" IPv4 address so public nodes can't send data to the indexers
#
# in the terraform config this needs to be stored as a base64-encoded file so that it can be copied across - when it's written from userdata you don't want it running the curl command

echo "Fixing register_forwarder_address in server.conf"
sed -i'.bak' -e 's/\(register_forwarder_address =.*\)FORWARDERADDRESS/\1'$(curl -s "http://169.254.169.254/latest/meta-data/public-ipv4")'/' /opt/splunk/etc/system/local/server.conf
