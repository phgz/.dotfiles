local util = require("gruvbox-baby.util")
local config = require("config.gruvbox-baby")

vim.cmd("hi clear")
vim.go.background = "dark"
util.load(config.theme)
require("gruvbox-baby.ts-fix")
