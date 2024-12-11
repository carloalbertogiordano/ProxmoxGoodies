#!/bin/bash

# Function to display available governors for the first CPU core
function list_governors() {
    if [[ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors ]]; then
        echo "Available governors:"
        cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
    else
        echo "CPU governor control is not available on this system."
        exit 1
    fi
}

# Function to set the CPU governor for all cores
function set_governor() {
    echo "Enter the desired governor (e.g., performance, powersave, conservative, ondemand):"
    read governor

    # Check if the entered governor is valid
    if grep -qw "$governor" /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors; then
        echo "Setting CPU governor to '$governor' on all cores..."
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            echo "$governor" | tee "$cpu" >/dev/null
        done
        echo "CPU governor set to '$governor' for all cores."
    else
        echo "Invalid governor specified. Please try again."
    fi
}

# Main function for the interactive menu
function menu() {
    while true; do
        clear
        echo "Proxmox CPU Governor Management"
        echo "------------------------------"
        list_governors
        echo ""
        echo "Choose an option:"
        echo "1) Set CPU governor"
        echo "2) Exit"
        read -p "Option: " choice

        case $choice in
            1)
                set_governor
                ;;
            2)
                echo "Exiting..."
                exit 0
                ;;
            *)
                echo "Invalid option. Please try again."
                ;;
        esac

        read -p "Press ENTER to continue..."
    done
}

# Start the main menu
menu
