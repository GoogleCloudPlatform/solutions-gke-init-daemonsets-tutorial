#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: setup_logging.sh <project_id>" >&2
    exit 1
fi

PROJECT_ID="$1"
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID  --format="value(projectNumber)")
SERVICE_ACCOUNT_EMAIL=${PROJECT_NUMBER}-compute@developer.gserviceaccount.com

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/compute.instanceAdmin"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/monitoring.metricWriter"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
    --role="roles/logging.logWriter"

METRIC_CONF='
{
  "name": "phc-clock-max-error",
  "description": "Maximum error of the VM clock from the host clock exposed by ptp_kvm",
  "filter": "logName=\"projects/clock-accuracy/logs/chrony_tracking_receiver\"",
  "metricDescriptor": {
    "metricKind": "DELTA",
    "valueType": "DISTRIBUTION",
    "unit": "s",
    "labels": []
  },
  "valueExtractor": "REGEXP_EXTRACT(jsonPayload.max_error, \"(.*)\")",
  "bucketOptions": {
    "explicitBuckets": {
      "bounds": [
        0.0, 1.0E-6, 5.0E-6, 1.0E-5, 1.0E-4, 0.001, 0.01, 0.1, 1.0
      ]
    }
  }
}
'

DASHBOARD_CONF='
{
  "displayName": "Overall Clock Accuracy",
  "dashboardFilters": [],
  "labels": {},
  "mosaicLayout": {
    "columns": 48,
    "tiles": [
      {
        "height": 28,
        "width": 28,
        "widget": {
          "xyChart": {
            "chartOptions": {
              "displayHorizontal": false,
              "mode": "COLOR"
            },
            "dataSets": [
              {
                "plotType": "LINE",
                "targetAxis": "Y1",
                "timeSeriesQuery": {
                  "prometheusQuery": "(\n    histogram_quantile(\n        1,\n        sum by (le, instance_id, monitored_resource) (\n            increase(\n                logging_googleapis_com:user_phc_clock_max_error_bucket{monitored_resource=\"gce_instance\"}[1m]\n            )\n        )\n    ) * 1000000000\n)\n+ on(instance_id, monitored_resource)\n(\n    compute_googleapis_com:instance_clock_accuracy_ptp_kvm_nanosecond_accuracy{monitored_resource=\"gce_instance\"}\n)",
                  "unitOverride": "ns"
                }
              }
            ],
            "thresholds": [],
            "yAxis": {
              "label": "Clock Accuracy",
              "scale": "LINEAR"
            }
          }
        }
      }
    ]
  }
}
'

echo "$METRIC_CONF" > /tmp/clock-error-metric.json
echo "$DASHBOARD_CONF" > /tmp/metrics-dashboard.json

gcloud logging metrics create phc-clock-max-error --config-from-file=/tmp/clock-error-metric.json
gcloud monitoring dashboards create --config-from-file=/tmp/metrics-dashboard.json

