local utils = require('utils')
local opt = { silent = true, noremap = true }

require("Comment").setup{
      toggler = {
        ---Line-comment toggle keymap
        line = 'KK',
        ---Block-comment toggle keymap
        block = 'gkb',
    },

    ---LHS of operator-pending mappings in NORMAL + VISUAL mode
    ---@type table
    opleader = {
        -- -Line-comment keymap
        line = 'K',
        ---Block-comment keymap
        block = 'gk',
    },
      extra = {
        ---Add comment on the line above
        above = 'KO',
        ---Add comment on the line below
        below = 'Ko',
        ---Add comment at the end of line
        eol = 'KA',
    },
}

vim.api.nvim_set_keymap('n', 'KD', '<ESC><CMD>lua require("custom_plugins.lines").yank_comment_paste()<CR>', opt)
vim.api.nvim_set_keymap('x', 'gkd', '<ESC><CMD>lua require("custom_plugins.lines").yank_comment_paste(vim.fn.visualmode())<CR>', opt)

-- function _G.___gcd(vmode)
--   lua require("custom_plugins.lines").yank_comment_paste()
-- end
-- A.nvim_set_keymap('n', 'gy', '<CMD>set operatorfunc=v:lua.___gdc<CR>g@', opt)

