return {
	"nvim-lua/plenary.nvim", -- Lua functions
	"tpope/vim-repeat", -- Repeat commands
	{
		"Shatur/neovim-ayu", -- midnight theme
		lazy = true,
		config = function() end,
	},
	{
		"luisiacc/gruvbox-baby", -- evening theme
		lazy = true,
		config = function() end,
	},
	{
		"projekt0n/github-nvim-theme", -- day theme
		lazy = true,
		config = function() end,
	},
	{
		dir = "~/.dotfiles/nvim/theme", -- colorschemes utils
		priority = 1000,
		config = function()
			require("colorscheme")
		end,
	},
	{
		dir = "~/.dotfiles/nvim/multiline-ft", -- multiline find/repeat
		event = "VeryLazy",
		config = function()
			require("multiline_ft")
		end,
	},
	{ "atusy/treemonkey.nvim", event = "VeryLazy" }, -- label-based node selection
	{
		"HiPhish/rainbow-delimiters.nvim",
		event = "VeryLazy",
		config = function()
			require("rainbow-delimiters").enable(0)
		end,
	}, -- "Enclosers" coloring
	{
		"RRethy/vim-illuminate", -- highlight other uses of the word under the cursor
		event = "VeryLazy",
		config = function()
			-- default configuration
			require("illuminate").configure({
				-- providers: provider used to get references in the buffer, ordered by priority
				providers = {
					"lsp",
					"treesitter",
					"regex",
				},
				-- delay: delay in milliseconds
				delay = 100,
				-- filetype_overrides: filetype specific overrides.
				-- The keys are strings to represent the filetype while the values are tables that
				-- supports the same keys passed to .configure except for filetypes_denylist and filetypes_allowlist
				filetype_overrides = {},
				-- filetypes_denylist: filetypes to not illuminate, this overrides filetypes_allowlist
				filetypes_denylist = {
					"dirvish",
					"fugitive",
				},
				-- filetypes_allowlist: filetypes to illuminate, this is overriden by filetypes_denylist
				filetypes_allowlist = {},
				-- modes_denylist: modes to not illuminate, this overrides modes_allowlist
				modes_denylist = {},
				-- modes_allowlist: modes to illuminate, this is overriden by modes_denylist
				modes_allowlist = {},
				-- providers_regex_syntax_denylist: syntax to not illuminate, this overrides providers_regex_syntax_allowlist
				-- Only applies to the 'regex' provider
				-- Use :echom synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
				providers_regex_syntax_denylist = {},
				-- providers_regex_syntax_allowlist: syntax to illuminate, this is overriden by providers_regex_syntax_denylist
				-- Only applies to the 'regex' provider
				-- Use :echom synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
				providers_regex_syntax_allowlist = {},
				-- under_cursor: whether or not to illuminate under the cursor
				under_cursor = false,
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter", -- TS parsers and queries
		branch = "main",
		event = "VeryLazy",
		build = function()
			-- currently installing about 360 parsers. Maybe install a smaller subset for faster bootstrapping
			-- Default directory where parsers and queries are installed is vim.fn.stdpath('data') .. '/site'
			local stable_parsers = require("nvim-treesitter.config").get_available("stable")
			local parsers_dir =
				vim.fs.find("parser", { type = "directory", path = os.getenv("HOME") .. "/.local/share/nvim/site/" })[1]
			if not parsers_dir then
				require("nvim-treesitter.install").install(stable_parsers, { force = true }, nil)
			else
				require("nvim-treesitter.install").update()
			end
			vim.api.nvim_exec_autocmds("FileType", {})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects", -- TS textobjects
		event = "VeryLazy",
		branch = "main",
		opts = {},
	},
	{
		"Wansmer/sibling-swap.nvim", -- Swap sibling treesitter nodes
		event = "VeryLazy",
		config = function()
			require("sibling-swap").setup({
				use_default_keymaps = false,
			})
		end,
	},
	{
		"gbprod/stay-in-place.nvim", -- prevent the cursor from moving when using shift and filter actions
		event = "VeryLazy",
		opts = {},
	},
	{
		"icholy/lsplinks.nvim", -- extends the behaviour of `gx` to support LSP document links
		event = "VeryLazy",
		opts = {},
	},
	"junegunn/vim-easy-align", -- Align text based on pattern
	{
		"Wansmer/treesj", -- split/join blocks of code like arrays, dicts, ...
		event = "VeryLazy",
		opts = { use_default_keymaps = false },
	},
	{
		"ckolkey/ts-node-action", -- Treesitter based node transformer (quote, bool, etc.)
		event = "VeryLazy",
		config = function()
			local actions = require("ts-node-action.actions")
			-- to get the node type under cursor: `vim.treesitter.get_node({ bufnr = 0 }):type()`
			require("ts-node-action").setup({
				lua = {
					["binary_expression"] = actions.toggle_operator({
						["=="] = "~=",
						["~="] = "==",
						["+"] = "-",
						["-"] = "+",
						["and"] = "or",
						["or"] = "and",
					}),
				},
				python = {
					["boolean_operator"] = actions.toggle_operator({
						["and"] = "or",
						["or"] = "and",
					}),
					["binary_operator"] = actions.toggle_operator({
						["+"] = "-",
						["-"] = "+",
					}),
				},
			})
		end,
	},
	{
		"arminveres/md-pdf.nvim", -- convert open markdown files to PDFs
		branch = "main",
		ft = "markdown",
		opts = {},
	},
	{
		"hat0uma/csvview.nvim", -- a comfortable CSV/TSV editing plugin
		ft = "csv",
		opts = {
			parser = { comments = { "#", "//" } },
			keymaps = {
				-- Text objects for selecting fields
				textobject_field_inner = { "if", mode = { "o", "x" } },
				textobject_field_outer = { "af", mode = { "o", "x" } },
				-- Excel-like navigation:
				-- Use <Tab> and <S-Tab> to move horizontally between fields.
				-- Use <Enter> and <S-Enter> to move vertically between rows and place the cursor at the end of the field.
				jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
				jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
				jump_next_row = { "<Enter>", mode = { "n", "v" } },
				jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
			},
			view = {
				display_mode = "border",
			},
		},
	},
	{
		"mhartington/formatter.nvim", -- format runner
		event = "VeryLazy",
		config = function()
			require("formatter").setup({
				logging = false,
				log_level = vim.log.levels.DEBUG,
				filetype = {
					fish = {
						require("formatter.filetypes.fish").fishindent,
					},
					sh = {
						require("formatter.filetypes.sh").shfmt,
					},
					markdown = {
						require("formatter.filetypes.markdown").prettier,
					},
					toml = {
						require("formatter.filetypes.toml").taplo,
					},
					yaml = {
						require("formatter.filetypes.yaml").yamlfmt,
					},
					json = {
						require("formatter.filetypes.json").prettier,
					},
					sql = {
						{
							exe = "sql-formatter",
							args = { "--language", "sqlite", "--" },
							stdin = true,
						},
					},
					python = {
						function()
							return {
								exe = "black",
								args = { "--quiet", "-" },
								stdin = true,
							}
						end,
					},
					lua = {
						require("formatter.filetypes.lua").stylua,
					},
					["*"] = {
						require("formatter.filetypes.any").remove_trailing_whitespace,
					},
				},
			})
		end,
	},
	{
		"gbprod/substitute.nvim", -- operator motions to perform quick substitutions and exchange
		event = "VeryLazy",
		opts = {
			on_substitute = nil,
			yank_substituted_text = false,
			highlight_substituted_text = {
				enabled = false,
			},
			exchange = {
				motion = false,
				use_esc_to_cancel = true,
			},
		},
	},
	{
		-- reload cache with, for example: `deno cache --reload denops/ddc/deps.ts`
		"Shougo/ddc.vim", -- autocompletion
		event = "VeryLazy",
		dependencies = {
			{
				"vim-denops/denops.vim",
				dependencies = "neovim/nvim-lspconfig",
			},
			{
				"matsui54/denops-popup-preview.vim",
				config = function()
					vim.g.popup_preview_config = {
						border = false,
						winblend = 30,
						maxHeight = 12,
						supportUltisnips = false,
						supportVsnip = false,
					}
				end,
			},
			{
				"matsui54/denops-signature_help",
				config = function()
					vim.g.signature_help_config = {
						contentsStyle = "currentLabel",
						viewStyle = "virtual",
					}
				end,
			},
			"Shougo/ddc-converter_remove_overlap",
			"Shougo/ddc-source-around",
			"Shougo/ddc-source-lsp",
			{ "Shougo/ddc-ui-inline", commit = "67761d84eac5f617970996af6d0d8dc4485e79f3" },
			"Shougo/ddc-ui-native",
			"tani/ddc-fuzzy",
			{
				"windwp/nvim-autopairs", -- End pairs like (), [], {}
				opts = {
					enable_afterquote = true, -- add bracket pairs after quote
					enable_check_bracket_line = true, -- check bracket in same line
					check_ts = true,
					map_cr = false,
					map_bs = true,
				},
			},
		},
		config = function()
			vim.fn["popup_preview#enable"]()
			vim.fn["signature_help#enable"]()
			vim.fn["ddc#custom#load_config"](os.getenv("HOME") .. "/.dotfiles/nvim/ddc.ts")
			vim.fn["ddc#enable"]({ context_filetype = "treesitter" })
		end,
	},
	{
		"danymat/neogen", -- create annotation template
		event = "VeryLazy",
		opts = {
			input_after_comment = true,
			languages = {
				python = {
					template = {
						annotation_convention = "numpydoc",
					},
				},
			},
		},
	},
	{ "ThePrimeagen/refactoring.nvim", event = "VeryLazy" }, -- extract block in new function
	{
		"numToStr/Comment.nvim", -- treesitter based commenting
		event = "VeryLazy",
		opts = {
			toggler = {
				--Line-comment toggle keymap
				line = "KL",
				block = "<nop>",
			},

			--LHS of operator-pending mappings in NORMAL + VISUAL mode
			--@type table
			opleader = {
				-- Line-comment keymap
				line = "K",
				block = "<nop>",
			},
			extra = {
				--Add comment on the line above
				above = "KO",
				--Add comment on the line below
				below = "Ko",
				--Add comment at the end of line
				eol = "KA",
			},
		},
	},
	{
		"s1n7ax/nvim-comment-frame", -- write comments in frames
		event = "VeryLazy",
		opts = {
			-- if true, <leader>cf keymap will be disabled
			disable_default_keymap = false,
			-- adds custom keymap
			keymap = "Kf",
			multiline_keymap = "Km",
			-- width of the comment frame
			frame_width = 80,
			-- wrap the line after 'n' characters
			line_wrap_len = 76,
			-- automatically indent the comment frame based on the line
			auto_indent = true,
			-- add comment above the current line
			add_comment_above = false,
			-- configurations for individual language goes here
			languages = {},
		},
	},
	{
		"trimclain/builder.nvim",
		event = "VeryLazy",
		opts = {
			commands = {
				python = "python %",
			},
		},
	},
	{
		"mrjones2014/smart-splits.nvim", -- smart window navigation
		event = "VeryLazy",
		dependencies = {
			"kwkarlwang/bufresize.nvim", -- keep windows proportions
			opts = {},
		},
		opts = {
			default_amount = 2,
			at_edge = "wrap", -- split
			move_cursor_same_row = false,
			cursor_follows_swapped_bufs = false,
			multiplexer_integration = false,
			disable_multiplexer_nav_when_zoomed = false,
			resize_mode = {
				hooks = {
					on_leave = function()
						require("bufresize").register()
					end,
				},
			},
		},
	},
	{ "neovim/nvim-lspconfig", event = "VeryLazy" }, -- basic lsp configurations
	{ "SmiteshP/nvim-navic", event = "VeryLazy" }, -- a whereami-in-code util
	{
		"williamboman/mason.nvim", -- neovim package manager
		event = "VeryLazy",
		opts = { ui = { keymaps = { uninstall_package = "x" } } },
	},
	{
		"williamboman/mason-lspconfig.nvim", -- bridge between mason and nvim-lspconfig
		event = "VeryLazy",
		build = function()
			local servers = {
				"bash-language-server",
				"dockerfile-language-server",
				"json-lsp",
				"lua-language-server",
				"pyright",
				"taplo",
				"vim-language-server",
				"yaml-language-server",
				"deno",
				-- "azure_pipelines_ls",
			}

			local formatters = { "black", "isort", "prettier", "shfmt", "stylua", "yamlfmt" }
			local linters = { "shellcheck" }

			require("mason-lspconfig").setup({ ensure_installed = servers })
		end,
		config = function()
			require("plugins_utils").mason_lspconfig_setup_handlers()
			vim.cmd("LspStart")
		end,
	},
	{
		"lewis6991/gitsigns.nvim", -- deep buffer integration for Git
		event = "VeryLazy",
		opts = {
			signs = {
				add = { text = "│" },
				change = { text = "│" },
				delete = { show_count = true, text = "_" },
				topdelete = { show_count = true, text = "‾" },
				changedelete = { show_count = true, text = "~" },
			},
			count_chars = {
				[1] = "", --"₁",
				[2] = "₂",
				[3] = "₃",
				[4] = "₄",
				[5] = "₅",
				[6] = "₆",
				[7] = "₇",
				[8] = "₈",
				[9] = "₉",
				["+"] = "₊",
			},
			signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
			numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
			linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
			word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
			diff_opts = {
				ignore_whitespace = false,
			},
			status_formatter = function(status)
				local head = status.head
				local status_txt = { head }
				local added, changed, removed = status.added, status.changed, status.removed
				if added and added > 0 then
					table.insert(status_txt, "%#GreenStatusLine#+" .. added)
				end
				if changed and changed > 0 then
					table.insert(status_txt, "%#YellowStatusLine#~" .. changed)
				end
				if removed and removed > 0 then
					table.insert(status_txt, "%#RedStatusLine#-" .. removed)
				end
				return table.concat(status_txt, " ")
			end,
			preview_config = {
				-- Options passed to nvim_open_win
				anchor = "SW",
				border = "none",
				style = "minimal",
				title = " Git diff ",
				title_pos = "center",
				relative = "cursor",
			},
		},
	},
	{
		"nvim-telescope/telescope.nvim", --  fuzzy finder over lists
		lazy = true,
		config = function()
			local actions = require("telescope.actions")

			require("telescope").setup({
				defaults = {
					mappings = {
						i = {
							["<esc>"] = actions.close,
							["<C-u>"] = false,
							["<C-n>"] = actions.cycle_history_next,
							["<C-p>"] = actions.cycle_history_prev,
							["<C-b>"] = actions.preview_scrolling_up,
							["<C-f>"] = actions.preview_scrolling_down,
							["<C-j>"] = actions.results_scrolling_up,
							["<C-k>"] = actions.results_scrolling_down,
							["<c-d>"] = function(p_bufnr)
								require("telescope.actions").delete_buffer(p_bufnr)
								require("telescope.actions").move_to_top(p_bufnr)
								local results =
									require("telescope.actions.state").get_current_picker(p_bufnr).finder.results
								local prev = vim.iter(results):find(function(item)
									return vim.startswith(item.indicator, "#h")
								end)
								if prev then
									vim.fn.setreg("#", vim.api.nvim_buf_get_name(prev.bufnr))
									require("plugins_utils").set_telescope_statusline()
								end
							end,
							["<tab>"] = actions.move_selection_next,
							["<S-tab>"] = actions.move_selection_previous,
							["<C-t>"] = actions.toggle_selection + actions.move_selection_next,
							["<C-o>"] = actions.toggle_all,
							["<C-e>"] = function(p_bufnr)
								actions.send_selected_to_qflist(p_bufnr)
								vim.cmd.cfdo("edit")
							end,
						},
					},
				},
				extensions = {
					repo = {
						list = {
							fd_opts = {
								-- "--exclude=.*/*",
								"--exclude=[A-Z]*",
								"--max-depth=2",
							},
						},
						settings = {
							auto_lcd = true,
						},
					},
				},
			})
		end,
	},
	{
		"phgz/telescope-repo.nvim", -- open/switch projects
		branch = "feature/custom-post-action",
		event = "VeryLazy",
		dependencies = "nvim-telescope/telescope.nvim",
		config = function()
			require("telescope").load_extension("repo")
		end,
	},
	{
		"rguruprakash/simple-note.nvim", -- notes viewer
		event = "VeryLazy",
		dependencies = "nvim-telescope/telescope.nvim",
		opts = { telescope_rename = "<C-r><C-n>" },
	},
	{
		"folke/noice.nvim", -- Notification system
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
		opts = {
			popupmenu = {
				enabled = false,
			},
			notify = {
				enabled = false,
			},
			lsp = {
				progress = {
					enabled = false,
				},
				hover = { enabled = true },
				signature = {
					enabled = true,
					auto_open = {
						enabled = false,
					},
				},
				override = {
					-- override the default lsp markdown formatter with Noice
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					-- override the lsp markdown formatter with Noice
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = false,
				},
			},
			presets = {
				bottom_search = true,
				lsp_doc_border = false,
			},
			cmdline = {
				view = "cmdline",
			},
			views = {
				messages = {
					enter = false,
					win_options = {
						winhighlight = { Normal = "Normal" },
					},
				},
				mini = {
					timeout = 4000,
					win_options = {
						winblend = 0,
						winhighlight = { Normal = "LineNr" },
					},
				},
				hover = {
					size = {
						max_height = 9,
						max_width = 96,
					},
					border = {
						padding = false,
					},
					scrollbar = true,
				},
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
		},
	},
	{
		"andymass/vim-matchup", -- highlight extended pairs of delimiters like function() end
		config = function()
			vim.g.matchup_matchparen_offscreen = {}
			vim.g.matchup_matchparen_deferred = 0
			vim.g.matchup_motion_cursor_end = 0
			vim.g.matchup_text_obj_linewise_operators = { "d", "y" } -- "c"?
			vim.g.matchup_matchparen_pumvisible = 0
			vim.g.matchup_matchparen_nomode = "i"
		end,
	},
	{
		"folke/flash.nvim", -- remote actions
		enabled = true,
		opts = {
			modes = {
				char = {
					enabled = false,
					jump_labels = true,
					keys = { "f", "F", "t", "T", ";", "," },
				},
			},
		},
		keys = {
			{
				"<leader>n",
				mode = { "n", "o", "x" },
				function()
					require("flash").treesitter()
				end,
			},
			{
				"r",
				mode = "o",
				function()
					local is_i_ctrl_o = require("registry").is_i_ctrl_o
					local is_eol = require("registry").insert_mode_col == vim.fn.col("$")
					local ret = require("flash").remote({ motion = true, restore = true })
					if not vim.deep_equal(ret.results, {}) and (vim.v.operator == "y" or vim.v.operator == "d") then
						vim.defer_fn(function()
							if is_i_ctrl_o then
								vim.api.nvim_feedkeys(
									(is_eol and "a" or "i") .. vim.keycode("<C-r>") .. '"',
									"n",
									false
								)
							else
								vim.api.nvim_feedkeys("p", "", false)
							end
						end, 0)
					end
				end,
				desc = "Remote Flash",
			},
			{
				"\\",
				mode = "n",
				function()
					local api = vim.api
					local fn = vim.fn
					if vim.v.count ~= 0 then
						api.nvim_feedkeys(":.-" .. vim.v.count - 1 .. ",.", "n", false)
						return
					end
					local char = fn.escape(fn.getcharstr(), "^$.*~")
					if char == "i" or char == "a" then
						local pos = api.nvim_win_get_cursor(0)
						local is_i_ctrl_o = fn.mode(1) == "niI"
						if is_i_ctrl_o then
							api.nvim_feedkeys(vim.keycode("<esc>"), "x", false)
						end
						require("flash").jump()
						if vim.deep_equal(api.nvim_win_get_cursor(0), pos) then
							return
						end
						api.nvim_create_autocmd("InsertLeave", {
							once = true,
							callback = function()
								api.nvim_win_set_cursor(0, pos)
								if is_i_ctrl_o then
									api.nvim_feedkeys("i", "n", false)
								end
							end,
						})
						api.nvim_feedkeys(char, "n", false)
					end
				end,
			},
		},
	},
	{
		"phgz/nvim-surround", -- surround motion with delimiters
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({
				move_cursor = "sticky",
				keymaps = {
					insert = "<C-s>",
					insert_line = "<C-g>s",
					normal = "s",
					normal_cur = false,
					normal_line = "sV",
					normal_cur_line = false,
					visual = "s",
					visual_line = "S",
					delete_line = "dVs",
					delete = "ds",
					change = "cs",
					change_line = "cS",
				},
				surrounds = {
					["c"] = "conditional",
					["f"] = "function",
					["l"] = "loop",
					["k"] = {
						add = function()
							vim.defer_fn(function()
								local row, col = unpack(require("nvim-surround.buffer").get_mark("["))
								vim.api.nvim_win_set_cursor(0, { row, col - 1 })
								local feed_prefix = require("nvim-surround.cache").normal.line_mode and "_" or ""
								vim.api.nvim_feedkeys(feed_prefix .. "i", "n", false)
							end, 0)

							vim.api.nvim_create_autocmd("InsertLeave", {
								once = true,
								callback = function()
									vim.go.operatorfunc = "v:lua.require'nvim-surround.utils'.NOOP"
									vim.api.nvim_feedkeys("g@l", "n", false)
								end,
							})

							return { { "(" }, { ")" } }
						end,
						find = function()
							if vim.g.loaded_nvim_treesitter then
								local selection =
									require("nvim-surround.queries").get_selection("@call.outer", "textobjects")
								if selection then
									return selection
								end
							end
							return require("nvim-surround.patterns").get_selection("[^=%s%(%){}]+%b()")
						end,
						delete = "^(.-%()().-(%))()$",
						change = {
							target = "^.-([%w%._]+)()%(.-%)()()$",
							replacement = function()
								vim.api.nvim_feedkeys("i", "n", false)
								return { { "" }, { "" } }
							end,
						},
					},
				},
			})
		end,
	},
	{
		"jinh0/eyeliner.nvim", -- highlight strategic positions for f/F/t/T
		event = "VeryLazy",
		config = function()
			require("eyeliner").setup({
				highlight_on_key = true,
				default_keymaps = false,
				-- dim = true,
			})
		end,
	},
	{
		"lukas-reineke/indent-blankline.nvim", -- Indentation line
		-- event = "BufReadPre",
		enabled = false,
		config = function()
			require("ibl").setup({
				indent = { char = "│" },
				scope = {
					enabled = false,
				},
			})
			local hooks = require("ibl.hooks")
			hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
			hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_tab_indent_level)
		end,
	},
	{
		"ibhagwan/smartyank.nvim", -- sync system clipboard with nvim
		event = "VeryLazy",
		opts = {
			highlight = {
				enabled = true, -- highlight yanked text
				higroup = "IncSearch", -- highlight group of yanked text
				timeout = 140, -- timeout for clearing the highlight
			},
			clipboard = {
				enabled = true,
			},
			tmux = {
				enabled = false,
				-- remove `-w` to disable copy to host client's clipboard
				cmd = { "tmux", "set-buffer", "-w" },
			},
			osc52 = {
				enabled = true,
				ssh_only = true, -- false to OSC52 yank also in local sessions
				silent = true, -- true to disable the "n chars copied" echo
				echo_hl = "Directory", -- highlight group of the OSC52 echo message
			},
		},
	},
}
