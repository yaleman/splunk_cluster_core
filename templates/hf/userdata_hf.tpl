#!/usr/bin/env bash

${userdata_common}

echo "Setting hostname to the public DNS"
TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 15")
sudo hostnamectl set-hostname "$(curl -s http://169.254.169.254/latest/meta-data/public-hostname -H "X-aws-ec2-metadata-token: $TOKEN")"

cat > /opt/splunk/etc/system/local/outputs.conf <<- 'EOM'
${outputsconf}
EOM

cat > /opt/splunk/etc/system/local/server.conf <<- 'EOM'
${serverconf}
EOM

echo "Creating deploymentclient.conf"
echo "${deploymentclient_conf}" | base64 -d > /opt/splunk/etc/system/local/deploymentclient.conf
