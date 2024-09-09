#!/bin/bash

# ANSI color codes
RESET="\e[0m"
DIM="\e[90m"

# Function to get list of applications
get_applications() {
    while IFS= read -r -d '' file; do
        name=$(awk -F= '/^Name=/{print $2; exit}' "$file")
        if [ -n "$name" ]; then
            echo -e "$name${DIM}|$file${RESET}"
        fi
    done < <(find /usr/share/applications ~/.local/share/applications -name "*.desktop" -print0)
}

# Function to launch the selected application
launch_application() {
    desktop_file=$(echo "$1" | awk -F'|' '{print $2}' | sed 's/\x1b\[0m$//')
    
    if [ -f "$desktop_file" ]; then
        nohup dex "$desktop_file"
        if [ $? -ne 0 ]; then
            notify-send "Failed to launch $1"
        fi
    else
        notify-send "Desktop file not found: $desktop_file"
    fi
}

# Main script
selected_app=$(get_applications | sort | fzf --ansi --prompt="Select an application: " --layout=reverse --border)

if [ -n "$selected_app" ]; then
    launch_application "$selected_app"
else
    echo "No application selected."
fi