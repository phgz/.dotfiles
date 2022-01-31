vim.api.nvim_exec([[
highlight! link pythonNone Blue
highlight! link pythonExceptions Yellow
highlight! link pythonExClass Green
highlight! link pythonBuiltin White
highlight! link pythonDecoratorName Aqua
]], false)

vim.bo.shiftwidth = 4
vim.bo.tabstop = 4
vim.bo.softtabstop = 4
vim.bo.expandtab = true
vim.bo.textwidth = 0
vim.bo.autoindent = true
vim.bo.smartindent = true
