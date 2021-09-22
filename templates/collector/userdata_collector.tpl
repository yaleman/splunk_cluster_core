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

echo "Creating authentication files"
mkdir -p /opt/splunk/etc/system/local/

#shellcheck disable=SC2016,2154
echo -n "${authentication_conf}" | base64 -d | sed -e 's/splunk.${base_domain}/splunk-collector.${base_domain}/'> /opt/splunk/etc/system/local/authentication.conf

mkdir -p /opt/splunk/etc/auth/idpCerts/
# CHECKTHIS - if you're using SAML SSO you'll need this
#shellcheck disable=2154
echo -n "${splunk_idpCert}" | base64 -d | gzip -d -c | tee /opt/splunk/etc/auth/idpCerts/idpCert.pem


echo "Resetting owner for /opt/splunk/ to 'splunk.'"
chown -R splunk. /opt/splunk/


echo "Installing cloudflared"
rpm -iv https://bin.equinox.io/c/VdrWdbjqyF/cloudflared-stable-linux-amd64.rpm

mkdir -p /etc/cloudflared

cat > /etc/cloudflared/config.yml <<- 'EOM'
hostname: splunk-collector.${base_cloudflare_domain}
url: https://localhost
logfile: /var/log/cloudflared.log
no-tls-verify: true
origin-server-name: collector.${base_domain}
EOM

echo "Doing the cloudflare install"
/usr/local/bin/cloudflared service install
