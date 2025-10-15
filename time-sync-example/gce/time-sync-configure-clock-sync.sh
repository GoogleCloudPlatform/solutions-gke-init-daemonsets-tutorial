#!/bin/bash

# Install chrony as needed
if ! command -v chronyc &>/dev/null; then
    # Detect the package manager and install chrony
    if command -v apt &>/dev/null; then
        # Debian, Ubuntu, and derivatives
        echo "Detected apt. Installing chrony..."
        apt-get update
        apt-get install -y chrony
    elif command -v dnf &>/dev/null; then
        # Fedora, RHEL 8+, CentOS 8+
        echo "Detected dnf. Installing chrony..."
        dnf install -y chrony
    elif command -v yum &>/dev/null; then
        # RHEL 7, CentOS 7
        echo "Detected yum. Installing chrony..."
        yum install -y chrony
    elif command -v zypper &>/dev/null; then
        # openSUSE, SLES
        echo "Detected zypper. Installing chrony..."
        zypper install -y chrony
    else
        echo "Please install chrony manually."
        exit 1
    fi
fi

# Different distros place chrony config in
# different locations, detect this.
if [ -f "/etc/chrony/chrony.conf" ]; then
    CHRONY_CONF="/etc/chrony/chrony.conf"
else
    CHRONY_CONF="/etc/chrony.conf"
fi

# Load PTP-KVM clock for high-accuracy clock synchronization
# PTP-KVM allows the VM to read a cross time-stamp of a platform
# provided clock and the VM CPU Clock (CycleCounter), providing
# resiliency from network and virtualization variability when
# synchronizing the realtime/wall clock
/sbin/modprobe ptp_kvm
echo "ptp_kvm" >/etc/modules-load.d/ptp_kvm.conf

# NTP servers might indicate the wrong time due to chrony
# greatly reducing the polling frequency, resulting in
# overall negative impact to the clock synchronization
# achieved, especially after live migration events.
#
# We disable NTP servers to prevent these issues.
#
# Customers interested in monitoring the clock accuracy compared to NTP sources
# should run a second instance of chrony in a no-change mode to do so.

# Disable NTP servers:
sed -i '/^server /d' $CHRONY_CONF
sed -i '/^pool /d' $CHRONY_CONF
sed -i '/^include /d' $CHRONY_CONF

#Disable DHCP based NTP config:
sed -i 's/^NETCONFIG_NTP_POLICY="auto"/NETCONFIG_NTP_POLICY=""/' /etc/sysconfig/network/config
truncate -s 0 /var/run/netconfig/chrony.servers
echo PEERNTP=no | sudo tee -a /etc/sysconfig/network
service NetworkManager restart
systemctl disable systemd-timesyncd.service
timedatectl set-ntp false

# Configure PTP-KVM based HW refclock, with leap second smearing
# Google's clocks are doing leap second smearing, and therefor chrony shouldn't attempt to adjust
# the time received from PTP-KVM to adjust for leap seconds.
sed "s/^leapsectz/#leapsectz/" -i $CHRONY_CONF
echo "refclock PHC /dev/ptp_kvm poll -1" >>$CHRONY_CONF
# For extra debugging logging, uncomment the following line
#echo "log measurements statistics tracking" >> $CHRONY_CONF
# Enable chrony's clock accuracy tracking log,
# for monitoring and auditing.
echo "log tracking" >>$CHRONY_CONF

# Restart chrony (Ubuntu named it differently)
systemctl restart chronyd
systemctl restart chrony
