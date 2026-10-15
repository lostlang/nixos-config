hl.window_rule({
	match = { class = "^org.telegram.desktop$" },
	no_screen_share = true,
})
hl.window_rule({
	match = {
		class = "^librewolf$",
		title = ".*Bitwarden.*",
	},
	no_screen_share = true,
})
