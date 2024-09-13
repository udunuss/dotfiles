#!/bin/bash
title="Power Menu"
echo -e '\033k'$title'\033\\'
# Define the menu options
options=("󰍃 Logout" "󰒲 Suspend" "󰑓 Reboot" "󰐥 Shutdown") 

# Use fzf to create a menu and get user selection
choice=$(printf '%s\n' "${options[@]}" | fzf --reverse --border=none  --info=inline )

# Handle the user's choice
case $choice in
    "󰍃 Logout")
        hyprctl dispatch exit
        ;;
    "󰒲 Suspend")
        systemctl suspend
        ;;
    "󰑓 Reboot")
        systemctl reboot
        ;;
    "󰐥 Shutdown")
        systemctl poweroff
        ;;
    Cancel|"")
        exit 0
        ;;
    *)
        echo "Invalid option selected"
        exit 1
        ;;
esac

