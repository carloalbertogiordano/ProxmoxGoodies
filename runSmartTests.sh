#!/bin/bash

# Check if smartmontools is installed
if ! command -v smartctl &> /dev/null; then
    echo "smartctl is not installed. Install it with: sudo apt-get install smartmontools"
    exit 1
fi

# List of disks
disks=$(ls /dev/sd? 2>/dev/null)

# Checking SMART status for each disk
for disk in $disks; do
    echo "Checking SMART for $disk..."
    smartctl -a "$disk" | grep -i "smart overall-health self-assessment test result"
done

echo "SMART check completed."
