local mk_repeatable = require("utils").mk_repeatable
local get_range = require("utils").get_range
local detect_selection_mode = require("utils").detect_selection_mode
local update_selection = require("utils").update_selection

local set = vim.keymap.set
local api = vim.api
local call = api.nvim_call_function

-- leader key
set("n", "<leader>t", function()
	vim.cmd(":b #")
end) -- Toggle alternate buffer
set("n", "<leader>v", function()
	vim.cmd("vsplit")
end) -- Split vertical
set("n", "<leader>h", function()
	vim.cmd("split")
end) -- Split horizontal

set("n", "<leader>d", function() -- delete buffer and set alternate file
	vim.cmd("bdelete")
	local new_current_file = call("expand", { "%:p" })
	local context = api.nvim_get_context({ types = { "jumps", "bufs" } })
	local jumps = call("msgpackparse", { context["jumps"] })
	local still_listed = vim.tbl_map(function(buf)
		return buf["f"]
	end, call("msgpackparse", { context["bufs"] })[4])
	local possible_alternatives = vim.tbl_filter(function(name)
		return name ~= new_current_file
	end, still_listed)
	-- print(vim.inspect(still_listed))

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
	-- print("jumps_current_file_index: ", jumps[jumps_current_file_index]['f'])

	local jumps_alternate_file_index = jumps_current_file_index - 4
	-- print("first jumps_alternate_file_index: ", jumps[jumps_alternate_file_index]['f'])

	for i = jumps_alternate_file_index, 1, -4 do
		if vim.tbl_contains(possible_alternatives, jumps[i]["f"]) then
			jumps_alternate_file_index = i
			break
		end
	end
	-- print("found jumps_alternate_file_index", jumps[jumps_alternate_file_index]['f'])
	call("setreg", { "#", jumps[jumps_alternate_file_index]["f"] })
end)

set("n", "<leader>q", function() -- Close window
	local win = api.nvim_get_current_win()
	api.nvim_win_close(win, false)
end)

set("v", "<leader>s", function() -- Sort selection
	local start_row, _, end_row, _ = get_range()
	local lines = api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
	table.sort(lines)
	api.nvim_buf_set_lines(0, start_row - 1, end_row, true, lines)
	api.nvim_feedkeys(api.nvim_replace_termcodes("<esc>", true, false, true), "x", true)
end)

