local get_range = require("utils").get_range
local move = require("utils").move
local goto_block_extremity = require("utils").goto_block_extremity
local goto_after_sep = require("utils").goto_after_sep
local apply_to_next_motion = require("utils").apply_to_next_motion
local new_lines = require("utils").new_lines
local get_modes = require("utils").get_modes

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
	print("about to delete", call("expand", { "%:p" }))
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
	print("still_listed:", vim.inspect(still_listed))
	print("possible_alternatives:", vim.inspect(possible_alternatives))

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
	print("jumps_current_file_index:", jumps[jumps_current_file_index]["f"])

	local jumps_alternate_file_index = jumps_current_file_index - 4
	local found = false
	print("first jumps_alternate_file_index:", jumps[jumps_alternate_file_index]["f"])

	for i = jumps_alternate_file_index, 1, -4 do
		if vim.list_contains(possible_alternatives, jumps[i]["f"]) then
			found = true
			jumps_alternate_file_index = i
			break
		end
	end
	if found then
		print("found jumps_alternate_file_index:", jumps[jumps_alternate_file_index]["f"])
		call("setreg", { "#", jumps[jumps_alternate_file_index]["f"] })
	else
		print("Alternate file not found in jumplist! Picking last in possible_alternatives")
		call("setreg", { "#", possible_alternatives[#possible_alternatives] })
	end
end)

set("v", "<leader>s", function() -- Sort selection
	local start_row, _, end_row, _ = get_range()
	local lines = api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
	table.sort(lines)
	api.nvim_buf_set_lines(0, start_row - 1, end_row, true, lines)
	api.nvim_feedkeys(api.nvim_replace_termcodes("<esc>", true, false, true), "x", true)
end)

set("n", "<leader>m", function() -- Add input to beginning of file
	local input = call("input", { "Add before first line: " })
	if input == "" then
		return
	end
	api.nvim_buf_set_lines(0, 0, 0, true, { input })
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
set("n", "<left>", "<nop>")
set("n", "<right>", "<nop>")
set("n", "<up>", "<nop>")
set("n", "<down>", "<nop>")
set("n", "<C-r>", "R") -- R is rare, so change it to <C-r>
set("n", "<S-cr>", function() -- Pad with newlines
	local row, col = unpack(api.nvim_win_get_cursor(0))
	api.nvim_buf_set_lines(0, row - 1, row - 1, true, { "" })
	api.nvim_buf_set_lines(0, row, row, true, { "" })
	api.nvim_win_set_cursor(0, { row + 1, col })
end)
set("o", "R", function() -- select line from first char to end
	vim.cmd.normal({ "vg_o^", bang = true })
end)
set("o", "?", function() -- select a diagnostic
	require("utils").diagnostic(5)
end)
set("n", "R", function() -- Replace motion with " register
	require("multiline_ft").set_registry(
		vim.tbl_extend("force", require("multiline_ft").get_registry(), { operator_count = vim.v.count })
	)
	vim.go.operatorfunc = "v:lua.require'utils'.replace"
	api.nvim_feedkeys("g@", "n", false)
end, { expr = false })
set("n", "Z", function() -- Write buffer
	vim.cmd("silent write")
	vim.notify("buffer written")
end)
set("n", "Q", function() -- Quit no write buffer
	vim.cmd("quit!")
end)
set("n", "U", function() -- Redo
	vim.cmd("redo")
end)
set("n", "o", function()
	local count = vim.v.count1
	if count > 1 then
		new_lines(true, count - 1)
	end
	vim.api.nvim_feedkeys("o", "n", false)
end)
set("n", "O", function()
	local count = vim.v.count1
	if count > 1 then
		new_lines(false, count - 1)
	end
	vim.api.nvim_feedkeys("O", "n", false)
end)
set("n", "cq", "ct_") -- Change until _
set("n", "yq", "yt_") -- Yank until _
set("n", "dq", "df_") -- Delete find _
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

vim.keymap.set({ "v" }, "<M-]>", function() -- Swap selection with next line
	move(true)
end)

vim.keymap.set({ "v" }, "<M-[>", function() -- Swap selection with prev line
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
	api.nvim_buf_set_lines(0, row - 1, row - 1, true, { "" })
	api.nvim_buf_set_lines(0, row, row, true, { "" })
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

set("i", "<C-b>", function() -- Go one character right
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
	print(word_under_cursor)
	local row, col = unpack(api.nvim_win_get_cursor(0))
	local end_col = call("searchpos", { word_under_cursor, "Wcnb" })[2] - 1 + #word_under_cursor
	api.nvim_buf_set_text(0, row - 1, col, row - 1, end_col, {})
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

set("n", "q", function() -- Go to after next _
	goto_after_sep(true)
end, { silent = true })
set("n", "gq", function() -- Go to after previous _
	goto_after_sep(false)
end, { silent = true })

set("n", "vn", function() -- Apply "v" to next motion
	apply_to_next_motion("v")
end)

set("n", "yn", function() -- Apply "v" to next motion
	apply_to_next_motion("y")
end)

set("n", "dn", function() -- Apply "v" to next motion
	apply_to_next_motion("d")
end)

set("n", "cn", function() -- Apply "v" to next motion
	apply_to_next_motion("c")
end)
