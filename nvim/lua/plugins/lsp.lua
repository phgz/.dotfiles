local api = vim.api
local fn = vim.fn
local keymap = vim.keymap
return {
	{
		"neovim/nvim-lspconfig",
		event = "BufReadPre",
		dependencies = {
			{
				"williamboman/mason.nvim",
				--  'WhoIsSethDaniel/mason-tool-installer.nvim'  -- Auto install tools like shellcheck
				opts = {
					ui = {
						keymaps = {
							uninstall_package = "x",
						},
					},
				},
			},
			{
				"williamboman/mason-lspconfig.nvim",
				build = function()
					local servers = {
						"bashls",
						"dockerls",
						"jsonls",
						"lua_ls",
						"pyright",
						-- "pylyzer",
						-- "ruff_lsp",
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

					require("mason-lspconfig").setup({
						ensure_installed = servers,
					})
				end,
				config = true,
			},
			{
				"folke/neodev.nvim",
				config = true,
			},
			{
				"SmiteshP/nvim-navic", -- Context in the status bar
			},
		}, -- LSP and completion
		config = function()
			local get_poetry_venv = function(project_root)
				return require("plenary.job")
					:new({
						command = "python3.11",
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
					if
						vim.list_contains(captures, "function.call")
						or vim.list_contains(captures, "function.method.call")
					then
						vim.lsp.buf.hover()
					else
						vim.lsp.buf.signature_help()
					end
				end, opts)
			end

			local lsp_config = {
				diagnostic = {
					virtual_text = false,
					underline = true,
					update_in_insert = false,
					severity_sort = true,
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
							local venv = vim.env.VIRTUAL_ENV

							if not venv then
								local is_poetry = vim.fs.find(
									{ "poetry.lock" },
									{ upward = true, path = config.root_dir, type = "file", stop = vim.env.HOME }
								)[1] ~= nil

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
								},
							},
						},
					})
				end,
			})
		end,
	},
}
