local api = vim.api
local call = api.nvim_call_function

local M = {}

M.operator_pending_registry = nil

local position_registry = {}
M.set_position_registry = function(pos)
	-- We check the length of pos, as getpos() returns a 4 elements table.
	-- If it's the case, we also readjust to be neovim API o-based
	position_registry = #pos == 4 and { pos[2], pos[3] - 1 } or pos
end
M.get_position_registry = function()
	return position_registry
end

local esc = vim.keycode("<esc>")

function M.abort()
	api.nvim_feedkeys(esc, "x", false)
	api.nvim_feedkeys(esc, "n", false)
end

function M.update_selection(use_gv, requested_visual_mode, start_row, start_col, end_row, end_col)
	api.nvim_buf_set_mark(0, "<", start_row, start_col, {})
	api.nvim_buf_set_mark(0, ">", end_row, end_col, {})

	local v_table = { charwise = "v", linewise = "V", blockwise = "<C-v>" }
	requested_visual_mode = requested_visual_mode or "charwise"

	-- Normalise selection_mode
	requested_visual_mode = v_table[requested_visual_mode] or requested_visual_mode

	requested_visual_mode = vim.keycode(requested_visual_mode)
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

		if M.get_normal_state().is_active then
			vim.cmd.normal({ requested_visual_mode, bang = true })
		end

		api.nvim_win_set_cursor(0, { end_row, end_col })
	end
end

function M.get_normal_state()
	local mode = api.nvim_get_mode().mode
	return { is_active = mode == "n" }
end

function M.get_visual_state()
	local mode = api.nvim_get_mode().mode
	local is_active = vim.list_contains({ "v", "V", vim.keycode("<C-v>") }, mode)

	return { is_active = is_active, char = is_active and mode or nil }
end

function M.get_operator_pending_state()
	local mode = api.nvim_get_mode().mode
	local is_active = mode:sub(1, 2) == "no"
	local forced_motion = mode:sub(3, 3)
	forced_motion = forced_motion ~= "" and forced_motion or nil

	return { is_active = is_active, forced_motion = is_active and forced_motion or nil }
end

local motion_back_char = "b"
function M.motion_back(lowercase)
	local char = lowercase and "b" or "B"
	motion_back_char = char
	local operator
	if vim.v.operator == "g@" and vim.go.operatorfunc == "v:lua.require'utils'.motion_back" then
		operator = M.operator_pending_registry
	else
		operator = vim.v.operator
	end
	M.operator_pending_registry = operator
	vim.print({
		char = char,
		operator = operator,
		operator_pending_registry = M.operator_pending_registry,
		motion_back_char = motion_back_char,
	})
	M.abort()
	local col = vim.fn.col(".")
	local chars_after_cursor = api.nvim_get_current_line():sub(col, col + 1)
	if #chars_after_cursor == 1 or chars_after_cursor:match("[^%w_]") then
		api.nvim_feedkeys(motion_back_char .. operator .. (operator == "y" and "e" or "w"), "n", false)
	else
		vim.cmd.normal({ operator .. motion_back_char, bang = true })
	end
	vim.go.operatorfunc = "{_ -> v:true}"
	api.nvim_feedkeys("g@l", "n", false)
	vim.defer_fn(function()
		vim.go.operatorfunc = "v:lua.require'utils'.motion_back"
	end, 100)
end

function M.get_listed_buffers(as_filenames)
	local raw_listed_buffers = vim.split(vim.api.nvim_exec2("buffers", { output = true }).output, "\n")
	return vim.iter.map(function(raw_buffer)
		local bufnr = raw_buffer:match("%s*(%d+)")
		return as_filenames and vim.fn.expand("#" .. bufnr .. ":p") or tonumber(bufnr)
	end, raw_listed_buffers)
end

function M.jump_within_buffer(older)
	local jumplist, current_jump_position = unpack(vim.fn.getjumplist())
	local current_bufnr = vim.api.nvim_win_get_buf(0)
	local start = older and current_jump_position or current_jump_position + 2
	local step = older and -1 or 1
	local stop = older and 1 or #jumplist
	local n = 0
	local action = vim.keycode(older and "<C-o>" or "<C-i>")

	for i = start, stop, step do
		n = n + 1
		if jumplist[i].bufnr == current_bufnr then
			vim.api.nvim_feedkeys(n .. action, "n", false)
			return
		end
	end
end

---@deprecated
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

	local visual_mode = M.get_visual_state().char or "v"

	if visual_mode == "V" then
		start_col, end_col = 0, #api.nvim_buf_get_lines(0, end_row - 1, end_row, true)[1]
	else
		local backward_col = start_col > end_col
		local same_row = start_row == end_row
		local cond_c_v = visual_mode == vim.keycode("<C-v>") and backward_col
		local cond_v = visual_mode == "v" and (backward_row or (same_row and backward_col))
		if cond_c_v or cond_v then
			start_col, end_col = end_col, start_col
		end
	end

	return start_row, start_col, end_row, end_col
end

-- Textobject for adjacent commented lines
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
		api.nvim_feedkeys(esc, "n", false)
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

-- The autocmd does not work with custom register (`".` for example)
function M.paste(lowercase)
	local char = lowercase and "p" or "P"
	api.nvim_feedkeys('"' .. vim.v.register .. char, "n", false)
	api.nvim_create_autocmd("TextChanged", {
		once = true,
		callback = function()
			local start_row, start_col = unpack(api.nvim_buf_get_mark(0, "["))
			local end_row, end_col = unpack(api.nvim_buf_get_mark(0, "]"))
			api.nvim_buf_set_mark(0, "<", start_row, start_col, {})
			api.nvim_buf_set_mark(0, ">", end_row, end_col, {})
		end,
	})
