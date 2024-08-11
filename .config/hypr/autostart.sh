#!/bin/bash

# Directory containing the .desktop files
AUTOSTART_DIR="$HOME/.config/autostart"

# Function to extract Exec line from .desktop file
get_exec_command() {
    grep '^Exec=' "$1" | tail -1 | sed 's/^Exec=//' | sed 's/%.//'
}

# Iterate over all .desktop files in the autostart directory
for file in "$AUTOSTART_DIR"/*.desktop; do
    if [ -f "$file" ]; then
        # Extract the Exec line
        cmd=$(get_exec_command "$file")
        
        # Execute the command
        if [ -n "$cmd" ]; then
            echo "Executing: $cmd"
            eval "$cmd" &
        fi
    fi
done

