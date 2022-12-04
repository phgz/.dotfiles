require("nvim-gps").setup()

vim.keymap.set("n", "<leader>w", function()
	print(require("nvim-gps").get_location())
end, { silent = true })
