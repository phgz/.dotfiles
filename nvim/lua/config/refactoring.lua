require('refactoring').setup({})
vim.keymap.set("v", "<Leader>e", "<Esc><Cmd>lua require('refactoring').refactor('Extract Function')<CR>", {noremap = false, silent = true, expr = false})
