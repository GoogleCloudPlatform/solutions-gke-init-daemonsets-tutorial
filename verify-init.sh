#!/bin/sh

NODE_NAME="$1"
ZONE="$2"

echo "Verifying $NODE_NAME ($ZONE) configuration"

if gcloud compute ssh "$NODE_NAME" --zone "$ZONE" --command "ls /dev/sdb" > /dev/null 2>&1; then
    echo "Disk configured successfully on $NODE_NAME ($ZONE)"
else
    echo "Disk not configured successfully on $NODE_NAME ($ZONE)"
    exit 1
fi

if gcloud compute ssh "$NODE_NAME" --zone "$ZONE" --command "dpkg -l | grep nano" > /dev/null 2>&1; then
    echo "Packages installed successfully in $NODE_NAME ($ZONE)"
else
    echo "Packages not installed successfully in $NODE_NAME ($ZONE)"
    exit 2
fi

if gcloud compute ssh "$NODE_NAME" --zone "$ZONE" --command "lsmod | grep test_module" > /dev/null 2>&1; then
    echo "Kernel modules loaded successfully on $NODE_NAME ($ZONE)"
else
    echo "Kernel modules not loaded successfully on $NODE_NAME ($ZONE)"
    exit 3
fi