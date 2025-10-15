#!/bin/bash

# Combine the scripts for configuring the clock sync and ops-agent into a single "VM Startup script"
cat time-sync-configure-clock-sync.sh time-sync-configure-ops-agent-monitor.sh >/tmp/startup-script.sh

# Adjust the following according to your needs
VM_NAME=$1
PROJECT=$2
IMAGE_FAMILY=$3
IMAGE_PROJECT=$4
ZONE="us-central1-f"

gcloud compute instances create "$VM_NAME" \
    --project="$PROJECT" \
    --zone="$ZONE" \
    --machine-type=c3-standard-4 \
    --image-family="$IMAGE_FAMILY" \
    --image-project="$IMAGE_PROJECT" \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --metadata-from-file=startup-script=/tmp/startup-script.sh

sleep 60s

#Confirms chrony successful install and config - expected output is:
# S Name/IP address         Stratum Poll Reach LastRx Last sample
# ===============================================================================
# #* PHC0                          0  -1   377     1    +17ns[  +46ns] +/-   37ns

gcloud compute ssh --zone "$ZONE" "$VM_NAME" --project "$PROJECT" --command="chronyc sources"
