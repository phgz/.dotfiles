vim.api.nvim_exec([[
hi NormalFloat guibg=None
hi ErrorFloat guibg=None
hi WarningFloat guibg=None
hi InfoFloat guibg=None
hi HintFloat guibg=None

hi def RedStatusLine guifg=Red guibg=#32302f
hi def GreenStatusLine guifg=Green guibg=#32302f
hi def BlueStatusLine guifg=Blue guibg=#32302f
hi def PurpleStatusLine guifg=turquoise guibg=#32302f
]], false)

--hi! link Pmenu NormalFloat
