local utils = require('utils')

require('hop').setup{}

utils.map('n', '<M-f>', '<cmd>HopChar2<cr>')
utils.map('n', '<M-S-f>', '<cmd>HopPattern<cr>')
