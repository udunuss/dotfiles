
#!/bin/bash
# ANSI color codes
RESET="\e[0m"
DIM="\e[90m"
RED="\e[1;33m"

# File to store app launch frequencies
LAUNCH_LOG="$HOME/.app-launch-frequency"

# Function to get launch frequency
get_frequency() {
    local app_name="$1"
    grep -P "^${app_name}\|" "$LAUNCH_LOG" 2>/dev/null | cut -d'|' -f2 || echo 0
}

# Function to increment launch frequency
increment_frequency() {
    local app_name="$1"
    local current_freq=$(get_frequency "$app_name")
    if grep -q "^${app_name}|" "$LAUNCH_LOG"; then
        sed -i "s/^${app_name}|.*/${app_name}|$((current_freq + 1))/" "$LAUNCH_LOG"
    else
        echo "${app_name}|1" >> "$LAUNCH_LOG"
    fi
}

# Function to get list of applications without ANSI codes for sorting
get_applications() {
    while IFS= read -r -d '' file; do
        name=$(awk -F= '/^Name=/{print $2; exit}' "$file")

        if [ -n "$name" ]; then
            freq=$(get_frequency "$name")
            # Output frequency and app info without ANSI codes for sorting
            echo -e "$freq|$name|$file"
        fi
    done < <(find /usr/share/applications ~/.local/share/applications -name "*.desktop" -print0)
}

# Function to launch the selected application
launch_application() {
    local app_name=$(echo "$1" | cut -d'|' -f2)
    local desktop_file=$(echo "$1" | cut -d'|' -f3)
    if [ -f "$desktop_file" ]; then
        nohup dex "$desktop_file"
        if [ $? -ne 0 ]; then
            notify-send "Failed to launch $app_name"
        else
            increment_frequency "$app_name"
        fi
    else
        notify-send "Desktop file not found: $desktop_file"
    fi
}

# Main script
selected_app=$(get_applications | sort -t'|' -k1,1nr -k2,2 | while IFS='|' read -r freq name file; do
    # Add ANSI escape codes (dimming the frequency)
    echo -e "${DIM}$freq|${RESET}$name${DIM}|$file${RESET}"
done | fzf --ansi \
    --cycle --multi --bind 'tab:toggle-down,change:first' \
    --prompt="Select an application: " \
    --layout=reverse \
    --preview "echo -e \"${RED}\$(echo {} | cut -d'|' -f2 | cut -c1-1 | figlet -f 3d)${RESET}\" " \
    --preview-window=right:10,border-left)

if [ -n "$selected_app" ]; then
    launch_application "$selected_app"
else
    echo "No application selected."
fi

