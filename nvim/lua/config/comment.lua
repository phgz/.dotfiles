local api = vim.api
local call = api.nvim_call_function

require("Comment").setup({
	toggler = {
		--Line-comment toggle keymap
		line = "<M-k>",
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
	local U = require("Comment.utils")

	local col = call("col", { "." })
	local range = U.get_region()
	local lines = U.get_lines(range)

	-- Copying the block
	local srow = range.erow
	api.nvim_buf_set_lines(0, srow, srow, false, lines)

	-- Doing the comment
	require("Comment.api").comment.linewise()

	-- Move the cursor
	api.nvim_win_set_cursor(0, { srow + 1, col - 1 })
end, { silent = true, noremap = true })

--Textobject for adjacent commented lines
local function commented_lines_textobject()
	local U = require("Comment.utils")
	local current_line = api.nvim_win_get_cursor(0)[1] -- current line
	local range = { srow = current_line, scol = 0, erow = current_line, ecol = 0 }
	local ctx = {
		ctype = U.ctype.linewise,
		range = range,
	}
	local cstr = require("Comment.ft").calculate(ctx) or vim.bo.commentstring
	local ll, rr = U.unwrap_cstr(cstr)
	local padding = true
	local is_commented = U.is_commented(ll, rr, padding)

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

	api.nvim_buf_set_mark(0, "<", rs, 0, {})
	api.nvim_buf_set_mark(0, ">", re, call("col", { "$" }), {})
	api.nvim_feedkeys(api.nvim_replace_termcodes("gv", true, false, true), "x", true)
end

vim.keymap.set(
	"o",
	"K",
	commented_lines_textobject,
	{ silent = true, desc = "Textobject for adjacent commented lines" }
)
