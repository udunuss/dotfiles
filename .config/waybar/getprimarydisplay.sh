#!/bin/bash

# Get the primary display using hyprctl
primary_display=$(hyprctl monitors -j | jq -r '.[] | select(.name != "") | .name' | head -n1)

# If no result, just get the first active output
if [ -z "$primary_display" ]; then
    primary_display=$(hyprctl monitors -j | jq -r '.[0].name')
fi

echo $primary_display
