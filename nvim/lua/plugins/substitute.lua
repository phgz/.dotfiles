local keymap = vim.keymap
local utils = require("utils")

require("substitute").setup({
	on_substitute = nil,
	yank_substituted_text = false,
	highlight_substituted_text = {
		enabled = false,
	},
	exchange = {
		motion = false,
		use_esc_to_cancel = true,
	},
})
keymap.set("n", "sx", function()
	require("substitute").operator({ register = vim.v.register })
end, { noremap = true })
keymap.set("n", "sxn", function()
	require("treemonkey").select({ ignore_injections = false })
	if utils.get_visual_state().is_active then
		require("substitute").visual({ register = vim.v.register })
	end
end, { noremap = true })
keymap.set("n", "sxx", require("substitute").line, { noremap = true })
keymap.set("n", "sX", require("substitute").eol, { noremap = true })
keymap.set("n", "cx", require("substitute.exchange").operator, { noremap = true })
keymap.set("x", "CX", require("substitute.exchange").operator, { noremap = true })
