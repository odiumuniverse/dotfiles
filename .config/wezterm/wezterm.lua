local wezterm = require("wezterm")

local keys = {}
for i = 32, 126 do
	local c = string.char(i)
	table.insert(keys, {
		key = c,
		mods = "OPT",
		action = wezterm.action.SendKey({
			key = c,
			mods = "ALT",
		}),
	})
end

local config = wezterm.config_builder()
-- config.color_scheme = "Google Light (Gogh)"
config.color_scheme = "cyberdream"
-- config.color_scheme = "Google (light) (terminal.sexy)"
config.font = wezterm.font("FiraCode Nerd Font Mono")
-- config.font = wezterm.font("RobotoMono Nerd Font")
config.font_size = 17
config.enable_tab_bar = false

config.window_decorations = "RESIZE"
config.window_background_opacity = 0.7
config.macos_window_background_blur = 25
-- config.window_background_image = (os.getenv("WEZTERM_CONFIG_FILE") or ""):gsub("wezterm.lua", "bg-blurred.png")
config.window_padding = {
	left = 5,
	right = 0,
	top = 25,
	bottom = 10,
}

config.max_fps = 120
config.prefer_egl = true

return config
