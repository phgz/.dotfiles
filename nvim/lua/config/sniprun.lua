local utils = require('utils')
local M = {}

function M.setup()
  require("sniprun").setup {
    borders = "rounded",
    display = {
      "NvimNotify",
    },
    --selected_interpreters = {'Python3_jupyter', 'Python3_original', 'Python3_fifo'},
    selected_interpreters = {'Python3_fifo'},
    repl_enable = {'Python3_fifo'}
  }
end

vim.api.nvim_set_keymap('v', '<leader>x', '<Plug>SnipRun', {silent = true})
vim.api.nvim_set_keymap('n', '<leader>x', '<Plug>SnipRunOperator', {silent = true})

vim.cmd([[autocmd VimEnter *.py silent SnipRun]]) -- maybe try BufNew

return M
