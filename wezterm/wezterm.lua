local wezterm = require("wezterm")
local act = wezterm.action
local mux = wezterm.mux

local ssh_domains = {}

for host, config in pairs(wezterm.enumerate_ssh_hosts()) do
	table.insert(ssh_domains, {
		-- the name can be anything you want; we're just using the hostname
		name = host,
		-- remote_address must be set to `host` for the ssh config to apply to it
		remote_address = host,
	})
end

-- wezterm.on("mux-startup", function()
-- 	local tab, pane, window = mux.spawn_window({})
-- 	pane:split({ direction = "Top" })
-- end)

-- edit remote: `/etc/ssh/sshd_config`, `sudo /usr/sbin/sshd -t`
-- then `sudo systemctl restart ssh`

wezterm.on("open-uri", function(window, pane, uri)
	print(uri)
	-- vim "+call cursor(<LINE>, <COLUMN>)"
	local is_url = uri:match([[^https?://]])
	-- local match = uri:match([[[a-zA-Z0-9_%-/%.]+]])
	if not is_url then
		-- local match = uri:match([[[a-zA-Z0-9_%-/%.]+%.[a-z][a-z][a-z]?[a-z]?$]])
		-- local success, stdout, stderr = wezterm.run_child_process({ "ls", "-l" })
		-- maybe just pane:send_text(text)
		pane:send_text("nvim " .. uri .. "\x0A")
		-- window:perform_action(
		-- 	act.SendString("nvim " .. uri .. "\x0A"),
		-- 	-- act.SpawnCommandInNewTab({
		-- 	-- 	args = { "nvim", uri },
		-- 	-- }),
		-- 	pane
		-- )
		-- prevent the default action from opening in a browser
		return false
	end
	print("error")
	-- otherwise, by not specifying a return value, we allow later
	-- handlers and ultimately the default action to caused the
	-- URI to be opened in the browser
end)

wezterm.on("update-status", function(window, pane)
	local date = wezterm.strftime("%H:%M")

	window:set_right_status(wezterm.format({
		-- { Foreground = { AnsiColor = "Grey" } },
		{ Attribute = { Intensity = "Half" } },
		{
			Text = "▏"
				.. pane:get_domain_name():gsub("SSH to", "")
				.. "/"
				.. window:active_workspace()
				.. ", "
				.. date,
		},
	}))
	-- window:set_right_status(wezterm.format({
	-- 	{ Text =  .. " " .. date },
	-- }))
end)

-- wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
-- 	local edge_background = "#0b0022"
-- 	local background = "#1b1032"
-- 	local foreground = "#808080"
--
-- 	if tab.is_active then
-- 		background = "#2b2042"
-- 		foreground = "#c0c0c0"
-- 	elseif hover then
-- 		background = "#3b3052"
-- 		foreground = "#909090"
-- 	end
--
-- 	local edge_foreground = background
--
-- 	-- ensure that the titles fit in the available space,
-- 	-- and that we have room for the edges.
-- 	-- local title = wezterm.truncate_right(tab.active_pane.title, max_width - 2)
--
-- 	return {
-- 		{ Foreground = { Color = edge_foreground } },
-- 		{ Text = SOLID_LEFT_ARROW },
-- 		{ Background = { Color = background } },
-- 		{ Foreground = { Color = foreground } },
-- 		{ Text = tab.tab_index + 1 .. ": " .. tab.active_pane.title },
-- 		"ResetAttributes",
-- 		{ Foreground = { Color = edge_foreground } },
-- 		{ Text = SOLID_RIGHT_ARROW },
-- 	}
-- end)

-- wezterm.on("gui-startup", function(cmd)
-- 	-- allow `wezterm start -- something` to affect what we spawn
-- 	-- in our initial window
-- 	local args = {}
-- 	print(cmd)
-- 	if cmd then
-- 		args = cmd.args
-- 	end
--
-- 	-- Set a workspace for coding on a current project
-- 	-- Top pane is for the editor, bottom pane is for the build tool
-- 	local project_dir = wezterm.home_dir .. "/dir2"
-- 	-- local tab, build_pane, window = mux.spawn_window({
-- 	-- 	workspace = "coding",
-- 	-- 	cwd = project_dir,
-- 	-- 	args = {},
-- 	-- })
-- 	-- -- may as well kick off a build in that pane
-- 	-- build_pane:send_text("cargo build")
--
-- 	-- A workspace for interacting with a local machine that
-- 	-- runs some docker containners for home automation
-- 	-- local tab, pane, window = mux.spawn_window({
-- 	-- 	workspace = "automation",
-- 	-- 	cwd = project_dir,
-- 	-- 	args = args,
-- 	-- })
-- 	-- local editor_pane = pane:split({
-- 	-- 	direction = "Top",
-- 	-- 	size = 0.6,
-- 	-- 	cwd = project_dir,
-- 	-- 	-- args = args,
-- 	-- })
-- 	-- for _, domain in ipairs(ssh_domains) do
-- 	-- 	mux.spawn_window({
-- 	-- 		workspace = "ws_" .. domain.name,
-- 	-- 		-- args = { 'ssh', 'vault' },
-- 	-- 	})
-- 	-- end
-- 	-- wezterm.mux.spawn_window({ workpace = "work", domain = { DomainName = "ai-dev-0" } })
-- 	-- We want to startup in the coding workspace
-- 	-- local windows = wezterm.mux.all_windows()
-- 	-- print(windows)
-- 	-- windows[1].perform_action(act({
-- 	-- 	SwitchToWorkspace = {
-- 	-- 		name = "aidev0",
-- 	-- 		spawn = {
-- 	-- 			domain = { DomainName = "ai-dev-0" },
-- 	-- 		},
-- 	-- 	},
-- 	-- }))
-- end)

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local path
	local cwd = tab.active_pane.current_working_dir
	local username = wezterm.home_dir:match("/.*/(.*)")
	local home = cwd:match("/Users/" .. username) or cwd:match("/home/" .. username)
	if home then
		local rel_dir = cwd:match(home .. "/(.*)")
		if rel_dir then
			path = rel_dir:match("[^/]+") -- project root
		else
			path = "~" -- home
		end
	else
		path = cwd:match("file://[^/]+(.*)") or tab.active_pane.title
	end
	local is_first = tab.tab_index == 0
	local is_last = tab.tab_index == #tabs - 1

	local pad_left = is_first and "" or "  "
	local pad_right = is_last and "" or "  "
	local active = tab.is_active and "*" or ""
	local zoomed = tab.active_pane.is_zoomed and "Z" or ""
	local active_zoomed_pad = active .. zoomed == "" and "" or " "
	local has_separator = is_last and 0 or 1
	local separator = is_last and "" or ""
	local tab_index = tab.tab_index + 1 .. " "
	local reserved = #tab_index + #pad_left + #pad_right + #zoomed + #active + #active_zoomed_pad + has_separator
	local path_max_width = config.tab_max_width - reserved
	local too_large = #path > path_max_width
	if too_large then
		while #path + 4 > path_max_width do
			path = path:match("(.*)/")
		end
		path = path .. "/..."
	end
	local title = pad_left .. tab_index .. active .. zoomed .. active_zoomed_pad .. path .. pad_right .. separator
	local output = {
		{ Text = title },
	}
	if not tab.is_active then
		for _, pane in ipairs(tab.panes) do
			if pane.has_unseen_output then
				output[1], output[2] = { Background = { Color = "Red" } }, output[1]
				break
			end
		end
	end

	return output
end)

-- wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
-- 	local zoomed, active = "", "notk"
-- 	if tab.active_pane.is_zoomed then
-- 		zoomed = "[Z] "
-- 	end
-- 	if tab.is_active then
-- 		active = "* "
-- 	end
--
-- 	return zoomed .. active .. tab.active_pane.title
-- end)

