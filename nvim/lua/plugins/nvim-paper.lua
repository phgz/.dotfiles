return {
	"phgz/nvim-paper", -- Color scheme
	lazy = true,
	config = function()
		local theme = require("nvim-paper.theme")
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

					LspSignatureActiveParameter = { fg = colors.green, italic = true },

					GitSignsDelete = { bg = "None", fg = colors.red },
					GitSignsAdd = { bg = "None", fg = colors.green },
					GitSignsChange = { bg = "None", fg = colors.yellow },
					PmenuThumb = { bg = colors.grey },
					PmenuSbar = { bg = colors.dgrey },

					EndOfBuffer = { fg = lbackground },

					MatchParen = { bg = colors.lgrey2 },
					MatchWord = { style = "italic" },

					IncSearch = { bg = colors.lgrey1 },
					Substitute = { fg = background, bg = colors.black },

					StatusLineNC = { fg = colors.black, bg = colors.none },

					NormalFloat = { bg = colors.lgrey1 },

					PopupPreviewDocument = { fg = colors.black, bg = colors.lgrey1 },
					PopupPreviewBorder = { fg = colors.black, bg = colors.lgrey1 },

					RedStatusLine = { fg = colors.red, bg = colors.lgrey1 },
					GreenStatusLine = { fg = colors.green, bg = colors.lgrey1 },
					BlueStatusLine = { fg = colors.blue, bg = colors.lgrey1 },
					GreyStatusLine = { fg = "grey", bg = colors.lgrey1 },

					IlluminatedWordText = { italic = true },
					IlluminatedWordRead = { italic = true },
					IlluminatedWordWrite = { italic = true },

					IndentBlanklineChar = { fg = lbackground },
				}
			end,
		}

		return theme.setup(custom_config)
	end,
}