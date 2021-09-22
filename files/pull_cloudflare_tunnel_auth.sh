#!/bin/bash

# This script pulls some data from AWS secrets manager to configure cloudflared

TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 15")
AWS_REGION="$(curl -s  -H "X-aws-ec2-metadata-token: ${TOKEN}" http://169.254.169.254/latest/meta-data/placement/region)"

SPLUNK_ROLE=$(cat /etc/splunk_role)

if [ -z "${SPLUNK_ROLE}" ]; then
    echo "/etc/splunk_role is missing, can't query role"
    exit 1
fi

if [ -z "${AWS_REGION}" ]; then
    echo "Failed to query AWS region from metadata, quitting"
    exit 1
fi

TEMPFILE="/tmp/cloudflare_tunnel.json"
PRODFILE="/etc/cloudflared/tunnel.json"

TEMPCERT="/tmp/cloudflare_tunnel.pem"
PRODCERT="/etc/cloudflared/cert.pem"

# grab the json file
echo "Testing tunnel file"
aws --region "${AWS_REGION}" secretsmanager get-secret-value --secret-id "cloudflared_${SPLUNK_ROLE}_tunnelfile" --output json | jq -r .SecretString > "${TEMPFILE}" || ( echo "Failed to get cloudflare tunnel creds, bailing."; exit 1)

# grab the certificate
aws --region "${AWS_REGION}" secretsmanager get-secret-value --secret-id "cloudflared_${SPLUNK_ROLE}_cert" --output json | jq -r .SecretString > "${TEMPCERT}" || ( echo "Failed to get cloudflare cert, bailing."; exit 1)

# check the file's valid
jq . "${TEMPFILE}" > /dev/null || ( echo "Failed to pull a valid JSON file, bailing."; exit 1 )

openssl x509 -noout -in "${TEMPCERT}" || ( echo "Failed to pull a valid cert, bailing."; exit 1 )

# update the file in place
if [ -f  "${PRODFILE}" ]; then
    mv "${PRODFILE}" "${PRODFILE}.backup"
fi
mv "${TEMPFILE}" "${PRODFILE}"

# update the file in place
if [ -f  "${PRODCERT}" ]; then
    mv "${PRODCERT}" "${PRODCERT}.backup"
fi
mv "${TEMPCERT}" "${PRODCERT}"
# done!