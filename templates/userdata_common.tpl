# NOTE ANY CHANGES TO THIS FILE WILL CAUSE A RE-CREATION OF ALL INSTANCES

# aws tools
yum install -y ec2-instance-connect
yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl start amazon-ssm-agent

# need jq for lots of things
yum install -y jq

# fix permissions so that /opt/aws is not owned by splunk
chown root. /opt/
chown -R root. /opt/aws/

echo "Adding splunk user"
useradd splunk

# install all the updates
yum update -y

# set the instance name in a file, so we can get certs later
echo -n ${name} > /etc/instance_name
chmod 0600 /etc/instance_name

# splunk certs script
PULLSPLUNKCERTS=/usr/local/sbin/pull_splunk_certs.sh
echo "Writing $PULLSPLUNKCERTS"
echo -n "${pull_splunk_certs}" | base64 -d > "$PULLSPLUNKCERTS"
chmod +x "$PULLSPLUNKCERTS"
echo "linking $PULLSPLUNKCERTS into /etc/cron.weekly"
ln -s /usr/local/sbin/pull_splunk_certs.sh /etc/cron.weekly/
ls -la /etc/cron.weekly/
echo "Running $PULLSPLUNKCERTS"
$PULLSPLUNKCERTS

echo "Make sure the splunk local config directory exists"
mkdir -p /opt/splunk/etc/system/local/

echo "Disabling the py3 warnings using user-prefs.conf"
cat > /opt/splunk/etc/system/local/user-prefs.conf <<- 'EOM'
${disable_python3_warning}
EOM

echo "Writing a default web.conf"
echo ${web_conf} | base64 -d > /opt/splunk/etc/system/local/web.conf

echo "Creating sysctl config to allow unpriv to run on port 443 and above"
echo "net.ipv4.ip_unprivileged_port_start=443" > /etc/sysctl.d/90-allow-unpriv-443.conf
sysctl -w net.ipv4.ip_unprivileged_port_start=443
${update_servername}