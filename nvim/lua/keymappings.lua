local get_range_motion = require"custom_plugins.utils".get_range_motion
local set = vim.keymap.set
local fn = vim.fn
local api = vim.api

-- leader key
set('n', '<leader>q', '<cmd>close<cr>')--< Close window
set('n', '<leader>b',
function()
  local row = api.nvim_win_get_cursor(0)[1]
  local content = api.nvim_get_current_line()
  local indent = content:match("^%s*")
  local text = indent .. 'breakpoint()'
	api.nvim_buf_set_lines(0, row, row, true, {text})
end
) --< set Breakpoint
set('n', '<leader>d', '<cmd>:windo :diffthis<cr>') --< Diff
set('v', '<leader>s',
function()
	local range = get_range_motion("v")
  local lines = api.nvim_buf_get_lines(0, range.start-1, range.end_, false)
	table.sort(lines)
	api.nvim_buf_set_lines(0, range.start-1, range.end_, true, lines)
  api.nvim_feedkeys(api.nvim_replace_termcodes("<esc>", true, false, true), 'x', true)
end
)--< Sort selection
set('n', '<localleader>v', '<cmd>vsplit<cr>')--< Split vertical
set('n', '<localleader>h', '<cmd>split<cr>')--< Split horizontal
set('n', '<localleader>q', 'mb<cmd>g/breakpoint()/d<cr>`b')--< Remove Breakpoint
set('n', '<localleader>n', '<cmd>bnext<cr>')--< goto next buffer
set('n', '<localleader>p', '<cmd>bprevious<cr>')--< goto prev buffer
set('n', '<localleader>d', '<cmd>bdelete<cr>')--< delete buffer
set('n', '<leader>i', function() local input = fn.input("Add import: ")
  if input == "" then
    return
  end
  api.nvim_buf_set_lines(0,0,0,true,{input})
  end)

-- Normal key
set('n', '<LeftDrag>', '<LeftMouse>')--< No drag
set('n', 'Z', '<cmd>write<CR>')--< Write buffer
set('n', 'Q', '<cmd>quit!<CR>')--< Quit no wirte buffer
set('n', 'U', '<cmd>redo<cr>')--< Redo
set('n', 'cq', 'ct_')  --< Change until _
set('n', 'yq', 'yt_')  --< Yank until _
set('n', 'dq', 'df_')  --< Delete find _
set('', 'j', '^') --< Swap document bengin/end with line
set('', 'k', '$')  --<
set('', '0', 'gg<cmd>goto 1<CR>')--<
set('', '-', 'G')  --<
set('n', 'sN', '<cmd>move .+1<cr>')--< Swap with next line
set('n', 'sP', '<cmd>move .-2<cr>')--< Swap with prev line
set('v', 'y', 'ygv<Esc>')--< Do not move cursor on yank

set('', '(', function()
  local line = fn.line("'{")
  if line == fn.line('.') - 1 then
    fn.cursor(line-1,0)
    line = fn.line("'{")
  end
  fn.cursor(line + fn.empty(fn.getline(line)), 0)
end)
set('', ')', function()
  local line = fn.line("'}")
  if line == fn.line('.') + 1 then
    fn.cursor(line+1,0)
    line = fn.line("'}")
  end
  fn.cursor(line - fn.empty(fn.getline(line)), 0)
end)

--Meta key
set('n', '<M-s>', 'r<CR>')--< Split below
set('n', '<M-S-s>', 'r<CR>ddkP')--< Split up
set('n', '<M-j>', 'd$jA <Esc>p')--< Join at end of below
set('n', '<M-S-d>', '<cmd>norm! yyp<cr>')--< Duplicate line
set('n', '<M-d>', '0D')--< Deleteline and keep \n
set('n', '<M-p>', 'A<Esc>p')   --< Append at EOL
set('n', '<M-S-p>', 'A <Esc>p')--< Append at EOL With space
set('n', '<M-a>', 'm`O<Esc>p``')--< Paste buffer above
set('n', '<M-b>', 'm`o<Esc>p``')--< Paste buffer below
set('n', '<M-o>', 'mbo<Esc>`b')  --< New line down
set('n', '<M-S-o>', 'mbO<Esc>`b')--< New line up
set('i', '<C-s>', '<space><space><left>')--< Add space after and before
set('i', '<C-l>',
function() --< Add new string parameter
  local row, col = unpack(api.nvim_win_get_cursor(0))
  local content = api.nvim_get_current_line()
  local quote = content:sub(col,col)
  local new_line_content = content:sub(1,col) .. ', ' .. quote .. quote .. content:sub(col+1)
  api.nvim_set_current_line(new_line_content)
  api.nvim_win_set_cursor(0, { row, col+3})
end
)
set('', '<M-x>', function() --< Delete lastchar multiline
  local content = api.nvim_get_current_line()
  api.nvim_set_current_line(content:sub(1,#content-1))
end
)
set('', '<M-S-x>', function() --< Delete firstchar multiline
  local row, col = unpack(api.nvim_win_get_cursor(0))
  local content = api.nvim_get_current_line()
  api.nvim_set_current_line(content:sub(2))
  api.nvim_win_set_cursor(0, { row, col-1})
end
)
