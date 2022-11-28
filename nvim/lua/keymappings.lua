local get_range_motion = require"custom_plugins.utils".get_range_motion
local set = vim.keymap.set
local fn = vim.fn
local api = vim.api

-- leader key
set('n', '<leader>t', '<cmd>:b #<cr>') -- Toggle alternate buffer
set('n', '<leader>v', '<cmd>vsplit<cr>') -- Split vertical
set('n', '<leader>h', '<cmd>split<cr>') -- Split horizontal

set('n', '<leader>d', function() -- delete buffer and set alternate file
	vim.cmd("bdelete")
	local new_current_file = vim.fn.expand("%:p")
	local context = vim.api.nvim_get_context({types={"jumps", "bufs"}})
	local jumps = vim.fn.msgpackparse(context['jumps'])
	local still_listed = vim.tbl_map(function(buf) return buf['f'] end, vim.fn.msgpackparse(context['bufs'])[4])

	if #still_listed == 0 then
		return

	elseif #still_listed == 1 then
		vim.cmd("call setreg('#', @%)")
		return
	end

	local jumps_current_file_index

	for i = #jumps, 1, -4 do
		if jumps[i]['f'] == new_current_file then
			jumps_current_file_index = i
			break
		end
	end

	local jumps_alternate_file_index = jumps_current_file_index - 4

	for i = jumps_alternate_file_index, 1, -4 do
		if vim.tbl_contains(still_listed, jumps[i]['f']) then
			jumps_alternate_file_index = i
			break
		end
	end

	vim.api.nvim_call_function("setreg", {"#", jumps[jumps_alternate_file_index]['f']})
end)

set('n', '<leader>q', function() -- Close popups
	local filter = function(win) return vim.api.nvim_win_get_config(win).relative ~= "" end
	local to_close = vim.tbl_filter(filter, vim.api.nvim_list_wins())
	for _, win in ipairs(to_close) do
			vim.api.nvim_win_close(win, false)
	end
end)

set('v', '<leader>s', function() -- Sort selection
	local range = get_range_motion("v")
  local lines = api.nvim_buf_get_lines(0, range.start-1, range.end_, false)
	table.sort(lines)
	api.nvim_buf_set_lines(0, range.start-1, range.end_, true, lines)
  api.nvim_feedkeys(api.nvim_replace_termcodes("<esc>", true, false, true), 'x', true)
end)

set('n', '<leader>m', function() -- Add input to beginning of file
  local input = fn.input("Add import: ")
  if input == "" then
    return
  end
  api.nvim_buf_set_lines(0,0,0,true,{input})
end)


-- localleader key
set('n', '<localleader>d', '<cmd>:windo :diffthis<cr>') -- Diff
set('n', '<localleader>q', function() -- Remove breakpoints
	local cur_pos = api.nvim_win_get_cursor(0)
	vim.cmd("g/breakpoint()/d")
  api.nvim_win_set_cursor(0, cur_pos)
end)

set('n', '<localleader>b', function() -- Set breakpoint
  local row = api.nvim_win_get_cursor(0)[1]
  local content = api.nvim_get_current_line()
  local indent = content:match("^%s*")
  local text = indent .. 'breakpoint()'
	api.nvim_buf_set_lines(0, row, row, true, {text})
end)


-- Normal key
set('n', '<LeftDrag>', '<LeftMouse>') -- No drag
set('n', 'Z', '<cmd>write<CR>') -- Write buffer
set('n', 'Q', '<cmd>quit!<CR>') -- Quit no wirte buffer
set('n', 'U', '<cmd>redo<cr>') -- Redo
set('n', 'cq', 'ct_') -- Change until _
set('n', 'yq', 'yt_') -- Yank until _
set('n', 'dq', 'df_') -- Delete find _
set('', 'j', '^') -- Go to first nonblank char
set('', 'k', '$') -- Go to last char
set('', '0', 'gg') -- Go to beggining of file
set('', '-', 'G') -- Go to end of file
set('n', 'sN', '<cmd>move .+1<cr>') -- Swap with next line
set('n', 'sP', '<cmd>move .-2<cr>') -- Swap with prev line
set('v', 'y', 'ygv<Esc>') -- Do not move cursor on yank

set('', '(', function() -- Go to beginning of block
  local line = fn.line("'{")
  if line == fn.line('.') - 1 then
    fn.cursor(line-1,0)
    line = fn.line("'{")
  end
  fn.cursor(line + fn.empty(fn.getline(line)), 0)
end)

set('', ')', function() -- Goto end of block
  local line = fn.line("'}")
  if line == fn.line('.') + 1 then
    fn.cursor(line+1,0)
    line = fn.line("'}")
  end
  fn.cursor(line - fn.empty(fn.getline(line)), 0)
end)


--Modifiers keys
set('n', '<M-s>', 'r<CR>') -- Split below
set('n', '<M-S-s>', 'r<CR><cmd>move .-2<cr>') -- Split up
set('n', '<M-S-j>', '<cmd>move .+1 <bar> .-1 join<cr>') -- Join at end of below
set('i', '<C-s>', '<space><space><left>') -- Add space after and before

set('n', '<M-S-d>', function() -- Duplicate line
  local row = api.nvim_win_get_cursor(0)[1]
  api.nvim_buf_set_lines(0, row-1, row-1, true, {api.nvim_get_current_line()})
end)

set('n', '<M-d>', function() -- Delete line content
  api.nvim_set_current_line("")
end)

set('n', '<M-p>', function() -- Append at EOL
  api.nvim_set_current_line(api.nvim_get_current_line() .. vim.fn.getreg('"'))
end)

set('n', '<M-S-p>', function() -- Append at EOL With space
  api.nvim_set_current_line(api.nvim_get_current_line() .. " " .. vim.fn.getreg('"'))
end)

set('n', '<M-a>', function() -- Paste buffer above
  local row = api.nvim_win_get_cursor(0)[1]
  api.nvim_buf_set_lines(0, row-1, row-1, true, {vim.fn.getreg('"')})
end)

set('n', '<M-b>', function() -- Paste buffer below
  local row = api.nvim_win_get_cursor(0)[1]
  api.nvim_buf_set_lines(0, row, row, true, {vim.fn.getreg('"')})
end)

set('n', '<M-o>', function() -- New line down
  local row = api.nvim_win_get_cursor(0)[1]
  api.nvim_buf_set_lines(0, row, row, true, {""})
end)

set('n', '<M-S-o>', function() -- New line up
  local row = api.nvim_win_get_cursor(0)[1]
  api.nvim_buf_set_lines(0, row-1, row-1, true, {""})
end)

set('i', '<C-l>', function() -- Add new string parameter
  local row, col = unpack(api.nvim_win_get_cursor(0))
  local content = api.nvim_get_current_line()
  local quote = content:sub(col+1,col+1)
  local new_line_content = content:sub(1,col+1) .. ', ' .. quote .. quote .. content:sub(col+2)
  api.nvim_set_current_line(new_line_content)
  api.nvim_win_set_cursor(0, { row, col+4})
end)

set('', '<M-x>', function() -- Delete lastchar multiline
  local content = api.nvim_get_current_line()
  api.nvim_set_current_line(content:sub(1,#content-1))
end)

set('', '<M-S-x>', function() -- Delete firstchar multiline
  local row, col = unpack(api.nvim_win_get_cursor(0))
  local content = api.nvim_get_current_line()
  api.nvim_set_current_line(content:sub(2))
  api.nvim_win_set_cursor(0, { row, col-1})
end)
