require("noice").setup({
	popupmenu = {
		enabled = false,
	},
	notify = {
		enabled = false,
	},
	lsp = {
		progress = {
			enabled = false,
		},
		hover = { enabled = true },
		signature = {
			enabled = true,
			auto_open = {
				enabled = false,
			},
		},
		override = {
			-- override the default lsp markdown formatter with Noice
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			-- override the lsp markdown formatter with Noice
			["vim.lsp.util.stylize_markdown"] = true,
			["cmp.entry.get_documentation"] = false,
		},
	},
	presets = {
		bottom_search = true,
		lsp_doc_border = false,
	},
	cmdline = {
		view = "cmdline",
	},
	views = {
		messages = {
			enter = false,
			win_options = {
				winhighlight = { Normal = "Normal" },
			},
		},
		mini = {
			timeout = 4000,
			win_options = {
				winblend = 0,
				winhighlight = { Normal = "LineNr" },
			},
		},
		hover = {
			size = {
				max_height = 9,
				max_width = 96,
			},
			border = {
				padding = false,
			},
			scrollbar = true,
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

vim.keymap.set("n", "<C-f>", function()
	if not require("noice.lsp").scroll(4) then
		return "<C-f>"
	end
end, { silent = true, expr = true })

vim.keymap.set("n", "<C-b>", function()
	if not require("noice.lsp").scroll(-4) then
		return "<C-b>"
	end
end, { silent = true, expr = true })
