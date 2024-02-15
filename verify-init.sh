#!/bin/sh

# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

NODE_NAME="$1"
ZONE="$2"

echo "Verifying $NODE_NAME ($ZONE) configuration"

if gcloud compute ssh "$NODE_NAME" --zone "$ZONE" --command "ls /dev/sdb" >/dev/null 2>&1; then
    echo "Disk configured successfully on $NODE_NAME ($ZONE)"
else
    echo "Disk not configured successfully on $NODE_NAME ($ZONE)"
    exit 1
fi

if gcloud compute ssh "$NODE_NAME" --zone "$ZONE" --command "dpkg -l | grep nano" >/dev/null 2>&1; then
    echo "Packages installed successfully in $NODE_NAME ($ZONE)"
else
    echo "Packages not installed successfully in $NODE_NAME ($ZONE)"
    exit 2
fi

if gcloud compute ssh "$NODE_NAME" --zone "$ZONE" --command "lsmod | grep bridge" >/dev/null 2>&1; then
    echo "Kernel modules loaded successfully on $NODE_NAME ($ZONE)"
else
    echo "Kernel modules not loaded successfully on $NODE_NAME ($ZONE)"
    exit 3
fi
