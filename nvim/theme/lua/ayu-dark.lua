local green = "#A6CC70"
local yellow = "#FFC300"
local red = "#F27983"
local blue = "#77A8D9"
local grey = "grey"
local statusline_bg = "#14191F"
local dark_grey = "#0F1419"
local light_grey = "#3E4B59"
local accent = "#E6B450"
local black = "#00010A"

require("ayu").setup({
	mirage = false,
	overrides = {
		Substitute = { fg = dark_grey, bg = blue },
		IncSearch = { link = "Substitute" },
		Search = { bg = grey },
		Normal = { bg = "None" },
		NormalFloat = { bg = black },
		vertSplit = { bg = "None" },
		Folded = { link = "Comment" },
		SignColumn = { bg = "None" },
		IlluminatedWordText = { bold = true },
		IlluminatedWordRead = { bold = true },
		IlluminatedWordWrite = { bold = true },

		LspSignatureActiveParameter = { italic = true, fg = green },

		MatchParen = { fg = "None", bg = light_grey },
		MatchWord = { bold = true },

		DiagnosticUnderlineHint = { undercurl = true, bg = "None", sp = green },
		DiagnosticUnderlineWarn = { undercurl = true, bg = "None", sp = yellow },
		DiagnosticUnderlineInfo = { undercurl = true, bg = "None", sp = blue },
		DiagnosticUnderlineError = { undercurl = true, bg = "None", sp = red },

		DiagnosticLineNrHint = { bold = true, bg = "None", fg = green },
		DiagnosticLineNrWarn = { bold = true, bg = "None", fg = yellow },
		DiagnosticLineNrInfo = { bold = true, bg = "None", fg = blue },
		DiagnosticLineNrError = { bold = true, bg = "None", fg = red },

		DiagnosticHint = { bg = "None", fg = green },
		DiagnosticWarn = { bg = "None", fg = yellow },
		DiagnosticInfo = { bg = "None", fg = blue },
		DiagnosticError = { bg = "None", fg = red },

		CursorLineNr = { fg = accent, bg = "None" },
		WrappedLineNr = { bg = "None", fg = black },

		StatusLine = { bg = statusline_bg },
		YellowStatusLine = { fg = yellow, bg = statusline_bg },
		RedStatusLine = { fg = red, bg = statusline_bg },
		GreenStatusLine = { fg = green, bg = statusline_bg },
		BlueStatusLine = { fg = blue, bg = statusline_bg },
		GreyStatusLine = { fg = grey, bg = statusline_bg },

		LazyDimmed = { fg = grey },
		LazyProp = { fg = grey },

		NoiceCmdlineIcon = { link = "StatusLine" },
		NoiceCmdline = { link = "StatusLine" },
		NoiceCursor = { bg = "#F29718" },

		FlashPrompt = { link = "StatusLine" },
	},
})

vim.cmd("colorscheme ayu-dark")
