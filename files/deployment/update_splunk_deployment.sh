#!/bin/bash

# This runs on the deployment server to pull the repository and reload coniguratino periodically
#
# Yes, the admin password is set to the default.

SYSTEMD_TOPIC="$(basename -s .sh "${0}")"

TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 15")
INSTANCEID="$(curl -s http://169.254.169.254/latest/meta-data/instance-id -H "X-aws-ec2-metadata-token: ${TOKEN}")"

if [ -z "${INSTANCEID}" ]; then
    echo "Failed to query instanceID, quitting" | /usr/bin/systemd-cat -t "${SYSTEMD_TOPIC}"
    exit 1
fi

CURRENT_COMMIT="$(/usr/bin/git -C /opt/splunk/etc/deployment-apps/ rev-parse HEAD)"

/usr/bin/git -C /opt/splunk/etc/deployment-apps/ pull 2>&1 | grep -v "Warning: Permanently added" | /usr/bin/systemd-cat -t "${SYSTEMD_TOPIC}"

LATEST_COMMIT="$(/usr/bin/git -C /opt/splunk/etc/deployment-apps/ rev-parse HEAD)"

if [ "${LATEST_COMMIT}" != "${CURRENT_COMMIT}" ]; then
    echo "Reloading splunk deployment server" | /usr/bin/systemd-cat -t "${SYSTEMD_TOPIC}"
    /opt/splunk/bin/splunk reload deploy-server -auth "admin:SPLUNK-${INSTANCEID}" | /usr/bin/systemd-cat -t "${SYSTEMD_TOPIC}"
fi