--Global (g:) editor variables.
local g = vim.g

-- A special interface |vim.opt| exists for conveniently interacting with list-
-- and map-style option from Lua: It allows accessing them as Lua tables and
-- offers object-oriented method for adding and removing entries.
local opt = vim.opt

-- Get or set global |options|. Like `:setglobal`.
-- Note: this is different from |vim.o| because this accesses the global
-- option value and thus is mostly useful for use with |global-local|
-- options.
local go = vim.go

-- Get or set buffer-scoped |options| for the buffer with number {bufnr}. Like `:set` and `:setlocal`.
-- Note: this is equivalent to both `:set` and `:setlocal`.
local bo = vim.bo

-- Get or set window-scoped |options| for the window with handle {winid}. Like `:set`.
-- Note: this does not access |local-options| (`:setlocal`).
local wo = vim.wo

local function status_line()
  local status = " %{%get(b:,'gitsigns_status','')%}"
  status = status .. [[%=%#GreyStatusLine#%{%luaeval('require("noice.api.status").message.get() or ""')%}]]
  status = status .. '%=%h%#RedStatusLine#%m%#BlueStatusLine#%r%#StatusLine# %F ▏%2c'
  return status
end

g.loaded_perl_provider = 0
g.maplocalleader = "!"
g.python3_host_prog = "~/.miniconda3/envs/neovim/bin/python"

bo.expandtab = true
bo.shiftwidth = 4
bo.smartindent = true
bo.softtabstop = 4
bo.tabstop = 4

go.autochdir = true
-- go.clipboard = 'unnamed,unnamedplus'
go.cmdheight = 0
go.completeopt = 'menu,menuone,noinsert,noselect'
go.gdefault = true
go.hlsearch = false
go.ignorecase = true
go.laststatus = 3
go.mouse = 'nicr'
go.pumblend = 30
go.pumheight = 9
go.shell = "/bin/sh"
go.shiftround = true
go.smartcase = true
go.splitbelow = true
go.splitright = true
go.statusline = status_line()
go.termguicolors = true
go.timeoutlen = 4000
go.wildmode = 'list:longest'

wo.cursorline = true
wo.foldtext = 'getline(v:foldstart+1)'
wo.linebreak = true
wo.number = true
wo.signcolumn = "yes"
-- wo.winbar = "..." -- Use winbar feature

opt.formatoptions:remove { "ro" }
opt.iskeyword:append { "-" }
opt.matchpairs:append { ">:<" }
opt.shortmess:append { c = true, I = true --[[A = true]]}

vim.fn.matchadd('DiffText', '\\%97v')
