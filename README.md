# Automatically bootstrapping Kubernetes Engine nodes with daemonSets

This reference guide demonstrates how to use
[Kubernetes DaemonSets](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)
to initialize your Kubernetes cluster nodes.

For more information, refer to [Automatically bootstrapping GKE nodes with DaemonSets](https://cloud.google.com/solutions/automatically-bootstrapping-gke-nodes-with-daemonsets).

## Contents of this repository

### DaemonSet

The [`DaemonSet`](daemon-set.yaml) descriptor defines the DaemonSet that executes the [init container](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)
that runs a customized initialization procedure.

### ConfigMap

The [`entrypoint`](cm-entrypoint.yaml) contains an example of a script that the init container runs. The example script
is part of the customized initialization procedure.

As part of the example, the script runs both privileged and un-privileged commands.

### Verification script

This [`verify-init.sh`](verify-init.sh) runs checks on the nodes of the cluster to verify that the initialization completed successfully.

### TimeSync example

The folder [`time-sync-example`](time-sync-example) contains a real-world
example: a Compute Engine (single VM + OpsAgent) configuration for accurately
synchronizing the VM clock with monitoring of the clock synchronization
accuracy, alongside the equivalent Kubernetes Engine variant - a GKE DaemonSet to configure
the VMs in the node pool, supporting taint/untaint flow to prevent workload
execution on nodes without synchronized time, and monitoring solution based on
GKE's log collection flow.
