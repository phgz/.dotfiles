--to input a function as insert mode: <C-R>=UltiSnips#ExpandSnippet()<CR>
local utils = require('utils')

-- leader key
utils.map('n', '<leader>v', '<C-w>v')--< Split vertical
utils.map('n', '<leader>h', '<C-w>s')--< Split horizontal
utils.map('n', '<leader>q', '<C-w>c')--< Close window
utils.map('n', '<leader>g', '<Nop>')
utils.map('n', '<leader>r', 'mb<cmd>g/breakpoint()/d<cr>`b')--< Remove Breakpoint
utils.map('n', '<leader>b', 'obreakpoint()<Esc>')--< set Breakpoint
utils.map('n', '<localleader>n', '<cmd>bnext<cr>')--< goto next buffer
utils.map('n', '<localleader>p', '<cmd>bprevious<cr>')--< goto prev buffer
utils.map('n', '<leader>d', '<cmd>bdelete<cr>')--< delete buffer
utils.map('n', '<leader>a', 'mbgg=G`b')--< Autoindent document
utils.map('v', '<leader>s', ':!sort<cr>')--< Sort selection

-- Normal key
utils.map('', ' ', '<Bslash>' , {noremap=false})--< Leader
utils.map('', '<BS>', '!' , {noremap=false})--< Local Leader
utils.map('n', '<LeftDrag>', '<LeftMouse>')--< No drag
utils.map('n', 'Z', '<cmd>w<CR>')--< Write buffer
utils.map('n', 'Q', '<cmd>q!<CR>')--< Quit no wirte buffer
utils.map('n', 'U', '<C-R>')--< Redo
utils.map('n', '<M-s>', 'r<CR>')--< Split below
utils.map('', 'j', '^') --< Swap document bengin/end with line
utils.map('', 'k', '$')  --<
utils.map('', '0', 'gg<cmd>goto 1<CR>')--<
utils.map('', '-', 'G')  --<
utils.map('n', 'Y', 'y$')--< Yank till end
utils.map('n', '<localLeader>d', '<cmd>:windo :diffthis<cr>') --< Diff
utils.map('n', 'sN', '<cmd>move .+1<cr>')--< Swap with next line
utils.map('n', 'sP', '<cmd>move .-2<cr>')--< Swap with prev line
utils.map('v', 'y', 'ygv<Esc>')--< Do not move cursor on yank

--Meta key
utils.map('n', '<M-S-s>', 'r<CR>ddkP')--< Split up
utils.map('n', '<M-j>', 'd$jA <Esc>p')--< Join at end of below
utils.map('n', '<M-S-d>', '<cmd>norm! yyp<cr>')--< Duplicate line
utils.map('n', '<M-d>', '0D')--< Deleteline and keep \n
utils.map('n', '<M-p>', 'A<Esc>p')   --< Append at EOL
utils.map('n', '<M-S-p>', 'A <Esc>p')--< Append at EOL With space
utils.map('n', '<M-a>', 'm`O<Esc>p``')--< Paste buffer above
utils.map('n', '<M-b>', 'm`o<Esc>p``')--< Paste buffer below
utils.map('n', '<M-o>', 'mbo<Esc>`b')  --< New line down
utils.map('n', '<M-S-o>', 'mbO<Esc>`b')--< New line up
utils.map('n', '<M-h>', 'i<space><esc><right>')--< Add space left
utils.map('n', '<M-l>', 'a<space><esc><left>')--< Add space right
utils.map('i', '<C-l>', '<C-o>:norm! "byl<cr><right>,<space><C-r>=@b[0].@b[0]<cr><left>')--< Add new string parameter
utils.map('', '<M-x>', 'm":norm kx<CR>`"')   --< Delete lastchar multiline
utils.map('', '<M-S-x>', 'm":norm x<CR>`"')--< Delete firstchar multiline
