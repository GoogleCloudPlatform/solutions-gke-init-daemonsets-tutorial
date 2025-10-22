# TimeSync "two-ways" (GCE+OpsAgent/GKE) example

This folder contains a real-world example of configuring TimeSync. It is intended to demonstrate how a GCE configuration flow with ops-agent based monitoring will be converted into a GKE DaemonSet with log collection monitoring.

To demonstrate this, the folder contains both the GCE configuration and the GKE configuration.

## GCE configuration

These configuration scripts are kept in the folder [`gce`](gce) . The configuration flow here is expected to be:

```bash
# configure the project for log collection via ops agent and parsing/display.
./time-sync-logging-dashboard.sh timesync-test-project

# create a test VM in the project with clock-sync configured and ops-agent monitoring enabled
./time-sync-vm-creation.sh test-vm-1 timesync-test-project ubuntu-2204-lts ubuntu-os-cloud

# The last few lines of the output from the command above should look like:
# MS Name/IP address         Stratum Poll Reach LastRx Last sample
# ===============================================================================
# #* PHC0                          0  -1   377     1     -1ns[   -1ns] +/-   33ns


# Create another test VM in the same project
./time-sync-vm-creation.sh test-vm-2 timesync-test-project rhel-9 rhel-cloud

```

The [`time-sync-logging-dashboard.sh`](gce/time-sync-logging-dashboard.sh) script
configures the project to support OpsAgent based log/telemetry collection for
Chrony. It grants the VMs service account the needed permissions to report
metrics to cloud-logging, and defines log based metric to track the clock
synchronization accuracy per VM. Finally, it is creating a dashboard that
indicates a tracability metric for each VM.


The [`time-sync-vm-creation.sh`](gce/time-sync-vm-creation.sh) script is creating a
VM with a startup script that is composed of 2 other scripts:

* [`time-sync-configure-clock-sync.sh`](gce/time-sync-configure-clock-sync.sh) -
  script for enabling PTP-KVM and configuring chrony to leverage it
* [`time-sync-configure-ops-agent-monitor.sh`](gce/time-sync-configure-ops-agent-monitor.sh) -
  script for installing OpsAgent and configuring it to monitor Chrony's tracking
  accuracy

## GKE Configuration

The scripts to configure a GKE cluster with PTP-KVM based clock synchronization are kept in the [`gke`](gke) folder. Expected usage is:

```bash
# configure the project for metric collection and parsing/display (note, this is different from the GCE one)
./create_gke_metric.sh timesync-test-project

# create a GKE cluster in this project with clock-sync configured and GKE based monitoring
./create_gke_cluster.sh timesync-test-project us-west1 test-cluster-1

# create a second GKE cluster in this project with clock-sync configured and GKE based monitoring
./create_gke_cluster.sh timesync-test-project us-west1 test-cluster-2

```

The [`create_gke_metric.sh`](gke/create_gke_metric.sh) script configures the
project to allow log collection from GKE workload, configures a log based metric
to extract the relevant clock accuracy data into a monitoring compatible form
and finally creates a dashboard combining platform and VM metrics into a
tracability metric for each node.

The [`create_gke_cluster.sh`](gke/create_gke_cluster.sh) script creates a GKE
cluster and configures it to leverage TimeSync. The cluster is created with the
nodes "tainted" to ensure the daemonset is applied to each node before workload
can start running on it. Once the cluster is created, the script apply the
following configurations to it:

* [`Service account`](gke/serviceaccount.yaml), [`role`](gke/cluster-role.yaml) and [`bindings`](gke/cluster-role-binding.yaml) to allow the DaemonSet to untaint the node once configured

* [`ConfigMap`](gke/cm-entrypoint.yaml) with the script used by the DaemonSet node initializer to load PTP-KVM, configure chrony and untaint the node once it is configured and synchronized.

* [`DaemonSet`](gke/daemonset.yaml) which configures two init containers for each node - "node-initializers" which executes the script from the ConfigMap, and "logshipper" which ships chrony's tracking log to GKE's workload logging system.

Together, these configurations ensure all nodes in the cluster are enabled for
TimeSync and collect the telemetry from them to Google's cloud logging, where it
is converted to metric and can be monitored and analyzed.
