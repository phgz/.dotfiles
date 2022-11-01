local hop = require("hop")

require('hop').setup{}

vim.keymap.set('', '<left>', function() hop.hint_char1 { direction = require'hop.hint'.HintDirection.BEFORE_CURSOR } end)
vim.keymap.set('', '<right>', function() hop.hint_char1 { direction = require'hop.hint'.HintDirection.AFTER_CURSOR } end)
vim.keymap.set('', '<down>', hop.hint_vertical)
vim.keymap.set('', '<up>', hop.hint_patterns)
