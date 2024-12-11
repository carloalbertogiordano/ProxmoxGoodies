#!/bin/bash

# Check if the user has root privileges
if [ "$(id -u)" -ne "0" ]; then
    echo "You must run this script as root."
    exit 1
fi

# Function to display usage instructions
usage() {
    echo "Usage: $0 [device]"
    echo "  [device]: The name of the device to format (e.g., sdx)."
    exit 1
}

# Verify the number of arguments
if [ "$#" -ne 1 ]; then
    usage
fi

# Define the disk
DISK="/dev/$1"

# Check if the device exists
if [ ! -b "$DISK" ]; then
    echo "The device $DISK does not exist."
    exit 1
fi

# Confirm the operation with the user
echo "WARNING: This script will delete all partitions on $DISK."
read -p "Are you sure you want to continue? (y/n): " response
if [[ "$response" != "y" ]]; then
    echo "Operation canceled."
    exit 0
fi

# Remove all existing partitions using fdisk
echo -e "o\nw" | fdisk "$DISK"

# Verify that fdisk removed the partitions
if [ "$(lsblk -no NAME "$DISK")" != "" ]; then
    echo "Partitions were not removed correctly."
    exit 1
fi

# Format the disk as "raw" using dd to wipe existing data
dd if=/dev/zero of="$DISK" bs=1M status=progress

# Check if the operation was successful
if [ $? -eq 0 ]; then
    echo "The disk $DISK has been formatted as raw and all partitions have been deleted."
else
    echo "An error occurred while formatting the disk."
    exit 1
fi
