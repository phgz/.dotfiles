--to input a function as insert mode: <C-R>=UltiSnips#ExpandSnippet()<CR>
local set = vim.keymap.set

vim.api.nvim_set_keymap('', ' ', '<Bslash>' , {noremap=false})--< Leader
vim.api.nvim_set_keymap('', '<BS>', '!' , {noremap=false})--< Local Leader

-- leader key
set('n', '<leader>v', '<C-w>v')--< Split vertical
set('n', '<leader>h', '<C-w>s')--< Split horizontal
set('n', '<leader>q', '<C-w>c')--< Close window
set('n', '<leader>g', '<Nop>')
set('n', '<leader>r', 'mb<cmd>g/breakpoint()/d<cr>`b')--< Remove Breakpoint
set('n', '<leader>b', 'obreakpoint()<Esc>')--< set Breakpoint
set('n', '<localleader>n', '<cmd>bnext<cr>')--< goto next buffer
set('n', '<localleader>p', '<cmd>bprevious<cr>')--< goto prev buffer
set('n', '<localleader>d', '<cmd>bdelete<cr>')--< delete buffer
set('n', '<localleader>=', 'mbgg=G=G`b')--< Autoindent document
set('v', '<leader>s', ':sort<cr>')--< Sort selection

-- Normal key
set('n', '<LeftDrag>', '<LeftMouse>')--< No drag
set('n', 'Z', '<cmd>w<CR>')--< Write buffer
set('n', 'Q', '<cmd>q!<CR>')--< Quit no wirte buffer
set('n', 'U', '<C-R>')--< Redo
set('n', '<M-s>', 'r<CR>')--< Split below
set('', 'j', '^') --< Swap document bengin/end with line
set('', 'k', '$')  --<
set('', 'h', 'zh')  --< Move screen to the left
set('', 'l', 'zl')  --< Move screen to the right
set('', '0', 'gg<cmd>goto 1<CR>')--<
set('', '-', 'G')  --<
set('n', 'Y', 'y$')--< Yank till end
set('n', '<leader>d', '<cmd>:windo :diffthis<cr>') --< Diff
set('n', 'sN', '<cmd>move .+1<cr>')--< Swap with next line
set('n', 'sP', '<cmd>move .-2<cr>')--< Swap with prev line
set('v', 'y', 'ygv<Esc>')--< Do not move cursor on yank

--Meta key
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
set('n', '<M-h>', 'i<space><esc><right>')--< Add space left
set('n', '<M-l>', 'a<space><esc><left>')--< Add space right
set('i', '<C-l>', '<C-o>:norm! "byl<cr><right>,<space><C-r>=@b[0].@b[0]<cr><left>')--< Add new string parameter
set('i', '<C-s>', '<space><space><left>')--< Add space after and before
set('', '<M-x>', 'm":norm kx<CR>`"')   --< Delete lastchar multiline
set('', '<M-S-x>', 'm":norm x<CR>`"')--< Delete firstchar multiline
