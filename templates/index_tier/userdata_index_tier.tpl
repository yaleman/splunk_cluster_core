#!/usr/bin/env bash

${userdata_common}

echo "##################################################"
echo "Doing all the build things"
echo "##################################################"


echo "Writing instance storage systemd config"

cat > /etc/systemd/system/instancestorage.service <<- 'EOM'
[Unit]
Description=Initialise instance storage on boot

[Service]
Type=oneshot
ExecStart=/opt/initialise_instance_storage.sh

[Install]
WantedBy=multi-user.target

EOM

INITSTORAGESCRIPT="/opt/initialise_instance_storage.sh"
echo "Writing $INITSTORAGESCRIPT"
cat > $INITSTORAGESCRIPT <<- 'EOM'
${index_tier_init_instance_storage}
EOM
chmod +x $INITSTORAGESCRIPT
echo "Forcing splunk to wait for instance storage init"
SPLUNKDREQUIRES="/etc/systemd/system/Splunkd.service.requires"
# create the 'service.requires' folder
mkdir -p $SPLUNKDREQUIRES 
# put the instance storage thing in the requires folder
ln -s /etc/systemd/system/instancestorage.service $SPLUNKDREQUIRES

echo "Writing forwarderaddress script"
echo "${updateforwarderaddress}" | base64 -d > /opt/update_forwarderaddress.sh
chmod +x /opt/update_forwarderaddress.sh

cat > /etc/systemd/system/splunk_update_forwarderaddress.service <<- 'EOM'
[Unit]
Description=Rewrites server.conf to replace the server public IP

[Service]
Type=oneshot
ExecStart=/opt/update_forwarderaddress.sh

[Install]
WantedBy=multi-user.target

EOM

echo "Forcing splunk to wait for update_forwarderaddress fixer"
# create the 'service.requires' folder
mkdir -p /etc/systemd/system/Splunkd.service.requires 
# put the service thing in the requires folder
ln -s /etc/systemd/system/splunk_update_forwarderaddress.service /etc/systemd/system/Splunkd.service.requires

systemctl daemon-reload
systemctl enable splunk_update_forwarderaddress
systemctl start splunk_update_forwarderaddress

echo "Done creating the service for update_forwarderaddress.sh"




echo "Loading new systemd config"
systemctl daemon-reload

echo "Setting hostname to the public DNS"
TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 15")
sudo hostnamectl set-hostname "$(curl -s http://169.254.169.254/latest/meta-data/public-hostname -H "X-aws-ec2-metadata-token: $TOKEN")"

echo "##################################################"
echo "Create the s3 config indexes.conf"
echo "##################################################"
echo "Make sure the splunk local config directory exists"
mkdir -p /opt/splunk/etc/system/local/

echo "Writing server.conf"
cat > /opt/splunk/etc/system/local/server.conf <<- 'EOM'
${server_conf}
EOM

echo "Fixing permissions on splunk directories"
chown -R splunk. /opt/splunk
