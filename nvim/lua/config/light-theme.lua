vim.cmd("colorscheme default")    -- Restore default values first
require("github-theme").setup({
  theme_style = "light",
  transparent = true,
  hide_end_of_buffer = true,
  dev = true,

  -- Change the "hint" color to the "orange" color, and make the "error" color bright red
  -- colors = {match_paren_bg = "orange", error = "#ff0000"},
  colors = {syntax = {match_paren_bg = "#babbbd"}},

  -- Overwrite the highlight groups
  overrides = function(c)
    return {
      --     htmlTag = {fg = c.red, bg = "#282c34", sp = c.hint, style = "underline"},
      StatusLine = {fg = c.blue, bg = "#babbbd"},
      Folded = {link = "Comment"},
      DiagnosticHint = {fg = c.green},
      DiagnosticLineNrError = {fg = c.error, style = "bold"},
      DiagnosticLineNrWarn = {fg = c.warning, style = "bold"},
      DiagnosticLineNrInfo = {fg = c.info, style = "bold"},
      DiagnosticLineNrHint = {fg = c.green, style = "bold"},
      DiagnosticUnderlineHint = {style = "undercurl", sp = c.green},
      RedStatusLine       = {fg = "#fb4934", bg = "#babbbd"  },
      GreenStatusLine     = {fg = c.bright_green, bg = "#babbbd"  },
      BlueStatusLine      = {fg = c.bright_blue, bg = "#babbbd"  },
      TurquoiseStatusLine = {fg = "turquoise", bg = "#babbbd"},
      MagentaStatusLine   = {fg = "magenta", bg = "#babbbd"  },
      GreyStatusLine      = {fg = "grey", bg = "#babbbd"     },
      LspSignatureActiveParameter = {fg = c.green, style = "italic"},
      --     -- this will remove the highlight groups
      --     TSField = {},
    }
  end
})

vim.cmd('luafile ' .. os.getenv( "HOME" ) .. '/.dotfiles/nvim/lua/highlights.lua')
