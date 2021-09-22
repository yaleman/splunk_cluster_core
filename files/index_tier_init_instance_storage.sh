#!/bin/bash

# This initialises the ephemeral storage on indexers and mounts it at /splunkdata

NVME_DEV=$(find  '/dev/' -maxdepth 1 -name 'nvme*n*')
NVME_MOUNTPOINT=/splunkdata

echo "Adding splunk user"
useradd splunk

echo "##################################################"
echo "Creating filesystem"
echo "##################################################"
mkfs -t ext4 "$NVME_DEV"
echo "Tuning reserved blocks to provide more space on $NVME_DEV"
tune2fs -m1 "$NVME_DEV"
echo "Mounting"
mkdir -p "$NVME_MOUNTPOINT"
mount "$NVME_DEV" "$NVME_MOUNTPOINT"
echo "Fixing storage permissions"
chown -R splunk. "$NVME_MOUNTPOINT"
