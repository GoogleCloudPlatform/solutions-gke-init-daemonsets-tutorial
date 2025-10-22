#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: time-sync-logging-dashboard.sh <project_id>" >&2
    exit 1
fi

PROJECT_ID="$1"
PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format="value(projectNumber)")
SERVICE_ACCOUNT_EMAIL=${PROJECT_NUMBER}-compute@developer.gserviceaccount.com

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/compute.instanceAdmin"

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/monitoring.metricWriter"

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/logging.logWriter"

gcloud logging metrics create phc-clock-max-error-gce --config-from-file=clock-error-metric.json
gcloud monitoring dashboards create --config-from-file=metric-dashboard.json
