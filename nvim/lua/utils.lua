local api = vim.api
local fn = vim.fn
local registry = require("registry")
local esc = vim.keycode("<esc>")
local M = {}

function vim.notify(mes, level, opts)
	-- vim.log.levels: DEBUG ERROR INFO TRACE WARN OFF
	local levels = vim.log.levels
	local highlight = "%#GreyStatusLine#"
	if level == levels.DEBUG then
		highlight = "%#BlueStatusLine#"
	elseif level == levels.ERROR then
		highlight = "%#RedStatusLine#"
	elseif level == levels.WARN then
		highlight = "%#YellowStatusLine#"
	end
	registry.message = highlight .. tostring(mes)
	vim.cmd("redrawstatus")
end

function vim.notify_once(mes, level, opts)
	registry.message = "NOTIFY ONCE called with: " .. mes
	vim.cmd("redrawstatus")
end

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
		local previous_mode = fn.visualmode()

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

function M.motion_back(lowercase)
	local char = lowercase and "b" or "B"
	registry.motion_back_char = char
	local operator
	if vim.v.operator == "g@" and vim.go.operatorfunc == "v:lua.require'utils'.motion_back" then
		operator = registry.operator_pending
	else
		operator = vim.v.operator
	end
	registry.operator_pending = operator
	M.abort()
	local col = fn.col(".")
	local chars_after_cursor = api.nvim_get_current_line():sub(col, col + 1)
	if #chars_after_cursor == 1 or chars_after_cursor:match("[^%w_]") then
		api.nvim_feedkeys(registry.motion_back_char .. operator .. (operator == "y" and "e" or "w"), "n", false)
	else
		vim.cmd.normal({ operator .. registry.motion_back_char, bang = true })
	end
	vim.go.operatorfunc = "{_ -> v:true}"
	if operator ~= "c" then
		api.nvim_feedkeys("g@l", "n", false)
		vim.defer_fn(function()
			vim.go.operatorfunc = "v:lua.require'utils'.motion_back"
		end, 1)
	else
		api.nvim_create_autocmd("InsertLeave", {
			once = true,
			callback = function()
				api.nvim_feedkeys("g@l", "n", false)
				vim.defer_fn(function()
					vim.go.operatorfunc = "v:lua.require'utils'.motion_back"
				end, 1)
			end,
		})
	end
end

function M.get_listed_buffers(as_filenames)
	local raw_listed_buffers = vim.split(api.nvim_exec2("buffers", { output = true }).output, "\n")
	return vim.iter(raw_listed_buffers)
		:map(function(raw_buffer)
			local bufnr = raw_buffer:match("%s*(%d+)")
			return as_filenames and fn.expand("#" .. bufnr .. ":p") or tonumber(bufnr)
		end)
		:totable()
end

function M.jump_within_buffer(older)
	local jumplist, current_jump_position = unpack(fn.getjumplist())
	local current_bufnr = api.nvim_win_get_buf(0)
	local start = older and current_jump_position or current_jump_position + 2
	local step = older and -1 or 1
	local stop = older and 1 or #jumplist
	local n = 0
	local action = vim.keycode(older and "<C-o>" or "<C-i>")

	for i = start, stop, step do
		n = n + 1
		if jumplist[i].bufnr == current_bufnr then
			api.nvim_feedkeys(n .. action, "n", false)
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
		_, start_row, start_col, _ = unpack(fn.getpos("v"))
		_, end_row, end_col, _ = unpack(fn.getpos("."))
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
	local pre_motion_row, pre_motion_col = unpack(registry.get_position())

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

function M.virtual_win_height()
	local first_row_in_win = fn.line("w0")
	local last_row_in_win = fn.line("w$")
	local last_row = fn.line("$")

	if last_row == last_row_in_win then
		-- use text height
		return api.nvim_win_text_height(0, {
			start_row = first_row_in_win - 1,
			end_row = last_row_in_win - 1,
		}).all
	else
		-- use win height
		return api.nvim_win_get_height(0)
	end
end

function M.win_row_offset_from_win_middle(win_row, height)
	local win_middle = math.ceil(height / 2)

	return win_middle - win_row
end

