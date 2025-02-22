local api = vim.api
local fn = vim.fn
local keymap = vim.keymap

require("mason").setup({ ui = { keymaps = { uninstall_package = "x" } } })

local servers = {
	"bashls",
	"dockerls",
	"jsonls",
	"lua_ls",
	"pyright",
	"taplo",
	"vimls",
	"yamlls",
	"denols",
	-- "azure_pipelines_ls",
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

require("mason-lspconfig").setup({ ensure_installed = servers })

local get_venv = function(lock_file_path)
	local project_root = vim.fs.dirname(lock_file_path)
	local tool = vim.startswith(vim.fs.basename(lock_file_path), "uv") and "uv" or "poetry"

	if tool == "uv" then
		return project_root .. "/.venv"
	end

	return require("plenary.job")
		:new({
			command = os.getenv("HOME") .. "/.miniconda3/bin/python3.12",
			args = {
				"-c",
				[[import base64, hashlib, pathlib, tomllib; h = base64.urlsafe_b64encode(hashlib.sha256(bytes(pathlib.Path.cwd())).digest()).decode()[:8]; p = tomllib.load(open("pyproject.toml", "rb"))["tool"]["poetry"]["name"].replace(".", "-").replace("_", "-"); cache = ".cache" if "$(uname -s)" == "Linux" else "Library/Caches"; virtualenvs = (pathlib.Path.home() / cache / "pypoetry/virtualenvs").iterdir(); env_name = next(dir for dir in virtualenvs if str(dir.name).startswith(p + "-" + h)); print(env_name)
]],
			},
			cwd = project_root,
			env = { ["PATH"] = vim.env.PATH },
		})
		:sync()[1]
end

local on_attach = function(client, bufnr)
	-- Enable completion triggered by <c-x><c-o>
	vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

	-- Mappings.

	local opts = { buffer = bufnr, silent = true }

	if client.server_capabilities.documentSymbolProvider then
		local navic = require("nvim-navic")
		local navic_lib = require("nvim-navic.lib")

		keymap.set("n", "<leader>w", function()
			if navic.is_available() then
				navic_lib.update_context(bufnr)
				vim.notify(navic.get_location())
			end
			vim.wo.statusline = vim.wo.statusline
		end, opts)

		navic.attach(client, bufnr)

		local navic_cursor_autocmds =
			api.nvim_get_autocmds({ group = "navic", event = { "CursorHold", "CursorMoved" } })
		api.nvim_del_autocmd(navic_cursor_autocmds[2].id)
		api.nvim_del_autocmd(navic_cursor_autocmds[3].id)
	end

	local function on_list(options)
		fn.setqflist({}, " ", options)
		vim.cmd("silent cfirst")
	end

	keymap.set("n", "<leader>j", function()
		vim.lsp.buf.definition({ on_list = on_list })
	end, opts)
	keymap.set("n", "<localleader>h", function()
		vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
	end, opts)
	keymap.set("n", "<localleader>r", vim.lsp.buf.rename)
	keymap.set("n", "H", function()
		local captures = vim.treesitter.get_captures_at_cursor()
		if vim.list_contains(captures, "function.call") or vim.list_contains(captures, "function.method.call") then
			vim.lsp.buf.hover()
		else
			vim.lsp.buf.signature_help()
		end
	end, opts)
end

local lsp_config = {
	diagnostic = {
		virtual_text = false, -- is false by default
		underline = true,
		update_in_insert = false,
		severity_sort = true,
		virtual_lines = false,
		signs = {
			text = {
				[vim.diagnostic.severity.WARN] = "",
				[vim.diagnostic.severity.INFO] = "",
				[vim.diagnostic.severity.HINT] = "",
				[vim.diagnostic.severity.ERROR] = "",
			},
			numhl = {
				[vim.diagnostic.severity.ERROR] = "DiagnosticLineNrError",
				[vim.diagnostic.severity.WARN] = "DiagnosticLineNrWarn",
				[vim.diagnostic.severity.INFO] = "DiagnosticLineNrInfo",
				[vim.diagnostic.severity.HINT] = "DiagnosticLineNrHint",
			},
		},
		float = {
			focusable = true,
			style = "minimal",
			border = "none",
			winblend = 30,
		},
	},
}

keymap.set("n", "L", vim.diagnostic.open_float, { silent = true })
vim.diagnostic.config(lsp_config.diagnostic)

-- local capabilities = vim.lsp.protocol.make_client_capabilities
local capabilities = require("ddc_source_lsp").make_client_capabilities
require("mason-lspconfig").setup_handlers({
	function(server_name) -- default handler
		require("lspconfig")[server_name].setup({ on_attach = on_attach, capabilities = capabilities() })
	end,
	["pyright"] = function()
		require("lspconfig").pyright.setup({
			on_attach = on_attach,
			capabilities = capabilities(),
			before_init = function(_, config)
				if not vim.env.VIRTUAL_ENV then
					local find_lock_file = function(path)
						return vim.fs.find(
							{ "uv.lock", "poetry.lock" },
							{ upward = true, path = path, type = "file", stop = vim.env.HOME }
						)[1]
					end
					local lock_file_path = find_lock_file(fn.expand("%:p:h"))
					if lock_file_path ~= nil then
						local venv_path = get_venv(lock_file_path)
						vim.env.VIRTUAL_ENV = venv_path
						config.settings.python.pythonPath = vim.env.VIRTUAL_ENV .. "/bin/python3"
						api.nvim_create_autocmd("BufEnter", {
							callback = function(event_args)
								if event_args.file ~= "" then
									local new_lock_file_path = find_lock_file(event_args.file)
									if new_lock_file_path ~= lock_file_path then
										vim.env.VIRTUAL_ENV = nil
										vim.cmd("LspRestart")
										return true --return a truthy value (not false or nil) to delete the autocommand.
									end
								end
							end,
						})
					end
				end
			end,
		})
	end,

	["lua_ls"] = function()
		require("lspconfig").lua_ls.setup({
			on_attach = on_attach,
			capabilities = capabilities(),
			settings = {
				Lua = {
					telemetry = {
						enable = false,
					},
					semantic = { enable = false },
					hint = {
						enable = true,
					},
					workspace = {
						checkThirdParty = false,
						library = {
							vim.fn.expand("$VIMRUNTIME/lua"),
							vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
						},
					},
				},
			},
		})
	end,
})
