-- Annotation generator

local config = function()
	require("neogen").setup({
		input_after_comment = true,
		languages = {
			python = {
				template = {
					annotation_convention = "numpydoc",
				},
			},
		},
	})
end

vim.keymap.set("n", "<leader>a", require("neogen").generate, { silent = true })

return { "danymat/neogen", config = config }
