hl.config({
	general = {
		layout = "scrolling",
		gaps_in = 5,
		gaps_out = 10,
		border_size = 2,
	},
	decoration = {
		rounding = 8,
		shadow = { enabled = false },
	},
	scrolling = {
		column_width = 0.5,
		explicit_column_widths = "0.5, 1.0",
		fullscreen_on_one_column = false,
		focus_fit_method = 1,
		follow_focus = true,
	},
	input = {
		follow_mouse = 0,
		float_switch_override_focus = 0,
		kb_layout = "us, ru",
		kb_options = "grp:win_space_toggle",
	},
	-- HACK: check this in new versions
	cursor = {
		no_hardware_cursors = 1,
	},
	misc = {
		disable_hyprland_logo = true,
		force_default_wallpaper = -1,
	},
})

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
dofile(os.getenv("HOME") .. "/.config/hypr/active-profile.lua")
