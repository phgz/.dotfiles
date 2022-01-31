local utils = require("utils")

require('gitsigns').setup {
  signs = {
    add = {hl = 'GitSignsAdd', text = '│', numhl='GitSignsAddNr', linehl='GitSignsAddLn'},
    change = {hl = 'GitSignsChange', text = '│', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
    delete = {show_count = true, hl = 'GitSignsDelete', text = '_', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
    topdelete = {show_count = true,hl = 'GitSignsDelete', text = '‾', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
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
  word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Actions
    map({'n', 'v'}, 'gr', gs.reset_hunk)
    map('n', 'gR', gs.reset_buffer)
    map('n', 'gd', gs.preview_hunk)
    map('n', 'gb', function() gs.blame_line{full=true} end)

    -- Text objects
     map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
     map({'o', 'x'}, 'ah', ':<C-U>Gitsigns select_hunk<CR>')
  end,
  status_formatter =function(status)
    local head = status.head
    local status_txt = {head}
    local added, changed, removed = status.added, status.changed, status.removed
    if added   and added   > 0 then table.insert(status_txt, '%#GreenStatusLine#+'..added) end
    if changed and changed > 0 then table.insert(status_txt, '%#BlueStatusLine#~'..changed) end
    if removed and removed > 0 then table.insert(status_txt, '%#RedStatusLine#-'..removed) end
    return table.concat(status_txt, ' ')
  end,
  preview_config = {
    -- Options passed to nvim_open_win
    border = 'rounded',
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1,
  },
}
