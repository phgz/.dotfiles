local keymap = vim.keymap
local api = vim.api

require("bufresize").setup()
keymap.set("n", "<leader>q", function() -- Close window
	require("bufresize").block_register()
	local win = api.nvim_get_current_win()
	api.nvim_win_close(win, false)
	require("bufresize").resize_close()
end)

require("smart-splits").setup({
	default_amount = 2,
	at_edge = "wrap", -- split
	move_cursor_same_row = false,
	cursor_follows_swapped_bufs = false,
	multiplexer_integration = false,
	disable_multiplexer_nav_when_zoomed = false,
	resize_mode = {
		hooks = {
			on_leave = require("bufresize").register,
		},
	},
})

-- moving between splits
keymap.set({ "i", "n", "o", "v" }, "<S-left>", require("smart-splits").move_cursor_left)
keymap.set({ "i", "n", "o", "v" }, "<S-down>", require("smart-splits").move_cursor_down)
keymap.set({ "i", "n", "o", "v" }, "<S-up>", require("smart-splits").move_cursor_up)
keymap.set({ "i", "n", "o", "v" }, "<S-right>", require("smart-splits").move_cursor_right)
-- resizing splits
keymap.set({ "i", "n", "o", "v" }, "<C-S-left>", require("smart-splits").resize_left)
keymap.set({ "i", "n", "o", "v" }, "<C-S-down>", require("smart-splits").resize_down)
keymap.set({ "i", "n", "o", "v" }, "<C-S-up>", require("smart-splits").resize_up)
keymap.set({ "i", "n", "o", "v" }, "<C-S-right>", require("smart-splits").resize_right)
-- swapping buffers between windows
keymap.set({ "i", "n", "o", "v" }, "<S-M-left>", require("smart-splits").swap_buf_left)
keymap.set({ "i", "n", "o", "v" }, "<S-M-down>", require("smart-splits").swap_buf_down)
keymap.set({ "i", "n", "o", "v" }, "<S-M-up>", require("smart-splits").swap_buf_up)
keymap.set({ "i", "n", "o", "v" }, "<S-M-right>", require("smart-splits").swap_buf_right)
