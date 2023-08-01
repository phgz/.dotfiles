local api = vim.api
local call = api.nvim_call_function

local M = {}

function M.update_selection(use_gv, requested_visual_mode, start_row, start_col, end_row, end_col)
	api.nvim_buf_set_mark(0, "<", start_row, start_col, {})
	api.nvim_buf_set_mark(0, ">", end_row, end_col, {})

	local v_table = { charwise = "v", linewise = "V", blockwise = "<C-v>" }
	requested_visual_mode = requested_visual_mode or "charwise"

	-- Normalise selection_mode
	requested_visual_mode = v_table[requested_visual_mode] or requested_visual_mode

	-- Call to `nvim_replace_termcodes()` is needed for sending appropriate command to enter blockwise mode
	requested_visual_mode = vim.api.nvim_replace_termcodes(requested_visual_mode, true, true, true)
	if use_gv then
		local previous_mode = call("visualmode", {})

		-- visualmode() is set to "" when no visual selection has yet been made. Defaults it to "v"
		if previous_mode == "" then
			previous_mode = "v"
		end

		if previous_mode == requested_visual_mode then
			requested_visual_mode = ""
		end
		-- "gv": Start Visual mode with the same area as the previous area and the same mode.
		-- Hence, area will be what we defined in "<" and ">" marks. We only feed `selection_mode` if it is
		-- different than previous `visualmode`, otherwise it will stop visual mode.
		api.nvim_feedkeys("gv" .. requested_visual_mode, "x", false)
	else
		api.nvim_win_set_cursor(0, { start_row, start_col })

		if M.get_modes().normal then
			vim.cmd.normal({ requested_visual_mode, bang = true })
		end

		api.nvim_win_set_cursor(0, { end_row, end_col })
	end
end

