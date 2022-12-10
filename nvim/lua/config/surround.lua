require("nvim-surround").setup({
	keymaps = {
		insert = "<C-g>s",
		insert_line = "<C-s>",
		normal = "s",
		normal_cur = "ss",
		normal_line = "yS",
		normal_cur_line = "sc",
		visual = "s",
		visual_line = "S",
		delete = "ds",
		change = "cs",
	},
})

local opts = {
	expr = true,
	remap = true,
	silent = true,
}
vim.keymap.set("n", "S", function()
	return "<Plug>(nvim-surround-normal)g_"
end, opts)
