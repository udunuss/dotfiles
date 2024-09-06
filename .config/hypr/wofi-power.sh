#!/bin/bash
p_style="* { font-size: 24px; font-family: monospace; margin-left: 2px; margin-right: 2px;}"
p_config="hide_search=true\nwidth=250\nheight=210\nexpander > list > #entry {\n* { font-size: 24px; font-family: monospace; margin-left: 2px; margin-right: 2px;}\n}"

echo -e $p_style > /tmp/wofi_style.css
echo -e $p_config > /tmp/wofi_config
entries="⇠ Logout\n⏾ Suspend\n⭮ Reboot\n⏻ Shutdown"

selected=$(echo -e $entries|wofi --conf=/tmp/wofi_config  -G -I -m  --dmenu --cache-file /dev/null --style=/tmp/wofi_style.css | awk '{print tolower($2)}')

case $selected in
  logout)
    hyprctl dispatch exit;;
  suspend)
    exec systemctl suspend;;
  reboot)
    exec systemctl reboot;;
  shutdown)
    exec systemctl poweroff -i;;
esac
