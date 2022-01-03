local fn = vim.fn
local execute = vim.api.nvim_command

-- Auto install packer.nvim if not exists
local install_path = fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
end
vim.cmd [[packadd packer.nvim]]
-- Auto compile when there are changes in plugins.lua
vim.cmd 'autocmd BufWritePost plugins.lua PackerCompile'

-- python provider
vim.g.python3_host_prog = "~/.miniconda3/envs/neovim/bin/python"

-- Perform load optimizations
require('impatient')

-- Install plugins
require('plugins')

-- Custom plugins
require('custom_plugins')

-- Global settings
require('settings')

-- Key mappings
require('keymappings')

-- Group configuration in one folder
require('config')

-- Setup Lua language server
require('lsp')

-- custom highlightings
require('highlights')

