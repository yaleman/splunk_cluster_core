#!/bin/bash

# this needs to be run like with the profile set in this way because the LetsEncrypt cert provider doesn't work like a normal one.

if [ -z "${AWS_PROFILE}" ]; then
    echo "Please set an env var of AWS_PROFILE, eg AWS_PROFILE=mysupercooladmin ./runterraform.sh"
fi

#shellcheck disable=SC2068
AWS_PROFILE="${AWS_PROFILE}" terraform $@