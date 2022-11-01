require("noice").setup({
  notify = {
    enabled = false,
  },
  lsp = {
    progress = {
      enabled = false,
    },
    override = {
      -- override the default lsp markdown formatter with Noice
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      -- override the lsp markdown formatter with Noice
      ["vim.lsp.util.stylize_markdown"] = true,
    },
    documentation = {
      view = "hover",
      opts = {
        lang = "markdown",
        replace = true,
        render = "plain",
        format = { "{message}" },
        win_options = { concealcursor = "n", conceallevel = 3 },
      },
    },
  },
  presets = {
    lsp_doc_border = true
  },
  routes = {
    {
      filter = {
        event = "msg_show",
        ["not"] = {
          kind = { "confirm", "confirm_sub" },
        },
      },
      opts = { skip = true },
    },
  },
})
