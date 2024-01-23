local esc = vim.keycode("<esc>")
local utils = require("utils")
local set = vim.keymap.set
local api = vim.api
local call = api.nvim_call_function

-- leader key
set("n", "<leader><esc>", function() -- Do nothing
end)
set("n", "<leader>t", function() -- Toggle alternate buffer
	vim.cmd(":b #")
end)
set("n", "<leader>v", function() -- Split vertical
	vim.cmd("vsplit")
end)
set("n", "<leader>h", function() -- Split horizontal
	vim.cmd("split")
end)

local last_deleted_buffer_registry = nil
set("n", "<leader>d", function() -- delete buffer and set alternate file
	last_deleted_buffer_registry = call("expand", { "%:p" })
	vim.cmd("bdelete")
	local new_current_file = call("expand", { "%:p" })
	local context = api.nvim_get_context({ types = { "jumps", "bufs" } })
	local jumps = call("msgpackparse", { context["jumps"] })
	local still_listed = vim.iter.map(function(buf)
		return buf["f"]
	end, call("msgpackparse", { context["bufs"] })[4])
	local possible_alternatives = vim.iter.filter(function(name)
		return name ~= new_current_file
	end, still_listed)

	if #still_listed == 0 then
		return
	elseif #still_listed == 1 then
		call("setreg", { "#", call("getreg", { "%" }) })
		return
	end

	local jumps_current_file_index

	for i = #jumps, 1, -4 do
		if jumps[i]["f"] == new_current_file then
			jumps_current_file_index = i
			break
		end
	end

	local jumps_alternate_file_index = jumps_current_file_index - 4
	local found = false

	for i = jumps_alternate_file_index, 1, -4 do
		if vim.list_contains(possible_alternatives, jumps[i]["f"]) then
			found = true
			jumps_alternate_file_index = i
			break
		end
	end
	if found then
		call("setreg", { "#", jumps[jumps_alternate_file_index]["f"] })
	else
		-- Alternate file not found in jumplist! Picking last in possible_alternatives
		call("setreg", { "#", possible_alternatives[#possible_alternatives] })
	end
end)

set("n", "<leader>T", function()
	vim.cmd.edit(last_deleted_buffer_registry)
end)

set("v", "<leader>s", function() -- Sort selection
	local start_row, _, end_row, _ = utils.get_range()
	local lines = api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
	table.sort(lines)
	api.nvim_buf_set_lines(0, start_row - 1, end_row, true, lines)
	api.nvim_feedkeys(esc, "x", false)
end)

set("n", "<leader>o", function() -- open files returned by input command
	local current_file = call("expand", { "%:p" })
	local input = vim.fn.input("Command (cwd is " .. vim.fn.getcwd() .. "): ")

	if input == 27 then
		utils.abort()
		return
	end

	local command = vim.system(vim.split(input, " "), { text = true }):wait()

	local files = vim.split(command.stdout, "\n", { trimempty = true })
	for _, file in ipairs(files) do
		vim.cmd.edit(file)
	end

	if current_file ~= "" then
		call("setreg", { "#", current_file })
	end
end)

-- localleader key
set("n", "<localleader>d", "<cmd>:windo :diffthis<cr>") -- Diff
set("n", "<localleader><esc>", function() -- Do nothing
end)
set("n", "<localleader>q", function() -- Remove breakpoints
	local cur_pos = api.nvim_win_get_cursor(0)
	vim.cmd("g/breakpoint()/d")
	api.nvim_win_set_cursor(0, cur_pos)
end)

set("n", "<localleader>b", function() -- Set breakpoint
	local row = api.nvim_win_get_cursor(0)[1]
	local content = api.nvim_get_current_line()
	local indent = content:match("^%s*")
	local text = indent .. "breakpoint()"
	api.nvim_buf_set_lines(0, row, row, true, { text })
end)

--Normal key
set("v", "ab", "apk") -- a block is a paragraph
set("o", "ab", "ap") -- a block is a paragraph
set("n", "<left>", "<nop>") -- do nothing with arrows
set("n", "<right>", "<nop>") -- do nothing with arrows
set("n", "<up>", "<nop>") -- do nothing with arrows
set("n", "<down>", "<nop>") -- do nothing with arrows
set("", "gh", "h") -- move left
set("", "gl", "l") -- move right
set("o", "iB", function() -- scroll  left
	local view = vim.fn.winsaveview()
	api.nvim_win_set_cursor(0, { 1, 0 })
	vim.cmd.normal({ "Vo", bang = true })
	api.nvim_win_set_cursor(0, { api.nvim_buf_line_count(0), 0 })
	if vim.v.operator == "y" then
		vim.defer_fn(function()
			vim.fn.winrestview(view)
		end, 0)
	end
end) -- buffer motion
set("o", "aB", function() -- scroll  left
	local view = vim.fn.winsaveview()
	api.nvim_win_set_cursor(0, { 1, 0 })
	vim.cmd.normal({ "Vo", bang = true })
	api.nvim_win_set_cursor(0, { api.nvim_buf_line_count(0), 0 })
	if vim.v.operator == "y" then
		vim.defer_fn(function()
			vim.fn.winrestview(view)
		end, 0)
	end
end) -- buffer motion
set("", "zJ", function() -- scroll  left
	local count = math.floor(api.nvim_win_get_width(0) / 3)
	vim.cmd.normal({ count .. "zh", bang = true })
end) -- scroll right
set("", "zK", function()
	local count = math.floor(api.nvim_win_get_width(0) / 3)
	vim.cmd.normal({ count .. "zl", bang = true })
end) -- scroll right
set("n", "`", "'") -- Swap ` and '
set("n", "'", "`") -- Swap ` and '
set("", "p", function() -- Paste and set '< and '> marks
	utils.paste(true)
end)
set("", "P", function() -- Paste and set '< and '> marks
	utils.paste(false)
end)
set("n", "mm", function()
	api.nvim_feedkeys("mVL", "", false)
end)
set("n", "mM", function()
	api.nvim_feedkeys("mVL", "", false)
	api.nvim_feedkeys("k", "n", false)
end)
set(
	"n",
	"m",
	[[<cmd>lua require'utils'.set_position_registry(vim.fn.getpos("."))<cr><cmd>let &operatorfunc = "v:lua.require'utils'.duplicate"<cr>g@]]
)
set({ "n" }, "go", function() -- open git modified files
	local current_file = call("expand", { "%:p" })
	local p_git_diff = vim.system({ "git", "diff", "--name-only" }, { text = true })
	local p_git_root = vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true })
	local git_diff = p_git_diff:wait()
	local git_root = p_git_root:wait().stdout
	git_root = git_root:sub(1, #git_root - 1) .. "/"

	local files = vim.split(git_diff.stdout, "\n", { trimempty = true })
	for _, file in ipairs(files) do
		vim.cmd.edit(git_root .. file)
	end

	if current_file ~= "" then
		call("setreg", { "#", current_file })
	end
end, { silent = true })
set({ "n", "x" }, "k", function() -- scroll down 1/3 of screen
	if call("line", { "w$" }) == call("line", { "$" }) then
		return
	end

	local first_screen_row = call("line", { "w0" })
	local last_screen_row = call("line", { "w$" })
	local increment = math.floor((last_screen_row - first_screen_row + 1) / 3)

	api.nvim_feedkeys(increment .. vim.keycode("<C-e>"), "n", false)
end, { silent = true })
set({ "n", "x" }, "j", function() -- scroll up 1/3 of screen
	if call("line", { "w0" }) == 1 then
		return
	end

	local first_screen_row = call("line", { "w0" })
	local last_screen_row = call("line", { "w$" })
	local increment = math.floor((last_screen_row - first_screen_row + 1) / 3)

	api.nvim_feedkeys(increment .. vim.keycode("<C-y>"), "n", false)
end, { silent = true })
set("n", "<S-cr>", function() -- Pad with newlines
	local row, col = unpack(api.nvim_win_get_cursor(0))
	api.nvim_buf_set_lines(0, row, row, true, { "" })
	api.nvim_buf_set_lines(0, row - 1, row - 1, true, { "" })
	api.nvim_win_set_cursor(0, { row + 1, col })
end)
set("n", "<C-cr>", function() -- insert mode with padded newlines
	api.nvim_feedkeys(vim.keycode("<S-cr>") .. "cc", "m", false)
end)

set("o", "L", function() -- select line from first char to end
	local operator_pending_state = utils.get_operator_pending_state()
	local visual_mode = operator_pending_state.forced_motion or "v"
	vim.cmd.normal({ visual_mode .. "g_o^", bang = true })
end)
set("o", "?", function() -- select prev diagnostic
	local forced_motion = utils.get_operator_pending_state().forced_motion
	local diagnostic_range = utils.get_diagnostic_under_cursor_range()

	if not diagnostic_range then
		diagnostic_range = utils.get_normalized_diag_range(vim.diagnostic.get_prev())
	end

	api.nvim_win_set_cursor(0, diagnostic_range.start_pos)
	vim.cmd.normal({ forced_motion or "v", bang = true })
	api.nvim_win_set_cursor(0, diagnostic_range.end_pos)
end)
set("o", "/", function() -- select next diagnostic
	local forced_motion = utils.get_operator_pending_state().forced_motion

	local diagnostic_range = utils.get_diagnostic_under_cursor_range()

	if not diagnostic_range then
		diagnostic_range = utils.get_normalized_diag_range(vim.diagnostic.get_next())
	end

	api.nvim_win_set_cursor(0, diagnostic_range.start_pos)
	vim.cmd.normal({ forced_motion or "v", bang = true })
	api.nvim_win_set_cursor(0, diagnostic_range.end_pos)
end)
set("n", "Z", function() -- Write buffer
	vim.cmd("silent write!")
	vim.notify("buffer written")
end)
set("n", "Q", function() -- Quit no write buffer
	vim.cmd("quit!")
end)
set("n", "U", function() -- Redo
	vim.cmd("redo")
end)
set("n", "o", function() -- `o` with count
	local count = vim.v.count1
	if count > 1 then
		utils.new_lines(true, count - 1)
	end
	api.nvim_feedkeys("o", "n", false)
end)
set("n", "O", function() -- `O` with count
	local count = vim.v.count1
	if count > 1 then
		utils.new_lines(false, count - 1)
	end
	api.nvim_feedkeys("O", "n", false)
end)

set("o", "b", function() -- inclusive motion back
	utils.motion_back(true)
end)

set("o", "B", function() -- inclusive motion BACK
	utils.motion_back(false)
end)

set("", "<M-j>", "^") -- Go to first nonblank char
set("", "<M-k>", "$") -- Go to last char
set("", "0", function() -- Go to beggining of file
	vim.cmd.normal({ "gg", bang = true })
	vim.cmd.call("cursor(1,1)")
end)
set("", "-", function() -- Go to end of file
	local count = vim.v.count
	local op_is_pending = utils.get_operator_pending_state().is_active
	local has_count = count ~= 0
	if op_is_pending then
		utils.abort()
	end
	api.nvim_feedkeys((has_count and count or "") .. (op_is_pending and vim.v.operator or "") .. "G", "n", false)
	if not (has_count or op_is_pending) then
		vim.cmd.call("cursor(line('$'),1)")
	end
end)

set({ "n" }, "<M-]>", function() -- Swap with next line
	vim.cmd("move .+1")
	api.nvim_feedkeys("==", "n", false)
end)
set({ "n" }, "<M-[>", function() -- Swap with prev line
	vim.cmd("move .-2")
	api.nvim_feedkeys("==", "n", false)
end)

set({ "v" }, "<M-]>", function() -- Swap selection with next line
	utils.move(true)
end)

set({ "v" }, "<M-[>", function() -- Swap selection with prev line
	utils.move(false)
end)

set("", "(", function() -- Goto beginning of block
	utils.goto_block_extremity(false)
end)

set("", ")", function() -- Goto end of block
	utils.goto_block_extremity(true)
end)

set("v", "+", function() -- get tabular stats
	local sr, sc, er, ec = utils.get_range()
	local tbl = {}
	for i = 0, er - sr do
		local raw_line = api.nvim_buf_get_text(0, sr + i - 1, sc, sr + i - 1, ec + 1, {})[1]
		table.insert(tbl, vim.split(raw_line, " "))
	end
	tbl = vim.iter(tbl):flatten():totable()
	local stat_fns = {
		sum = function(numbers)
			return vim.iter(numbers):fold(0, function(s, number)
				return s + number
			end)
		end,
		med = function(numbers)
			table.sort(numbers)
			local integral, fractional = math.modf((#numbers + 1) / 2)
			local middle = (#numbers + 1) / 2
			return (numbers[math.floor(middle)] + numbers[math.ceil(middle)]) / 2
		end,
		max = math.max,
		min = math.min,
		cnt = function(numbers)
			return #numbers
		end,
	}
	local stats = {}
	for name, fn in pairs(stat_fns) do
		stats[name] = (name == "min" or name == "max") and fn(unpack(tbl)) or fn(tbl)
	end
	stats.avg = stats.sum / stats.cnt
	local str = ""
	for name, stat in pairs(stats) do
		str = str .. name .. ": " .. stat .. "  "
	end
	vim.notify(str)
	vim.wo.statusline = vim.wo.statusline
end)

set("", "l", function() -- Goto line
	local op_pending_state = utils.operator_pending_registry or utils.get_operator_pending_state()
	utils.operator_pending_registry = nil
	local visual_state = utils.get_visual_state()

	local offset = utils.get_linechars_offset_from_cursor(108)

	if not offset then
		return
	end

	local visual = ""
	if op_pending_state.is_active then
		visual = op_pending_state.forced_motion or "V"
	elseif visual_state.is_active and visual_state.char == "v" then
		visual = "V"
	end
	vim.cmd.normal({ "m'", bang = true })
	vim.cmd.normal({ visual .. math.abs(offset) .. "g" .. (offset > 0 and "j" or "k"), bang = true })
end)

set("", "h", function() -- Goto line
	utils.operator_pending_registry = utils.get_operator_pending_state()
	local char = call("getchar", {})
	if char == 27 then
		utils.abort()
		return
	end

	vim.cmd.normal("l" .. call("nr2char", { 192 - char }))
end)

set("", "M", function() -- Goto line
	utils.operator_pending_registry = utils.get_operator_pending_state()
	vim.cmd.normal("l`")
end)

-- {motion} linewise remote
set("o", "\\", function()
	local operator = vim.v.operator
	local offset = utils.get_linechars_offset_from_cursor()

	if not offset then
		return
	end

	local row, col = unpack(api.nvim_win_get_cursor(0))
	api.nvim_win_set_cursor(0, { row + offset, col })
	vim.cmd.normal({ "V", bang = true })
	api.nvim_feedkeys(operator, "", false)
	utils.abort()
	if operator == "d" then
		api.nvim_win_set_cursor(0, { row + (math.min(math.max(offset, -1), 0)), col })
	else
		api.nvim_win_set_cursor(0, { row, col })
	end
	api.nvim_feedkeys("p", "", false)
	vim.defer_fn(function()
		vim.cmd.undojoin()
		api.nvim_feedkeys("==_", "n", false)
	end, 0)
end)

-- {motion} linewise range remote
set("o", "R", function()
	local operator = vim.v.operator
	if operator ~= "y" and operator ~= "d" then
		return
	end

	local first_line_offset = utils.get_linechars_offset_from_cursor(nil, true)

	if not first_line_offset then
		return
	end

	vim.cmd("redrawstatus")

	local second_line_offset = utils.get_linechars_offset_from_cursor()

	if not second_line_offset then
		return
	end

	local row, col = unpack(api.nvim_win_get_cursor(0))
	api.nvim_win_set_cursor(0, { row + first_line_offset, col })
	vim.cmd.normal({ "V", bang = true })
	api.nvim_win_set_cursor(0, { row + second_line_offset, col })
	api.nvim_feedkeys(operator, "", false)
	utils.abort()

	if operator == "d" then
		api.nvim_win_set_cursor(0, {
			row + (math.min(
				math.max(
					first_line_offset + second_line_offset,
					-(math.abs(first_line_offset - second_line_offset - 1))
				),
				0
			)),
			col,
		})
	else
		api.nvim_win_set_cursor(0, { row, col })
	end
	api.nvim_feedkeys("p", "", false)
	utils.abort()
	vim.defer_fn(function()
		vim.cmd.undojoin()
		api.nvim_feedkeys("gv=_", "n", false)
	end, 0)
end)

set("n", "q", function() -- Go to after next identifer part
	utils.goto_camel_or_snake_or_kebab_part(true, true)
end, { silent = true })
set("n", "gq", function() -- Go to after previous identifier part
	utils.goto_camel_or_snake_or_kebab_part(false, false)
end, { silent = true })
set("o", "q", function() -- go to after next identifier part
	utils.goto_camel_or_snake_or_kebab_part(true, true, vim.v.operator)
end)
set("o", "gq", function() -- go to after previous identifier part
	api.nvim_feedkeys("v", "x", false)
	utils.goto_camel_or_snake_or_kebab_part(false, true, vim.v.operator)
end)

set("o", ">", function() -- Apply operator to next pair
	utils.apply_to_next_motion(vim.v.operator)
	api.nvim_feedkeys(esc, "i", false)
end)

-- --Modifiers keys
set("n", "<M-s>", "r<CR>") -- Split below
set("n", "<M-S-s>", "r<CR><cmd>move .-2<cr>") -- Split up
set("i", "<M-left>", "<S-left>") -- Move one word left
set("i", "<M-right>", "<S-right>") -- Move one word right
set("c", "<C-a>", "<C-b>") -- Goto beginning of line
set("c", "<M-left>", function()
	local pos = vim.fn.getcmdpos()
	local content_till_cursor = vim.fn.getcmdline():sub(1, pos - 1)
	local rev_content = content_till_cursor:reverse()
	local punct_or_space_pos = #content_till_cursor - (rev_content:find("[%c%z%s%p]") or 0) + 1
	return string.rep("<left>", pos - punct_or_space_pos)
end, { expr = true }) -- Move one word left
set("c", "<M-right>", function()
	local pos = vim.fn.getcmdpos()
	local content_after_cursor = vim.fn.getcmdline():sub(pos + 1)
	local punct_or_space_pos = content_after_cursor:find("[%s%p]") or 0
	return string.rep("<right>", punct_or_space_pos)
end, { expr = true }) -- Move one word right
set("i", "<C-space>", function() -- Pad with space
	local row, col = unpack(api.nvim_win_get_cursor(0))
	api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { "  " })
	api.nvim_win_set_cursor(0, { row, col + 1 })
end)
set("n", "g<C-space>", function() -- Goto prev space and start insert mode between words
	api.nvim_feedkeys("F i ", "n", false)
end)
set("n", "<C-space>", function() -- Goto next space and start insert mode between words
	api.nvim_feedkeys("f i ", "n", false)
end)
set("i", "<C-cr>", function() -- Pad with newlines
	local row, col = unpack(api.nvim_win_get_cursor(0))
	api.nvim_buf_set_lines(0, row, row, true, { "" })
	api.nvim_buf_set_lines(0, row - 1, row - 1, true, { "" })
	api.nvim_win_set_cursor(0, { row + 1, col })
end)

set("n", "<M-S-j>", function() -- Join at end of below
	vim.cmd("move .+1 | .-1 join")
end)

set("n", "<C-g>", function() -- Show file stats
	local row, col = unpack(api.nvim_win_get_cursor(0))
	local line_count = api.nvim_buf_line_count(0)
	local relative = math.floor(row / line_count * 100 + 0.5)
	vim.wo.statusline = vim.wo.statusline
	vim.notify(row .. ":" .. col + 1 .. "; " .. line_count .. " lines --" .. relative .. "%--")
end)

set("n", "<M-m>", "mm")

set({ "n", "v" }, "<M-S-m>", function() -- Move lines
	local count
	local first_char
	local visual_state = utils.get_visual_state()
	local original_cursor_pos = api.nvim_win_get_cursor(0)

	if visual_state.is_active then
		local start_row, end_row, _ = vim.fn.line("v"), vim.fn.line(".")
		count = math.abs(end_row - start_row)
		if start_row < end_row then
			vim.cmd.normal({ "o", bang = true })
		end
	else
		first_char = vim.fn.getchar()
		if first_char == 27 then
			return
		end
		if first_char ~= 77 and first_char ~= 104 and first_char ~= 108 and vim.v.count == 0 then
			local operatorfunc = vim.go.operatorfunc
			vim.go.operatorfunc = "{_ -> v:true}"
			print(first_char)
			api.nvim_feedkeys("g@" .. vim.fn.nr2char(first_char), "x!", false)
			local start_row = api.nvim_buf_get_mark(0, "<")[1]
			local end_row = api.nvim_buf_get_mark(0, ">")[1]
			vim.go.operatorfunc = operatorfunc
			count = math.abs(end_row - start_row)
			first_char = nil
		else
			count = vim.v.count == 0 and 0 or vim.v.count - 1
		end
	end

	local cursor_pos = api.nvim_win_get_cursor(0)
	local offset = utils.get_linechars_offset_from_cursor(first_char)

	if not offset then
		api.nvim_win_set_cursor(0, original_cursor_pos)
		return
	end

	if visual_state.is_active then
		api.nvim_feedkeys(esc, "x", false)
	end

	vim.cmd(".,." .. count .. "move ." .. offset - 1)
	local adjustment = offset < 0 and offset or offset - count - 1
	api.nvim_win_set_cursor(0, { cursor_pos[1] + adjustment, cursor_pos[2] })
	vim.cmd.normal({ count + 1 .. "==_", bang = true })
end)

set("n", "<M-S-w>", function() -- Swap line
	local offset = utils.get_linechars_offset_from_cursor()
	local cursor_row = api.nvim_win_get_cursor(0)[1]
	local to_swap_row = cursor_row + offset
	local cursor_line = api.nvim_buf_get_lines(0, cursor_row - 1, cursor_row, true)
	local to_swap_line = api.nvim_buf_get_lines(0, to_swap_row - 1, to_swap_row, true)

	api.nvim_buf_set_lines(0, cursor_row - 1, cursor_row, true, to_swap_line)
	api.nvim_buf_set_lines(0, to_swap_row - 1, to_swap_row, true, cursor_line)
end)

set("n", "<M-d>", function() -- Delete line content
	api.nvim_set_current_line("")
end)

set("n", "<M-p>", function() -- Append at EOL
	api.nvim_set_current_line(api.nvim_get_current_line() .. call("getreg", { '"' }))
end)

set("n", "<M-S-p>", function() -- Append at EOL With space
	api.nvim_set_current_line(api.nvim_get_current_line() .. " " .. call("getreg", { '"' }))
end)

set("n", "<M-a>", function() -- Paste above
	vim.cmd("put!")
end)

set("n", "<M-b>", function() -- Paste below
	vim.cmd("put")
end)

set("n", "<M-o>", function() -- New line down
	utils.new_lines(true, vim.v.count1)
end)

set("n", "<M-S-o>", function() -- New line up
	utils.new_lines(false, vim.v.count1)
end)

set("i", "<C-f>", function() -- Go one character right
	local row, col = unpack(api.nvim_win_get_cursor(0))
	api.nvim_win_set_cursor(0, { row, col + 1 })
end)

set("i", "<C-b>", function() -- Go one character left
	local row, col = unpack(api.nvim_win_get_cursor(0))
	api.nvim_win_set_cursor(0, { row, col - 1 })
end)

set("i", "<C-esc>", function() -- Go to normal mode one char right
	api.nvim_feedkeys(esc, "t", false)
	local row, col = unpack(api.nvim_win_get_cursor(0))
	api.nvim_win_set_cursor(0, { row, col + 1 })
end)

set("i", "<C-/>", function() -- Delete line after cursor
	local col = api.nvim_win_get_cursor(0)[2]
	api.nvim_set_current_line(api.nvim_get_current_line():sub(1, col))
end)

set("i", "<C-k>", function() -- Delete next word
	local word_under_cursor = call("expand", { "<cword>" })
	-- print(word_under_cursor)
	local row, col = unpack(api.nvim_win_get_cursor(0))
	local end_col = call("searchpos", { word_under_cursor, "Wcnb" })[2] - 1 + #word_under_cursor
	api.nvim_buf_set_text(0, row - 1, col, row - 1, end_col, {})
end)

set("n", "<C-l>", function() -- Clear message
	vim.cmd.echo([["\u00A0"]])
	vim.wo.statusline = vim.wo.statusline
	vim.cmd.mes("clear")
end)

set("i", "<C-l>", function() -- Add new string parameter
	local row, col = unpack(api.nvim_win_get_cursor(0))
	local quote = api.nvim_get_current_line():sub(col + 1, col + 1)
	api.nvim_buf_set_text(0, row - 1, col + 1, row - 1, col + 1, { ", " .. quote .. quote })
	api.nvim_win_set_cursor(0, { row, col + 4 })
end)

set("x", "<C-g>", function() -- Show rows/cols stats
	local start_row, end_row = vim.fn.line("v"), vim.fn.line(".")
	local start_col, end_col = vim.fn.col("v"), vim.fn.col(".")
	local row_range = math.abs(start_row - end_row) + 1
	local col_range = math.abs(start_col - end_col) + 1
	vim.notify(row_range > 1 and (row_range .. " selected rows.") or (col_range .. " selected cols."))
	vim.cmd("redrawstatus")
end)

set("", "<M-x>", function() -- Delete character after cursor
	local content = api.nvim_get_current_line()
	local col = api.nvim_win_get_cursor(0)[2]
	call("setreg", { '"', content:sub(col + 2, col + 2) })

	api.nvim_set_current_line(content:sub(1, col + 1) .. content:sub(col + 3))
end)

set("n", "<C-[>", "<C-t>")
