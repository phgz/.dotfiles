local function signature_help(client, bufnr)
  local trigger_chars = client.server_capabilities.signatureHelpProvider.triggerCharacters
  for _, char in ipairs(trigger_chars) do
    vim.keymap.set("i", char, function()
      vim.defer_fn(function()
        pcall(vim.lsp.buf.signature_help)
      end, 0)
      return char
    end, {
        buffer = bufnr,
        noremap = true,
        silent = true,
        expr = true,
      })
  end
end

local on_attach = function(client, bufnr)

  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local buf_keymap = vim.api.nvim_buf_set_keymap
  local keymap = vim.api.nvim_set_keymap
  local opts = {noremap = true, silent = true}
  buf_keymap(bufnr, 'n', '<leader>j', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_keymap(bufnr, 'n', '<localleader>m', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_keymap(bufnr, 'n', 'h', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  keymap('n', 'l', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)

  -- Set hightlights conditional on server_capabilities
  -- if client.resolved_capabilities.document_highlight then

  local sign_define = vim.fn.sign_define
  sign_define("DiagnosticSignError", {texthl="DiagnosticSignError", numhl="DiagnosticLineNrError"})
  sign_define("DiagnosticSignWarn", {texthl="DiagnosticSignWarn", numhl="DiagnosticLineNrWarn"})
  sign_define("DiagnosticSignInfo", {texthl="DiagnosticSignInfo", numhl="DiagnosticLineNrInfo"})
  sign_define("DiagnosticSignHint", {texthl="DiagnosticSignHint", numhl="DiagnosticLineNrHint"})
  -- end
  if client.server_capabilities.signatureHelpProvider then
    signature_help(client, bufnr)
  end
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

vim.diagnostic.config(lsp_config.diagnostic)
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, lsp_config.diagnostic.float)
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, lsp_config.diagnostic.float)

local servers = {
  "pyright",
  "yamlls",
  "sumneko_lua",
  "dockerls",
  "vimls",
  "bashls"
}

require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = servers
})

local capabilities = vim.lsp.protocol.make_client_capabilities

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
