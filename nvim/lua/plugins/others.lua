return {
	"nvim-lua/plenary.nvim", -- Lua functions
	"nvim-lua/popup.nvim",
	"mrjones2014/nvim-ts-rainbow", -- "Enclosers" coloring
	"tpope/vim-repeat", -- Repeat plugins commands
	{
		dir = "~/.dotfiles/nvim/theme",
		priority = 1000,
		config = function()
			require("colorscheme")
		end,
	},
	{
		"RRethy/vim-illuminate",
		event = "BufReadPost",
		config = function()
			-- default configuration
			require("illuminate").configure({
				-- providers: provider used to get references in the buffer, ordered by priority
				providers = {
					"treesitter",
					"lsp",
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
	}, -- Word highlighting
	{
		"s1n7ax/nvim-comment-frame",
		keys = { "Kf", "Km" },
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
	}, -- Comment frame
	{
		"ibhagwan/smartyank.nvim",
		event = "BufReadPost",
		config = function()
			require("smartyank").setup({
				highlight = {
					enabled = true, -- highlight yanked text
					higroup = "IncSearch", -- highlight group of yanked text
					timeout = 140, -- timeout for clearing the highlight
				},
				clipboard = {
					enabled = true,
				},
				tmux = {
					enabled = true,
					-- remove `-w` to disable copy to host client's clipboard
					cmd = { "tmux", "set-buffer", "-w" },
				},
				osc52 = {
					enabled = true,
					ssh_only = true, -- false to OSC52 yank also in local sessions
					silent = true, -- true to disable the "n chars copied" echo
					echo_hl = "Directory", -- highlight group of the OSC52 echo message
				},
			})
		end,
	},

	{
		"SmiteshP/nvim-gps",
		keys = "<leader>w",
		config = function()
			require("nvim-gps").setup()
			vim.keymap.set("n", "<leader>w", function()
				print(require("nvim-gps").get_location())
			end, { silent = true })
		end,
	}, -- Context in the status bar
	{
		"ThePrimeagen/refactoring.nvim",
		keys = { { "<leader>e", mode = "v" } },
		config = function()
			vim.keymap.set("v", "<Leader>e", function()
				require("refactoring").refactor("Extract Function")
			end, { silent = true })
		end,
	}, --  Extract block in new function
	{
		"danymat/neogen",
		keys = "<leader>a",
		config = function()
			require("neogen").setup({
				enabled = true,
				input_after_comment = true,
				languages = {
					python = {
						template = {
							annotation_convention = "numpydoc",
						},
					},
				},
			})

			vim.keymap.set("n", "<leader>a", require("neogen").generate, { silent = true })
		end,
	}, -- Annotation generator
	{
		"kylechui/nvim-surround",
		keys = {
			{ "<C-g>s", mode = "i" },
			{ "<C-s>", mode = "i" },
			{ "s", mode = { "n", "v" } },
			{ "S", mode = { "n", "v" } },
			{ "ds", mode = "n" },
			{ "cs", mode = "n" },
		},
		config = function()
			require("nvim-surround").setup({
				keymaps = {
					insert = "<C-g>s",
					insert_line = "<C-s>",
					normal = "s",
					normal_cur = "ss",
					normal_line = "sc",
					normal_cur_line = "sC",
					visual = "s",
					visual_line = "S",
					delete = "ds",
					change = "cs",
				},
			})

			vim.keymap.set("n", "S", function()
				return "<Plug>(nvim-surround-normal)g_"
			end, { expr = true, silent = true })
		end,
	},
	{
		"Wansmer/sibling-swap.nvim",
		keys = { "sN", "sP" },
		config = function()
			print("hey")
			require("sibling-swap").setup({
				use_default_keymaps = false,
			})
			vim.keymap.set("n", "sN", require("sibling-swap")["swap_with_right_with_opp"])
			vim.keymap.set("n", "sP", require("sibling-swap")["swap_with_left_with_opp"])
		end,
	},
	{
		"beauwilliams/focus.nvim",
		cmd = "Focus",
		opts = {
			signcolumn = false,
			cursorline = false,
		},
	}, -- Split and resize window intelligently

	{
		"windwp/nvim-autopairs",
		event = "VeryLazy",
		opts = {
			enable_afterquote = true, -- add bracket pairs after quote
			enable_check_bracket_line = true, -- check bracket in same line
			check_ts = true,
			map_cr = false,
			map_bs = true,
		},
	}, -- Pairwise
	--
	{
		"lukas-reineke/indent-blankline.nvim",
		event = "BufReadPre",
		opts = {
			show_trailing_blankline_indent = false,
			show_first_indent_level = false,
		},
	}, -- Indentation line
	{
		"numToStr/Comment.nvim",
		keys = { "K", "dK", "yK", "cK", { "K", mode = "x" } },
		config = function()
			require("Comment").setup({
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
			})
			vim.keymap.set("n", "KD", "<cmd>lua require'utils'.yank_comment_paste()<cr>", { silent = true })

			vim.keymap.set(
				"o",
				"K",
				"<cmd>lua require'utils'.adj_commented()<cr>",
				{ silent = true, desc = "Textobject for adjacent commented lines" }
			)
		end,
	},
	{
		"ggandor/leap.nvim",
		dependencies = { "ggandor/leap-ast.nvim" },
		keys = vim.tbl_map(function(key)
			return { key, mode = "" }
		end, { "<M-f>", "<M-S-f>", "<leader>z" }),
		config = function()
			vim.api.nvim_set_hl(0, "LeapBackdrop", { link = "Comment" })
			vim.api.nvim_set_hl(0, "LeapLabelPrimary", { link = "IncSearch" })
			vim.api.nvim_set_hl(0, "LeapMatch", { link = "DiagnosticLineNrWarn" })
			-- vim.api.nvim_set_hl(0, "LeapMatch", {
			-- 	fg = "red", -- for light themes, set to 'black' or similar
			-- 	bold = true,
			-- 	nocombine = true,
			-- })
			require("leap").opts.highlight_unlabeled_phase_one_targets = true
			vim.keymap.set("", "<M-f>", function()
				require("leap").leap({ backward = false })
			end)
			vim.keymap.set("", "<M-S-f>", function()
				require("leap").leap({ backward = true })
			end)
			vim.keymap.set({ "" }, "<leader>z", require("leap-ast").leap)
		end,
	},
	{
		"Shatur/neovim-session-manager",
		dependencies = {
			"airblade/vim-rooter",
			config = function()
				vim.g.rooter_cd_cmd = "lcd"
				require("session_manager").setup({
					autoload_mode = require("session_manager.config").AutoloadMode.Disabled,
				})
			end,
		},
	},
	-- {
	-- 	"phaazon/hop.nvim",
	-- 	keys = vim.tbl_map(function(key)
	-- 		return { key, mode = "" }
	-- 	end, { "<left>", "<right>", "<up>", "<down>", "<M-f>" }),
	-- 	config = function()
	-- 		local hop = require("hop")
	-- 		local hint = require("hop.hint")
	--
	-- 		require("hop").setup({})
	--
	-- 		vim.keymap.set("", "<left>", function()
	-- 			hop.hint_char1({ direction = hint.HintDirection.BEFORE_CURSOR })
	-- 		end)
	-- 		vim.keymap.set("", "<right>", function()
	-- 			hop.hint_char1({ direction = hint.HintDirection.AFTER_CURSOR })
	-- 		end)
	-- 		vim.keymap.set("", "<up>", function()
	-- 			hop.hint_vertical({ direction = hint.HintDirection.BEFORE_CURSOR })
	-- 		end)
	-- 		vim.keymap.set("", "<down>", function()
	-- 			hop.hint_vertical({ direction = hint.HintDirection.AFTER_CURSOR })
	-- 		end)
	-- 		vim.keymap.set("", "<M-f>", hop.hint_patterns)
	-- 	end,
	-- }, -- Vim Motions

	{
		"Weissle/easy-action",
		keys = { "<leader>k", "\\" },
		dependencies = {
			{
				"kevinhwang91/promise-async",
				"ggandor/leap.nvim",
			},
		},
		config = function()
			require("easy-action").setup({
				-- These chars can show up any times in your action input.
				free_chars = "0123456789",
				-- These chars can show up no more than twice in action input.
				limited_chars = "iafFtT",
				-- Cancel action.
				terminate_char = "<ESC>",
				-- all action contains `key` will be replaced by `value`. For example yib -> yi(
				remap = {
					ib = "i(",
					ab = "a(",
				},
				-- Default jump provider
				jump_provider = "leap",
				jump_provider_config = {
					leap = {
						action_select = {
							default = function()
								require("leap").leap({
									target_windows = { vim.api.nvim_call_function("win_getid", {}) },
								})
							end,
						},
					},
					hop = {
						action_select = {
							char1 = {
								-- action ends with any char of options will use HopChar1MW command.
								options = "(){}[]<>`'\"",
								cmd = "HopChar1",
								feed = function(action)
									return string.sub(action, #action)
								end,
							},
							line = {
								-- action ends with any char of options will use HopLineMW command.
								options = "yd",
								cmd = "HopLine",
							},
							-- Default command.
							default = "HopWord",
						},
					},
				},
				-- Just make sure they are greater than 0. Usually 1 is all right.
				jump_back_delay_ms = 1,
				feed_delay_ms = 1,
			})

			-- trigger easy-action.
			vim.keymap.set("n", "\\", function()
				require("easy-action").base_easy_action(nil, nil, nil)
			end, { silent = true })

			-- To insert something and jump back after you leave the insert mode
			vim.keymap.set("n", "<leader>k", function()
				require("easy-action").base_easy_action("i", nil, "InsertLeave")
			end)
		end,
	},
	{
		"ckolkey/ts-node-action",
		dependencies = { "nvim-treesitter" },
		keys = "<leader>n",
		config = function()
			vim.keymap.set(
				{ "n" },
				"<leader>n",
				require("ts-node-action").node_action,
				{ desc = "Trigger Node Action" }
			)
		end,
	},
	{
		"diegoulloao/nvim-file-location",
		keys = "<localleader>f",
		opts = {
			keymap = "<localleader>f",
			mode = "absolute", -- options: workdir | absolute
			add_line = true,
			add_column = false,
		},
	},
	{
		"junegunn/vim-easy-align",
		keys = { { "<localleader>a", mode = { "n", "x" } } },
		config = function()
			vim.keymap.set({ "n", "x" }, "<localleader>a", "<Plug>(LiveEasyAlign)")
		end,
	}, -- Tabularize

	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
		opts = {
			popupmenu = {
				enabled = false, -- enables the Noice popupmenu UI
			},
			commands = {
				last = {
					view = "mini",
				},
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
				lsp_doc_border = false,
			},
			views = {
				messages = {
					enter = false,
					win_options = {
						winhighlight = { Normal = "Normal" },
					},
				},
				-- popup = {
				-- 	win_options = {
				-- 		winhighlight = { Normal = "Normal" },
				-- 	},
				-- },
				mini = {
					timeout = 4000,
					--   position = {
					--   row = -1,
					--   col = "50%",
					-- },
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
		"philipGaudreau/nvim-cheat.sh",
		branch = "feature/rounded-borders",
		dependencies = "philipGaudreau/popfix",
		keys = "<leader>c",
		config = function()
			vim.keymap.set("n", "<leader>c", "<cmd>Cheat<cr>a")
		end,
	}, -- cheat.sh

	--	-- "jose-elias-alvarez/null-ls.nvim", -- Bridge for non-LSP stuff
	--	--  'WhoIsSethDaniel/mason-tool-installer.nvim'  -- Auto install tools like shellcheck
	--	--  "nacro90/numb.nvim"  -- Line preview
	--	--  'vimpostor/vim-tpipeline'  -- Status line in TMUX bar
}
