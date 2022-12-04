require("noice").setup({
	popupmenu = {
		enabled = false, -- enables the Noice popupmenu UI
	},
	commands = {
		last = {
			view = "mini",
		},
	},
	notify = {
		enabled = false,
	},
	lsp = {
		progress = {
			enabled = false,
		},
		override = {
			-- override the default lsp markdown formatter with Noice
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			-- override the lsp markdown formatter with Noice
			["vim.lsp.util.stylize_markdown"] = true,
		},
	},
	presets = {
		lsp_doc_border = true,
	},
	views = {
		mini = {
			timeout = 4000,
			--   position = {
			--   row = -1,
			--   col = "50%",
			-- },
			win_options = {
				winblend = 0,
				winhighlight = { Normal = "LineNr" },
			},
		},
	},
	routes = {
		{
			filter = {
				event = "msg_show",
				["not"] = {
					kind = { "confirm", "confirm_sub" },
				},
			},
			opts = { skip = true },
		},
	},
})
