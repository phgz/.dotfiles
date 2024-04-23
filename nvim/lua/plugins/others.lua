local keymap = vim.keymap
local api = vim.api
local fn = vim.fn
-- https://github.com/trimclain/builder.nvim: Simple building plugin
local utils = require("utils")
return {
	"nvim-lua/plenary.nvim", -- Lua functions
	"tpope/vim-repeat", -- Repeat plugins commands
	{
		"Shatur/neovim-ayu", -- midnight theme
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
		-- tag = "v0.0.7",
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
			keymap.set("n", "<leader>q", function() -- Close window
				require("bufresize").block_register()
				local win = api.nvim_get_current_win()
				api.nvim_win_close(win, false)
				require("bufresize").resize_close()
			end)
		end,
	},
	{
		"mrjones2014/smart-splits.nvim", -- smart window navigation
		keys = vim.iter(vim.iter({ "left", "right", "up", "down" })
			:map(function(key)
				return { "<C-S-" .. key .. ">", "<S-M-" .. key .. ">", "<S-" .. key .. ">" }
			end)
			:flatten()):map(function(key)
			return { key, mode = { "i", "n", "o", "v" } }
		end),
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
			keymap.set({ "i", "n", "o", "v" }, "<S-left>", require("smart-splits").move_cursor_left)
			keymap.set({ "i", "n", "o", "v" }, "<S-down>", require("smart-splits").move_cursor_down)
			keymap.set({ "i", "n", "o", "v" }, "<S-up>", require("smart-splits").move_cursor_up)
			keymap.set({ "i", "n", "o", "v" }, "<S-right>", require("smart-splits").move_cursor_right)
			-- resizing splits
			keymap.set({ "i", "n", "o", "v" }, "<C-S-left>", require("smart-splits").resize_left)
			keymap.set({ "i", "n", "o", "v" }, "<C-S-down>", require("smart-splits").resize_down)
			keymap.set({ "i", "n", "o", "v" }, "<C-S-up>", require("smart-splits").resize_up)
			keymap.set({ "i", "n", "o", "v" }, "<C-S-right>", require("smart-splits").resize_right)
			-- swapping buffers between windows
			keymap.set({ "i", "n", "o", "v" }, "<S-M-left>", require("smart-splits").swap_buf_left)
			keymap.set({ "i", "n", "o", "v" }, "<S-M-down>", require("smart-splits").swap_buf_down)
			keymap.set({ "i", "n", "o", "v" }, "<S-M-up>", require("smart-splits").swap_buf_up)
			keymap.set({ "i", "n", "o", "v" }, "<S-M-right>", require("smart-splits").swap_buf_right)
		end,
	},
	{
		"https://github.com/atusy/treemonkey.nvim",
		init = function()
			keymap.set({ "x", "o" }, "n", function()
				require("treemonkey").select({ ignore_injections = false })
			end)
		end,
	},
	{
		"HiPhish/rainbow-delimiters.nvim", -- "Enclosers" coloring
		config = function()
			-- local strategy = function()
			-- 	if api.nvim_call_function("line", { "$" }) > 10000 then
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
		"ibhagwan/smartyank.nvim", -- Sync system clipboard with nvim
		event = "TextYankPost",
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
			})
		end,
	},
	{
		"gbprod/substitute.nvim",
		config = function()
			require("substitute").setup({
				on_substitute = nil,
				yank_substituted_text = false,
				highlight_substituted_text = {
					enabled = false,
				},
				exchange = {
					motion = false,
					use_esc_to_cancel = true,
				},
			})
			keymap.set("n", "sx", function()
				require("substitute").operator({ register = vim.v.register })
			end, { noremap = true })
			keymap.set("n", "sxn", function()
				require("treemonkey").select({ ignore_injections = false })
				if utils.get_visual_state().is_active then
					require("substitute").visual({ register = vim.v.register })
				end
			end, { noremap = true })
			keymap.set("n", "sxx", require("substitute").line, { noremap = true })
			keymap.set("n", "sX", require("substitute").eol, { noremap = true })
			keymap.set("n", "cx", require("substitute.exchange").operator, { noremap = true })
			keymap.set("x", "CX", require("substitute.exchange").operator, { noremap = true })
		end,
	},
	{
		"roobert/tabtree.nvim",
		config = function()
			require("tabtree").setup({
				key_bindings_disabled = true,
				language_configs = {
					lua = {
						target_query = [[
						(string) @string_capture
						(parameters) @parameters_capture
						]],
						offsets = {},
					},
					python = {
						target_query = [[
              (string) @string_capture
              (interpolation) @interpolation_capture
              (parameters) @parameters_capture
              (argument_list) @argument_list_capture
            ]],
						-- experimental feature, to move the cursor in certain situations like when handling python f-strings
						offsets = {
							string_start_capture = 1,
						},
					},
				},
			})
		end,
	},
	{
		"ThePrimeagen/refactoring.nvim", --  Extract block in new function
		keys = { { "<leader>e", mode = "v" } },
		config = function()
			keymap.set("v", "<Leader>e", function()
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

			keymap.set("n", "<leader>a", require("neogen").generate, { silent = true })
		end,
	},
	{
		"phgz/nvim-surround", -- Surround motion with delimiters
		keys = {
			{ "<C-g>s", mode = "i" },
			{ "<C-s>", mode = "i" },
			{ "s", mode = { "n", "v" } },
			{ "S", mode = { "n", "v" } },
			{ "ds", mode = "n" },
			{ "dVs", mode = "n" },
			{ "cs", mode = "n" },
			{ "sn", mode = "n" },
			{ "sVn", mode = "n" },
		},
		config = function()
			require("nvim-surround").setup({
				move_cursor = false,
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
								api.nvim_win_set_cursor(0, { row, col - 1 })
								local feed_prefix = require("nvim-surround.cache").normal.line_mode and "_" or ""
								api.nvim_feedkeys(feed_prefix .. "i", "n", false)
							end, 0)

							api.nvim_create_autocmd("InsertLeave", {
								once = true,
								callback = function()
									vim.go.operatorfunc = "v:lua.require'nvim-surround.utils'.NOOP"
									api.nvim_feedkeys("g@l", "n", false)
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
								api.nvim_feedkeys("i", "n", false)
								return { { "" }, { "" } }
							end,
						},
					},
				},
			})

			keymap.set("n", "S", function()
				return "<Plug>(nvim-surround-normal)g_"
			end, { expr = true, silent = true })

			keymap.set("n", "ss", function()
				local current_line = fn.line(".")

				require("nvim-surround.buffer").highlight_selection({
					first_pos = { current_line, api.nvim_get_current_line():find("[^%s]") or 0 },
					last_pos = { current_line, vim.fn.col("$") },
				})

				local input = vim.fn.getcharstr()
				if input == "V" then
					return "<Plug>(nvim-surround-normal-line)L"
				else
					return "<Plug>(nvim-surround-normal-cur)" .. input
				end
			end, { expr = true, silent = true, remap = true })

			keymap.set("n", "sn", function()
				require("treemonkey").select({ ignore_injections = false })
				if utils.get_visual_state().is_active then
					api.nvim_feedkeys(vim.keycode("<esc>") .. "sv`<", "", false)
				end
			end, { silent = true })

			keymap.set("n", "sVn", function()
				require("treemonkey").select({ ignore_injections = false })
				if utils.get_visual_state().is_active then
					api.nvim_feedkeys(vim.keycode("<esc>") .. "sVv`<", "", false)
				end
			end, { silent = true })
		end,
	},
	{
		"Wansmer/sibling-swap.nvim", -- Swap sibling treesitter nodes
		keys = { "<C-.>", "<C-,>" },
		config = function()
			require("sibling-swap").setup({
				use_default_keymaps = false,
			})
			keymap.set("n", "<C-.>", require("sibling-swap")["swap_with_right_with_opp"])
			keymap.set("n", "<C-,>", require("sibling-swap")["swap_with_left_with_opp"])
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
		enabled = false,
		-- main = "ibl",
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
		-- opts = {
		--
		-- 	show_trailing_blankline_indent = false,
		-- 	show_first_indent_level = false,
		-- },
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
			keymap.set(
				"n",
				"KD",
				[[<cmd>lua require'registry'.set_position(vim.fn.getpos("."))<cr><cmd>let &operatorfunc = "v:lua.require'utils'.yank_comment_paste"<cr>g@]],
				{ silent = true }
			)

			keymap.set(
				"o",
				"K",
				"<cmd>lua require'utils'.adj_commented()<cr>",
				{ silent = true, desc = "Textobject for adjacent commented lines" }
			)
		end,
	},
	{ "github/copilot.vim", enabled = false },
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {
			modes = {
				search = {
					enabled = false,
				},
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
				"l",
				mode = { "n", "o", "x" },
				function()
					local forced_motion = utils.get_operator_pending_state().forced_motion
					-- vim.cmd.normal("V")
					local ret = require("flash").jump({
						-- search = { forward = true, wrap = false, multi_window = false },
						search = { multi_window = false },
						prompt = { enabled = false },
						label = { after = { 0, 0 }, reuse = "all" },
						jump = { autojump = true },
						highlight = { backdrop = false, matches = false },
					})
					if vim.deep_equal(ret.results, {}) then
						api.nvim_feedkeys(vim.keycode("<esc>"), "x", false)
						api.nvim_feedkeys(vim.keycode("<esc>"), "n", false)
					elseif forced_motion then
						api.nvim_feedkeys(forced_motion, "x", false)
					end
				end,
			},
			{
				"r",
				mode = "o",
				function()
					local is_i_ctrl_o = require("registry").is_i_ctrl_o
					local is_eol = require("registry").insert_mode_col == fn.col("$")
					local ret = require("flash").remote({ motion = true, restore = true })
					if not vim.deep_equal(ret.results, {}) and (vim.v.operator == "y" or vim.v.operator == "d") then
						vim.defer_fn(function()
							if is_i_ctrl_o then
								api.nvim_feedkeys((is_eol and "a" or "i") .. vim.keycode("<C-r>") .. '"', "n", false)
							else
								api.nvim_feedkeys("p", "", false)
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
					if vim.v.count ~= 0 then
						api.nvim_feedkeys(":.-" .. vim.v.count - 1 .. ",.", "n", false)
						return
					end
					local char = fn.escape(fn.getcharstr(), "^$.*~")
					if char == "h" or char == "l" or char == "M" then
						local offset = utils.get_linechars_offset_from_cursor(fn.char2nr(char))
						if not offset then
							return
						end
						if offset < 0 then
							api.nvim_feedkeys(":." .. offset .. ",.", "n", false)
						else
							api.nvim_feedkeys(":.,.+" .. offset, "n", false)
						end
					elseif char == "i" or char == "a" then
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
		"ckolkey/ts-node-action", -- Treesitter based node transformer (quote, bool, etc.)
		dependencies = {
			"nvim-treesitter",
			{
				"Wansmer/treesj",
				config = function()
					require("treesj").setup({
						use_default_keymaps = false,
					})
				end,
			},
		},
		keys = "<leader>k",
		config = function()
			local ts_node_action = require("ts-node-action")
			local actions = require("ts-node-action.actions")
			-- to get the node type under cursor: `vim.treesitter.get_node({ bufnr = 0 }):type()`
			ts_node_action.setup({
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
			keymap.set({ "n" }, "<leader>k", function()
				local is_markup_lang = vim.list_contains({ "json", "toml", "yaml" }, vim.bo.ft)
				local is_yaml_bool_scalar = vim.bo.ft == "yaml"
					and vim.treesitter.get_node({ bufnr = 0 }):type() == "boolean_scalar"
				if is_markup_lang and not is_yaml_bool_scalar then
					require("treesj").toggle()
				else
					ts_node_action.node_action()
				end
			end, { desc = "Trigger Node Action" })
		end,
	},
	{
		"gbprod/stay-in-place.nvim",
		config = function()
			require("stay-in-place").setup({})
		end,
	},
	{
		"icholy/lsplinks.nvim",
		config = function()
			local lsplinks = require("lsplinks")
			lsplinks.setup()
			vim.keymap.set("n", "gx", lsplinks.gx)
		end,
	},
	{
		"junegunn/vim-easy-align", -- Align text based on pattern
		keys = { { "<localleader>a", mode = { "n", "x" } } },
		config = function()
			keymap.set({ "n", "x" }, "<localleader>a", "<Plug>(LiveEasyAlign)")
		end,
	},
	{
		"folke/noice.nvim", -- Notification system
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
		keys = {
			{
				"<C-f>",
				function()
					if not require("noice.lsp").scroll(4) then
						return "<C-f>"
					end
				end,
				mode = { "n" },
				silent = true,
				expr = true,
			},
			{
				"<C-b>",
				function()
					if not require("noice.lsp").scroll(-4) then
						return "<C-b>"
					end
				end,
				mode = { "n" },
				silent = true,
				expr = true,
			},
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
}