return {
	adjust_window_size_when_changing_font_size = false,
	cell_width = 1.0,
	-- color_scheme = "Gruvbox dark, medium (base16)",
	cursor_blink_rate = 0,
	cursor_thickness = 1,
	font = wezterm.font("FantasqueSansMono Nerd font"),
	font_size = 19,
	hide_tab_bar_if_only_one_tab = true,
	line_height = 1.2,
	native_macos_fullscreen_mode = true,
	pane_focus_follows_mouse = true,
	show_new_tab_button_in_tab_bar = false,
	show_update_window = true,
	ssh_domains = ssh_domains,
	status_update_interval = 20000,
	switch_to_last_active_tab_when_closing_tab = true,
	tab_bar_at_bottom = true,
	tab_max_width = 32,
	term = "wezterm",
	underline_position = "-4pt",
	use_fancy_tab_bar = false,
	use_resize_increments = true,
	window_decorations = "RESIZE",
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	hyperlink_rules = {
		{
			regex = "\\b\\w+://[\\w.-]+\\.[a-z]{2,15}\\S*\\b",
			format = "$0",
		},

		-- Linkify things that look like URLs with numeric addresses as hosts.
		-- E.g. http://127.0.0.1:8000 for a local development server,
		-- or http://192.168.1.1 for the web interface of many routers.
		{
			regex = [[\b\w+://(?:[\d]{1,3}\.){3}[\d]{1,3}\S*\b]],
			format = "$0",
		},

		-- file:// URI
		-- Compiled-in default. Used if you don't specify any hyperlink_rules.
		{
			regex = [[[a-zA-Z0-9_\-/.]+\.[a-z]{2,4}\b]],
			format = "$0",
		},
	},
	keys = {
		-- {
		-- 	key = "u",
		-- 	mods = "CTRL|SHIFT",
		-- 	action = act.SwitchToWorkspace({
		-- 		name = "monitoring",
		-- 		spawn = {
		-- 			args = { "top" },
		-- 		},
		-- 	}),
		-- },
		{
			key = "u",
			mods = "SUPER",
			action = wezterm.action.AttachDomain("ai-dev-0"),
		},
		{
			key = "a",
			mods = "CTRL|SHIFT",
			action = act.SwitchToWorkspace({
				name = "remote",
			}),
		},
		{
			key = "y",
			mods = "CTRL|SHIFT",
			action = act.SwitchToWorkspace({
				name = "default",
			}),
		},
		{ key = "d", mods = "SUPER", action = act.DetachDomain("CurrentPaneDomain") },
		{
			key = "9",
			mods = "ALT",
			action = act({ ShowLauncherArgs = {
				flags = "FUZZY|WORKSPACES",
			} }),
		},
		{
			key = "a",
			mods = "SUPER",
			-- action = act.ActivateLastTab,
			action = wezterm.action_callback(function(win, pane)
				-- act.SwitchToWorkspace({
				-- 	name = "remote",
				-- })
				wezterm.mux.spawn_window({
					workspace = "remote",--[[ , domain = { DomainName = "ai-dev-0" } ]]
				})
				local win_ = win:mux_window()
				print(win_)
				win_:set_workspace("remote")
				-- wezterm.mux.set_active_workspace("remote")
				-- local domain = mux.get_domain("ai-dev-0")
				-- print(domain)
				-- for _, mux_ in ipairs(mux.all_domains()) do
				-- print(mux_:name())
				-- end
				-- print(mux.get_workspace_names())
				-- print(domain:state())
				-- print(domain:has_any_panes())
				-- print(domain:is_spawnable())
				-- if not domain:has_any_panes() then
				-- act.AttachDomain("ai-dev-0")
				-- print("no pane")
				-- wezterm.mux.spawn_window({ domain = { DomainName = "ai-dev-0" } })
				win:perform_action(act.AttachDomain("ai-dev-0"), pane)
				-- win:perform_action(act.SwitchToWorkspace({ name = "remote" }), pane)
				-- action = act.SwitchToWorkspace({
				-- 	name = "remote",
				-- 	spawn = {
				-- 		domain = { DomainName = "ai-dev-0" },
				-- 	},
				-- }),
				-- act.SwitchToWorkspace({
				-- 				name = "monitoring",
				-- 				spawn = {
				-- 					args = { "top" },
				-- 				},
				-- 			}),
				-- else
				-- domain:attach()
				-- print("has panes: ", domain:state())
				-- end
				wezterm.sleep_ms(2000)
				print(domain:is_spawnable())
				win:perform_action(act.SwitchToWorkspace({ name = "remote" }), pane)
				-- win:perform_action(act.EmitEvent("update-status"), pane)
			end),
			-- action = act.AttachDomain("ai-dev-0"),
		},
		{
			key = "c",
			mods = "SUPER",
			action = wezterm.action_callback(function(window, pane)
				window:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)

				window:perform_action(act.ClearSelection, pane)
			end),
		},
		{
			key = "|",
			mods = "SUPER|SHIFT",
			action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
		},
		{
			key = "z",
			mods = "SUPER",
			action = act.TogglePaneZoomState,
		},
		{
			key = "Enter",
			mods = "SUPER",
			action = act.ToggleFullScreen,
		},
		{
			key = "_",
			mods = "SUPER|SHIFT",
			action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
		},
		{
			key = "e",
			mods = "SUPER|SHIFT",
			-- action = act.AttachDomain("ai-dev-0"),
			action = act.SwitchToWorkspace({
				name = "remote",
				spawn = {
					domain = { DomainName = "ai-dev-0" },
				},
			}),
			-- action = wezterm.action_callback(function(window, pane)
			-- 	-- window:perform_action(act.EmitEvent("update-status"), pane)
			-- 	local dimensions = window:get_dimensions()
			-- 	window:set_inner_size(dimensions.pixel_width + 1, dimensions.pixel_height + 1)
			-- end),
		},
	},
	-- tab_bar_style = {
	-- 	active_tab_left = wezterm.format({
	-- 		{ Background = { Color = "#0b0022" } },
	-- 		{ Foreground = { Color = "#2b2042" } },
	-- 		{ Text = SOLID_LEFT_ARROW },
	-- 	}),
	-- 	active_tab_right = wezterm.format({
	-- 		{ Background = { Color = "#0b0022" } },
	-- 		{ Foreground = { Color = "#2b2042" } },
	-- 		{ Text = SOLID_RIGHT_ARROW },
	-- 	}),
	-- 	inactive_tab_left = wezterm.format({
	-- 		{ Background = { Color = "#0b0022" } },
	-- 		{ Foreground = { Color = "#1b1032" } },
	-- 		{ Text = SOLID_LEFT_ARROW },
	-- 	}),
	-- 	inactive_tab_right = wezterm.format({
	-- 		{ Background = { Color = "#0b0022" } },
	-- 		{ Foreground = { Color = "#1b1032" } },
	-- 		{ Text = SOLID_RIGHT_ARROW },
	-- 	}),
	-- },
	colors = {
		-- The default text color
		foreground = "#24292f",
		-- The default background color
		background = "#f4f4f4",
		-- the foreground color of selected text
		cursor_bg = "#044289",
		cursor_fg = "#f4f4f4",
		selection_fg = "#24292f",
		-- the background color of selected text
		selection_bg = "#dbe9f9",
		ansi = {
			"#24292e",
			"#d73a49",
			"#28a745",
			"#dbab09",
			"#0366d6",
			"#5a32a3",
			"#0598bc",
			"#6a737d",
		},
		brights = {
			"#959da5",
			"#cb2431",
			"#22863a",
			"#b08800",
			"#005cc5",
			"#5a32a3",
			"#3192aa",
			"#d1d5da",
		},
		tab_bar = {
			-- The color of the strip that goes along the top of the window
			-- (does not apply when fancy tab bar is in use)
			background = "#413c37",

			-- The active tab is the one that has focus in the window
			active_tab = {
				-- The color of the background area for the tab
				bg_color = "#413c37",
				-- The color of the text for the tab
				fg_color = "#ffd787",

				-- Specify whether you want "Half", "Normal" or "Bold" intensity for the
				-- label shown for this tab.
				-- The default is "Normal"
				intensity = "Bold",

				-- Specify whether you want "None", "Single" or "Double" underline for
				-- label shown for this tab.
				-- The default is "None"
				underline = "None",

				-- Specify whether you want the text to be italic (true) or not (false)
				-- for this tab.  The default is false.
				italic = false,

				-- Specify whether you want the text to be rendered with strikethrough (true)
				-- or not for this tab.  The default is false.
				strikethrough = false,
			},

			-- Inactive tabs are the tabs that do not have focus
			inactive_tab = {
				bg_color = "#413c37",
				fg_color = "#928374",

				-- The same options that were listed under the `active_tab` section above
				-- can also be used for `inactive_tab`.
			},

			-- You can configure some alternate styling when the mouse pointer
			-- moves over inactive tabs
			inactive_tab_hover = {
				bg_color = "#3b3052",
				fg_color = "#909090",
				italic = true,

				-- The same options that were listed under the `active_tab` section above
				-- can also be used for `inactive_tab_hover`.
			},

			-- The new tab button that let you create new tabs
			new_tab = {
				bg_color = "#1b1032",
				fg_color = "#808080",

				-- The same options that were listed under the `active_tab` section above
				-- can also be used for `new_tab`.
			},

			-- You can configure some alternate styling when the mouse pointer
			-- moves over the new tab button
			new_tab_hover = {
				bg_color = "#3b3052",
				fg_color = "#909090",
				italic = true,

				-- The same options that were listed under the `active_tab` section above
				-- can also be used for `new_tab_hover`.
			},
		},
	},
}
