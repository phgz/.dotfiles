local colors = require("gruvbox-baby.colors").p
local util = require("gruvbox-baby.util")

vim.g.gruvbox_baby_transparent_mode = 1

vim.g.gruvbox_baby_highlights = {
	DiagnosticUnderlineInfo = { style = "undercurl", bg = "None", sp = colors.light_blue },
	DiagnosticUnderlineHint = { style = "undercurl", bg = "None", sp = colors.forest_green },
	DiagnosticUnderlineWarn = { style = "undercurl", bg = "None", sp = colors.soft_yellow },
	DiagnosticUnderlineError = { style = "undercurl", bg = "None", sp = colors.red },

	DiagnosticLineNrInfo = { style = "bold", bg = "None", fg = colors.light_blue },
	DiagnosticLineNrHint = { style = "bold", bg = "None", fg = colors.forest_green },
	DiagnosticLineNrWarn = { style = "bold", bg = "None", fg = colors.soft_yellow },
	DiagnosticLineNrError = { style = "bold", bg = "None", fg = colors.red },

	DiagnosticInfo = { bg = "None", fg = colors.light_blue },
	DiagnosticHint = { bg = "None", fg = colors.forest_green },
	DiagnosticWarn = { bg = "None", fg = colors.soft_yellow },
	DiagnosticError = { bg = "None", fg = colors.red },

	LspInlayHint = { fg = "teal" },

	LspSignatureActiveParameter = { style = "italic", fg = colors.soft_green },
	SignatureHelpVirtual = { fg = "teal" },

	GitSignsDelete = { bg = "None", fg = colors.red },
	GitSignsAdd = { bg = "None", fg = colors.forest_green },
	GitSignsChange = { bg = "None", fg = colors.soft_yellow },
	GitSignsAddInline = { bg = colors.diff.change },
	GitSignsDeleteInline = { bg = colors.diff.change },
	GitSignsChangeInline = { bg = colors.diff.change },

	EyelinerPrimary = { style = "underline" },
	EyelinerSecondary = { style = "underdouble" },

	EndOfBuffer = { fg = colors.medium_gray },

	MatchParen = { bg = colors.medium_gray },
	MatchWord = { style = "bold" },

	IncSearch = { fg = colors.forest_green, bg = colors.comment },
	Substitute = { bg = colors.diff.text },

	StatusLine = { fg = "#ffd787", bg = "#413c37" },

	NormalFloat = { bg = colors.background_dark },

	PopupPreviewDocument = { fg = colors.foreground, bg = colors.background_light },
	PopupPreviewBorder = { fg = colors.foreground, bg = colors.background_light },

	YellowStatusLine = { fg = colors.soft_yellow, bg = "#413c37" },
	RedStatusLine = { fg = colors.red, bg = "#413c37" },
	GreenStatusLine = { fg = colors.forest_green, bg = "#413c37" },
	BlueStatusLine = { fg = colors.soft_yellow, bg = "#413c37" },
	GreyStatusLine = { fg = "grey", bg = "#413c37" },

	WrappedLineNr = { fg = util.darken(colors.medium_gray, 0.66) },

	TelescopeBorder = { fg = colors.background_dark, bg = colors.background_dark },
	TelescopePromptCounter = { fg = colors.milk, bg = colors.medium_gray },
	TelescopePromptBorder = { fg = colors.medium_gray, bg = colors.medium_gray },
	TelescopePromptNormal = { fg = colors.milk, bg = colors.medium_gray },
	TelescopePromptPrefix = { fg = colors.soft_yellow, bg = colors.medium_gray },

	TelescopeNormal = { bg = colors.background_dark },

	TelescopePreviewTitle = { fg = colors.background, bg = colors.forest_green },
	TelescopePreviewMatch = { fg = colors.background_dark, bg = colors.milk },
	TelescopePromptTitle = { fg = colors.background, bg = colors.soft_yellow },
	TelescopeResultsTitle = { fg = colors.background_dark, bg = colors.milk },

	TelescopeSelection = { bg = colors.diff.change },
	TelescopeMultiSelection = { fg = colors.soft_yellow },

	IlluminatedWordText = { style = "bold" },
	IlluminatedWordRead = { style = "bold" },
	IlluminatedWordWrite = { style = "bold" },

	NoiceCursor = { bg = "#928374" },
	NoiceCmdlineIcon = { link = "StatusLine" },
	NoiceCmdline = { link = "StatusLine" },
	NoiceCmdlinePrompt = { link = "YellowStatusLine" },

	FlashPrompt = { link = "StatusLine" },
}
