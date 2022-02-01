vim.api.nvim_exec([[
hi NormalFloat guibg=None
hi ErrorFloat guibg=None
hi WarningFloat guibg=None
hi InfoFloat guibg=None
hi HintFloat guibg=None

hi def RedStatusLine guifg=#fb4934 guibg=#32302f
hi def GreenStatusLine guifg=#afaf00 guibg=#32302f
hi def BlueStatusLine guifg=#87afaf guibg=#32302f
hi def TurquoiseStatusLine guifg=turquoise guibg=#32302f
hi def MagentaStatusLine guifg=magenta guibg=#32302f
hi def GreyStatusLine guifg=grey guibg=#32302f
]], false)

--hi! link Pmenu NormalFloat
