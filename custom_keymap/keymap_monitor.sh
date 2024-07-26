#!/bin/bash

# Define file paths
CUSTOM_KEYMAP="$HOME/.config/custom_keymap/custom_keymap.xkb"  # Path to the custom keymap file
KEYMAP_HASH_FILE="/tmp/current_keymap_hash"  # Temporary file to store the current keymap hash
XMODMAP_SETTING="$HOME/.config/.Xmodmap"  # Path to the Xmodmap settings file
LOG_FILE="/tmp/custom_keymap.log"  # Log file path

# Function to log messages with timestamps
log_message() {
    echo "$(date): $1" >> "$LOG_FILE"
}

# Function to check if required files exist
check_required_files() {
    for file in "$CUSTOM_KEYMAP" "$XMODMAP_SETTING"; do
        if [ ! -f "$file" ]; then
            log_message "Error: Required file $file not found."
            exit 1
        fi
    done
}

# Function to generate a hash of the current keyboard layout and input devices
get_current_keymap_hash() {
    # Combine the output of setxkbmap and xinput, then generate an MD5 hash
    { setxkbmap -print; xinput list; } | md5sum | awk '{print $1}'
}

# Function to apply the custom keymap if changes are detected
apply_keymap_if_changed() {
    current_hash=$(get_current_keymap_hash)
    # Apply keymap if the hash file doesn't exist or the hash has changed
    if [ ! -f "$KEYMAP_HASH_FILE" ] || [ "$current_hash" != "$(cat "$KEYMAP_HASH_FILE")" ]; then
        if xkbcomp -w 0 "$CUSTOM_KEYMAP" "$DISPLAY"; then
            if xmodmap "$XMODMAP_SETTING"; then
                echo "$current_hash" > "$KEYMAP_HASH_FILE"  # Update the stored hash
                log_message "Custom keymap and xmodmap settings applied successfully"
            else
                log_message "Error: Failed to apply xmodmap settings"
            fi
        else
            log_message "Error: Failed to apply custom keymap"
        fi
    fi
}

# Function to check and apply keymap after a short delay
check_and_apply() {
    sleep 2  # Wait for the system to settle after a change
    apply_keymap_if_changed
}

# Main function
main() {
    check_required_files  # Ensure all required files exist
    apply_keymap_if_changed  # Apply the custom keymap when the script starts

    # Monitor for input device changes and Bluetooth events
    {
        # Monitor for input device changes (e.g., connecting/disconnecting keyboards)
        inotifywait -m -e create,delete /dev/input/event* &
        # Monitor Bluetooth events (e.g., connecting/disconnecting Bluetooth devices)
        bluetoothctl --monitor &
    } | while read -r line; do
        # For each detected change, check and apply the keymap if needed
        check_and_apply
    done
}

# Run the main function
main
