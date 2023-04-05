return {
	{
		"nvim-treesitter/playground", -- See parsed tree
		keys = "<localleader>t",
		config = function()
			vim.keymap.set("n", "<localleader>t", "<cmd>TSHighlightCapturesUnderCursor<cr>")
		end,
	},
	{
		"andymass/vim-matchup",
		-- event = "BufReadPost",
	},
	"nvim-treesitter/nvim-treesitter-textobjects", -- More text motions
	"nvim-treesitter/nvim-treesitter-refactor", -- Highlight definitions, Rename
	"RRethy/nvim-treesitter-endwise",
	{
		"nvim-treesitter/nvim-treesitter",
		build = function()
			vim.cmd("TSUpdate")
			vim.cmd("TSInstall all")
		end,
		config = function()
			vim.g.matchup_matchparen_offscreen = {}
			vim.g.matchup_matchparen_deferred = 0
			vim.g.matchup_motion_cursor_end = 0
			vim.g.matchup_text_obj_linewise_operators = { "d", "y" } -- "c"?

			local mk_repeatable = require("utils").mk_repeatable
			require("nvim-treesitter.configs").setup({
				-- ensure_installed = "all",
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = { "python" },
				},
				indent = {
					enable = true,
					-- disable = { "python" },
				},
				rainbow = {
					enable = true,
					extended_mode = true, -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
					max_file_lines = 1000, -- Do not enable for files with more than 1000 lines, int
				},
				incremental_selection = {
					enable = true,
					keymaps = {
						node_incremental = ";",
						node_decremental = ",",
					},
				},
				refactor = {
					-- highlight_definitions = {
					--   enable = true,
					--   -- Set to false if you have an `updatetime` of ~100.
					--   clear_on_cursor_move = true,
					-- },
					-- highlight_current_scope = { enable = true },
					smart_rename = {
						enable = true,
						keymaps = {
							smart_rename = "<localleader>r",
						},
					},
					navigation = {
						enable = true,
						keymaps = {
							goto_definition = "<leader>J",
							list_definitions = "`<nop>`",
							list_definitions_toc = "`<nop>`",
							goto_next_usage = "<a-*>",
							goto_previous_usage = "<a-#>",
						},
					},
				},
				textobjects = {
					select = {
						enable = true,

						-- Automatically jump forward to textobj, similar to targets.vim
						lookahead = true,

						keymaps = {
							-- You can use the capture groups defined in textobjects.scm
							-- ["ib"] = "@block.inner",
							-- ["ab"] = "@block.outer",
							["ik"] = "@call.inner",
							["ak"] = "@call.outer",
							["aC"] = "@class.outer",
							["iC"] = "@class.inner",
							["aK"] = "@comment.outer",
							["ic"] = "@conditional.inner",
							["ac"] = "@conditional.outer",
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["il"] = "@loop.inner",
							["al"] = "@loop.outer",
							["ip"] = "@parameter.inner",
							["ap"] = "@parameter.outer",
							["as"] = "@statement.outer",
						},
						selection_modes = {
							-- 	['@parameter.outer'] = 'v', -- charwise
							-- ["@function.outer"] = "V", -- linewise
							-- 	['@class.outer'] = '<c-v>', -- blockwise
						},
					},
					swap = {
						enable = true,
					},
					move = {
						enable = true,
						set_jumps = true, -- whether to set jumps in the jumplist
					},
					lsp_interop = {
						enable = true,
						floating_preview_opts = { max_height = 9 },
					},
				},
				playground = {
					enable = true,
					disable = {},
					updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
					persist_queries = false, -- Whether the query persists across vim sessions
					keybindings = {
						toggle_query_editor = "o",
						toggle_hl_groups = "i",
						toggle_injected_languages = "t",
						toggle_anonymous_nodes = "a",
						toggle_language_display = "I",
						focus_language = "f",
						unfocus_language = "F",
						update = "R",
						goto_node = "<cr>",
						show_help = "?",
					},
				},
				query_linter = {
					enable = false,
					use_virtual_text = true,
					lint_events = { "BufWrite", "CursorHold" },
				},
				endwise = {
					enable = true,
				},
				matchup = {
					enable = true, -- mandatory, false will disable the whole extension
					-- disable = { },  -- optional, list of language that will be disabled
					-- [options]
					-- do not use virtual text to highlight the virtual end of a block,
					-- for languages without explicit end markers
					disable_virtual_text = true,
					-- include_match_words = {''},
				},
			})
			vim.cmd([[
		highlight! TSDefinition gui=underline
		highlight! TSDefinitionUsage gui=bold

		highlight! link TreesitterContext CursorLine
		]])

			-- TODO: Make more general
			local get_text_object = function()
				local info =
					vim.inspect_pos(nil, nil, nil, { syntax = false, extmarks = false, semantic_tokens = false })
				local ts_info = info.treesitter[1]

				if not ts_info then
					return
				end

				local lang = ts_info.lang
				local query = vim.treesitter.query.get_query(lang, "textobjects")
				local node = vim.treesitter.get_node_at_pos(0, info.row, info.col + 1, {})

				while not query.captures[query:iter_captures(node, info.buffer)()] do
					node = node:parent()
				end

				local textobject
				for id, _, _ in query:iter_captures(node, 0) do
					local name = query.captures[id] -- name of the capture in the query
					if name ~= "block.outer" then
						textobject = name
						print(textobject)
						break
					end
				end

				return "@" .. textobject
			end

			local function match(fwd)
				local row, col = unpack(vim.api.nvim_win_get_cursor(0))
				local node = vim.treesitter.get_node_at_pos(0, row - 1, col, {})

				if node:type() ~= "string" then
					vim.api.nvim_call_function("matchup#motion#find_matching_pair", { 0, fwd and 1 or 0 })
					return
				end

				local row1, col1, row2, col2 = node:range() -- range of the capture
				row1, row2 = row1 + 1, row2 + 1
				col2 = col2 - 1
				local match_begin = { row1, col1 }
				local match_end = { row2, col2 }
				local current_pos = { row, col }
				if not fwd then
					match_begin, match_end = match_end, match_begin
				end

				vim.api.nvim_win_set_cursor(0, vim.deep_equal(current_pos, match_end) and match_begin or match_end)
			end

			vim.keymap.set("", "%", function()
				match(true)
			end, { silent = true })
			vim.keymap.set("", "g%", function()
				match(false)
			end, { silent = true })

			vim.keymap.set(
				"n",
				"sp",
				mk_repeatable(function()
					require("nvim-treesitter.textobjects.swap").swap_previous(get_text_object())
				end),
				{ silent = true }
			)

			vim.keymap.set(
				"n",
				"sn",
				mk_repeatable(function()
					require("nvim-treesitter.textobjects.swap").swap_next(get_text_object())
				end),
				{ silent = true }
			)

			vim.keymap.set("n", "<leader>i", function()
				local func = require("nvim-treesitter.textobjects.lsp_interop").peek_definition_code
				local captures = vim.treesitter.get_captures_at_cursor()
				if vim.tbl_contains(captures, "constructor") or vim.tbl_contains(captures, "type") then
					func("@class.outer")
				else
					func("@function.outer")
				end
			end, { silent = true })
		end,
	},
}
