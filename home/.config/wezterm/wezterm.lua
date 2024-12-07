local wezterm = require("wezterm")
local config = wezterm.config_builder()
config.enable_tab_bar = false
config.font = wezterm.font("MesloLGM Nerd Font")
config.freetype_load_flags = "NO_HINTING"
config.color_scheme = "Belge (terminal.sexy)"
config.font_size = 12
config.window_background_opacity = 0.7
if os.getenv("XDG_CURRENT_DESKTOP") == "Hyprland" then
	config.enable_wayland = false
else
	config.enable_wayland = true
end
return config
