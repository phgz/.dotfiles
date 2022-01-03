local utils = require('utils')

utils.map('n', '<leader>s', '<cmd>lua require("custom_plugins.lines").swap()<cr>', {silent = true})

utils.map('n', '<leader>m', '<cmd>lua require("custom_plugins.lines").move()<cr>', {silent = true})
utils.map('x', '<leader>m', '<cmd>lua require("custom_plugins.lines").move("v")<cr>', {silent = true})
--
utils.map('n', '<leader>p', '<cmd>lua require("custom_plugins.lines").copy()<cr>', {silent = true})
utils.map('x', '<leader>p', '<cmd>lua require("custom_plugins.lines").copy("v")<cr>', {silent = true})