set("n", "<leader>m", function() -- Add input to beginning of file
	local input = call("input", { "Add import: " })
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

-- Normal key
set("n", "<LeftDrag>", "<LeftMouse>") -- No drag
set("n", "Z", function()
	vim.cmd("silent write")
	print("buffer written")
end) -- Write buffer
set("n", "Q", function()
	vim.cmd("quit!")
end) -- Quit no wirte buffer
set("n", "U", function()
	vim.cmd("redo")
end) -- Redo
set("n", "cq", "ct_") -- Change until _
set("n", "yq", "yt_") -- Yank until _
set("n", "dq", "df_") -- Delete find _
set("", "j", "^") -- Go to first nonblank char
set("", "k", "$") -- Go to last char
set("", "0", "gg") -- Go to beggining of file
set("", "-", "G") -- Go to end of file
set(
	{ "n", "x" },
	"<M-]>",
	mk_repeatable(function()
		vim.cmd("move .+1")
	end)
) -- Swap with next line
set(
	{ "n", "x" },
	"<M-[>",
	mk_repeatable(function()
		vim.cmd("move .-2")
	end)
) -- Swap with prev line
set("v", "y", "ygv<Esc>") -- Do not move cursor on yank

set("n", "[<space>", function() -- Go left
	local row, col = unpack(api.nvim_win_get_cursor(0))
	api.nvim_win_set_cursor(0, { row, col - 1 })
end)

set("n", "]<space>", function() -- Go right
	local row, col = unpack(api.nvim_win_get_cursor(0))
	api.nvim_win_set_cursor(0, { row, col + 1 })
end)

set({ "o", "n" }, "]<cr>", function() -- Go down one line
	local row, col = unpack(api.nvim_win_get_cursor(0))
	api.nvim_win_set_cursor(0, { row + 1, col })
end)

set({ "o", "n" }, "[<cr>", function() -- Go up one line
	local row, col = unpack(api.nvim_win_get_cursor(0))
	api.nvim_win_set_cursor(0, { row - 1, col })
end)

set("", "(", function() -- Go to beginning of block
	local line = call("line", { "'{" })
	if line == call("line", { "." }) - 1 then
		call("cursor", { line - 1, 0 })
		line = call("line", { "'{" })
	end
	call("cursor", { line + call("empty", { call("getline", { line }) }), 0 })
end)

set("", ")", function() -- Goto end of block
	local line = call("line", { "'}" })
	if line == call("line", { "." }) + 1 then
		call("cursor", { line + 1, 0 })
		line = call("line", { "'}" })
	end
	call("cursor", { line - call("empty", { call("getline", { line }) }), 0 })
end)

--Modifiers keys
set("n", "<M-s>", "r<CR>") -- Split below
set("n", "<M-S-s>", "r<CR><cmd>move .-2<cr>") -- Split up
set("n", "<M-S-j>", function()
	vim.cmd("move .+1 | .-1 join")
end) -- Join at end of below

set("n", "<M-left>", function()
	vim.cmd("wincmd h")
end) -- Go left window
set("n", "<M-right>", function()
	vim.cmd("wincmd l")
end) -- Go right window
set("n", "<M-up>", function()
	vim.cmd("wincmd k")
end) -- Go up window
set("n", "<M-down>", function()
	vim.cmd("wincmd j")
end) -- Go down window

set("n", "<C-g>", function() -- Show file stats
	local row, col = unpack(api.nvim_win_get_cursor(0))
	local line_count = api.nvim_buf_line_count(0)
	local relative = math.floor(row / line_count * 100 + 0.5)
	print(row .. ":" .. col + 1 .. "; " .. line_count .. " lines --" .. relative .. "%--")
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

set("n", "<M-a>", function() -- Paste buffer above
	local row = api.nvim_win_get_cursor(0)[1]
	api.nvim_buf_set_lines(0, row - 1, row - 1, true, { call("getreg", { '"' }) })
end)

set("n", "<M-b>", function() -- Paste buffer below
	local row = api.nvim_win_get_cursor(0)[1]
	api.nvim_buf_set_lines(0, row, row, true, { call("getreg", { '"' }) })
end)

set("n", "<M-o>", function() -- New line down
	local row = api.nvim_win_get_cursor(0)[1]
	api.nvim_buf_set_lines(0, row, row, true, { "" })
	api.nvim_win_set_cursor(0, { row + 1, 0 })
end)

set("n", "<M-S-o>", function() -- New line up
	local row = api.nvim_win_get_cursor(0)[1]
	api.nvim_buf_set_lines(0, row - 1, row - 1, true, { "" })
	api.nvim_win_set_cursor(0, { row, 0 })
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

set("i", "<C-_>", function() -- Delete line after cursor
	local col = api.nvim_win_get_cursor(0)[2]
	api.nvim_set_current_line(api.nvim_get_current_line():sub(1, col))
end)

set("i", "<C-k>", function() -- Delete next character
	local col = api.nvim_win_get_cursor(0)[2]
	local line_content = api.nvim_get_current_line()
	api.nvim_set_current_line(line_content:sub(1, col) .. line_content:sub(col + 2))
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

-- set("", "<M-x>", function() -- Delete lastchar multiline
-- 	local content = api.nvim_get_current_line()
-- 	api.nvim_set_current_line(content:sub(1, #content - 1))
-- end)

set(
	"",
	"<M-r>",
	mk_repeatable(function() -- Replace word under cursor with " bufffer
		local word_under_cursor = call("expand", { "<cword>" })
		local to_replace = call("getreg", { '"' })
		local row, col = unpack(api.nvim_win_get_cursor(0))
		-- api.nvim_win_set_cursor(0, { row, col - 1 })
		local wuc_start_col = call("searchpos", { word_under_cursor, "Wcnb" })[2] - 1
		api.nvim_buf_set_text(0, row - 1, wuc_start_col, row - 1, wuc_start_col + #word_under_cursor, { to_replace })
	end)
)

set("", "<M-S-x>", function() -- Delete firstchar multiline
	local row, col = unpack(api.nvim_win_get_cursor(0))
	local content = api.nvim_get_current_line()
	api.nvim_set_current_line(content:sub(2))
	api.nvim_win_set_cursor(0, { row, col - 1 })
end)

local after_sep = function(fwd)
	local row, col = unpack(api.nvim_win_get_cursor(0))
	local prev_char = api.nvim_get_current_line():sub(col, col)
	local back_on_edge = not fwd and prev_char == "_"
	local opts = "Wn"
	opts = fwd and opts or opts .. "b"

	if back_on_edge then
		api.nvim_win_set_cursor(0, { row, col - 1 })
	end

	local new_row, new_col = unpack(call("searchpos", { "_", opts }))

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

vim.keymap.set("n", "q", function()
	after_sep(true)
end, { silent = true })
vim.keymap.set("n", "gq", function()
	after_sep(false)
end, { silent = true })
