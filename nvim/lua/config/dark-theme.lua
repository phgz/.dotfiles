local colors = require("gruvbox-baby.colors").config()

vim.g.gruvbox_baby_transparent_mode = 1
-- vim.g.gruvbox_baby_telescope_theme = 1
-- func local asadfad avc = @424r
vim.g.gruvbox_baby_highlights = {
  DiagnosticUnderlineHint = {style = "undercurl", bg = "None",  sp = colors.forest_green},
  DiagnosticUnderlineWarn = {style = "undercurl", bg = "None",  sp = colors.soft_yellow},
  DiagnosticUnderlineInfo = {style = "undercurl", bg = "None",  sp = colors.light_blue},
  DiagnosticUnderlineError = {style = "undercurl", bg = "None", sp = colors.red},

  DiagnosticLineNrHint  = {style = "bold", bg = "None", fg = colors.forest_green},
  DiagnosticLineNrWarn  = {style = "bold", bg = "None", fg = colors.soft_yellow},
  DiagnosticLineNrInfo  = {style = "bold", bg = "None", fg = colors.light_blue},
  DiagnosticLineNrError = {style = "bold", bg = "None", fg = colors.red},

  DiagnosticHint  = {bg = "None", fg = colors.forest_green},
  DiagnosticWarn  = {bg = "None", fg = colors.soft_yellow},
  DiagnosticInfo  = {bg = "None", fg = colors.light_blue},
  DiagnosticError = {bg = "None", fg = colors.red},

  GitSignsDelete = {bg = "None", fg = colors.red},

  EndOfBuffer = { fg = colors.medium_gray },

  MatchParen = { bg = colors.medium_gray},
}
vim.api.nvim_exec([[
colorscheme gruvbox-baby

highlight RedStatusLine guifg=#fb4934 guibg=#504945
highlight GreenStatusLine guifg=#689d6a guibg=#504945
highlight BlueStatusLine guifg=#eebd35 guibg=#504945
highlight TurquoiseStatusLine guifg=turquoise guibg=#504945
highlight MagentaStatusLine guifg=magenta guibg=#504945
highlight GreyStatusLine guifg=grey guibg=#504945
]], false)

 --highlight link LspSignatureActiveParameter GreenItalic

 --highlight! link TSKeywordFunction RedItalic
 --highlight! link TSKeyword RedItalic
 --highlight! link TSConditional RedItalic
 --highlight! link TSRepeat RedItalic
 --highlight! link TSString Green
 --highlight! link TSInclude PreProc
 --highlight! link TSField Blue
 --highlight! link TSFuncBuiltin Yellow
 --highlight! link TSFunction AquaBold
 --highlight! link TSMethod Aqua
