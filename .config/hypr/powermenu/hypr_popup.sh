#!/bin/bash

# Path to your power menu script
POWER_MENU_SCRIPT="$HOME/fzfpowermenu.sh"

# Function to get the focused window class
get_focused_window_class() {
    hyprctl activewindow -j | jq -r .class
}

# Function to get current focus mode
get_focus_mode() {
    hyprctl getoption input:follow_mouse -j | jq -r .int
}
get_s_o_f() {
    hyprctl getoption input:float_switch_override_focus -j | jq -r .int
}
# Save the current focus mode
ORIGINAL_FOCUS_MODE=$(get_focus_mode)
ORIGINAL_S_O_F=$(get_s_o_f)
# Global variable for the WezTerm PID
WEZTERM_PID=""

# Cleanup function
cleanup() {
    # Kill the power menu if it's still running
    if [ -n "$WEZTERM_PID" ]; then
        kill $WEZTERM_PID 2>/dev/null
    fi

    # Restore the original focus mode
    hyprctl keyword input:follow_mouse $ORIGINAL_FOCUS_MODE
    hyprctl keyword input:float_switch_override_focus $ORIGINAL_S_O_F
}

# Set trap for cleanup
trap cleanup EXIT INT TERM

# Change focus mode to click to focus
hyprctl keyword input:follow_mouse 2
hyprctl keyword input:float_switch_override_focus 0
# Launch the power menu
wezterm --config initial_rows=6 --config initial_cols=15 --config font_size=20 start --class floating "$1" &

# Get the PID of the launched wezterm process
WEZTERM_PID=$!

# Wait a bit for the window to appear
sleep 0.5

# Get the initial focused window class
INITIAL_FOCUS=$(get_focused_window_class)

# Monitor focus
while true; do
    

    CURRENT_FOCUS=$(get_focused_window_class)
    
    # If focus has changed from the power menu window, exit
    if  [ "$CURRENT_FOCUS" != "$INITIAL_FOCUS" ]; then
        break
    fi
    
    # Check if the wezterm process is still running
    if ! kill -0 $WEZTERM_PID 2>/dev/null; then
        break
    fi
    
    sleep 0.1
done

# The cleanup function will be called automatically due to the trap
