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
