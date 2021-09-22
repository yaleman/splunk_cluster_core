#!/bin/bash

if [ -z "${AWS_PROFILE}" ]; then
    echo "Please set an env var of AWS_PROFILE, eg AWS_PROFILE=mysupercooladmin ./runterraform.sh"
fi
echo "Querying state list..."
CERTS=$( AWS_PROFILE=${AWS_PROFILE} ./runterraform.sh state list | grep -E '^acme_certificate.certificate')

for CERT in $CERTS; do
    echo "doing $CERT"
    ./runterraform.sh apply -target="$CERT" -auto-approve
done
