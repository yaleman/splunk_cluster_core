#!/usr/bin/bash

#shellcheck disable=SC2154
${userdata_common}
/bin/systemctl start splunk_update_servername

echo "deployment" > /etc/splunk_role

echo "Setting hostname to the public DNS"
TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 15")
sudo hostnamectl set-hostname "$(curl -s http://169.254.169.254/latest/meta-data/public-hostname -H "X-aws-ec2-metadata-token: $TOKEN")"

cat > /opt/splunk/etc/system/local/outputs.conf <<- 'EOM'
${outputsconf}
EOM

cat > /opt/splunk/etc/system/local/server.conf <<- 'EOM'
${serverconf}
EOM

mkdir -p /home/splunk/.ssh/
#shellcheck disable=SC2154
echo -n "${github_private_key}" | base64 -d | gzip -d -c > /home/splunk/.ssh/github.com
#shellcheck disable=SC2154
echo -n "${ssh_config}" | base64 -d | gzip -d -c > /home/splunk/.ssh/config

chown -R splunk. /home/splunk
chmod 0600 /home/splunk/.ssh/*

echo "Installing git"
yum install -y git
echo "git-clone deployment apps"
mkdir -p /opt/splunk/etc/deployment-apps/
chown -R splunk. /opt/splunk/etc/deployment-apps/
# TODO: CHANGE THIS TO A VARIABLE
sudo -u splunk git clone "${deployment_apps_repo}" /opt/splunk/etc/deployment-apps/


echo "Writing script to pull and reload deployment app config"
echo "${update_splunk_deployment}" | base64 -d | gzip -d -c > /usr/local/sbin/update_splunk_deployment.sh
chmod +x /usr/local/sbin/update_splunk_deployment.sh
echo "Setting up cron job to pull deployment app config"
echo '*/2 * * * * splunk /usr/local/sbin/update_splunk_deployment.sh' | tee '/etc/cron.d/update_splunk_deployment'

echo "Creating serverclass.conf link in /opt/splunk/etc/apps/_serverclassfromgit/default/"
mkdir -p /opt/splunk/etc/apps/_serverclassfromgit/default/
ln -s /opt/splunk/etc/deployment-apps/serverclass.conf /opt/splunk/etc/apps/_serverclassfromgit/default/serverclass.conf

echo "Creating authentication files"
mkdir -p /opt/splunk/etc/system/local/
#shellcheck disable=SC2154
echo -n "${authentication_conf}" | base64 -d | gzip -d -c | sed -e 's/splunk.${base_domain}/splunk-deployment.${base_domain}/'> /opt/splunk/etc/system/local/authentication.conf

mkdir -p /opt/splunk/etc/auth/idpCerts/
# CHECKTHIS - if you're using SAML SSO you'll need this
#shellcheck disable=SC2154
echo -n "${splunk_idpCert}" | base64 -d | gzip -d -c | tee /opt/splunk/etc/auth/idpCerts/idpCert.pem


echo "Resetting owner for /opt/splunk/ to 'splunk.'"
chown -R splunk. /opt/splunk/


echo "Installing cloudflared"
rpm -iv https://bin.equinox.io/c/VdrWdbjqyF/cloudflared-stable-linux-amd64.rpm

mkdir -p /etc/cloudflared

# CHECKTHIS - these details need to be valid for your environment
cat > /etc/cloudflared/config.yml <<- 'EOM'
hostname: splunk-deployment.${base_cloudflare_domain}
url: https://localhost
tunnel: 254da0d0-c45d-430a-96d4-11807a6f993e
credentials-file: /etc/cloudflared/tunnel.json
logfile: /var/log/cloudflared.log
no-tls-verify: true
origin-server-name: deployment.${base_domain}
EOM


echo "Creating cloudflare tunnel auth config"
echo "1 1 * * * root /usr/local/sbin/pull_cloudflare_tunnel_auth.sh | systemd-cat -t pull_cloudflare_tunnel_auth" | tee /etc/cron.d/pull_cloudflare_tunnel_auth_sh
chmod 0755 /etc/cron.d/pull_cloudflare_tunnel_auth_sh
#shellcheck disable=SC2154
echo "${pull_cloudflare_tunnel_auth_sh}" | base64 -d | gzip -d -c | tee -a /usr/local/sbin/pull_cloudflare_tunnel_auth.sh
chmod 0755 /usr/local/sbin/pull_cloudflare_tunnel_auth.sh
echo "Running /usr/local/sbin/pull_cloudflare_tunnel_auth.sh"
/usr/local/sbin/pull_cloudflare_tunnel_auth.sh

/usr/local/bin/cloudflared service install
/bin/systemctl daemon-reload
/bin/systemctl start cloudflared
