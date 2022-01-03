vim.g.gitgutter_map_keys = 0
vim.g.gitgutter_close_preview_on_escape = 1
vim.g.gitgutter_preview_win_border = 'rounded'

utils.map('n', 'gr', '<cmd>GitGutterUndoHunk<cr>')
utils.map('n', 'gd', '<cmd>GitGutterPreviewHunk<cr>')
