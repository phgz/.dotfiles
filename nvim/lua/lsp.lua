local on_attach = function(client, bufnr)

    local function buf_set_option(...)
        vim.api.nvim_buf_set_option(bufnr, ...)
    end

    -- Enable completion triggered by <c-x><c-o>
    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

    local function buf_set_keymap(...)
        vim.api.nvim_buf_set_keymap(bufnr, ...)
    end

    -- Mappings.
    local opts = {noremap = true, silent = true}
    buf_set_keymap('n', '<leader>j', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'h', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    buf_set_keymap('n', 'l', '<cmd>lua vim.diagnostic.open_float({ border = "rounded" })<CR>', opts)

    -- Set hightlights conditional on server_capabilities
    -- if client.resolved_capabilities.document_highlight then
        vim.api.nvim_exec([[
        highlight link LspDiagnosticsLineNrError RedBold
        highlight link LspDiagnosticsLineNrWarning YellowBold
        highlight link LspDiagnosticsLineNrInformation BlueBold
        highlight link LspDiagnosticsLineNrHint GreenBold

        highlight link LspSignatureActiveParameter GreenItalic
            ]], false)

        local sign_define = vim.fn.sign_define
        sign_define("DiagnosticSignError", {texthl="LspDiagnosticsSignError", numhl="LspDiagnosticsLineNrError"})
        sign_define("DiagnosticSignWarn", {texthl="LspDiagnosticsSignWarning", numhl="LspDiagnosticsLineNrWarning"})
        sign_define("DiagnosticSignInfo", {texthl="LspDiagnosticsSignInformation", numhl="LspDiagnosticsLineNrInformation"})
        sign_define("DiagnosticSignHint", {texthl="LspDiagnosticsSignHint", numhl="LspDiagnosticsLineNrHint"})
    -- end
end

local function goto_definition(split_cmd)
    local util = vim.lsp.util
    local log = require("vim.lsp.log")
    local api = vim.api

    -- note, this handler style is for neovim 0.5.1/0.6
    local handler = function(_, result, ctx)
        if result == nil or vim.tbl_isempty(result) then
            local _ = log.info() and log.info(ctx.method, "No location found")
            return nil
        end

        if split_cmd then
            vim.cmd(split_cmd)
        end

        if vim.tbl_islist(result) then
            util.jump_to_location(result[1])

            if #result > 1 then
                util.set_qflist(util.locations_to_items(result))
                api.nvim_command("copen")
                api.nvim_command("wincmd p")
            end
        else
            util.jump_to_location(result)
        end
    end

    return handler
end

vim.lsp.handlers["textDocument/definition"] = goto_definition('vsplit')

vim.lsp.handlers["textDocument/publishDiagnostics"] =
    vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = false,
        underline = true,
        signs = true,
        update_in_insert = true
    })

-- capabilities = vim.lsp.protocol.make_client_capabilities()
local lsp_installer = require("nvim-lsp-installer")

local servers = {
  "bashls",
  "pyright",
  "yamlls",
  "sumneko_lua",
  "dockerls",
  "vimls"
}

for _, name in pairs(servers) do
  local server_is_found, server = lsp_installer.get_server(name)
  if server_is_found and not server:is_installed() then
    print("Installing " .. name)
    server:install()
  end
end


-- local enhance_server_opts = {
  -- Provide settings that should only apply to the "pyright" server
  -- ["pyright"] = function(opts)
  --   opts.settings = {
  --     format = {
  --       enable = true,
  --     },
  --   }
  -- end,
-- }

lsp_installer.on_server_ready(function(server)
  -- Specify the default options which we'll use to setup all servers
  local opts = {
    on_attach = on_attach,
  }

  -- if enhance_server_opts[server.name] then
  --   -- Enhance the default opts with the server-specific ones
  --   enhance_server_opts[server.name](opts)
  -- end

  server:setup(opts)
end)
