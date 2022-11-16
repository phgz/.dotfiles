require("noice").setup({
  popupmenu = {
    enabled = false, -- enables the Noice popupmenu UI
  },
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
