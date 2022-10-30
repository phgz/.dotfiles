vim.keymap.set('n', 'q', '<cmd>lua require("custom_plugins.lines").after_sep(true)<cr>', {silent = true})
vim.keymap.set('n', 'gq', '<cmd>lua require("custom_plugins.lines").after_sep(false)<cr>', {silent = true})

vim.keymap.set('n', '<leader>s', '<cmd>lua require("custom_plugins.lines").swap()<cr>', {silent = true})

vim.keymap.set('n', '<leader>y', '<cmd>lua require("custom_plugins.lines").duplicate()<cr>', {silent = true})

vim.keymap.set('n', '<leader>k', '<cmd>lua require("custom_plugins.lines").kill()<cr>', {silent = true})

vim.keymap.set('n', '<leader>m', '<cmd>lua require("custom_plugins.lines").move()<cr>', {silent = true})
vim.keymap.set('x', '<leader>m', '<cmd>lua require("custom_plugins.lines").move("v")<cr>', {silent = true})

vim.keymap.set('n', '<leader>p', '<cmd>lua require("custom_plugins.lines").copy()<cr>', {silent = true})
vim.keymap.set('x', '<leader>p', '<cmd>lua require("custom_plugins.lines").copy("v")<cr>', {silent = true})
