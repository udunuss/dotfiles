#!/bin/bash

if [[ $# -lt 4 ]]; then
    echo "Usage: $0 <script_path> <cols> <rows> <font_size>"
    exit 1
fi
# Change focus mode to click to focus
hyprctl keyword input:follow_mouse 2
hyprctl keyword input:float_switch_override_focus 0
# Function to get the focused window (returns window ID)
get_focused_window() {
    hyprctl activewindow -j | jq -r '.address'
}

# Function to get current focus mode
get_focus_mode() {

    grep "follow_mouse" ~/.config/hypr/hyprland.conf | cut -d '=' -f 2 | cut -d '#' -f 1 | tr -d ' '
}
get_s_o_f() {

    grep "float_switch_override_focus" ~/.config/hypr/hyprland.conf | cut -d '=' -f 2 | cut -d '#' -f 1 | tr -d ' '
}
# Function to get the window ID by process PID
get_window_by_pid() {
    local pid=$1
    hyprctl clients -j | jq -r --arg pid "$pid" '.[] | select(.pid == ($pid | tonumber)) | .address'
}

# Save the current focus mode
ORIGINAL_FOCUS_MODE=$(get_focus_mode)
ORIGINAL_S_O_F=$(get_s_o_f)
# Global variable for the WezTerm PID
TERMINAL_PID=""

# Cleanup function
cleanup() {
    # Kill the power menu if it's still running
    if [ -n "$TERMINAL_PID" ]; then
        kill $TERMINAL_PID 2>/dev/null
    fi

    # Restore the original focus mode
    hyprctl keyword input:follow_mouse $ORIGINAL_FOCUS_MODE
    hyprctl keyword input:float_switch_override_focus $ORIGINAL_S_O_F
}

# Set trap for cleanup
trap cleanup EXIT INT TERM


# Launch the power menu
wezterm --config initial_cols=$2 --config initial_rows=$3 --config font_size=$4 start --class floating "$1" &

# Get the PID of the launched wezterm process
TERMINAL_PID=$!

# Wait a bit for the window to appear
sleep 0.7

# Get the initial focused window
INITIAL_FOCUS=$(get_window_by_pid "$TERMINAL_PID")

# Monitor focus
while true; do
    

    CURRENT_FOCUS=$(get_focused_window)
    
    # If focus has changed from the power menu window, exit
    if  [ "$CURRENT_FOCUS" != "$INITIAL_FOCUS" ]; then
        break
    fi
    
    # Check if the wezterm process is still running
    if ! kill -0 $TERMINAL_PID 2>/dev/null; then
        break
    fi
    
    sleep 0.1
done

# The cleanup function will be called automatically due to the trap
