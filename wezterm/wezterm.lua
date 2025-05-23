local wezterm = require("wezterm")
local act = wezterm.action
local dotfiles_path = wezterm.home_dir .. "/.dotfiles"
local current_path = dotfiles_path .. "/theme/current"
local accepted_extensions = {
	"R",
	"ada",
	"asm",
	"c",
	"cob",
	"cpp",
	"cs",
	"csv",
	"fs",
	"fish",
	"go",
	"hs",
	"htm",
	"html",
	"java",
	"jl",
	"js",
	"json",
	"lisp",
	"lua",
	"md",
	"php",
	"pl",
	"py",
	"rb",
	"rs",
	"rst",
	"scm",
	"sh",
	"sql",
	"swift",
	"tex",
	"toml",
	"ts",
	"txt",
	"vb",
	"xml",
	"yaml",
	"yml",
}

local file_regex =
	string.format([[([a-zA-Z0-9_\-/.~]+\.(?:%s)\b)(?:.*line (\d+))?]], table.concat(accepted_extensions, "|"))

local color_scheme_mapping = { night = "ayu", day = "github-light", evening = "gruvbox-dark" }

local function get_color_scheme()
	local current
	for line in io.lines(current_path) do
		current = line
	end
	return color_scheme_mapping[current]
end

wezterm.add_to_config_reload_watch_list(current_path)

-- A custom function to URL encode a string
local function urlencode(str)
	if str then
		str = str:gsub("\n", " "):gsub("([^%w%-%.%_%~ ])", function(c)
			return string.format("%%%02X", string.byte(c))
		end)
		return str:gsub(" ", "%%20")
	end
	return ""
end

wezterm.on("gui-startup", function(cmd) -- set startup Window position
	local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
	window:gui_window():set_position(300, 165)
end)

wezterm.on("open-uri", function(window, pane, uri)
	local is_url = uri:match([[^https?://]])
	if not is_url then
		local file = uri:match([[(.*)>]])
		local line_number = uri:match([[>(%d+)$]])
		if line_number then
			-- vim "+call cursor(<LINE>, <COLUMN>)"
			pane:send_text(" hx " .. file .. ":" .. line_number .. "\x0A")
		else
			pane:send_text("hx " .. file .. "\x0A")
		end
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
		{ Foreground = { AnsiColor = "Yellow" } },
		{
			Text = ", time: " .. date,
		},
	}))
end)

local get_tab_title = function(tab, reserved)
	local cwd = tab:active_pane():get_current_working_dir().file_path
	local formatted_path = cwd
	local home = cwd:match(wezterm.home_dir)
	if home then
		local rel_dir = cwd:match(home .. "/(.*)")
		if rel_dir then
			formatted_path = rel_dir:match("[^/]+") -- project root
		else
			formatted_path = "~" -- home
		end
	end
	local config = tab:window():gui_window():effective_config()
	if reserved then
		local path_max_width = config.tab_max_width - reserved
		local too_large = #formatted_path > path_max_width
		if too_large then
			while #formatted_path + 4 > path_max_width do
				formatted_path = formatted_path:match("(.*)/")
			end
			formatted_path = formatted_path .. "/..."
		end
	end
	return formatted_path
end

local c = wezterm.config_builder()