function M.cursor_is_punctuation()
	local captures = vim.treesitter.get_captures_at_cursor()

	local is_punct = vim.iter(captures):any(function(capture)
		return capture:match("^punctuation%.")
	end)

	local col = api.nvim_win_get_cursor(0)[2] + 1
	local cursor_char = api.nvim_get_current_line():sub(col, col)
	local extra_punct = { "/", "'", '"', "." }
	vim.notify(is_punct or vim.list_contains(extra_punct, cursor_char))
	return is_punct or vim.list_contains(extra_punct, cursor_char)
end

function M.goto_quote(fwd)
	fn.search([[\("\|'\)]], "W" .. (fwd and "" or "b"))
end

function M.compare_pos(pos_1, pos_2, opts)
	if opts.gt then
		return pos_1[1] > pos_2[1]
			or (pos_1[1] == pos_2[1] and (opts.eq and pos_1[2] >= pos_2[2] or pos_1[2] > pos_2[2]))
	else
		return pos_1[1] < pos_2[1]
			or (pos_1[1] == pos_2[1] and (opts.eq and pos_1[2] <= pos_2[2] or pos_1[2] < pos_2[2]))
	end
end

M.get_normalized_diag_range = function(diagnostic)
	-- INFO for whatever reason, diagnostic line numbers are off-by-one -1 and end_col is off-by-one +1
	return {
		start_pos = { diagnostic.lnum + 1, diagnostic.col },
		end_pos = { diagnostic.end_lnum + 1, diagnostic.end_col - 1 },
	}
end

function M.get_diagnostic_under_cursor_range()
	local cursor_pos = api.nvim_win_get_cursor(0)
	local row_diags = vim.diagnostic.get(0, { lnum = cursor_pos[1] - 1 })
	local nearest_diagnostic_under_cursor = vim.iter(row_diags):fold(nil, function(acc, diag)
		local diagnostic_range = M.get_normalized_diag_range(diag)
		local cursor_is_on_diagnostic = M.compare_pos(cursor_pos, diagnostic_range.start_pos, { gt = true, eq = true })
			and M.compare_pos(cursor_pos, diagnostic_range.end_pos, { gt = false, eq = true })

		if not cursor_is_on_diagnostic then
			return acc
		end

		local distance = math.abs(diagnostic_range.start_pos[2] - cursor_pos[2])

		if acc == nil then
			return { diagnostic_range, distance }
		end

		if distance < acc[2] then
			return { diagnostic_range, distance }
		end
	end)

	if nearest_diagnostic_under_cursor == nil then
		vim.print({ vim.diagnostic.get_next({ wrap = false }) }, {
			vim.diagnostic.get_prev({
				wrap = false,
			}),
		})
		return nil
	else
		local start_pos, end_pos =
			nearest_diagnostic_under_cursor[1].start_pos, nearest_diagnostic_under_cursor[1].end_pos

		vim.print({ vim.diagnostic.get_next({ cursor_position = { end_pos[1], end_pos[2] + 1 }, wrap = false }) }, {
			vim.diagnostic.get_prev({
				cursor_position = { start_pos[1], start_pos[2] - 1 },
				wrap = false,
			}),
		})
		-- local asd = adsf
		return nearest_diagnostic_under_cursor[1]
	end
end

function M.get_offset_from_cursor()
	local char = fn.getchar()
	if char ~= 104 and char ~= 108 and char ~= 77 then
		M.abort()
		return
	end

	if char == 104 then
		local next_char = fn.getchar()
		if next_char == 27 then
			M.abort()
			return
		end
		return M.get_linechars_offset_from_cursor(192 - next_char)
	else
		return M.get_linechars_offset_from_cursor(char == 77 and 96 or nil)
	end
end

function M.get_linechars_offset_from_cursor(char_as_nr)
	char_as_nr = char_as_nr or fn.getchar()

	if char_as_nr == 27 then
		return nil
	end

	local height = M.virtual_win_height()
	local win_row = fn.winline()

	local offset = M.win_row_offset_from_win_middle(win_row - (char_as_nr - 96), height)
	if offset == 0 or win_row + offset > height or win_row + offset < 1 then
		return nil
	else
		return offset
	end
end

function M.replace()
	local quote_reg = fn.getreg('"'):gsub("\n$", "")
	local start_row, start_col = unpack(api.nvim_buf_get_mark(0, "["))
	local end_row, end_col = unpack(api.nvim_buf_get_mark(0, "]"))
	local to_insert = vim.split(quote_reg, "\n")

	if #to_insert > 1 then
		local old_indent = quote_reg:match("^%s*")
		local new_indent = api.nvim_get_current_line():match("^%s*")
		to_insert = vim.iter(to_insert)
			:map(function(str)
				local formatted = str:gsub("^" .. old_indent, new_indent)
				return formatted
			end)
			:totable()
	end

	to_insert[1] = to_insert[1]:gsub("^%s*", "")
	api.nvim_buf_set_text(0, start_row - 1, start_col, end_row - 1, end_col + 1, to_insert)
end

M.move = function(fwd)
	local visual_mode = M.get_visual_state().char
	local start_row, start_col, end_row, end_col = M.get_range()
	vim.cmd(start_row .. "," .. end_row .. "move" .. (fwd and end_row .. "+1" or start_row .. "-2"))

	if fwd then
		M.update_selection(true, visual_mode, start_row + 1, start_col, end_row + 1, end_col)
	else
		M.update_selection(true, visual_mode, start_row - 1, start_col, end_row - 1, end_col)
	end
	api.nvim_feedkeys("=gv", "n", false)
end

M.goto_block_extremity = function(forward)
	local mark = forward and "'}" or "'{"
	local opposite = forward and "'{" or "'}"

	local col = fn.col(".")
	local line = fn.line(mark)
	if line == fn.line(".") + (forward and 1 or -1) then
		fn.cursor(line, 0)
		line = fn.line(mark)
	end
	local line_content = api.nvim_get_current_line()
	fn.cursor(line, 0)
	local is_empty = line_content == ""
	line = is_empty and fn.line(opposite) or line
	local rhs = (is_empty == forward and 1 or -1) * fn.empty(fn.getline(line))
	fn.cursor(line + rhs, col)
end

M.goto_camel_or_snake_or_kebab_part = function(fwd, seek_after, operator)
	local flags = "Wn" .. (fwd and "" or "b")
	local initial_stopline = fn.line("w" .. (fwd and "$" or "0"))

	local snake_part_after = [==[_\zs[[:alnum:]]]==]
	local snake_part_before = [==[[[:alnum:]]\ze_]==]
	local kebab_part_after = [==[\(\<-\d\+\>\)\@!\&-\zs[[:alnum:]]]==] -- take negative numbers into account
	local kebab_part_before = [==[[[:alnum:]]\ze-]==]
	local camelPart = [[\l\zs\u\|\u\@<=\u\ze\l]]

	local snake_word_start = [==[\<\a[[:alnum:]]*_\w\{-}\>]==]
	local kebab_word_start = [==[\<\a[[:alnum:]]*-[\-[:alnum:]]\{-}\>]==]
	local camelWordStart = [==[\<\a\+\l\u[[:alnum:]]\{-}\>]==]

	local snake_word_end = [==[\<\a[[:alnum:]]*_\w\{-}\zs\w\>]==]
	local kebab_word_end = [==[\<\a[[:alnum:]]*-[\-[:alnum:]]\{-}\zs[\-[:alnum:]]\>]==]
	local camelWordEnd = [==[\<\a\+\l\u[[:alnum:]]\{-}\zs[[:alnum:]]\>]==]

	local snake_part = seek_after and snake_part_after or snake_part_before
	local kebab_part = seek_after and kebab_part_after or kebab_part_before

	local word_end_patterns = {
		snake_word_end,
		kebab_word_end,
		camelWordEnd,
	}

	local patterns = {
		snake_part,
		snake_word_start,
		snake_word_end,
		kebab_part,
		kebab_word_start,
		kebab_word_end,
		camelPart,
		camelWordStart,
		camelWordEnd,
	}

	local closest_pattern = vim.iter(patterns):fold({ 0, 0, initial_stopline }, function(acc, pattern)
		local closest_row, closest_col, stopline = unpack(acc)
		local match_row, match_col = unpack(fn.searchpos(pattern, flags, stopline))

		if match_row == 0 then
			return acc
		end
		if closest_row == 0 then
			return { match_row, match_col, match_row, pattern }
		end

		-- No need to check if match_row exceeds closest_row because of stopline
		local match_is_closer = (fwd and { match_row < closest_row or match_col < closest_col } or {
			match_row > closest_row or match_col > closest_col,
		})[1]

		return match_is_closer and { match_row, match_col, match_row, pattern } or acc
	end)

	local found_row, found_col, _, pattern = unpack(closest_pattern)
	if found_row ~= 0 then
		found_col = found_col - 1 -- 0-based indexed in neovim API
		local offset = 0
		if operator then
			if vim.list_contains(word_end_patterns, pattern) then
				offset = 1
			elseif pattern == snake_part or pattern == kebab_part then
				if operator == "d" then
					offset = fwd and 0 or -1
				else
					offset = fwd and -1 or 0
				end
			end
		end
		api.nvim_win_set_cursor(0, { found_row, found_col + offset })
	end
end

M.find_punct_in_string = function(str, from_end)
	if from_end then
		str = str:reverse()
	end

	local init = 1
	if str:sub(1, 1):match("[%s%p]") then
		init = 2
	end

	if from_end then
		return #str - (str:find("[%s%p]", init) or (2 * #str)) + 1
	else
		return str:find("[%s%p]", init) or #str + 1
	end
end

M.set_register = function()
	local register = registry.register
	local start_row, start_col = unpack(api.nvim_buf_get_mark(0, "["))
	local end_row, end_col = unpack(api.nvim_buf_get_mark(0, "]"))
	local text = api.nvim_buf_get_text(0, start_row - 1, start_col, end_row - 1, end_col + 1, {})[1]
	fn.setreg(register, vim.trim(text))
end

M.apply_to_next_motion = function(motion)
	local arg1 = fn.nr2char(fn.getchar())

	if arg1 == esc or (arg1 ~= "i" and arg1 ~= "a") then
		M.abort()
		return
	end

	local arg2 = fn.nr2char(fn.getchar())

	local pairs = {
		["'"] = "'",
		['"'] = '"',
		["{"] = "{}",
		["}"] = "}{",
		["("] = "()",
		[")"] = ")(",
		["["] = "[]",
		["]"] = "][",
		["<"] = "<>",
		[">"] = "><",
	}
	if vim.list_contains(vim.tbl_keys(pairs), arg2) then
		-- api.nvim_feedkeys(esc, "i", false)
		local pos = fn.searchpos(table.concat(vim.split(pairs[arg2], "", { plain = true }), "\\|"), "Wn")
		api.nvim_win_set_cursor(0, pos)
		api.nvim_feedkeys(motion .. arg1 .. arg2, "x!", false)
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

function M.searchcount()
	local entries = fn.searchcount({ maxcount = 0 })
	if next(entries) ~= nil then
		if entries.current > 0 then
			return fn.getreg("/") .. " [" .. entries.current .. "/" .. entries.total .. "]"
		end
	end
end

function M.diagnostics_status_line(bufnr)
	local diag_count = vim.diagnostic.count(bufnr or 0)
	local severity = vim.diagnostic.severity
	local errors = diag_count[severity.E] and "%#RedStatusLine#" .. diag_count[severity.E] .. "E" or ""
	local warns = diag_count[severity.W] and "%#YellowStatusLine#" .. diag_count[severity.W] .. "W" or ""
	local hints = diag_count[severity.N] and "%#GreenStatusLine#" .. diag_count[severity.N] .. "H" or ""
	local infos = diag_count[severity.I] and "%#BlueStatusLine#" .. diag_count[severity.I] .. "I" or ""
	local non_empty = vim.iter({ errors, warns, hints, infos })
		:filter(function(diag)
			return diag ~= ""
		end)
		:totable()

	return vim.deep_equal(non_empty, {}) and "" or " " .. table.concat(non_empty, " ")
end

function M.status_column()
	-- we subtract api.nvim_win_get_position(0)[1] to handle stacked windows
	local offset = M.win_row_offset_from_win_middle(
		fn.screenpos(0, vim.v.lnum, 1).row - api.nvim_win_get_position(0)[1],
		M.virtual_win_height()
	)
	local highlight = vim.v.virtnum > 0 and "%#WrappedLineNr#" or ""
	local chars = " M"
	if vim.v.virtnum ~= offset then
		chars = (vim.v.virtnum < offset and "h" or "l") .. string.char(math.abs(offset - vim.v.virtnum) % 30 + 96)
	end

	return highlight .. chars
end

return M
