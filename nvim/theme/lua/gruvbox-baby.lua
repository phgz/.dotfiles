local theme = require("gruvbox-baby.theme")
local colors = require("gruvbox-baby.colors").config({
	transparent_mode = true,
	use_original_palette = false,
	-- color_overrides = { light_blue = "#4FABB1" },
})
local util = require("gruvbox-baby.util")
local background_dark = "#1d2021"
local background = "#282828"
local config = {
	comment_style = "italic",
	keyword_style = "italic",
	function_style = "bold",
	string_style = "nocombine",
	variable_style = "NONE",
	-- color_overrides = { light_blue = "#4FABB1" },

	telescope_theme = false,
	transparent_mode = true,
	highlights = {
		DiagnosticUnderlineOk = { style = "undercurl", bg = "None", sp = colors.magenta },
		DiagnosticUnderlineHint = { style = "undercurl", bg = "None", sp = colors.forest_green },
		DiagnosticUnderlineWarn = { style = "undercurl", bg = "None", sp = colors.soft_yellow },
		DiagnosticUnderlineInfo = { style = "undercurl", bg = "None", sp = colors.light_blue },
		DiagnosticUnderlineError = { style = "undercurl", bg = "None", sp = colors.red },

		DiagnosticLineNrOk = { style = "bold", bg = "None", fg = colors.magenta },
		DiagnosticLineNrHint = { style = "bold", bg = "None", fg = colors.forest_green },
		DiagnosticLineNrWarn = { style = "bold", bg = "None", fg = colors.soft_yellow },
		DiagnosticLineNrInfo = { style = "bold", bg = "None", fg = colors.light_blue },
		DiagnosticLineNrError = { style = "bold", bg = "None", fg = colors.red },

		DiagnosticOk = { bg = "None", fg = colors.magenta },
		DiagnosticHint = { bg = "None", fg = colors.forest_green },
		DiagnosticWarn = { bg = "None", fg = colors.soft_yellow },
		DiagnosticInfo = { bg = "None", fg = colors.light_blue },
		DiagnosticError = { bg = "None", fg = colors.red },

		DiagnosticDeprecated = { bg = "None", fg = colors.orange },
		-- DiagnosticUnnecessary = { bg = "None", fg = colors.pink },

		LspSignatureActiveParameter = { style = "italic", fg = colors.soft_green },

		GitSignsDelete = { bg = "None", fg = colors.red },
		GitSignsAdd = { bg = "None", fg = colors.forest_green },
		GitSignsChange = { bg = "None", fg = colors.soft_yellow },

		EndOfBuffer = { fg = colors.medium_gray },

		MatchParen = { bg = colors.medium_gray },
		MatchWord = { style = "bold" },

		IncSearch = { fg = colors.forest_green, bg = colors.comment },
		Substitute = { bg = colors.diff.text },

		StatusLine = { fg = colors.foreground, bg = "#413c37" },

		NormalFloat = { bg = background_dark },
		ErrorFloat = { bg = background_dark },
		WarningFloat = { bg = background_dark },
		InfoFloat = { bg = background_dark },
		HintFloat = { bg = background_dark },
		FloatBorder = { bg = background_dark },

		PopupPreviewDocument = { fg = colors.foreground, bg = colors.background_light },
		PopupPreviewBorder = { fg = colors.foreground, bg = colors.background_light },

		RedStatusLine = { fg = colors.red, bg = "#413c37" },
		GreenStatusLine = { fg = colors.forest_green, bg = "#413c37" },
		BlueStatusLine = { fg = colors.soft_yellow, bg = "#413c37" },
		GreyStatusLine = { fg = "grey", bg = "#413c37" },

		TelescopeBorder = { fg = background_dark, bg = background_dark },
		TelescopePromptCounter = { fg = colors.milk, bg = colors.medium_gray },
		TelescopePromptBorder = { fg = colors.medium_gray, bg = colors.medium_gray },
		TelescopePromptNormal = { fg = colors.milk, bg = colors.medium_gray },
		TelescopePromptPrefix = { fg = colors.soft_yellow, bg = colors.medium_gray },

		TelescopeNormal = { bg = background_dark },

		TelescopePreviewTitle = { fg = background, bg = colors.forest_green },
		TelescopePreviewMatch = { fg = background_dark, bg = colors.milk },
		TelescopePromptTitle = { fg = background, bg = colors.soft_yellow },
		TelescopeResultsTitle = { fg = background_dark, bg = colors.milk },

		TelescopeSelection = { bg = colors.diff.change },
		TelescopeMultiSelection = { fg = colors.soft_yellow },

		IlluminatedWordText = { style = "bold" },
		IlluminatedWordRead = { style = "bold" },
		IlluminatedWordWrite = { style = "bold" },
	},
}

vim.cmd("hi clear")
vim.go.background = "dark"
util.load(theme.setup(config))
