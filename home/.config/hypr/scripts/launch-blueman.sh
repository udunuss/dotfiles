
#!/usr/bin/env bash

##################################
# 1. Functions
##################################

# Get the current focused window (returns window address)
get_focused_window() {
    hyprctl activewindow -j | jq -r '.address'
}

# Get current follow_mouse setting
get_focus_mode() {
    grep -m 1 "follow_mouse" ~/.config/hypr/hyprland.conf \
      | cut -d '=' -f 2 \
      | cut -d '#' -f 1 \
      | tr -d ' '
}

# Get current float_switch_override_focus
get_s_o_f() {
    grep -m 1 "float_switch_override_focus" ~/.config/hypr/hyprland.conf \
      | cut -d '=' -f 2 \
      | cut -d '#' -f 1 \
      | tr -d ' '
}

# Get the window address by PID
get_window_by_pid() {
    local pid=$1
    hyprctl clients -j \
      | jq -r --arg pid "$pid" '.[] | select(.pid == ($pid | tonumber)) | .address'
}

##################################
# 2. Save current Hyprland settings
##################################

ORIGINAL_FOCUS_MODE=$(get_focus_mode)
ORIGINAL_S_O_F=$(get_s_o_f)

##################################
# 3. Prep environment
##################################

# Switch focus mode to click-to-focus
hyprctl keyword input:follow_mouse 2
hyprctl keyword input:float_switch_override_focus 0

# We will restore these settings in cleanup()
cleanup() {
    # If Blueman (or the launched process) is still running, kill it
    if [[ -n "$BLUEMAN_PID" ]]; then
        kill "$BLUEMAN_PID" 2>/dev/null
    fi

    # Restore original focus mode
    hyprctl keyword input:follow_mouse "$ORIGINAL_FOCUS_MODE"
    hyprctl keyword input:float_switch_override_focus "$ORIGINAL_S_O_F"
}

# Call cleanup on script exit
trap cleanup EXIT INT TERM

##################################
# 4. Launch your GUI app
##################################

# Example: Open Blueman Manager
blueman-manager &
BLUEMAN_PID=$!

# Give it a moment to appear in Hyprland
sleep 0.6

# Get the newly launched window address
WINDOW_ADDR=$(get_window_by_pid "$BLUEMAN_PID")

##################################
# 5. Monitor focus; close if user changes focus
##################################

while true; do
    CURRENT_FOCUS=$(get_focused_window)

    # If focus no longer on the blueman-manager window, break
    if [[ "$CURRENT_FOCUS" != "$WINDOW_ADDR" ]]; then
        break
    fi

    # If the process died, break
    if ! kill -0 "$BLUEMAN_PID" 2>/dev/null; then
        break
    fi

    sleep 0.1
done

# Script ends. "cleanup" is called via trap.
exit 0
