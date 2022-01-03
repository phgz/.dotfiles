local utils = require('utils')
utils.map('n', '<leader>g', 'copilot#Enabled() ? "<cmd>Copilot disable<cr>" : "<Cmd>Copilot enable<cr>"', {expr=true})
utils.map('i', '<C-k>', 'copilot#Dismiss()', {expr=true})

utils.map('i', '<right>', '(col(".") ==# col("$")) ? copilot#Accept("<right>") : "<right>"', {expr=true, silent=true})
vim.g.copilot_no_tab_map = true
