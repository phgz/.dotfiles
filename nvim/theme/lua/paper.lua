local colors = require("nvim-paper.colors").config()

-- func local asadfad avc = @424r

vim.g.nvim_paper_transparent = 1

vim.g.nvim_paper_highlights = {
	DiagnosticLineNrHint = { bg = "None", fg = colors.grey, bold = true },
	DiagnosticLineNrWarn = { bg = "None", fg = colors.yellow, bold = true },
	DiagnosticLineNrInfo = { bg = "None", fg = colors.blue, bold = true },
	DiagnosticLineNrError = { bg = "None", fg = colors.red, bold = true },
	LspInlayHint = { fg = "teal" },

	LspSignatureActiveParameter = { fg = colors.green, italic = true },
	SignatureHelpVirtual = { fg = "teal" },

	EyelinerPrimary = { underline = true },
	EyelinerSecondary = { underdouble = true },

	GitSignsDelete = { bg = "None", fg = colors.red },
	GitSignsAdd = { bg = "None", fg = colors.green },
	GitSignsChange = { bg = "None", fg = colors.yellow },
	GitSignsAddInline = { bg = colors.lgrey2 },
	GitSignsDeleteInline = { bg = colors.lgrey2 },
	GitSignsChangeInline = { bg = colors.lgrey2 },

	DiffDelete = { bg = "#EACCCC" },
	PmenuThumb = { bg = colors.grey },
	PmenuSbar = { bg = colors.dgrey },

	EndOfBuffer = { fg = colors.lbackground },

	MatchParen = { bg = colors.lgrey1 },
	MatchWord = { italic = true },

	Search = { bg = colors.lgrey1 },
	IncSearch = { bg = colors.lgrey2 },
	Substitute = { fg = colors.background, bg = colors.black },

	StatusLineNC = { fg = colors.black, bg = colors.none },
	WrappedLineNr = { link = "Comment" },

	NormalFloat = { bg = colors.lgrey1 },

	PopupPreviewDocument = { fg = colors.black, bg = colors.lgrey1 },
	PopupPreviewBorder = { fg = colors.black, bg = colors.lgrey1 },

	YellowStatusLine = { fg = colors.yellow, bg = colors.lgrey1 },
	RedStatusLine = { fg = colors.red, bg = colors.lgrey1 },
	GreenStatusLine = { fg = colors.green, bg = colors.lgrey1 },
	BlueStatusLine = { fg = colors.blue, bg = colors.lgrey1 },
	GreyStatusLine = { fg = "grey", bg = colors.lgrey1 },

	IlluminatedWordText = { italic = true },
	IlluminatedWordRead = { italic = true },
	IlluminatedWordWrite = { italic = true },

	IblIndent = { link = "Comment" },

	NoiceCursor = { bg = "#000000" },
	NoiceCmdlineIcon = { link = "StatusLine" },
	NoiceCmdline = { link = "StatusLine" },
	NoiceCmdlinePrompt = { link = "YellowStatusLine" },

	FlashLabel = { link = "IncSearch" },
	FlashPrompt = { link = "StatusLine" },
}
