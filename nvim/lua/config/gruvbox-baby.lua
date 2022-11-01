local colors = require("gruvbox-baby.colors").config()

vim.g.gruvbox_baby_transparent_mode = 1
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

  LspSignatureActiveParameter = {style = "italic", fg = colors.soft_green},

  GitSignsDelete = {bg = "None", fg = colors.red},
  GitSignsAdd = {bg = "None", fg = colors.forest_green},
  GitSignsChange = {bg = "None", fg = colors.soft_yellow},

  EndOfBuffer = { fg = colors.medium_gray },

  MatchParen = { bg = colors.medium_gray},

  StatusLine = { fg = colors.foreground, bg = "#413c37" },
}
vim.api.nvim_exec([[
colorscheme default
colorscheme gruvbox-baby

highlight RedStatusLine guifg=#fb4934 guibg=#413c37
highlight GreenStatusLine guifg=#689d6a guibg=#413c37
highlight BlueStatusLine guifg=#eebd35 guibg=#413c37
highlight TurquoiseStatusLine guifg=turquoise guibg=#413c37
highlight MagentaStatusLine guifg=magenta guibg=#413c37
highlight GreyStatusLine guifg=grey guibg=#413c37
luafile $HOME/.dotfiles/nvim/lua/highlights.lua
]], false)
