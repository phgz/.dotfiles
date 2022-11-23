local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = {buffer = bufnr, noremap = true, silent = true}
  vim.keymap.set('n', '<leader>j', vim.lsp.buf.definition, opts)
	vim.keymap.set('n', 'h', function()
  local captures = vim.treesitter.get_captures_at_cursor()
  if vim.tbl_contains(captures, "function.call") or vim.tbl_contains(captures, "method.call") then
    return vim.lsp.buf.hover()
  else
    return vim.lsp.buf.signature_help()
  end
end, opts)

  local sign_define = vim.fn.sign_define
  sign_define({
  {name = "DiagnosticSignError", texthl="DiagnosticSignError", numhl="DiagnosticLineNrError", culhl="DiagnosticLineNrWarn"},
  {name = "DiagnosticSignWarn", texthl="DiagnosticSignWarn", numhl="DiagnosticLineNrWarn"},
  {name = "DiagnosticSignInfo", texthl="DiagnosticSignInfo", numhl="DiagnosticLineNrInfo"},
  {name = "DiagnosticSignHint", texthl="DiagnosticSignHint", numhl="DiagnosticLineNrHint"},
  })
end

local lsp_config = {
  diagnostic = {
    virtual_text = false,
    underline = true,
    update_in_insert = true,
    severity_sort = false,
    signs = true,
    float = {
      focusable = true,
      style = "minimal",
      border = "rounded",
    },
  },
}

local servers = {
  "bashls",
  "dockerls",
  "pyright",
  "sumneko_lua",
  "vimls",
  "yamlls",
}

local formatters = {
  "black",
  "isort"
}

local linters = {
  "shellcheck"
}

local capabilities = vim.lsp.protocol.make_client_capabilities

vim.keymap.set("n", "l", vim.diagnostic.open_float, {noremap=true, silent = true})
vim.diagnostic.config(lsp_config.diagnostic)

-- vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, lsp_config.diagnostic.float)
-- vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, lsp_config.diagnostic.float)

require("mason").setup({
    ui = {
        keymaps = {
          uninstall_package = "x",
        }
    }
})
require("mason-lspconfig").setup({
    ensure_installed = servers
})

require("mason-lspconfig").setup_handlers{
  function (server_name) -- default handler
    require("lspconfig")[server_name].setup {on_attach = on_attach, capabilities = capabilities()}
  end,

  ["sumneko_lua"] = function ()
    require("lspconfig").sumneko_lua.setup {
      on_attach = on_attach,
      capabilities = capabilities(),
      settings = {   Lua = {
        runtime = {
          -- Tell the language server which version of Lua we're using (most likely LuaJIT in the case of Neovim)
          version = "LuaJIT",
          -- Setup your lua path
          path = vim.split(package.path, ";"),
        },
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = { "vim" },
        },
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = {
            [vim.fn.expand "$VIMRUNTIME/lua"] = true,
            [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
          },
        },
      },
    }
  }
end,
}
