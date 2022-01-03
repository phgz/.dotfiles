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
    buf_set_keymap('n', '<leader>l', '<cmd>Trouble lsp_document_diagnostics<CR>', opts)
    buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
    buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)

    -- Set hightlights conditional on server_capabilities
    if client.resolved_capabilities.document_highlight then
        vim.api.nvim_exec([[
        highlight link LspDiagnosticsLineNrError RedBold
        highlight link LspDiagnosticsLineNrWarning YellowBold
        highlight link LspDiagnosticsLineNrInformation BlueBold
        highlight link LspDiagnosticsLineNrHint GreenBold

        highlight link LspSignatureActiveParameter GreenItalic

        sign define DiagnosticSignError text= texthl=LspDiagnosticsSignError linehl= numhl=LspDiagnosticsLineNrError
        sign define DiagnosticSignWarn text= texthl=LspDiagnosticsSignWarning linehl= numhl=LspDiagnosticsLineNrWarning
        sign define DiagnosticSignInfo text= texthl=LspDiagnosticsSignInformation linehl= numhl=LspDiagnosticsLineNrInformation
        sign define DiagnosticSignHint text= texthl=LspDiagnosticsSignHint linehl= numhl=LspDiagnosticsLineNrHint
            ]], false)
    end
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

local nvim_lsp = require('lspconfig')

--python
local bin_name = os.getenv( "HOME" ) .. '/.miniconda3/envs/neovim/bin/pyright-langserver'
nvim_lsp["pyright"].setup{on_attach = on_attach, cmd = {bin_name, "--stdio"}}
