local utils = require ('utils')

utils.map('n', '<localLeader>f', '<cmd>Telescope git_files<cr>')
utils.map('n', '<localLeader>g', '<cmd>Telescope live_grep<cr>')
utils.map('n', '<localLeader>b', '<cmd>Telescope buffers<cr>')
utils.map('n', '<localLeader>s', '<cmd>Telescope treesitter<CR>')
