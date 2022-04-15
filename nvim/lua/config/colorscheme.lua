local utils = require('utils')
utils.opt('o', 'termguicolors', true)

local time_of_day = tonumber(os.date("%H"))


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

if time_of_day >= 8 and time_of_day < 20 then
  vim.o.background = light    -- Setting dark mode

  require("github-theme").setup({
    theme_style = "light",
    function_style = "italic",
    transparent = true,
    hide_end_of_buffer = false,

    -- Change the "hint" color to the "orange" color, and make the "error" color bright red
    colors = {hint = "orange", error = "#ff0000"},

    -- Overwrite the highlight groups
    -- overrides = function(c)
    --   return {
    --     htmlTag = {fg = c.red, bg = "#282c34", sp = c.hint, style = "underline"},
    --     DiagnosticHint = {link = "LspDiagnosticsDefaultHint"},
    --     -- this will remove the highlight groups
    --     TSField = {},
    --   }
    -- end
  })

else
  vim.o.background = dark    -- Setting dark mode
  -- Change search hl to orange instead of red
  vim.api.nvim_exec([[
  colorscheme gruvbox-material
  call gruvbox_material#highlight('IncSearch', ['#282828',   '235'], ['#fe8019',   '208'])
  ]], false)
end
