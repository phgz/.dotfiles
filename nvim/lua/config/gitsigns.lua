require('gitsigns').setup {
    signs = {
        add          = {hl = 'GitSignsAdd'   , text = '│', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'},
        change       = {hl = 'GitSignsChange', text = '│', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
        delete       = {show_count = true, hl = 'GitSignsDelete', text = '_', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
        topdelete    = {show_count = true,hl = 'GitSignsDelete', text = '‾', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
        changedelete = {show_count = true,hl = 'GitSignsChange', text = '~', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
    },
    count_chars = {
        [1]   = '',
        [2]   = '₂',
        [3]   = '₃',
        [4]   = '₄',
        [5]   = '₅',
        [6]   = '₆',
        [7]   = '₇',
        [8]   = '₈',
        [9]   = '₉',
        ['+'] = '₊',
    },
    signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
    numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
    linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
    word_diff  = true, -- Toggle with `:Gitsigns toggle_word_diff`
    keymaps = {
        -- Default keymap options
        noremap = true,


        ['n gr'] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
        ['v gr'] = '<cmd>lua require"gitsigns".reset_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
        ['n gd'] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',
        ['n gb'] = '<cmd>lua require"gitsigns".blame_line(true)<CR>',
        ['n gw'] = '<cmd>Gitsigns toggle_word_diff<CR>',

        -- Text objects

        ['o ih'] = ':<C-U>lua require"gitsigns".select_hunk()<CR>',
        ['x ih'] = ':<C-U>lua require"gitsigns".select_hunk()<CR>',
        ['o ah'] = ':<C-U>lua require"gitsigns".select_hunk()<CR>',
        ['x ah'] = ':<C-U>lua require"gitsigns".select_hunk()<CR>'
    },
    preview_config = {
        -- Options passed to nvim_open_win
        border = 'rounded',
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1,
    },
}
