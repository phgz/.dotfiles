return {
	"sainnhe/gruvbox-material",
	enabled = false,
	config = function()
		-- GRUVBOX_MATERIAL
		vim.g.gruvbox_material_sign_column_background = "none"
		vim.g.gruvbox_material_better_performance = 1
		vim.g.gruvbox_material_show_eob = 0
		vim.g.gruvbox_material_transparent_background = 1
		vim.g.gruvbox_material_enable_bold = 1
		vim.g.gruvbox_material_enable_italic = 1
		vim.g.gruvbox_material_menu_selection_background = "orange"
		vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
		vim.g.gruvbox_material_palette = "original"

		-- Change search hl to orange instead of red
		vim.cmd([[
hi clear
set background=dark
colorscheme gruvbox-material
call gruvbox_material#highlight('IncSearch', ['#282828',   '235'], ['#fe8019',   '208'])
highlight StatusLine guibg=#413c37
highlight RedStatusLine guifg=#fb4934 guibg=#413c37
highlight GreenStatusLine guifg=#afaf00 guibg=#413c37
highlight BlueStatusLine guifg=#87afaf guibg=#413c37
highlight TurquoiseStatusLine guifg=turquoise guibg=#413c37
highlight MagentaStatusLine guifg=magenta guibg=#413c37
highlight GreyStatusLine guifg=grey guibg=#413c37

highlight link DiagnosticLineNrError RedBold
highlight link DiagnosticLineNrWarn YellowBold
highlight link DiagnosticLineNrInfo BlueBold
highlight link DiagnosticLineNrHint GreenBold

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
]])
	end,
}
