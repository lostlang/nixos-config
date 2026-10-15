local mod = "SUPER"
local mouse_left_button = "mouse:272"
local mouse_right_button = "mouse:273"

local function spawn(key, command, flags)
	hl.bind(key, hl.dsp.exec_cmd(command), flags or {})
end

spawn(mod .. " + T", "kitty")

hl.bind(mod .. " + X", hl.dsp.window.close())
spawn(mod .. " + R", "noctalia msg panel-toggle launcher")
spawn("Print", "noctalia msg screenshot-region")
spawn(mod .. " + P", "noctalia msg screenshot-region")
spawn("SHIFT + Print", "noctalia msg screenshot-fullscreen")
spawn(mod .. " + SHIFT + P", "noctalia msg screenshot-fullscreen")
spawn(mod .. " + L", "noctalia msg session lock")
spawn(mod .. " + Q", "noctalia msg panel-toggle session")
spawn(mod .. " + Tab", "noctalia msg window-switcher")
spawn(mod .. " + S", "noctalia msg plugin alok-debnath/shelf:service all toggle")

hl.bind(mod .. " + SHIFT + R", function()
	local window = hl.get_active_window()
	if not window then
		return
	end

	if not window.floating then
		hl.dispatch(hl.dsp.layout("colresize +conf"))
		return
	end
end)

hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))

_G.hiddenFloatingWindows = _G.hiddenFloatingWindows or {}
hl.bind(mod .. " + H", function()
	local hidden = _G.hiddenFloatingWindows

	if #hidden > 0 then
		local workspace = hl.get_active_workspace()
		for _, saved in ipairs(hidden) do
			local ok, window = pcall(hl.get_window, saved.window)
			if ok and window and window.workspace and window.workspace.name == "special:hidden-floating" then
				hl.dispatch(hl.dsp.window.move({ window = window, workspace = workspace.id, follow = false }))
				hl.dispatch(hl.dsp.window.move({ window = window, x = saved.x, y = saved.y, relative = false }))
				hl.dispatch(hl.dsp.window.pin({ window = window, action = "enable" }))
			end
		end
		_G.hiddenFloatingWindows = {}
		return
	end

	for _, window in ipairs(hl.get_windows()) do
		local workspace = window.workspace
		if window.floating and window.pinned and workspace and workspace.id > 0 then
			table.insert(hidden, {
				window = window,
				x = window.at.x,
				y = window.at.y,
			})
			hl.dispatch(hl.dsp.window.pin({ window = window, action = "disable" }))
			hl.dispatch(hl.dsp.window.move({ window = window, workspace = "special:hidden-floating", follow = false }))
		end
	end
end)

hl.bind(mod .. " + C", function()
	local window = hl.get_active_window()
	if not window then
		return
	end

	if not window.floating then
		hl.dispatch(hl.dsp.layout("center"))
		return
	end

	local monitor = window.monitor
	if not monitor or window.fullscreen ~= 0 then
		return
	end

	local width, height = monitor.width / monitor.scale, monitor.height / monitor.scale
	if monitor.transform % 2 == 1 then
		width, height = height, width
	end

	local reserved = monitor.reserved
	local gaps = hl.get_config("general:gaps_out")
	local border = hl.get_config("general:border_size")

	local left = monitor.x + reserved.left + gaps.left + border
	local top = monitor.y + reserved.top + gaps.top + border
	local right = math.max(left, monitor.x + width - reserved.right - gaps.right - border - window.size.x)
	local bottom = math.max(top, monitor.y + height - reserved.bottom - gaps.bottom - border - window.size.y)
	local positions = {
		{ x = left, y = top },
		{ x = right, y = top },
		{ x = right, y = bottom },
		{ x = left, y = bottom },
		{ x = (left + right) / 2, y = (top + bottom) / 2 },
	}

	local next_position = positions[1]
	local current = window.at
	for index, position in ipairs(positions) do
		if math.abs(current.x - position.x) <= 3 and math.abs(current.y - position.y) <= 3 then
			next_position = positions[index % #positions + 1]
			break
		end
	end

	hl.dispatch(hl.dsp.window.move({
		x = math.floor(next_position.x),
		y = math.floor(next_position.y),
		relative = false,
	}))
end)

hl.bind(mod .. " + left", hl.dsp.layout("focus l"))
hl.bind(mod .. " + right", hl.dsp.layout("focus r"))
hl.bind(mod .. " + mouse_left", hl.dsp.layout("focus l"))
hl.bind(mod .. " + mouse_right", hl.dsp.layout("focus r"))
hl.bind(mod .. " + SHIFT + left", hl.dsp.layout("consume_or_expel prev"))
hl.bind(mod .. " + SHIFT + right", hl.dsp.layout("consume_or_expel next"))
for _, direction in ipairs({ "up", "down" }) do
	hl.bind(mod .. " + " .. direction, hl.dsp.focus({ direction = direction }))
	hl.bind(mod .. " + SHIFT + " .. direction, hl.dsp.window.move({ direction = direction }))
end

hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mod .. " + minus", hl.dsp.layout("colresize -0.1"))
hl.bind(mod .. " + equal", hl.dsp.layout("colresize +0.1"))
hl.bind(mod .. " + CTRL + minus", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))
hl.bind(mod .. " + CTRL + equal", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))
hl.bind(mod .. " + period", hl.dsp.layout("promote"))

for workspace = 1, 10 do
	local key = tostring(workspace % 10)
	hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = workspace }))
	hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end
hl.bind(mod .. " + M", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mod .. " + SHIFT + M", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mod .. " + " .. mouse_left_button, hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + " .. mouse_right_button, hl.dsp.window.resize(), { mouse = true })

local repeatLocked = { locked = true, repeating = true }
spawn("XF86AudioRaiseVolume", "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+", repeatLocked)
spawn("XF86AudioLowerVolume", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-", repeatLocked)
spawn("XF86AudioMute", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle", { locked = true })
spawn("XF86AudioMicMute", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle", { locked = true })
spawn("XF86MonBrightnessUp", "brightnessctl set 10%+", repeatLocked)
spawn("XF86MonBrightnessDown", "brightnessctl set 10%-", repeatLocked)
spawn("XF86AudioNext", "playerctl next", { locked = true })
spawn("XF86AudioPause", "playerctl play-pause", { locked = true })
spawn("XF86AudioPlay", "playerctl play-pause", { locked = true })
spawn("XF86AudioPrev", "playerctl previous", { locked = true })
