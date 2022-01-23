local utils = require("utils")

require('refactoring').setup({})
utils.map("v", "<Leader>e", "<Esc><Cmd>lua require('refactoring').refactor('Extract Function')<CR>", {noremap = false, silent = true, expr = false})
