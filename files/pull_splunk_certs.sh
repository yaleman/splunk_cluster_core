#!/bin/bash

# Grabs certificates for the certs from SSM and puts them into the right place for splunk to use.

AWS_REGION="$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/.$//')"

# get the certificate
aws ssm get-parameter --name "/application/splunk/certificate/$(cat /etc/instance_name)/certificate" --region "${AWS_REGION}" --with-decryption | jq -r .Parameter.Value > /etc/ssl/certs/splunk.pem
# get the private key
aws ssm get-parameter --name "/application/splunk/certificate/$(cat /etc/instance_name)/privatekey" --region "${AWS_REGION}" --with-decryption | jq -r .Parameter.Value > /etc/ssl/certs/splunk.key
# get the intermediate
aws ssm get-parameter --name "/application/splunk/certificate/$(cat /etc/instance_name)/intermediate" --region "${AWS_REGION}" --with-decryption | jq -r .Parameter.Value > /etc/ssl/certs/splunk-intermediate.pem

cat /etc/ssl/certs/splunk.pem /etc/ssl/certs/splunk-intermediate.pem /etc/ssl/certs/splunk.key > /etc/ssl/certs/splunk-fullchain.pem

chown root:splunk /etc/ssl/certs/splunk*
chmod 0640 /etc/ssl/certs/splunk*
