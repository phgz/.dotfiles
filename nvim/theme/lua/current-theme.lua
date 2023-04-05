local config = require("plugins.github-light").config
local util = require("github-theme.util")
vim.cmd("hi clear")
util.load(config())
