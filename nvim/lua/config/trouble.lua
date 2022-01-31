local utils = require('utils')

require("trouble").setup{
    auto_preview = false,
    action_keys = { -- key mappings for actions in the trouble list
        cancel = {},
        close = "<Esc>", -- close the list
        jump = {},
        jump_close = {"<cr>"},
        previous = {"<S-Tab>","k"}, -- preview item
        next = {"<Tab>","j"} -- next item
    }
}

utils.map('n', '<leader>l', '<cmd>Trouble document_diagnostics<cr>')
