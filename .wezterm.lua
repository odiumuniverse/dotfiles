local wezterm = require("wezterm")

local config = wezterm.config_builder()
-- config.color_scheme = "Bluloco Light (Gogh)"
-- config.color_scheme = "Catppuccin Latte"

-- config.color_scheme = "Google Light (Gogh)"
config.color_scheme = "Google (light) (terminal.sexy)"
config.font = wezterm.font("FiraCode Nerd Font Mono")
-- config.font = wezterm.font("RobotoMono Nerd Font")
config.font_size = 17

config.enable_tab_bar = false

config.window_decorations = "RESIZE"
config.window_background_opacity = 0.99
config.macos_window_background_blur = 20

return config
