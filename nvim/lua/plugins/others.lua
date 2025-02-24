local keymap = vim.keymap
local api = vim.api
local fn = vim.fn
-- https://github.com/trimclain/builder.nvim: Simple building plugin
return {
	{
		"nvim-lualine/lualine.nvim",
		enabled = false,
		config = function()
			require("lualine").setup({
				sections = {
					lualine_x = {
						{
							require("noice").api.status.message.get_hl,
							cond = require("noice").api.status.message.has,
						},
						{
							require("noice").api.status.command.get,
							cond = require("noice").api.status.command.has,
							color = { fg = "#ff9e64" },
						},
						{
							require("noice").api.status.search.get,
							cond = require("noice").api.status.search.has,
							color = { fg = "#ff9e64" },
						},
					},
				},
			})
		end,
	},
}
