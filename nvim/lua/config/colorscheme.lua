local utils = require('utils')
utils.opt('o', 'termguicolors', true)

vim.o.background = "dark"    -- Setting dark mode

-- GRUVBOX_MATERIAL
-- vim.g.gruvbox_material_background = 'medium'
vim.g.gruvbox_material_sign_column_background = 'none'
vim.g.gruvbox_material_better_performance = 1
vim.g.gruvbox_material_show_eob = 0
vim.g.gruvbox_material_transparent_background = 1
vim.g.gruvbox_material_enable_bold = 1
vim.g.gruvbox_material_enable_italic = 1
vim.g.gruvbox_material_menu_selection_background = 'orange'
vim.g.gruvbox_material_diagnostic_virtual_text = 'colored'
vim.g.gruvbox_material_palette = 'original'

-- Change search hl to orange instead of red 
vim.api.nvim_exec([[
colorscheme gruvbox-material
call gruvbox_material#highlight('IncSearch', ['#282828',   '235'], ['#fe8019',   '208'])
]], false)
