local utils = require('utils')

vim.g.ultest_use_pty = 1
utils.map('n', '<leader>t', '<cmd>UltestNearest<cr>')
