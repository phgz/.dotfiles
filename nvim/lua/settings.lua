local utils = require('utils')
local gps = require("nvim-gps")
local cmd = vim.cmd
local indent = 4

function NvimGPS()
    return  gps.is_available() and ('  ' .. gps.get_location()) or ''
end

function status_line()
    local status = ' %{gitbranch#name()}%='
    status = status .. '%#PurpleStatusLine#%{luaeval("NvimGPS()")}'
    status = status .. '%=%h%#RedStatusLine#%m%#BlueStatusLine#%r%#StatusLine# %F | %2c'
    return status
end

vim.api.nvim_exec([[
syntax enable
filetype plugin indent on
set nohlsearch
set history=100
set shell=fish
set foldtext=getline(v:foldstart+1)
    ]], false)

vim.g.maplocalleader = "!"

utils.opt('b', 'expandtab', true)
utils.opt('b', 'shiftwidth', indent)
utils.opt('b', 'smartindent', true)
utils.opt('b', 'tabstop', indent)
utils.opt('o', 'updatetime', 100)
utils.opt('o', 'timeoutlen', 4000) -- Keymap timer
utils.opt('o', 'laststatus', 2)
utils.opt('o', 'pumblend', 30)
utils.opt('o', 'pumheight', 9)
utils.opt('o', 'icm', 'nosplit')
utils.opt('o', 'mouse', 'nicr')
utils.opt('o', 'hidden', true)
utils.opt('o', 'lazyredraw', true) -- Don’t update screen during macro and script execution
utils.opt('o', 'autochdir', true) 
utils.opt('o', 'ignorecase', true)
utils.opt('o', 'shiftround', true)
utils.opt('o', 'smartcase', true)
utils.opt('o', 'splitbelow', true)
utils.opt('o', 'splitright', true)
utils.opt('o', 'showmode', false)
utils.opt('o', 'wildmode', 'list:longest')
utils.opt('o', 'completeopt', 'menu,menuone,noinsert,noselect')
--utils.opt('o', 'backspace', 'indent,start')
utils.opt('w', 'number', true)
utils.opt('w', 'signcolumn', "yes")
utils.opt('w', 'cursorline', true)
utils.opt('w', 'linebreak', true) -- Avoid wrapping a line in the middle of a word
-- utils.opt('w', 'foldmethod', 'expr')
-- utils.opt('w', 'foldexpr', 'nvim_treesitter#foldexpr()')
vim.opt.formatoptions = vim.opt.formatoptions - { "ro" }
vim.opt.iskeyword = vim.opt.iskeyword + { "-" }
vim.o.statusline = status_line()
--utils.opt('o', 'clipboard','unnamed,unnamedplus')

-- Highlight on yank
-- Highlight when more than 80 cols
-- Fold docstring
--call matchadd('DiffText', '\%81v\|\%89v\|\%97v')
vim.api.nvim_exec([[
autocmd TextYankPost * silent! lua vim.highlight.on_yank {timeout=140}
call matchadd('DiffText', '\%97v')
autocmd FileType python setlocal foldenable foldmethod=syntax
    ]], false)
