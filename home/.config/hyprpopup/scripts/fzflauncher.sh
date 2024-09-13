
#!/bin/bash

set -euo pipefail

# Set terminal title
title="Launcher"
echo -ne "\033]0;${title}\007"

# ANSI color codes
RESET="\e[0m"
DIM="\e[90m"
COLOR="\e[1;33m"

# File to store app launch frequencies
LAUNCH_LOG="$HOME/.app-launch-frequency"

# Function to get launch frequency
get_frequency() {
    local app_name="$1"
    grep "^${app_name}|" "$LAUNCH_LOG" 2>/dev/null | cut -d'|' -f2 || echo 0
}

# Function to increment launch frequency
increment_frequency() {
    local app_name="$1"
    local current_freq
    current_freq=$(get_frequency "$app_name")
    if grep -q "^${app_name}|" "$LAUNCH_LOG" 2>/dev/null; then
        sed -i "s/^${app_name}|.*/${app_name}|$((current_freq + 1))/" "$LAUNCH_LOG"
    else
        echo "${app_name}|1" >> "$LAUNCH_LOG"
    fi
}

# Function to get list of applications
get_applications() {
    local app_dirs=()
    IFS=':' read -ra xdg_dirs <<< "$XDG_DATA_DIRS"
    for dir in "${xdg_dirs[@]}"; do
        dir="${dir%/}/applications"
        if [ -d "$dir" ]; then
            app_dirs+=("$dir")
        fi
    done

    local local_app_dir="$HOME/.local/share/applications"
    if [[ ! " ${app_dirs[*]} " =~ " ${local_app_dir} " ]]; then
        app_dirs+=("$local_app_dir")
    fi

    find "${app_dirs[@]}" -name "*.desktop" -print0 | while IFS= read -r -d '' file; do
        local name
        name=$(awk -F= '/^Name=/{print $2; exit}' "$file")
        if [ -n "$name" ]; then
            local freq
            freq=$(get_frequency "$name")
            local categories
            categories=$(awk -F= '/^Categories=/{print $2}' "$file" | tr -d '\n' | tr ';' ' ' | sed 's/ $//' )
            # Output frequency, app name, categories, and desktop file path
            printf "%s|%s|%s|%s\n" "$freq" "$name" "$categories" "$file"
        fi
    done
}

# Function to launch the selected application
launch_application() {
    local IFS='|'
    read -r freq app_name categories desktop_file <<< "$1"
    if [ -f "$desktop_file" ]; then
        if (nohup dex "$desktop_file" &); then
            increment_frequency "$app_name"
        else
            notify-send "Failed to launch $app_name"
        fi
    else
        notify-send "Desktop file not found: $desktop_file"
    fi
}

# Main script
selected_app=$(get_applications | sort -t'|' -k1,1nr -k2,2 | while IFS='|' read -r freq name categories file; do
    # Add ANSI escape codes (dimming the frequency)
    printf "${DIM}%s|${RESET}%s${DIM}|%s|%s${RESET}\n" "$freq" "$name" "$categories" "$file"
done | fzf --ansi \
     --nth=1 \
     --with-nth=1,2,3 \
     --cycle --bind 'tab:toggle+down' \
     --prompt="Select an application: " \
     --layout=reverse \
     --preview "echo -e \"${COLOR}\$(echo {} | cut -d'|' -f2 | cut -c1-1 | figlet -f 3d)${RESET}\" " \
     --preview-window=right:11,border-left)

if [ -n "${selected_app:-}" ]; then
    launch_application "$selected_app"
else
    echo "No application selected."
fi

