M = {}

local theme = require("gruvbox-baby.theme")
local colors = require("gruvbox-baby.colors").config()

-- func local asadfad avc = @424r

local config = {
  background_color = "medium",
  comment_style = "italic",
  keyword_style = "italic",
  function_style = "bold",
  string_style = "nocombine",
  variable_style = "NONE",
  color_overrides = {},
  telescope_theme = false,
  use_original_palette = false,
  transparent_mode = true,
  highlights = {
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

    Substitute = { bg = colors.diff.text },

    StatusLine = { fg = colors.foreground, bg = "#413c37" },

    NormalFloat  = {bg = "None"},
    ErrorFloat   = {bg = "None"},
    WarningFloat = {bg = "None"},
    InfoFloat    = {bg = "None"},
    HintFloat    = {bg = "None"},
    FloatBorder = {bg = "None"},

    PopupPreviewDocument = { fg = colors.foreground, bg = colors.background_light },
    PopupPreviewBorder = { fg = colors.foreground, bg = colors.background_light },

    RedStatusLine       = {fg = colors.red, bg = "#413c37"  },
    GreenStatusLine     = {fg = colors.forest_green, bg = "#413c37"  },
    BlueStatusLine      = {fg = colors.soft_yellow, bg = "#413c37"  },
    GreyStatusLine      = {fg = "grey", bg = "#413c37"     },

    TelescopeBorder = { fg = colors.background_dark, bg = colors.background_dark },
    TelescopePromptCounter = { fg = colors.milk, bg = colors.medium_gray },
    TelescopePromptBorder = { fg = colors.medium_gray, bg = colors.medium_gray },
    TelescopePromptNormal = { fg = colors.milk, bg = colors.medium_gray },
    TelescopePromptPrefix = { fg = colors.soft_yellow, bg = colors.medium_gray },

    TelescopeNormal = { bg = colors.background_dark },

    TelescopePreviewTitle = { fg = colors.background, bg = colors.forest_green },
    TelescopePreviewMatch = { fg = colors.background_dark, bg = colors.milk },
    TelescopePromptTitle = { fg = colors.background, bg = colors.soft_yellow },
    TelescopeResultsTitle = { fg = colors.background_dark, bg = colors.milk },

    TelescopeSelection = { bg = colors.diff.change },
    TelescopeMultiSelection = { fg = colors.soft_yellow },

    IlluminatedWordText = { style = 'bold' },
    IlluminatedWordRead = { style = 'bold' },
    IlluminatedWordWrite= { style = 'bold' },
  }
}

M.theme = theme.setup(config)

return M
