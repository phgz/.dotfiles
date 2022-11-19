local util = require('github-theme.util')
local config = require('config.github-light')

vim.cmd("hi clear")
util.load(config.theme)
