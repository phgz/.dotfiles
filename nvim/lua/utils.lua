local api = vim.api

local call = api.nvim_call_function
local M = {}

function M.mk_repeatable(fn)
	return function(...)
		local args = { ... }
		local nargs = select("#", ...)
		vim.go.operatorfunc = "v:lua.require'utils'.repeat_action"

		M.repeat_action = function()
			fn(unpack(args, 1, nargs))
			-- if vim.fn.exists("*repeat#set") == 1 then
			-- 	local action = api.nvim_replace_termcodes(
			-- 		string.format("<cmd>call %s()<cr>", vim.go.operatorfunc),
			-- 		true,
			-- 		true,
			-- 		true
			-- 	)
			-- 	vim.fn["repeat#set"](action, -1)
			-- end
		end

		api.nvim_feedkeys("g@l", "n", false)
	end
end

function M.update_selection(selection_mode, start_row, start_col, end_row, end_col)
	api.nvim_buf_set_mark(0, "<", start_row, start_col - 1, {})
	api.nvim_buf_set_mark(0, ">", end_row, end_col - 1, {})

	local v_table = { charwise = "v", linewise = "V", blockwise = "<C-v>" }
	selection_mode = selection_mode or "charwise"

	-- Normalise selection_mode
	if vim.tbl_contains(vim.tbl_keys(v_table), selection_mode) then
		selection_mode = v_table[selection_mode]
	end

	-- Call to `nvim_replace_termcodes()` is needed for sending appropriate command to enter blockwise mode
	selection_mode = vim.api.nvim_replace_termcodes(selection_mode, true, true, true)

	local previous_mode = call("visualmode", {})

	-- visualmode() is set to "" when no visual selection has yet been made. Defaults it to "v"
	if previous_mode == "" then
		previous_mode = "v"
	end

	if previous_mode == selection_mode then
		selection_mode = ""
	end

	-- "gv": Start Visual mode with the same area as the previous area and the same mode.
	-- Hence, area will be what we defined in "<" and ">" marks. We only feed `selection_mode` if it is
	-- different than previous `visualmode`, otherwise it will stop visual mode.
	api.nvim_feedkeys("gv" .. selection_mode, "x", false)
end

function M.detect_selection_mode()
	local visual_mode = call("mode", { 1 })
	local selection_mode = visual_mode:sub(#visual_mode)

	return selection_mode
end

function M.get_range()
	local _, start_row, start_col, _ = unpack(call("getpos", { "v" }))
	local _, end_row, end_col, _ = unpack(call("getpos", { "." }))

	local backward_row = start_row > end_row

	if backward_row then
		start_row, end_row = end_row, start_row
	end

	local mode = call("mode", {})
	if mode == "V" then
		start_col, end_col = 0, #api.nvim_buf_get_lines(0, end_row - 1, end_row, true)[1]
	else
		local backward_col = start_col > end_col
		local same_row = start_row == end_row
		local cond_c_v = mode == api.nvim_replace_termcodes("<C-v>", true, true, true) and backward_col
		local cond_v = mode == "v" and (backward_row or (same_row and backward_col))
		if cond_c_v or cond_v then
			start_col, end_col = end_col, start_col
		end
	end

	return start_row, start_col, end_row, end_col
end

--Textobject for adjacent commented lines
function M.adj_commented()
	local utils = require("Comment.utils")
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
end

function M.yank_comment_paste()
	local utils = require("Comment.utils")
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
end

function M.goto_quote(fwd)
	call("search", { [[\("\|'\)]], "W" .. (fwd and "" or "b") })
end

function M.replace()
	local quote_reg = call("getreg", { '"' })
	local start_row, start_col = unpack(api.nvim_buf_get_mark(0, "["))
	local end_row, end_col = unpack(api.nvim_buf_get_mark(0, "]"))

	local to_insert = {}

	local non_match_start = 1
	local match_start, match_end = quote_reg:find("\n")
	if match_start then
		while match_start do
			table.insert(to_insert, quote_reg:sub(non_match_start, match_start - 1))
			non_match_start = match_end + 1
			match_start, match_end = quote_reg:find("\n", non_match_start)
		end
	else
		to_insert[1] = quote_reg
	end
	api.nvim_buf_set_text(0, start_row - 1, start_col, end_row - 1, end_col + 1, to_insert)
end

M.move = function(fwd)
	local get_range = require("utils").get_range
	local detect_selection_mode = require("utils").detect_selection_mode
	local update_selection = require("utils").update_selection

	local selection_mode = detect_selection_mode()
	local start_row, start_col, end_row, end_col = get_range()
	local range = end_row - start_row
	vim.cmd(start_row .. "," .. end_row .. "move" .. (fwd and end_row .. "+1" or start_row .. "-2"))

	if fwd then
		update_selection(selection_mode, end_row, start_col, end_row + range, end_col)
	else
		update_selection(selection_mode, start_row - range, start_col, start_row, end_col)
	end
	vim.api.nvim_feedkeys("=gv", "n", false)
end

return M
