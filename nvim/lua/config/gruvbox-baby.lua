-- GRUVBOX_MATERIAL
vim.g.gruvbox_baby_transparent_mode = 1
-- vim.g.gruvbox_baby_telescope_theme = 1

vim.g.gruvbox_baby_highlights = {DiagnosticUnderlineHint = {style = "undercurl", bg = "None"}}
-- Change search hl to orange instead of red
vim.api.nvim_exec([[
set background=dark
colorscheme gruvbox-baby

highlight RedStatusLine guifg=#fb4934 guibg=#504945
highlight GreenStatusLine guifg=#afaf00 guibg=#504945
highlight BlueStatusLine guifg=#87afaf guibg=#504945
highlight TurquoiseStatusLine guifg=turquoise guibg=#504945
highlight MagentaStatusLine guifg=magenta guibg=#504945
highlight GreyStatusLine guifg=grey guibg=#504945

highlight link DiagnosticLineNrError DiagnosticError
highlight link DiagnosticLineNrWarn DiagnosticWarn
highlight link DiagnosticLineNrInfo DiagnosticInfo
highlight link DiagnosticLineNrHint DiagnosticHint

highlight link LspSignatureActiveParameter GreenItalic

" highlight! link TSKeywordFunction RedItalic
" highlight! link TSKeyword RedItalic
" highlight! link TSConditional RedItalic
" highlight! link TSRepeat RedItalic
" highlight! link TSString Green
" highlight! link TSInclude PreProc
" highlight! link TSField Blue
" highlight! link TSFuncBuiltin Yellow
" highlight! link TSFunction AquaBold
" highlight! link TSMethod Aqua

]], false)
