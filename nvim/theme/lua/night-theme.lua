local config = require("plugins.gruvbox-baby").config
local util = require("gruvbox-baby.util")

vim.cmd("hi clear")
vim.go.background = "dark"
util.load(config())
