#!/usr/bin/env bash

# userdata for the clustermaster, this needs customisation for your individual use

#shellcheck disable=SC2154
${userdata_common}
/bin/systemctl start splunk_update_servername

echo "Writing role file"
echo "clustermaster" | tee /etc/splunk_role
chmod 0644 /etc/splunk_role

echo "Setting hostname to the public DNS"
TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 15")
sudo hostnamectl set-hostname "$(curl -s http://169.254.169.254/latest/meta-data/public-hostname -H "X-aws-ec2-metadata-token: $TOKEN")"
AWS_REGION="$(curl -s http://169.254.169.254/latest/meta-data/placement/region -H "X-aws-ec2-metadata-token: $TOKEN")"
echo "Setting up the git-powered index cluster config"
echo "Creating .ssh for user: splunk"
mkdir -p /home/splunk/.ssh/


echo "Writing out the github key for indexer config"
aws --region "$AWS_REGION" secretsmanager get-secret-value --secret-id "clustermaster_git_deploy_key" --output json | jq -r .SecretString > /home/splunk/.ssh/github.com
chmod 0600 /home/splunk/.ssh/github.com
echo "Writing out /home/splunk/.ssh/config"
cat > /home/splunk/.ssh/config <<- 'EOM'
Host github.com
    IdentityFile ~/.ssh/%h
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
EOM

echo "Add the github.com ssh key to known_hosts"
ssh-keyscan github.com >> /home/splunk/.ssh/known_hosts
echo "Fix /home/splunk/.ssh/ permissions"
chmod 0700 /home/splunk/.ssh/
chmod 0600 /home/splunk/.ssh/*
chown -R splunk. /home/splunk/

echo "Installing git"
yum install -q -y git

echo "Downloading the configuration"
mkdir -p /opt/splunk/etc/master-apps
sudo chown -R splunk. /opt/splunk/etc/
sudo -u splunk git clone "${git_cluster_config_repo}" /opt/splunk/etc/master-apps

echo "Creating /opt/splunk/etc/system/local"
mkdir -p /opt/splunk/etc/system/local/

echo "### server.conf"
#shellcheck disable=SC2154
echo -n "${server_conf}" | base64 -d | gzip -d -c | tee /opt/splunk/etc/system/local/server.conf

echo "### outputs.conf"
#shellcheck disable=SC2154
echo -n "${outputsconf}" | base64 -d | gzip -d -c | tee /opt/splunk/etc/system/local/outputs.conf

echo "Creating the license file"
mkdir -p /opt/splunk/etc/licenses/enterprise/
#shellcheck disable=SC2154
echo -n "${splunk_licensefile_1}" | base64 -d | gzip -d -c | tee /opt/splunk/etc/licenses/enterprise/Splunk1.License.lic

echo "Resetting owner for /opt/splunk/ to 'splunk.'"
chown -R splunk. /opt/splunk/

echo "Creating authentication files"
mkdir -p /opt/splunk/etc/system/local/
# CHECKTHIS - this renames the local host based on your domain name for authentication.conf
#shellcheck disable=SC2154
echo -n "${authentication_conf}" | base64 -d | gzip -d -c | sed -e 's/splunk.example/splunk-clustermaster.example/' | tee /opt/splunk/etc/system/local/authentication.conf

mkdir -p /opt/splunk/etc/auth/idpCerts/
# CHECKTHIS - if you're using SAML SSO you'll need this
#shellcheck disable=SC2154
echo -n "${splunk_idpCert}" | base64 -d | gzip -d -c | tee /opt/splunk/etc/auth/idpCerts/idpCert.pem


echo "Installing cloudflared"
rpm -iv https://bin.equinox.io/c/VdrWdbjqyF/cloudflared-stable-linux-amd64.rpm

mkdir -p /etc/cloudflared

cat > /etc/cloudflared/config.yml <<- 'EOM'
hostname: splunk-clustermaster.${base_cloudflare_domain}
url: https://localhost
tunnel: ${cloudflare_tunnelid}
credentials-file: /etc/cloudflared/tunnel.json
logfile: /var/log/cloudflared.log
no-tls-verify: true
origin-server-name: clustermaster.${base_domain}
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
