-- GRUVBOX_MATERIAL
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
set background=dark
colorscheme gruvbox-material
call gruvbox_material#highlight('IncSearch', ['#282828',   '235'], ['#fe8019',   '208'])
highlight RedStatusLine guifg=#fb4934 guibg=#32302f
highlight GreenStatusLine guifg=#afaf00 guibg=#32302f
highlight BlueStatusLine guifg=#87afaf guibg=#32302f
highlight TurquoiseStatusLine guifg=turquoise guibg=#32302f
highlight MagentaStatusLine guifg=magenta guibg=#32302f
highlight GreyStatusLine guifg=grey guibg=#32302f

highlight link LspDiagnosticsLineNrError RedBold
highlight link LspDiagnosticsLineNrWarning YellowBold
highlight link LspDiagnosticsLineNrInformation BlueBold
highlight link LspDiagnosticsLineNrHint GreenBold

highlight link LspSignatureActiveParameter GreenItalic

highlight! link TSKeywordFunction RedItalic
highlight! link TSKeyword RedItalic
highlight! link TSConditional RedItalic
highlight! link TSRepeat RedItalic
highlight! link TSString Green
highlight! link TSInclude PreProc
highlight! link TSField Blue
highlight! link TSFuncBuiltin Yellow
highlight! link TSFunction AquaBold
highlight! link TSMethod Aqua
]], false)
