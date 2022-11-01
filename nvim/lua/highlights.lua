vim.api.nvim_exec([[
hi! link PopupPreviewDocument Pmenu
hi! link PopupPreviewBorder Pmenu
hi NormalFloat guibg=None
hi ErrorFloat guibg=None
hi WarningFloat guibg=None
hi InfoFloat guibg=None
hi HintFloat guibg=None
hi FloatBorder guibg=None

hi def RedStatusLine none
hi def GreenStatusLine none
hi def BlueStatusLine none
hi def TurquoiseStatusLine none
hi def MagentaStatusLine none
hi def GreyStatusLine none
]], false)
