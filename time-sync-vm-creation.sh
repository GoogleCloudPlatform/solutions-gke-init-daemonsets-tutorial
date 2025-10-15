#!/bin/bash 

STARTUP_SCRIPT='#!/bin/bash
apt install chrony
modprobe ptp_kvm
echo "ptp_kvm" > /etc/modules-load.d/ptp_kvm.conf
sed "s/^leapsectz/#leapsectz/" -i /etc/chrony/chrony.conf 
sed "s/prefer iburst/iburst/" -i /etc/chrony/chrony.conf
grep -v "^server " /etc/chrony/chrony.conf > /tmp/chrony_new.conf && mv /tmp/chrony_new.conf /etc/chrony/chrony.conf
grep -v "^pool " /etc/chrony/chrony.conf > /tmp/chrony_new.conf && mv /tmp/chrony_new.conf /etc/chrony/chrony.conf
echo "refclock PHC /dev/ptp_kvm poll -1" >> /etc/chrony/chrony.conf
#echo "log measurements statistics tracking" >> /etc/chrony/chrony.conf
echo "log tracking" >> /etc/chrony/chrony.conf
systemctl restart chronyd

curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
bash add-google-cloud-ops-agent-repo.sh --also-install

OPS_AGENT_CONF="
logging:
  receivers:
    chrony_tracking_receiver:
      type: files
      include_paths:
        - /var/log/chrony/tracking.log
  processors:
    chrony_tracking_processor:
      type: parse_regex
      regex: \"^.*PHC0.*  (?<max_error>[-\d\.eE]+)$\"
  service:
    pipelines:
      chrony_tracking_pipeline:
        receivers: [chrony_tracking_receiver]
        processors: [chrony_tracking_processor]
"

OPS_AGENT_CONF_PATH="/etc/google-cloud-ops-agent/config.yaml"
echo "$OPS_AGENT_CONF" > "$OPS_AGENT_CONF_PATH"
systemctl restart google-cloud-ops-agent
'

echo "$STARTUP_SCRIPT" > /tmp/startup-script.sh

gcloud compute instances create metrics-test \
    --project=clock-accuracy \
    --zone=us-central1-f \
    --machine-type=e2-medium \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --metadata-from-file=startup-script=/tmp/startup-script.sh
