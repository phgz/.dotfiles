return {
	"projekt0n/github-nvim-theme", -- Color scheme
	tag = "v0.0.7",
	lazy = true,
	config = function()
		local config = require("github-theme.config")
		local theme = require("github-theme.theme")

		local user_config = {
			theme_style = "light",
			transparent = true,
			hide_end_of_buffer = true,
			dev = true,

			-- Change the "hint" color to the "orange" color, and make the "error" color bright red
			-- colors = {match_paren_bg = "orange", error = "#ff0000"},
			colors = { syntax = { match_paren_bg = "#babbbd" } },

			-- Overwrite the highlight groups
			overrides = function(c)
				return {
					--     htmlTag = {fg = c.red, bg = "#282c34", sp = c.hint, style = "underline"},
					StatusLine = { fg = c.blue, bg = "#babbbd" },
					Folded = { link = "Comment" },
					PopupPreviewDocument = { link = "Pmenu" },
					PopupPreviewBorder = { link = "Pmenu" },
					PmenuSbar = { bg = c.white },
					PmenuThumb = { bg = c.bright_white },
					DiagnosticHint = { fg = c.green },
					DiagnosticLineNrError = { fg = c.error, style = "bold" },
					DiagnosticLineNrWarn = { fg = c.warning, style = "bold" },
					DiagnosticLineNrInfo = { fg = c.info, style = "bold" },
					DiagnosticLineNrHint = { fg = c.green, style = "bold" },
					DiagnosticUnderlineHint = { style = "undercurl", sp = c.green },
					RedStatusLine = { fg = "#fb4934", bg = "#babbbd" },
					GreenStatusLine = { fg = c.bright_green, bg = "#babbbd" },
					BlueStatusLine = { fg = c.bright_blue, bg = "#babbbd" },
					TurquoiseStatusLine = { fg = "turquoise", bg = "#babbbd" },
					MagentaStatusLine = { fg = "magenta", bg = "#babbbd" },
					GreyStatusLine = { fg = "grey", bg = "#babbbd" },
					Substitute = { link = "PMenuSel" },
					LspSignatureActiveParameter = { fg = c.green, style = "italic" },
					TelescopePromptTitle = { fg = c.border },
					TelescopePromptBorder = { fg = c.border },
					MatchWord = { style = "bold" },
					NormalFloat = { bg = c.bg },
					ErrorFloat = { bg = "None" },
					WarningFloat = { bg = "None" },
					InfoFloat = { bg = "None" },
					HintFloat = { bg = "None" },
					FloatBorder = { bg = "None" },
					IlluminatedWordText = { style = "bold" },
					IlluminatedWordRead = { style = "bold" },
					IlluminatedWordWrite = { style = "bold" },
					--     -- this will remove the highlight groups
					--     TSField = {},
				}
			end,
		}

		config.apply_configuration(user_config)

		return theme.setup(config.schema)
	end,
}