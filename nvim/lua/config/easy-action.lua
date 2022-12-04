-- Below setting is default and you don't need to copy it. You may just require("easy-action").setup({})
require("easy-action").setup({
	-- These chars can show up any times in your action input.
	free_chars = "0123456789",
	-- These chars can show up no more than twice in action input.
	limited_chars = "iafFtT",
	-- Cancel action.
	terminate_char = "<ESC>",
	-- all action contains `key` will be replaced by `value`. For example yib -> yi(
	remap = {
		ib = "i(",
		ab = "a(",
	},
	-- Default jump provider
	jump_provider = "hop",
	jump_provider_config = {
		hop = {
			action_select = {
				char1 = {
					-- action ends with any char of options will use HopChar1MW command.
					options = "(){}[]<>`'\"",
					cmd = "HopChar1",
					feed = function(action)
						return string.sub(action, #action)
					end,
				},
				line = {
					-- action ends with any char of options will use HopLineMW command.
					options = "yd",
					cmd = "HopLine",
				},
				-- Default command.
				default = "HopWord",
			},
		},
	},
	-- Just make sure they are greater than 0. Usually 1 is all right.
	jump_back_delay_ms = 1,
	feed_delay_ms = 1,
})

local opts = { silent = true, remap = false }
-- trigger easy-action.
vim.keymap.set("n", "\\", "<cmd>BasicEasyAction<cr>", opts)

-- To insert something and jump back after you leave the insert mode
vim.keymap.set("n", "<leader>g", function()
	require("easy-action").base_easy_action("i", nil, "InsertLeave")
end, opts)
