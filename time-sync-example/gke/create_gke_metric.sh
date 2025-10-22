#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: create_gke_metric.sh <project_id>" >&2
    exit 1
fi

PROJECT_ID="$1"
PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format="value(projectNumber)")
SERVICE_ACCOUNT_EMAIL=${PROJECT_NUMBER}-compute@developer.gserviceaccount.com

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/logging.logWriter"

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/compute.instanceAdmin"

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/monitoring.metricWriter"

gcloud logging --project "$PROJECT_ID" metrics create phc-clock-max-error --config-from-file=gke-clock-metric.json
gcloud monitoring --project "$PROJECT_ID" dashboards create --config-from-file=gke-metrics-dashboard.json
