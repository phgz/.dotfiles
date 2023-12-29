local get_range = require("utils").get_range
local paste = require("utils").paste
local move = require("utils").move
local goto_block_extremity = require("utils").goto_block_extremity
local goto_after_sep = require("utils").goto_after_sep
local apply_to_next_motion = require("utils").apply_to_next_motion
local new_lines = require("utils").new_lines
local get_modes = require("utils").get_modes
local abort = require("utils").abort

local set = vim.keymap.set
local api = vim.api
local call = api.nvim_call_function

-- leader key
set("n", "<leader>t", function() -- Toggle alternate buffer
	vim.cmd(":b #")
end)
set("n", "<leader>v", function() -- Split vertical
	vim.cmd("vsplit")
end)
set("n", "<leader>h", function() -- Split horizontal
	vim.cmd("split")
end)

set("n", "<leader>d", function() -- delete buffer and set alternate file
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

set("v", "<leader>s", function() -- Sort selection
	local start_row, _, end_row, _ = get_range()
	local lines = api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
	table.sort(lines)
	api.nvim_buf_set_lines(0, start_row - 1, end_row, true, lines)
	api.nvim_feedkeys(vim.keycode("<esc>"), "x", true)
end)

set("n", "<leader>o", function() -- open files returned by input command
	local current_file = call("expand", { "%:p" })
	local input = vim.fn.input("Command (cwd is " .. vim.fn.getcwd() .. "): ")
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
set({ "v" }, "ab", "apk") -- a block is a paragraph
set({ "o" }, "ab", "ap") -- a block is a paragraph
set("n", "<left>", "<nop>") -- do nothing with arrows
set("n", "<right>", "<nop>") -- do nothing with arrows
set("n", "<up>", "<nop>") -- do nothing with arrows
set("n", "<down>", "<nop>") -- do nothing with arrows
set("", "p", function() -- Paste and set '< and '> marks
	paste(true)
end)
set("", "P", function() -- Paste and set '< and '> marks
	paste(false)
end)
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
set("o", "L", function() -- select line from first char to end
	vim.cmd.normal({ "vg_o^", bang = true })
end)
set("o", "?", function() -- select a diagnostic
	require("utils").diagnostic(5)
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
		new_lines(true, count - 1)
	end
	vim.api.nvim_feedkeys("o", "n", false)
end)
set("n", "O", function() -- `O` with count
	local count = vim.v.count1
	if count > 1 then
		new_lines(false, count - 1)
	end
	vim.api.nvim_feedkeys("O", "n", false)
end)
set("o", "q", function() -- go to after next word delimiter
	local pattern = "_"
	local word_under_cursor = call("expand", { "<cword>" })
	if word_under_cursor:find("_") == nil then
		pattern = "\\u"
	end
	local row, col = unpack(call("searchpos", { pattern, "Wn" }))
	if not (vim.v.operator == "d" and pattern == "_") then
		col = col - 1
	end
	api.nvim_win_set_cursor(0, { row, col })
end)
set("", "<M-j>", "^") -- Go to first nonblank char
set("", "<M-k>", "$") -- Go to last char
set("", "0", function() -- Go to beggining of file
	vim.cmd.normal({ "gg", bang = true })
	vim.cmd.call("cursor(1,1)")
end)
set("", "-", function() -- Go to end of file
	local count = vim.v.count
	local op_pending = get_modes().operator_pending
	local has_count = count ~= 0
	if op_pending then
		abort()
	end
	vim.api.nvim_feedkeys((has_count and count or "") .. (op_pending and vim.v.operator or "") .. "G", "n", false)
	if not (has_count or op_pending) then
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
	move(true)
end)

set({ "v" }, "<M-[>", function() -- Swap selection with prev line
	move(false)
end)

set("v", "y", "ygv<Esc>") -- Do not move cursor on yank

set("", "(", function() -- Goto beginning of block
	goto_block_extremity(false)
end)

set("", ")", function() -- Goto end of block
	goto_block_extremity(true)
end)

set("v", "+", function() -- get tabular stats
	local sr, sc, er, ec = require("utils").get_range()
	local tbl = {}
	for i = 0, er - sr do
		local raw_line = vim.api.nvim_buf_get_text(0, sr + i - 1, sc, sr + i - 1, ec + 1, {})[1]
		table.insert(tbl, vim.split(raw_line, " "))
	end
	tbl = vim.tbl_flatten(tbl)
	local stat_fns = {
		sum = function(numbers)
			return vim.iter(numbers):fold(0, function(s, number)
				return s + number
			end)
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

-- --Modifiers keys
set("n", "<M-s>", "r<CR>") -- Split below
set("n", "<M-S-s>", "r<CR><cmd>move .-2<cr>") -- Split up
set("!", "<M-left>", "<S-left>") -- Move one word left
set("!", "<M-right>", "<S-right>") -- Move one word right
set("i", "<C-space>", function() -- Pad with space
	local row, col = unpack(api.nvim_win_get_cursor(0))
	api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { "  " })
	api.nvim_win_set_cursor(0, { row, col + 1 })
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

set("n", "<M-S-d>", function() -- Duplicate line
	local row = api.nvim_win_get_cursor(0)[1]
	api.nvim_buf_set_lines(0, row - 1, row - 1, true, { api.nvim_get_current_line() })
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
	new_lines(true, vim.v.count1)
end)

set("n", "<M-S-o>", function() -- New line up
	new_lines(false, vim.v.count1)
end)

set("i", "<C-f>", function() -- Go one character right
	local row, col = unpack(api.nvim_win_get_cursor(0))
	api.nvim_win_set_cursor(0, { row, col + 1 })
end)

set("i", "<C-b>", function() -- Go one character left
	local row, col = unpack(api.nvim_win_get_cursor(0))
	api.nvim_win_set_cursor(0, { row, col - 1 })
end)

set("i", "<C-q>", function() -- Go to normal mode one char right
	api.nvim_feedkeys(api.nvim_replace_termcodes("<esc>", true, false, true), "t", true)
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
end)

set("i", "<C-l>", function() -- Add new string parameter
	local row, col = unpack(api.nvim_win_get_cursor(0))
	local content = api.nvim_get_current_line()
	local quote = content:sub(col + 1, col + 1)
	local new_line_content = content:sub(1, col + 1) .. ", " .. quote .. quote .. content:sub(col + 2)
	api.nvim_set_current_line(new_line_content)
	api.nvim_win_set_cursor(0, { row, col + 4 })
end)

set("", "<M-x>", function() -- Delete character after cursor
	local content = api.nvim_get_current_line()
	local col = api.nvim_win_get_cursor(0)[2]
	call("setreg", { '"', content:sub(col + 2, col + 2) })

	api.nvim_set_current_line(content:sub(1, col + 1) .. content:sub(col + 3))
end)

set("", "h", function() -- Goto line
	local char = call("getchar", {})

	if char == 27 then
		abort()
		return
	end

	vim.cmd.normal({ "m'", bang = true })
	local first_screen_row = call("line", { "w0" })
	local last_screen_row = call("line", { "w$" })
	local last_row = call("line", { "$" })
	local middle

	if last_row == last_screen_row then
		-- use text height
		local text_height = vim.api.nvim_win_text_height(0, {
			start_row = first_screen_row - 1,
			end_row = last_screen_row - 1,
		})
		middle = math.ceil(text_height.all / 2)
	else
		-- use win height
		local window_height = vim.api.nvim_win_get_height(0)
		middle = math.ceil(window_height / 2)
	end

	local curpos = call("winline", {})
	local wanted = middle - (char - 96)
	local dist = math.abs(wanted - curpos)

	vim.cmd.normal({ dist .. "g" .. (wanted > curpos and "j" or "k"), bang = true })
end)

set("", "l", function() -- Goto line
	local char = call("getchar", {})
	if char == 27 then
		abort()
		return
	end

	vim.cmd.normal("h" .. call("nr2char", { 192 - char }))
end)

set("", "M", function() -- Goto line
	vim.cmd.normal("h`")
end)

set("n", "q", function() -- Go to after next _
	goto_after_sep(true)
end, { silent = true })
set("n", "gq", function() -- Go to after previous _
	goto_after_sep(false)
end, { silent = true })

set("n", "vn", function() -- Apply "v" to next motion
	apply_to_next_motion("v")
end)

set("n", "yn", function() -- Apply "y" to next motion
	apply_to_next_motion("y")
end)

set("n", "dn", function() -- Apply "d" to next motion
	apply_to_next_motion("d")
end)

set("n", "cn", function() -- Apply "c" to next motion
	apply_to_next_motion("c")
end)
