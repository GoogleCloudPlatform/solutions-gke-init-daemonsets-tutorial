# Automatically bootstrapping Kubernetes Engine nodes with daemonSets

This reference guide demonstrates how to use [Kubernetes DaemonSets](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)
to initialize your Kubernetes cluster nodes.

Please refer to the [following article](https://cloud.google.com/solutions/automatically-bootstrapping-gke-daemonsets) for the steps to run the code.

## Contents of this repository

### ConfigMap

The [`entrypoint`](cm-entrypoint.yaml) contains the initialization script that each selected node will run as part of its initialization procedure.
This procedure includes privileged and un-privileged commands.

#### DaemonSet

The [`daemon-set`](daemon-set.yaml) descriptor defines the daemonSet that executes the [init container](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)
that runs the initialization procedure.

### Verification script

This [`verify-init.sh`](verify-init.sh) runs quick checks on the nodes of the cluster to verify that the initialization completed successfully.
