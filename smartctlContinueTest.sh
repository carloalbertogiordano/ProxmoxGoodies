#!/bin/bash

# Function to check the SMART status of disks
check_smart() {
    # List all available disks in the system
    disks=$(lsblk -ndo NAME,TYPE | grep 'disk' | awk '{print $1}')

    # Start loop for each disk
    for disk in $disks; do
        echo "Checking disk: /dev/$disk"
        
        # Check if the disk supports SMART
        if smartctl -i /dev/$disk | grep -q "SMART support is: Enabled"; then
            echo "SMART supported on /dev/$disk. Checking test status..."
            
            # Check SMART test status
            test_status=$(smartctl -c /dev/$disk)

            if echo "$test_status" | grep -q "Self-test routine in progress"; then
                echo "Test in progress on /dev/$disk:"
                
                # Extract and display test status
                echo "$test_status"
                
                # Extract test progress and remaining time
                progress=$(echo "$test_status" | grep -oP '(?<=Test in progress: )\d+%')
                remaining_time=$(echo "$test_status" | grep -oP '(?<=Estimated remaining time: )\d+ minutes')

                echo "Test progress: ${progress:-Not available}"
                echo "Remaining time: ${remaining_time:-Not available} minutes"
            else
                echo "No test in progress on /dev/$disk."
            fi
        else
            echo "SMART not supported or not enabled on /dev/$disk."
        fi

        echo "----------------------------------------"
    done
}

# Continuous mode if --continue option is specified
if [[ "$1" == "--continue" ]]; then
    while true; do
        # Clear the screen
        clear
        # Call the function to check SMART status
        check_smart
        # Wait a few seconds before repeating the loop (modify the wait time as needed)
        sleep 10
    done
else
    # Run once if the --continue option is not specified
    check_smart
fi
