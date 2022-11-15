require('refactoring').setup({})

local opts = {noremap = false, silent = true, expr = false}
vim.keymap.set("v", "<Leader>e", function() require('refactoring').refactor('Extract Function') end, opts)
