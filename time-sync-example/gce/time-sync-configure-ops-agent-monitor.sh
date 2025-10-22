#!/bin/bash

# From https://cloud.google.com/stackdriver/docs/solutions/agents/ops-agent/installation#install-latest-version
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
echo "$OPS_AGENT_CONF" >"$OPS_AGENT_CONF_PATH"
systemctl restart google-cloud-ops-agent
