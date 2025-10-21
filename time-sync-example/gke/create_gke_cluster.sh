#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: create_gke_cluster.sh <project_id> <region> <cluster_name>" >&2
    exit 1
fi

PROJECT_ID="$1"
REGION="$2"
CLUSTER_NAME="$3"
MACHINE_TYPE="c3-standard-4"

gcloud container --project "$PROJECT_ID" clusters create "$CLUSTER_NAME" \
    --region "$REGION" --release-channel "regular" \
    --machine-type "$MACHINE_TYPE" --image-type "COS_CONTAINERD" \
    --node-taints startup-taint.cluster-autoscaler.kubernetes.io/node-initializer=true:NoSchedule \
    --logging=SYSTEM,WORKLOAD --monitoring=SYSTEM,STORAGE,POD,DEPLOYMENT,STATEFULSET,DAEMONSET,HPA,JOBSET,CADVISOR,KUBELET,DCGM

gcloud container clusters get-credentials "$CLUSTER_NAME" \
    --location="$REGION" --project "$PROJECT_ID"

# Add a service account the daemonset will use to untaint the node
# when chrony is synced.
kubectl apply -f serviceaccount.yaml
# Bind the service account to a role allowed to untain nodes
kubectl apply -f cluster-role.yaml
kubectl apply -f cluster-role-binding.yaml
# Add a config map with entrypoint script configuring chrony
# This can also be done via a command-line creating the map from a shell script file of the content, see
# https://kubernetes.io/docs/reference/kubectl/generated/kubectl_create/kubectl_create_configmap/
kubectl apply -f cm-entrypoint.yaml
# Finally, configure daemonset with chrony configuration,
# node untaint and monitoring
kubectl apply -f daemonset.yaml
