local call = vim.api.nvim_call_function

local get_poetry_venv = function(project_root)
	return require("plenary.job")
		:new({
			command = "python",
			args = {
				"-c",
				[[import base64, hashlib, pathlib, tomllib; h = base64.urlsafe_b64encode(hashlib.sha256(bytes(pathlib.Path.cwd())).digest()).decode()[:8]; p=tomllib.load(open('pyproject.toml', 'rb'))['tool']['poetry']['name'].replace('.','-').replace('_', '-'); print(next(dir for dir in (pathlib.Path.home() / '.cache/pypoetry/virtualenvs').iterdir() if str(dir.name).startswith(p+'-'+h)))]],
			},
			cwd = project_root,
			env = { ["PATH"] = vim.env.PATH },
		})
		:sync()[1]
end

local on_attach = function(client, bufnr)
	-- Enable completion triggered by <c-x><c-o>
	vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

	local function on_list(options)
		vim.fn.setqflist({}, " ", options)
		vim.cmd("silent cfirst")
	end

	-- Mappings.

	local opts = { buffer = bufnr, noremap = true, silent = true }
	vim.keymap.set("n", "<leader>j", function()
		vim.lsp.buf.definition({ on_list = on_list })
	end, opts)
	vim.keymap.set("n", "h", function()
		local captures = vim.treesitter.get_captures_at_cursor()
		if vim.tbl_contains(captures, "function.call") or vim.tbl_contains(captures, "method.call") then
			return vim.lsp.buf.hover()
		else
			return vim.lsp.buf.signature_help()
		end
	end, opts)

	call("sign_define", {
		{
			{
				name = "DiagnosticSignError",
				texthl = "DiagnosticSignError",
				numhl = "DiagnosticLineNrError",
				culhl = "DiagnosticLineNrWarn",
			},
			{ name = "DiagnosticSignWarn", texthl = "DiagnosticSignWarn", numhl = "DiagnosticLineNrWarn" },
			{ name = "DiagnosticSignInfo", texthl = "DiagnosticSignInfo", numhl = "DiagnosticLineNrInfo" },
			{ name = "DiagnosticSignHint", texthl = "DiagnosticSignHint", numhl = "DiagnosticLineNrHint" },
		},
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
			border = "none",
			winblend = 30,
		},
	},
}

local servers = {
	"bashls",
	"dockerls",
	"jsonls",
	"sumneko_lua",
	"pyright",
	"taplo",
	"vimls",
	"yamlls",
	"denols",
}

local formatters = {
	"black",
	"isort",
	"prettier",
	"shfmt",
	"stylua",
	"yamlfmt",
}

local linters = {
	"shellcheck",
}

local capabilities = vim.lsp.protocol.make_client_capabilities

vim.keymap.set("n", "l", vim.diagnostic.open_float, { noremap = true, silent = true })
vim.diagnostic.config(lsp_config.diagnostic)

-- vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, lsp_config.diagnostic.float)
-- vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, lsp_config.diagnostic.float)

require("mason").setup({
	ui = {
		keymaps = {
			uninstall_package = "x",
		},
	},
})
require("mason-lspconfig").setup({
	ensure_installed = servers,
})

require("mason-lspconfig").setup_handlers({
	function(server_name) -- default handler
		require("lspconfig")[server_name].setup({ on_attach = on_attach, capabilities = capabilities() })
	end,

	["pyright"] = function()
		require("lspconfig").pyright.setup({
			on_attach = on_attach,
			capabilities = capabilities(),
			before_init = function(_, config)
				local venv = vim.env.VIRTUAL_ENV

				if not venv then
					local is_poetry = vim.fs.find({ "poetry.lock" }, { upward = true, path = config.root_dir })[1]
						~= nil

					if is_poetry then
						local venv_path = get_poetry_venv(config.root_dir)
						vim.env.VIRTUAL_ENV = venv_path
						config.settings.python.pythonPath =
							require("lspconfig.util").path.join(vim.env.VIRTUAL_ENV, "bin", "python3")
					end
				end
			end,
		})
	end,

	["sumneko_lua"] = function()
		require("lspconfig").sumneko_lua.setup({
			on_attach = on_attach,
			capabilities = capabilities(),
			settings = {
				Lua = {
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
							[call("expand", { "$VIMRUNTIME/lua" })] = true,
							[call("expand", { "$VIMRUNTIME/lua/vim/lsp" })] = true,
						},
						checkThirdParty = false,
					},
				},
			},
		})
	end,
})
