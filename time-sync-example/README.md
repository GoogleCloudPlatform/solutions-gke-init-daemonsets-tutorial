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
