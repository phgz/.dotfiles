-- local Color = require("github-theme.lib.color")
-- local spec = require("github-theme.spec").load("github_light")
-- local wrapped_line_nr = Color.shade(Color.from_hex(spec.fg1), 0.66):to_hex()
-- local sts_bg = Color.from_hex(spec.bg0):blend(Color.from_hex(spec.palette.blue.base), 0.1):to_css()

require("github-theme").setup({
	options = {
		transparent = true,
		styles = {
			comments = "italic",
			keywords = "italic",
		},
	},
	palettes = {
		-- all = {
		-- 	blue = {
		-- 		base = "#0366D6",
		-- 		bright = "#005CC5",
		-- 	},
		-- },
	},
	specs = {
		all = {
			syntax = {
				param = "#E36209",
			},
			diag = {
				hint = "#1A7F37",
				warn = "#BF8803",
			},
		},
	},
	groups = {
		all = {
			["@markup.raw"] = { fg = "#0366d6" },
			WrappedLineNr = { fg = "#B3B4B6" },

			Delimiter = { fg = "black" },
			Visual = { bg = "#B3B4B6" },

			IlluminatedWordText = { style = "bold" },
			IlluminatedWordRead = { style = "bold" },
			IlluminatedWordWrite = { style = "bold" },

			IncSearch = { bg = "diag.warn" },
			Substitute = { link = "PMenuSel" },
			Folded = { link = "Comment" },

			NoiceCmdlineIcon = { link = "StatusLine" },
			NoiceCmdline = { link = "StatusLine" },
			NoiceCursor = { bg = "#044289" },
			NoiceCmdlinePrompt = { link = "YellowStatusLine" },

			NormalFloat = { bg = "bg1" },
			TelescopePromptTitle = { fg = "#4C92E1" },
			LspSignatureActiveParameter = { fg = "palette.green.bright", style = "italic" },
			SignatureHelpVirtual = { fg = "teal" },

			DiagnosticLineNrError = { fg = "diag.error", style = "bold" },
			DiagnosticLineNrWarn = { fg = "diag.warn", style = "bold" },
			DiagnosticLineNrInfo = { fg = "diag.info", style = "bold" },
			DiagnosticLineNrHint = { fg = "diag.hint", style = "bold" },

			GitSignsAddInline = { bg = "sel1" },
			GitSignsDeleteInline = { bg = "sel1" },
			GitSignsChangeInline = { bg = "sel1" },
			GitSignsAddPreview = { bg = "diff.add" },
			GitSignsDeletePreview = { bg = "diff.delete" },

			CursorLine = { bg = "#DEE9F6" },
			CursorLineNr = { fg = "fg2", style = "bold" },
			StatusLine = { fg = "#4C92E1", bg = "bg3" },
			YellowStatusLine = { fg = "diag.warn", bg = "bg3" },
			GreenStatusLine = { fg = "git.add", bg = "bg3" },
			BlueStatusLine = { fg = "git.changed", bg = "bg3" },
			RedStatusLine = { fg = "git.removed", bg = "bg3" },
			GreyStatusLine = { fg = "grey", bg = "bg3" },

			LspInlayHint = { fg = "teal" },
			MatchWord = { style = "bold" },

			Pmenu = { bg = "bg1" },
			PmenuSbar = { bg = "fg0" },

			FlashLabel = { link = "PmenuSel" },
			FlashPrompt = { link = "StatusLine" },
		},
	},
})