c.adjust_window_size_when_changing_font_size = false
c.cell_width = 1.0
c.color_scheme = get_color_scheme()
c.cursor_blink_rate = 0
c.cursor_thickness = 1
c.font = wezterm.font("FantasqueSansM Nerd Font")
c.font_size = 18
c.front_end = "WebGpu"
c.hide_tab_bar_if_only_one_tab = false
c.enable_tab_bar = false
c.show_tabs_in_tab_bar = false
c.line_height = 1.2
c.cell_width = 0.9
c.mouse_wheel_scrolls_tabs = false
c.native_macos_fullscreen_mode = true
-- c.pane_focus_follows_mouse = true
c.show_new_tab_button_in_tab_bar = false
c.show_update_window = false
c.ssh_domains = ssh_domains --
c.enable_kitty_keyboard = false
-- c.status_update_interval = 20000
c.switch_to_last_active_tab_when_closing_tab = true
c.tab_bar_at_bottom = true
c.tab_max_width = 32
c.term = "wezterm"
c.underline_position = "-4pt"
c.use_fancy_tab_bar = false
c.use_resize_increments = true
c.initial_cols = 125
c.initial_rows = 36
c.window_decorations = "RESIZE"
-- c.window_background_opacity = 0.9
-- c.text_background_opacity = 0.5
-- c.macos_window_background_blur = 30
c.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
c.hyperlink_rules = {
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
		regex = file_regex,
		format = "$1>$2",
		highlight = 1,
	},
	-- implicit mailto link
	{
		regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b",
		format = "mailto:$0",
	},
}
c.keys = {
	{
		key = "i",
		mods = "SUPER",
		action = wezterm.action_callback(function(win, pane, line) -- Briefly show tab bar
			local overrides = { enable_tab_bar = true }
			win:set_config_overrides(overrides)
			overrides.enable_tab_bar = false
			wezterm.sleep_ms(4000)
			win:set_config_overrides(overrides)
		end),
	},
	{
		key = "a",
		mods = "SUPER",
		action = act.ActivateLastTab,
	},
	{
		key = "s",
		mods = "SUPER",
		action = wezterm.action_callback(function(win, pane)
			local mux_win = win:mux_window()

			-- for _, tab in ipairs(mux_win:tabs()) do
			-- 	tab:set_title(get_tab_title(tab))
			-- end

			win:perform_action(act.ShowTabNavigator, pane)
		end),
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
		key = "g",
		mods = "SUPER",
		action = wezterm.action_callback(function(window, pane)
			local selection = window:get_selection_text_for_pane(pane)
			if selection and selection ~= "" then
				local url = "https://www.google.com/search?q=" .. urlencode(selection)
				wezterm.open_with(url)
			end
		end),
	},
	{
		key = "v",
		mods = "SUPER",
		action = wezterm.action_callback(function(window, pane)
			window:perform_action(act.PasteFrom("Clipboard"), pane)

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
		mods = "META",
		action = act.DisableDefaultAssignment,
	},
	{
		key = "D",
		mods = "SUPER|SHIFT",
		action = act.ShowDebugOverlay,
	},
	{
		key = "w",
		mods = "CMD",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},
	{
		key = "S",
		mods = "SUPER|SHIFT",
		action = act.QuickSelect,
	},
	{
		key = "U",
		mods = "SUPER|SHIFT",
		action = act.CharSelect,
	},
	{
		key = "_",
		mods = "SUPER|SHIFT",
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "t",
		mods = "SUPER",
		action = act.SpawnCommandInNewTab({
			cwd = wezterm.home_dir,
		}),
	},
	{
		key = "k",
		mods = "SUPER",
		action = act.Multiple({
			act.ClearScrollback("ScrollbackAndViewport"),
			act.SendKey({ key = "L", mods = "CTRL" }),
		}),
	},
	{
		key = "LeftArrow",
		mods = "CTRL | SHIFT",
		action = act.DisableDefaultAssignment,
	},
	{
		key = "RightArrow",
		mods = "CTRL | SHIFT",
		action = act.DisableDefaultAssignment,
	},
	{
		key = "UpArrow",
		mods = "CTRL | SHIFT",
		action = act.DisableDefaultAssignment,
	},
	{
		key = "DownArrow",
		mods = "CTRL | SHIFT",
		action = act.DisableDefaultAssignment,
	},
	{
		key = "LeftArrow",
		mods = "CTRL | SHIFT | META",
		action = act.DisableDefaultAssignment,
	},
	{
		key = "RightArrow",
		mods = "CTRL | SHIFT | META",
		action = act.DisableDefaultAssignment,
	},
	{
		key = "UpArrow",
		mods = "CTRL | SHIFT | META",
		action = act.DisableDefaultAssignment,
	},
	{
		key = "DownArrow",
		mods = "CTRL | SHIFT | META",
		action = act.DisableDefaultAssignment,
	},
	{
		key = "LeftArrow",
		mods = "SUPER",
		action = wezterm.action_callback(function(window, pane)
			local direction = "Left"
			local mux_pane = pane:tab():get_pane_direction(direction)
			if mux_pane == nil then
				direction = "Prev"
			end

			window:perform_action(act.ActivatePaneDirection(direction), pane)
		end),
	},
	{
		key = "RightArrow",
		mods = "SUPER",
		action = wezterm.action_callback(function(window, pane)
			local direction = "Right"
			local mux_pane = pane:tab():get_pane_direction(direction)
			if mux_pane == nil then
				direction = "Next"
			end

			window:perform_action(act.ActivatePaneDirection(direction), pane)
		end),
	},
	{
		key = "UpArrow",
		mods = "SUPER",
		action = wezterm.action_callback(function(window, pane)
			local direction = "Up"
			local mux_pane = pane:tab():get_pane_direction(direction)
			if mux_pane == nil then
				direction = "Prev"
			end

			window:perform_action(act.ActivatePaneDirection(direction), pane)
		end),
	},
	{
		key = "DownArrow",
		mods = "SUPER",
		action = wezterm.action_callback(function(window, pane)
			local direction = "Down"
			local mux_pane = pane:tab():get_pane_direction(direction)
			if mux_pane == nil then
				direction = "Next"
			end

			window:perform_action(act.ActivatePaneDirection(direction), pane)
		end),
	},
	{
		key = "LeftArrow",
		mods = "SUPER|CTRL",
		action = act.AdjustPaneSize({ "Left", 2 }),
	},
	{
		key = "RightArrow",
		mods = "SUPER|CTRL",
		action = act.AdjustPaneSize({ "Right", 2 }),
	},
	{
		key = "UpArrow",
		mods = "SUPER|CTRL",
		action = act.AdjustPaneSize({ "Up", 2 }),
	},
	{
		key = "DownArrow",
		mods = "SUPER|CTRL",
		action = act.AdjustPaneSize({ "Down", 2 }),
	},
	{
		key = "LeftArrow",
		mods = "SUPER|META",
		action = act.PaneSelect({
			mode = "SwapWithActive", -- SwapWithActiveKeepFocus: swap the position of the active pane with the selected pane, retaining focus on the currently active pane but in its new position
		}),
	},
	{
		key = "RightArrow",
		mods = "SUPER|META",
		action = act.PaneSelect({
			mode = "SwapWithActive",
		}),
	},
	{
		key = "UpArrow",
		mods = "SUPER|META",
		action = act.PaneSelect({
			mode = "SwapWithActive",
		}),
	},
	{
		key = "DownArrow",
		mods = "SUPER|META",
		action = act.PaneSelect({
			mode = "SwapWithActive",
		}),
	},
	{
		key = "[",
		mods = "META",
		action = act.SendKey({ key = "\\", mods = "META" }),
	},
	{ key = "j", mods = "SUPER", action = act.ScrollByPage(-0.3) },
	{ key = "k", mods = "SUPER", action = act.ScrollByPage(0.3) },
	{
		key = "l",
		mods = "SUPER",
		action = act.Multiple({
			act.ClearScrollback("ScrollbackAndViewport"),
			act.SendKey({ key = "l", mods = "CTRL" }),
		}),
	},
}
-- ctrl-shift-x activates copy mode
return c
