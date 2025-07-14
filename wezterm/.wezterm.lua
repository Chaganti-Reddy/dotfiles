-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

config.font = wezterm.font("Iosevka Nerd Font")
config.font_size = 14
config.enable_tab_bar = false
config.window_decorations = "RESIZE"
-- config.color_scheme = 'AdventureTime'
config.window_background_opacity = 0.9
-- Finally, return the configuration to wezterm:
return config
