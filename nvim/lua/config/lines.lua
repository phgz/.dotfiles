vim.keymap.set('n', 'q', function() require("custom_plugins.lines").after_sep(true) end, {silent = true})
vim.keymap.set('n', 'gq', function() require("custom_plugins.lines").after_sep(false) end, {silent = true})
