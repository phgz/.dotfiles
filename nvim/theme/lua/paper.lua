local theme = require("nvim-paper.theme")
local utils = require("nvim-paper.utils")
local lbackground = "#f7f3e3"
local background = "#f2eede"

-- func local asadfad avc = @424r

local custom_config = {
	transparent_mode = false,
	highlights = function(colors)
		return {

			DiagnosticLineNrHint = { bg = "None", fg = colors.grey, bold = true },
			DiagnosticLineNrWarn = { bg = "None", fg = colors.yellow, bold = true },
			DiagnosticLineNrInfo = { bg = "None", fg = colors.blue, bold = true },
			DiagnosticLineNrError = { bg = "None", fg = colors.red, bold = true },
			LspInlayHint = { fg = "teal" },

			LspSignatureActiveParameter = { fg = colors.green, italic = true },

			GitSignsDelete = { bg = "None", fg = colors.red },
			GitSignsAdd = { bg = "None", fg = colors.green },
			GitSignsChange = { bg = "None", fg = colors.yellow },
			PmenuThumb = { bg = colors.grey },
			PmenuSbar = { bg = colors.dgrey },

			EndOfBuffer = { fg = lbackground },

			MatchParen = { bg = colors.lgrey1 },
			MatchWord = { italic = true },

			Search = { bg = colors.lgrey1 },
			IncSearch = { bg = colors.lgrey2 },
			Substitute = { fg = background, bg = colors.black },

			StatusLineNC = { fg = colors.black, bg = colors.none },

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

			IndentBlanklineChar = { fg = lbackground },

			NoiceCursor = { bg = "#000000" },
			NoiceCmdlineIcon = { link = "StatusLine" },
			NoiceCmdline = { link = "StatusLine" },

			FlashLabel = { link = "IncSearch" },
			FlashPrompt = { link = "StatusLine" },
		}
	end,
}

utils.load(theme.setup(custom_config))
