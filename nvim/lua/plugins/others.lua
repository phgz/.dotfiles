return {
	"nvim-lua/plenary.nvim", -- Lua functions
	"nvim-lua/popup.nvim",
	"tpope/vim-repeat", -- Repeat plugins commands
	{
		"ayu-theme/ayu-vim", -- midnight theme
		lazy = true,
		config = function() end,
	},
	{
		"phgz/nvim-paper", -- transition theme
		lazy = true,
		config = function() end,
	},
	{
		"luisiacc/gruvbox-baby", -- night theme
		lazy = true,
		config = function() end,
	},
	{
		"projekt0n/github-nvim-theme", -- day theme
		lazy = true,
		tag = "v0.0.7",
		config = function() end,
	},
	{
		dir = "~/.dotfiles/nvim/theme", -- colorscheme
		priority = 1000,
		config = function()
			require("colorscheme")
		end,
	},
	{
		dir = "~/.dotfiles/nvim/multiline-ft", -- multiline find/repeat
		config = function()
			require("multiline_ft")
		end,
	},
	{
		"kwkarlwang/bufresize.nvim", -- keep windows proportions
		config = function()
			require("bufresize").setup()
			vim.keymap.set("n", "<leader>q", function() -- Close window
				require("bufresize").block_register()
				local win = vim.api.nvim_get_current_win()
				vim.api.nvim_win_close(win, false)
				require("bufresize").resize_close()
			end)
		end,
	},
	{
		"mrjones2014/smart-splits.nvim", -- smart window navigation
		keys = vim.iter.map(
			function(key)
				return { key, mode = { "i", "n", "o", "v" } }
			end,
			vim.tbl_flatten(vim.iter.map(function(key)
				return { "<C-S-" .. key .. ">", "<S-M-" .. key .. ">", "<S-" .. key .. ">" }
			end, { "left", "right", "up", "down" }))
		),
		config = function()
			require("smart-splits").setup({
				default_amount = 2,
				at_edge = "wrap", -- split
				move_cursor_same_row = false,
				cursor_follows_swapped_bufs = false,
				multiplexer_integration = false,
				disable_multiplexer_nav_when_zoomed = false,
				resize_mode = {
					hooks = {
						on_leave = require("bufresize").register,
					},
				},
			})
			-- moving between splits
			vim.keymap.set({ "i", "n", "o", "v" }, "<S-left>", require("smart-splits").move_cursor_left)
			vim.keymap.set({ "i", "n", "o", "v" }, "<S-down>", require("smart-splits").move_cursor_down)
			vim.keymap.set({ "i", "n", "o", "v" }, "<S-up>", require("smart-splits").move_cursor_up)
			vim.keymap.set({ "i", "n", "o", "v" }, "<S-right>", require("smart-splits").move_cursor_right)
			-- resizing splits
			vim.keymap.set({ "i", "n", "o", "v" }, "<C-S-left>", require("smart-splits").resize_left)
			vim.keymap.set({ "i", "n", "o", "v" }, "<C-S-down>", require("smart-splits").resize_down)
			vim.keymap.set({ "i", "n", "o", "v" }, "<C-S-up>", require("smart-splits").resize_up)
			vim.keymap.set({ "i", "n", "o", "v" }, "<C-S-right>", require("smart-splits").resize_right)
			-- swapping buffers between windows
			vim.keymap.set({ "i", "n", "o", "v" }, "<S-M-left>", require("smart-splits").swap_buf_left)
			vim.keymap.set({ "i", "n", "o", "v" }, "<S-M-down>", require("smart-splits").swap_buf_down)
			vim.keymap.set({ "i", "n", "o", "v" }, "<S-M-up>", require("smart-splits").swap_buf_up)
			vim.keymap.set({ "i", "n", "o", "v" }, "<S-M-right>", require("smart-splits").swap_buf_right)
		end,
	},
	{
		"HiPhish/rainbow-delimiters.nvim", -- "Enclosers" coloring
		config = function()
			-- local strategy = function()
			-- 	if vim.api.nvim_call_function("line", { "$" }) > 10000 then
			-- 		return require("rainbow-delimiters").strategy["local"]
			-- 	else
			-- 		return require("rainbow-delimiters").strategy["global"]
			-- 	end
			-- end

			-- vim.g.rainbow_delimiters = {
			-- 	strategy = vim.iter(require("nvim-treesitter.parsers")["available_parsers"]())
			-- 		:fold({}, function(t, lang)
			-- 			t[lang] = strategy
			-- 			return t
			-- 		end),
			-- 	query = {
			-- 		[""] = "rainbow-delimiters",
			-- 		lua = "rainbow-blocks",
			-- 	},
			-- 	highlight = {
			-- 		"RainbowDelimiterRed",
			-- 		"RainbowDelimiterYellow",
			-- 		"RainbowDelimiterBlue",
			-- 		"RainbowDelimiterOrange",
			-- 		"RainbowDelimiterGreen",
			-- 		"RainbowDelimiterViolet",
			-- 		"RainbowDelimiterCyan",
			-- 	},
			-- }
		end,
	},
	{
		"RRethy/vim-illuminate",
		event = "CursorMoved",
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
		"s1n7ax/nvim-comment-frame", -- Wirte comments in frames
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
		"EtiamNullam/deferred-clipboard.nvim", -- Sync system clipboard with nvim
		config = function()
			local deferred_clipboard = require("deferred-clipboard")
			deferred_clipboard.setup()
			vim.api.nvim_create_autocmd("CmdlineEnter", {
				callback = function()
					deferred_clipboard.write()
				end,
			})
		end,
	},
	{
		"SmiteshP/nvim-gps", -- Context in the status bar
		keys = "<leader>w",
		config = function()
			require("nvim-gps").setup()
			vim.keymap.set("n", "<leader>w", function()
				vim.notify(require("nvim-gps").get_location())
				vim.wo.statusline = vim.wo.statusline
			end, { silent = true })
		end,
	},
	{
		"ThePrimeagen/refactoring.nvim", --  Extract block in new function
		keys = { { "<leader>e", mode = "v" } },
		config = function()
			vim.keymap.set("v", "<Leader>e", function()
				require("refactoring").refactor("Extract Function")
			end, { silent = true })
		end,
	},
	{
		"danymat/neogen", -- Annotation generator
		keys = "<leader>a",
		config = function()
			require("neogen").setup({
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
	},
	{
		"kylechui/nvim-surround", -- Surround motion with delimiters
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
		"Wansmer/sibling-swap.nvim", -- Swap sibling treesitter nodes
		keys = { "sN", "sP" },
		config = function()
			require("sibling-swap").setup({
				use_default_keymaps = false,
			})
			vim.keymap.set("n", "sN", require("sibling-swap")["swap_with_right_with_opp"])
			vim.keymap.set("n", "sP", require("sibling-swap")["swap_with_left_with_opp"])
		end,
	},
	{
		"windwp/nvim-autopairs", -- End pairs like (), [], {}
		event = "VeryLazy",
		opts = {
			enable_afterquote = true, -- add bracket pairs after quote
			enable_check_bracket_line = true, -- check bracket in same line
			check_ts = true,
			map_cr = false,
			map_bs = true,
		},
	},
	{
		"lukas-reineke/indent-blankline.nvim", -- Indentation line
		event = "BufReadPre",
		opts = {
			show_trailing_blankline_indent = false,
			show_first_indent_level = false,
		},
	},
	{
		"numToStr/Comment.nvim", -- Treesitter based commenting
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
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {
			modes = {
				search = {
					enabled = false,
				},
				char = {
					jump_labels = true,
					keys = { "f", "F", "t", "T", ";", "," },
				},
			},
		},
		keys = {
			{
				"r",
				mode = "o",
				function()
					require("flash").remote({ motion = true, restore = true })
				end,
				desc = "Remote Flash",
			},
			{
				"\\",
				mode = "n",
				function()
					local char = vim.fn.escape(vim.fn.getcharstr(), "^$.*~")
					if char ~= "i" and char ~= "a" then
						-- escape
						return
					else
						local pos = vim.api.nvim_win_get_cursor(0)
						local is_i_ctrl_o = vim.fn.mode(1) == "niI"
						if is_i_ctrl_o then
							vim.api.nvim_feedkeys(vim.keycode("<esc>"), "x", false)
						end
						require("flash").jump()
						if vim.deep_equal(vim.api.nvim_win_get_cursor(0), pos) then
							return
						end
						vim.api.nvim_create_autocmd("InsertLeave", {
							once = true,
							callback = function()
								vim.api.nvim_win_set_cursor(0, pos)
								if is_i_ctrl_o then
									vim.api.nvim_feedkeys("i", "n", false)
								end
							end,
						})
						vim.api.nvim_feedkeys(char, "n", false)
					end
				end,
			},
		},
	},
	-- {
	-- 	"ggandor/leap.nvim", -- Label based motions
	-- 	dependencies = { "ggandor/leap-ast.nvim" },
	-- 	keys = { "<M-f>", "M-S-f", "<leader>z" },
	-- 	config = function()
	-- 		vim.api.nvim_set_hl(0, "LeapBackdrop", { link = "Comment" })
	-- 		vim.api.nvim_set_hl(0, "LeapLabelPrimary", { link = "IncSearch" })
	-- 		vim.api.nvim_set_hl(0, "LeapMatch", { link = "DiagnosticLineNrWarn" })
	-- 		require("leap").opts.highlight_unlabeled_phase_one_targets = true
	-- 		vim.keymap.set("", "<M-f>", function()
	-- 			require("leap").leap({ backward = false })
	-- 		end)
	-- 		vim.keymap.set("", "<M-S-f>", function()
	-- 			require("leap").leap({ backward = true })
	-- 		end)
	-- 		vim.keymap.set({ "" }, "<leader>z", require("leap-ast").leap)
	-- 	end,
	-- },
	-- {
	-- 	"Weissle/easy-action", -- Remote actions
	-- 	keys = { "<leader>k", "\\" },
	-- 	dependencies = {
	-- 		{
	-- 			"kevinhwang91/promise-async",
	-- 			"ggandor/leap.nvim",
	-- 		},
	-- 	},
	-- 	config = function()
	-- 		require("easy-action").setup({
	-- 			-- These chars can show up any times in your action input.
	-- 			free_chars = "0123456789",
	-- 			-- These chars can show up no more than twice in action input.
	-- 			limited_chars = "iafFtT",
	-- 			-- Cancel action.
	-- 			terminate_char = "<ESC>",
	-- 			-- all action contains `key` will be replaced by `value`. For example yib -> yi(
	-- 			remap = {
	-- 				ib = "i(",
	-- 				ab = "a(",
	-- 			},
	-- 			-- Default jump provider
	-- 			jump_provider = "leap",
	-- 			jump_provider_config = {
	-- 				leap = {
	-- 					action_select = {
	-- 						default = function()
	-- 							require("leap").leap({
	-- 								target_windows = { vim.api.nvim_call_function("win_getid", {}) },
	-- 							})
	-- 						end,
	-- 					},
	-- 				},
	-- 				hop = {
	-- 					action_select = {
	-- 						char1 = {
	-- 							-- action ends with any char of options will use HopChar1MW command.
	-- 							options = "(){}[]<>`'\"",
	-- 							cmd = "HopChar1",
	-- 							feed = function(action)
	-- 								return string.sub(action, #action)
	-- 							end,
	-- 						},
	-- 						line = {
	-- 							-- action ends with any char of options will use HopLineMW command.
	-- 							options = "yd",
	-- 							cmd = "HopLine",
	-- 						},
	-- 						-- Default command.
	-- 						default = "HopWord",
	-- 					},
	-- 				},
	-- 			},
	-- 			-- Just make sure they are greater than 0. Usually 1 is all right.
	-- 			jump_back_delay_ms = 1,
	-- 			feed_delay_ms = 1,
	-- 		})
	--
	-- 		-- trigger easy-action.
	-- 		vim.keymap.set("n", "\\", function()
	-- 			require("easy-action").base_easy_action(nil, nil, nil)
	-- 		end, { silent = true })
	--
	-- 		-- To insert something and jump back after you leave the insert mode
	-- 		vim.keymap.set("n", "<leader>k", function()
	-- 			require("easy-action").base_easy_action("i", nil, "InsertLeave")
	-- 		end)
	-- 	end,
	-- },
	{
		"ckolkey/ts-node-action", -- Treesitter based node transformer (quote, bool, etc.)
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
		"junegunn/vim-easy-align", -- Align text based on pattern
		keys = { { "<localleader>a", mode = { "n", "x" } } },
		config = function()
			vim.keymap.set({ "n", "x" }, "<localleader>a", "<Plug>(LiveEasyAlign)")
		end,
	},
	{
		"folke/noice.nvim", -- Notification system
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
}
