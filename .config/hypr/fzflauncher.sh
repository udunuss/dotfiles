#!/bin/bash

# Function to get list of applications
get_applications() {
    find /usr/share/applications -name "*.desktop" -exec basename {} .desktop \;
}

# Function to launch the selected application
launch_application() {
    gtk-launch "$1" || notify-send "Failed to launch $1"
}

# Main script
selected_app=$(get_applications | sort | fzf --prompt="Select an application: " --layout=reverse --border)

if [ -n "$selected_app" ]; then
    launch_application "$selected_app"
else
    echo "No application selected."
fi
