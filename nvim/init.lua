local execute = vim.api.nvim_command

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

