require("neogen").setup({
	enabled = true,
	input_after_comment = true,
	languages = {
		python = {
			template = {
				annotation_convention = "numpydoc",
			},
		},
	},
})

local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<leader>a", require("neogen").generate, opts)