function M.get_modes()
	local modes = { normal = false, operator_pending = false, visual = "v" }
	local str_mode = api.nvim_get_mode().mode
	if vim.startswith(str_mode, "n") then
		modes.normal = true
	end
	if vim.startswith(str_mode, "no") then
		modes.operator_pending = true
	end
	if not (vim.endswith(str_mode, "no") or vim.endswith(str_mode, "n")) then
		modes.visual = str_mode:sub(#str_mode)
	end
	return modes
end

function M.get_range(range)
	local start_row, start_col, end_row, end_col

	if range == nil then
		_, start_row, start_col, _ = unpack(call("getpos", { "v" }))
		_, end_row, end_col, _ = unpack(call("getpos", { "." }))
		start_col, end_col = start_col - 1, end_col - 1
	else
		start_row, start_col = range.start_row, range.start_col
		end_row, end_col = range.end_row, range.end_col
	end

	local backward_row = start_row > end_row

	if backward_row then
		start_row, end_row = end_row, start_row
	end

	local visual_mode = M.get_modes().visual

	if visual_mode == "V" then
		start_col, end_col = 0, #api.nvim_buf_get_lines(0, end_row - 1, end_row, true)[1]
	else
		local backward_col = start_col > end_col
		local same_row = start_row == end_row
		local cond_c_v = visual_mode == api.nvim_replace_termcodes("<C-v>", true, true, true) and backward_col
		local cond_v = visual_mode == "v" and (backward_row or (same_row and backward_col))
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

	M.update_selection(true, "V", rs, 0, re, 0)
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

function M.diagnostic(lookForwL)
	-- INFO for whatever reason, diagnostic line numbers and the end column (but
	-- not the start column) are all off-by-one

	-- HACK if cursor is standing on a diagnostic, get_prev() will return that
	-- diagnostic *BUT* only if the cursor is not on the first character of the
	-- diagnostic, since the columns checked seem to be off-by-one as well m(
	-- Therefore counteracted by temporarily moving the cursor
	vim.cmd.normal({ "l", bang = true })
	local prevD = vim.diagnostic.get_prev({ wrap = false })
	vim.cmd.normal({ "h", bang = true })

	local nextD = vim.diagnostic.get_next({ wrap = false })
	local curStandingOnPrevD = false -- however, if prev diag is covered by or before the cursor has yet to be determined
	local curRow, curCol = unpack(vim.api.nvim_win_get_cursor(0))

	if prevD then
		local curAfterPrevDstart = (curRow == prevD.lnum + 1 and curCol >= prevD.col) or (curRow > prevD.lnum + 1)
		local curBeforePrevDend = (curRow == prevD.end_lnum + 1 and curCol <= prevD.end_col - 1)
			or (curRow < prevD.end_lnum)
		curStandingOnPrevD = curAfterPrevDstart and curBeforePrevDend
	end

	local target
	if curStandingOnPrevD then
		target = prevD
	elseif nextD and (curRow + lookForwL > nextD.lnum) then
		target = nextD
	else
		return
	end
	local start_pos, end_pos = { target.lnum + 1, target.col }, { target.end_lnum + 1, target.end_col - 1 }
	vim.api.nvim_win_set_cursor(0, start_pos)
	vim.cmd.normal({ "v", bang = true })
	vim.api.nvim_win_set_cursor(0, end_pos)
end

function M.replace()
	local quote_reg = call("getreg", { '"' }):gsub("\n$", "")
	local start_row, start_col = unpack(api.nvim_buf_get_mark(0, "["))
	local end_row, end_col = unpack(api.nvim_buf_get_mark(0, "]"))
	local to_insert = vim.split(quote_reg, "\n")

	if #to_insert > 1 then
		vim.print(to_insert)
		local old_indent = quote_reg:match("^%s*")
		local new_indent = api.nvim_get_current_line():match("^%s*")
		to_insert = vim.iter.map(function(str)
			local formatted = str:gsub("^" .. old_indent, new_indent)
			return formatted
		end, to_insert)
		vim.print(to_insert)
		print(old_indent .. "-" .. new_indent)
	end

	to_insert[1] = to_insert[1]:gsub("^%s*", "")
	api.nvim_buf_set_text(0, start_row - 1, start_col, end_row - 1, end_col + 1, to_insert)
end

M.move = function(fwd)
	local visual_mode = M.get_modes().visual
	local start_row, start_col, end_row, end_col = M.get_range()
	local range = end_row - start_row
	vim.cmd(start_row .. "," .. end_row .. "move" .. (fwd and end_row .. "+1" or start_row .. "-2"))

	if fwd then
		M.update_selection(true, visual_mode, end_row, start_col, end_row + range, end_col)
	else
		M.update_selection(true, visual_mode, start_row - range, start_col, start_row, end_col)
	end
	vim.api.nvim_feedkeys("=gv", "n", false)
end

M.goto_block_extremity = function(forward)
	local mark = forward and "'}" or "'{"
	local opposite = forward and "'{" or "'}"

	local col = call("col", { "." })
	local line = call("line", { mark })
	if line == call("line", { "." }) + (forward and 1 or -1) then
		call("cursor", { line, 0 })
		line = call("line", { mark })
	end
	local line_content = api.nvim_get_current_line()
	call("cursor", { line, 0 })
	local is_empty = line_content == ""
	line = is_empty and call("line", { opposite }) or line
	local rhs = (is_empty == forward and 1 or -1) * call("empty", { call("getline", { line }) })
	call("cursor", { line + rhs, col })
end

M.goto_after_sep = function(fwd)
	local row, col = unpack(api.nvim_win_get_cursor(0))
	local prev_char = api.nvim_get_current_line():sub(col, col)
	local back_on_edge = not fwd and prev_char:find("[%u_]")
	local opts = "Wn"
	opts = fwd and opts or opts .. "b"

	if back_on_edge then
		api.nvim_win_set_cursor(0, { row, col - 1 })
	end

	local new_row, new_col = unpack(call("searchpos", { "\\u\\|_", opts }))

	if new_row == 0 then
		if back_on_edge then
			api.nvim_win_set_cursor(0, { row, col })
		else
			return
		end
	else
		api.nvim_win_set_cursor(0, { new_row, new_col })
	end
end

M.apply_to_next_motion = function(motion)
	local arg1 = call("nr2char", { call("getchar", {}) })
	local arg2 = call("nr2char", { call("getchar", {}) })

	if vim.list_contains({ "'", '"', "{", "}", "(", ")", "[", "]", "<", ">" }, arg2) then
		vim.cmd("norm f" .. arg2)
		api.nvim_feedkeys(motion .. arg1 .. arg2, "m", false)
	end
end

function M.new_lines(forward, count)
	local row = api.nvim_win_get_cursor(0)[1]
	local lines_list = {}
	for _ = 1, count do
		table.insert(lines_list, "")
	end
	local row_offset = forward and 0 or -1
	local cursor_offset = forward and count or 0
	api.nvim_buf_set_lines(0, row + row_offset, row + row_offset, true, lines_list)
	api.nvim_win_set_cursor(0, { row + cursor_offset, 0 })
end

function M.mk_repeatable(fn)
	return function(...)
		local args = { ... }
		local nargs = select("#", ...)
		vim.go.operatorfunc = "v:lua.require'utils'.repeat_action"

		M.repeat_action = function()
			fn(unpack(args, 1, nargs))
		end

		api.nvim_feedkeys("g@l", "n", false)
	end
end

function M.status_column()
	if vim.v.virtnum > 0 then
		return ""
	else
		local text_height = vim.api.nvim_win_text_height(
			0,
			{ start_row = call("line", { "w0" }) - 1, end_row = call("line", { "w$" }) - 1 }
		)
		local middle = math.ceil(text_height.all / 2)
		local screenpos = call("screenpos", { 0, vim.v.lnum, 1 }).row
		if screenpos ~= middle then
			return (screenpos < middle and "h" or "l") .. string.char(math.abs(middle - screenpos) % 30 + 96)
		else
			return " M"
		end
	end
end

return M
