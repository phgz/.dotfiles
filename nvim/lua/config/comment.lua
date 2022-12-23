local api = vim.api
local call = api.nvim_call_function
local utils = require("Comment.utils")

require("Comment").setup({
	toggler = {
		--Line-comment toggle keymap
		line = "KL",
	},

	--LHS of operator-pending mappings in NORMAL + VISUAL mode
	--@type table
	opleader = {
		-- Line-comment keymap
		line = "K",
	},
	extra = {
		--Add comment on the line above
		above = "KO",
		--Add comment on the line below
		below = "Ko",
		--Add comment at the end of line
		eol = "KA",
	},
})

vim.keymap.set("n", "KD", function()
	local col = call("col", { "." })
	local range = utils.get_region()
	local lines = utils.get_lines(range)

	-- Copying the block
	local srow = range.erow
	api.nvim_buf_set_lines(0, srow, srow, false, lines)

	-- Doing the comment
	require("Comment.api").comment.linewise()

	-- Move the cursor
	api.nvim_win_set_cursor(0, { srow + 1, col - 1 })
end, { silent = true, noremap = true })

--Textobject for adjacent commented lines

vim.keymap.set("o", "K", function()
	local current_line = api.nvim_win_get_cursor(0)[1] -- current line
	local range = { srow = current_line, scol = 0, erow = current_line, ecol = 0 }
	local ctx = {
		ctype = utils.ctype.linewise,
		range = range,
	}
	local cstr = require("Comment.ft").calculate(ctx) or vim.bo.commentstring
	local ll, rr = utils.unwrap_cstr(cstr)
	local padding = true
	local is_commented = utils.is_commented(ll, rr, padding)

	local line = api.nvim_buf_get_lines(0, current_line - 1, current_line, false)
	if next(line) == nil or not is_commented(line[1]) then
		return
	end

	local rs, re = current_line, current_line -- range start and end
	repeat
		rs = rs - 1
		line = api.nvim_buf_get_lines(0, rs - 1, rs, false)
	until next(line) == nil or not is_commented(line[1])
	rs = rs + 1
	repeat
		re = re + 1
		line = api.nvim_buf_get_lines(0, re - 1, re, false)
	until next(line) == nil or not is_commented(line[1])
	re = re - 1

	require("utils").update_selection("V", rs, 0, re, 0)
end, { silent = true, desc = "Textobject for adjacent commented lines" })
