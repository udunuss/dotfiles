
#!/bin/bash

set -euo pipefail

# Set terminal title
title="Launcher"
echo -ne "\033]0;${title}\007"

# ANSI color codes
RESET="\e[0m"
DIM="\e[38;5;243m"
COLOR_ONE="\e[38;5;30m"
COLOR_TWO="\e[38;5;173m"
COLOR="\e[1;33m"

DATADIR="$HOME/.fzflauncherdata"
mkdir -p "$DATADIR"
# File to store app launch frequencies
LAUNCH_LOG="$DATADIR/freq"

# Cache directory and file
CACHE_FILE="$DATADIR/cache"


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
        local categories
        local comments
        name=$(awk -F= '/^Name=/{print $2; exit}' "$file")

        if [ -n "$name" ]; then
            local freq
            freq=$(get_frequency "$name")
            categories=$(awk -F= '/^Categories=/{print $2}' "$file" | tr -d '\n' | tr ';' ',' | sed 's/,$//' | sed 's/ $//' )
            comments=$(awk -F= '/^Comment=/{print $2}' "$file" | tr -d '\n' | sed 's/ $//' )

            # Output frequency, app name, categories, and desktop file path
            printf "%s\x1F%s\x1F%s\x1F%s\n" "$name" "$categories" "$comments" "$file"
        fi
    done
}

# Function to launch the selected application
launch_application() {
    local IFS=$'\x1F'
    read -r freq app_name categories comments desktop_file <<< "$1"
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

# Read from cache if available, else generate applications and cache them
if [ -f "$CACHE_FILE" ]; then
    applications=$(cat "$CACHE_FILE")
else
    applications=$(get_applications)
    echo "$applications" > "$CACHE_FILE"
fi

# Now, for each application, get the frequency
applications_with_freq=$(echo "$applications" | while IFS=$'\x1F' read -r name categories comments file; do
    freq=$(get_frequency "$name")
    printf "%s\x1F%s\x1F%s\x1F%s\x1F%s\n" "$freq" "$name" "$categories" "$comments" "$file"
done)


selected_app=$(echo "$applications_with_freq" | sort -t $'\x1F' -k1,1nr -k2,2 | while IFS=$'\x1F' read -r freq name categories comments file; do
    # Add ANSI escape codes (dimming the frequency), delimiters outside ANSI codes
    printf "${DIM}%s${RESET}\x1F%s\x1F${COLOR_ONE}%s${RESET}\x1F${COLOR_TWO}%s${RESET}\x1F${DIM}%s${RESET}\n" \
    "$freq" "$name" "$categories" "$comments" "$file"
done | fzf --ansi \
     -d $'\x1F' \
     --no-multi \
     --algo=v2 \
     --with-nth 2,3,4 \
     --tiebreak=begin,index \
     --cycle --bind 'tab:toggle+down' \
     --prompt="Select an application: " \
     --layout=reverse \
     --preview "echo -e \"${COLOR}\$(echo {} | cut -d $'\x1F' -f2 | cut -c1-1 | figlet -f 3d)${RESET}\" " \
     --preview-window=right:11,border-left)


if [ -n "${selected_app:-}" ]; then
    launch_application "$selected_app"
    (get_applications > "$CACHE_FILE.tmp" && mv "$CACHE_FILE.tmp" "$CACHE_FILE") &
else
    echo "No application selected."
fi
