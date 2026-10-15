local gaps = hl.get_config("general:gaps_out")
local border = hl.get_config("general:border_size")

hl.window_rule({
	match = { title = "^(Picture-in-Picture).*" },
	float = true,
	pin = true,
	move = {
		"monitor_w - window_w - " .. (gaps.right + border),
		"monitor_h - window_h - " .. (gaps.bottom + border),
	},
})
hl.window_rule({ match = { class = "^(imv)$" }, float = true, pin = true })
hl.window_rule({ match = { class = "^librewolf$" }, workspace = "3", scrolling_width = 1.0 })
hl.window_rule({ match = { class = "^obsidian$" }, workspace = "9", scrolling_width = 1.0 })
hl.window_rule({ match = { class = "^org.telegram.desktop$" }, workspace = "10", scrolling_width = 1.0 })
hl.window_rule({ match = { class = "^dev\\.noctalia\\.Shelf$" }, float = true, pin = true })