end

-- The dot repeat behaviour is undefined
function M.duplicate(visual_motion)
	local start_row, start_col = unpack(api.nvim_buf_get_mark(0, "["))
	local end_row, end_col = unpack(api.nvim_buf_get_mark(0, "]"))
	local pre_motion_row, pre_motion_col = unpack(M.get_position_registry())

	if visual_motion == "line" then
		local lines = api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
		local range = end_row - start_row + 1
		api.nvim_buf_set_lines(0, end_row, end_row, true, lines)
		api.nvim_win_set_cursor(0, { pre_motion_row + range, pre_motion_col })
	elseif visual_motion == "char" then
		local lines = api.nvim_buf_get_text(0, start_row - 1, start_col, end_row - 1, end_col + 1, {})
		local range = end_col - start_col + 1
		api.nvim_buf_set_text(0, end_row - 1, end_col + 1, end_row - 1, end_col + 1, lines)
		api.nvim_win_set_cursor(0, { end_row, pre_motion_col + range })
	else
		api.nvim_win_set_cursor(0, { pre_motion_row, pre_motion_col })
	end
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

function M.cursor_is_punctuation()
	local captures = vim.treesitter.get_captures_at_cursor()

	return vim.iter(captures):any(function(capture)
		return capture:match("^punctuation%.")
	end)
end

function M.goto_quote(fwd)
	call("search", { [[\("\|'\)]], "W" .. (fwd and "" or "b") })
end

function M.diagnostic(fwd)
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
	if not fwd or curStandingOnPrevD then
		target = prevD
	elseif nextD then
		target = nextD
	end
	if not target then
		vim.notify("Diagnostic not found")
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
		-- vim.print(to_insert)
		local old_indent = quote_reg:match("^%s*")
		local new_indent = api.nvim_get_current_line():match("^%s*")
		to_insert = vim.iter.map(function(str)
			local formatted = str:gsub("^" .. old_indent, new_indent)
			return formatted
		end, to_insert)
		-- vim.print(to_insert)
		-- print(old_indent .. "-" .. new_indent)
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
		M.update_selection(true, visual_mode, start_row + 1, start_col, end_row + 1, end_col)
	else
		M.update_selection(true, visual_mode, start_row - 1, start_col, end_row - 1, end_col)
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

M.goto_camelCase_or_snake_case_part = function(fwd, supplemental_snakecase_offset)
	local row, col = unpack(api.nvim_win_get_cursor(0))
	local prev_char = api.nvim_get_current_line():sub(col, col)
	local is_backward_and_neighbour = not fwd and prev_char:find("[%u_]")
	local snake_case = "_"
	local opts = "Wn" .. (fwd and "" or "b")

	if is_backward_and_neighbour then
		api.nvim_win_set_cursor(0, { row, col - 1 })
	end

	local pattern = snake_case
	local word_under_cursor = call("expand", { "<cword>" })
	local wuc_start_col = call("searchpos", { word_under_cursor, "Wcnb" })[2] - 1
	local i = fwd and col - wuc_start_col + 1 or 1
	local j = fwd and -1 or col - wuc_start_col - (is_backward_and_neighbour and 1 or 0)

	if word_under_cursor:sub(i, j):find(snake_case) == nil then
		pattern = pattern .. "\\|\\u\\l"
	end

	local new_row, new_col = unpack(call("searchpos", { pattern, opts }))

	if new_row == 0 then
		if is_backward_and_neighbour then
			-- Reset cursor position since we moved it for `searchpos`
			api.nvim_win_set_cursor(0, { row, col })
		end
	else
		new_col = new_col - 1 -- 0-based indexed in neovim API
		local char = api.nvim_buf_get_text(0, new_row - 1, new_col, new_row - 1, new_col + 1, {})[1]
		local offset = char == snake_case and 1 + supplemental_snakecase_offset or 0
		api.nvim_win_set_cursor(0, { new_row, new_col + offset })
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

function M.mk_repeatable(func)
	return function(...)
		local args = { ... }
		local nargs = select("#", ...)
		vim.go.operatorfunc = "v:lua.require'utils'.repeat_action"

		M.repeat_action = function()
			func(unpack(args, 1, nargs))
		end

		api.nvim_feedkeys("g@l", "n", false)
	end
end

function M.status_column()
	local screen_row = call("screenpos", { 0, vim.v.lnum, 1 }).row
	local last_screen_row = call("line", { "w$" })
	local last_row = call("line", { "$" })
	local middle

	if last_row == last_screen_row then
		-- use text height
		local text_height = vim.api.nvim_win_text_height(0, {
			start_row = call("line", { "w0" }) - 1,
			end_row = last_screen_row - 1,
		})
		middle = math.ceil(text_height.all / 2)
	else
		-- use win height
		local window_height = vim.api.nvim_win_get_height(0)
		middle = math.ceil(window_height / 2)
	end

	local highlight = vim.v.virtnum > 0 and "%#WrappedLineNr#" or ""
	local chars = " M"
	if screen_row + vim.v.virtnum ~= middle then
		chars = (screen_row + vim.v.virtnum < middle and "h" or "l")
			.. string.char(math.abs(middle - screen_row - vim.v.virtnum) % 30 + 96)
	end

	return highlight .. chars
end

return M
