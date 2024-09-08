local wezterm = require("wezterm")
local config = wezterm.config_builder()
config.enable_tab_bar = false
config.font = wezterm.font("MesloLGM Nerd Font")
config.freetype_load_flags = "NO_HINTING"
config.bold_brightens_ansi_colors = "BrightOnly"
config.font_size = 12
return config
