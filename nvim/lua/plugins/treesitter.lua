return {
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			"andymass/vim-matchup",
			"RRethy/nvim-treesitter-endwise", -- Add Delimiters for Pascal-like languages
			"nvim-treesitter/nvim-treesitter-textobjects", -- More text motions
			"nvim-treesitter/nvim-treesitter-refactor", -- Highlight definitions, Rename
		},
		build = function()
			vim.cmd("TSUpdate")
			vim.cmd("TSInstall all")
		end,
		config = function()
			vim.g.matchup_matchparen_offscreen = {}
			vim.g.matchup_matchparen_deferred = 0
			vim.g.matchup_motion_cursor_end = 0
			vim.g.matchup_text_obj_linewise_operators = { "d", "y" } -- "c"?
			vim.g.matchup_matchparen_pumvisible = 0
			vim.g.matchup_matchparen_nomode = "i"

			local call = vim.api.nvim_call_function
			local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")
			local mk_repeatable = require("utils").mk_repeatable
			require("nvim-treesitter.configs").setup({
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = { "python" },
				},
				indent = {
					enable = false,
				},
				incremental_selection = {
					enable = false,
					keymaps = {
						node_incremental = ";",
						node_decremental = ",",
					},
				},
				refactor = {
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
							list_definitions = false,
							list_definitions_toc = false,
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
							["aa"] = "@assignment.lhs",
							["ia"] = "@assignment.lhs",
							["av"] = "@assignment.rhs",
							["iv"] = "@assignment.rhs",
							["ak"] = "@call.outer",
							["ik"] = "@call.inner",
							["aC"] = "@class.outer",
							["iC"] = "@class.inner",
							["aK"] = "@comment.outer",
							["iK"] = "@comment.outer",
							["ac"] = "@conditional.outer",
							["ic"] = "@conditional.inner",
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["al"] = "@loop.outer",
							["il"] = "@loop.inner",
							["an"] = "@number.inner",
							["in"] = "@number.inner",
							["ap"] = "@parameter.outer",
							["ip"] = "@parameter.inner",
							["ar"] = "@return.outer",
							["ir"] = "@return.inner",
							["as"] = "@statement.outer",
							["is"] = "@statement.outer",
						},
						include_surrounding_whitespace = false,
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
						goto_next_start = {
							["]a"] = "@assignment.lhs",
							["]v"] = "@assignment.rhs",
							["]k"] = "@call.outer",
							["]C"] = "@class.outer",
							["]K"] = "@comment.outer",
							["]c"] = "@conditional.outer",
							["]f"] = "@function.outer",
							["]l"] = "@loop.outer",
							["]n"] = "@number.inner",
							["]p"] = "@parameter.inner",
							["]r"] = "@return.outer",
							["]s"] = "@statement.outer",
						},
						goto_next_end = {
							["]ga"] = "@assignment.lhs",
							["]gv"] = "@assignment.rhs",
							["]gk"] = "@call.outer",
							["]gC"] = "@class.outer",
							["]gK"] = "@comment.outer",
							["]gc"] = "@conditional.outer",
							["]gf"] = "@function.outer",
							["]gl"] = "@loop.outer",
							["]gn"] = "@number.inner",
							["]gp"] = "@parameter.inner",
							["]gr"] = "@return.outer",
							["]gs"] = "@statement.outer",
						},
						goto_previous_start = {
							["[a"] = "@assignment.lhs",
							["[v"] = "@assignment.rhs",
							["[k"] = "@call.outer",
							["[C"] = "@class.outer",
							["[K"] = "@comment.outer",
							["[c"] = "@conditional.outer",
							["[f"] = "@function.outer",
							["[l"] = "@loop.outer",
							["[n"] = "@number.inner",
							["[p"] = "@parameter.inner",
							["[r"] = "@return.outer",
							["[s"] = "@statement.outer",
						},
						goto_previous_end = {
							["[ga"] = "@assignment.lhs",
							["[gv"] = "@assignment.rhs",
							["[gk"] = "@call.outer",
							["[gC"] = "@class.outer",
							["[gK"] = "@comment.outer",
							["[gc"] = "@conditional.outer",
							["[gf"] = "@function.outer",
							["[gl"] = "@loop.outer",
							["[gn"] = "@number.inner",
							["[gp"] = "@parameter.inner",
							["[gr"] = "@return.outer",
							["[gs"] = "@statement.outer",
						},
					},
					lsp_interop = {
						enable = true,
						floating_preview_opts = { max_height = 9 },
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
					enable = false, -- mandatory, false will disable the whole extension
					enable_quotes = true,
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

			local get_text_object = function()
				local info =
					vim.inspect_pos(nil, nil, nil, { syntax = false, extmarks = false, semantic_tokens = false })
				local ts_info = info.treesitter[1]

				if not ts_info then
					return
				end

				local lang = ts_info.lang
				local query = vim.treesitter.query.get(lang, "textobjects")
				local node = vim.treesitter.get_node({ bufnr = 0, pos = { info.row, info.col + 1 } })

				while not query.captures[query:iter_captures(node, info.buffer)()] do
					node = node:parent()
				end

				local capture_id = vim.iter(query:iter_captures(node, 0)):find(function(id, _, _)
					local name = query.captures[id] -- name of the capture in the query
					-- print(id, name)
					return name ~= "block.outer"
				end)

				return "@" .. query.captures[capture_id]
			end

			local hunk_wrapper = function(fn)
				return function()
					fn()
					vim.defer_fn(function()
						local winid = require("gitsigns.popup").is_open("hunk")
						if winid then
							local filetype = vim.bo.filetype
							vim.api.nvim_win_call(winid, function()
								vim.bo.filetype = filetype
								vim.keymap.set("n", "q", "<cmd>close<cr>", { silent = true, buffer = true })
							end)
						end
					end, 1)
				end
			end

			-- ensure ; goes forward and , goes backward regardless of the last direction
			-- vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
			-- vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

			-- vim way: ; goes to the direction you were moving.
			vim.keymap.set({ "n", "x", "o" }, ";", hunk_wrapper(ts_repeat_move.repeat_last_move))
			vim.keymap.set({ "n", "x", "o" }, ",", hunk_wrapper(ts_repeat_move.repeat_last_move_opposite))
			local gs = require("gitsigns")
			local next_hunk, prev_hunk = ts_repeat_move.make_repeatable_move_pair(gs.next_hunk, gs.prev_hunk)
			local next_diagnostic, prev_diagnostic = ts_repeat_move.make_repeatable_move_pair(function()
				vim.diagnostic.goto_next({ float = { border = "none" } })
			end, function()
				vim.diagnostic.goto_prev({ float = { border = "none" } })
			end)
			local next_quote, prev_quote = ts_repeat_move.make_repeatable_move_pair(function()
				require("utils").goto_quote(true)
			end, function()
				require("utils").goto_quote(false)
			end)
			local next_fold, prev_fold = ts_repeat_move.make_repeatable_move_pair(function()
				vim.cmd("norm! zj")
			end, function()
				vim.cmd("norm! zk")
			end)
			local next_line, prev_line = ts_repeat_move.make_repeatable_move_pair(function()
				vim.cmd("norm! j")
			end, function()
				vim.cmd("norm! k")
			end)
			local next_col, prev_col = ts_repeat_move.make_repeatable_move_pair(function()
				vim.cmd("norm! l")
			end, function()
				vim.cmd("norm! h")
			end)
			local next_tab, prev_tab = ts_repeat_move.make_repeatable_move_pair(function()
				require("tabtree").next()
			end, function()
				require("tabtree").previous()
			end)
			local find_unmatched = function(visual, forward)
				return function()
					call("matchup#motion#find_unmatched", { visual, forward })
				end
			end
			local nnext_match, nprev_match =
				ts_repeat_move.make_repeatable_move_pair(find_unmatched(0, 1), find_unmatched(0, 0))
			local xnext_match, xprev_match =
				ts_repeat_move.make_repeatable_move_pair(find_unmatched(1, 1), find_unmatched(1, 0))

			local rhs =
				"<cmd>lua require('multiline_ft').multiline_find(%s,%s,require('nvim-treesitter.textobjects.repeatable_move'))<cr>"
			vim.keymap.set({ "n", "x" }, "f", string.format(rhs, "true", "false"))
			vim.keymap.set({ "n", "x" }, "F", string.format(rhs, "false", "false"))
			vim.keymap.set({ "n", "x" }, "t", string.format(rhs, "true", "true"))
			vim.keymap.set({ "n", "x" }, "T", string.format(rhs, "false", "true"))
			vim.keymap.set({ "n", "x", "o" }, "]h", hunk_wrapper(next_hunk))
			vim.keymap.set({ "n", "x", "o" }, "[h", hunk_wrapper(prev_hunk))
			vim.keymap.set({ "n", "x", "o" }, "]d", next_diagnostic)
			vim.keymap.set({ "n", "x", "o" }, "[d", prev_diagnostic)
			vim.keymap.set({ "n", "x", "o" }, "]q", next_quote)
			vim.keymap.set({ "n", "x", "o" }, "[q", prev_quote)
			vim.keymap.set({ "n", "x", "o" }, "]z", next_fold)
			vim.keymap.set({ "n", "x", "o" }, "[z", prev_fold)
			vim.keymap.set({ "n", "x", "o" }, "]<cr>", next_line)
			vim.keymap.set({ "n", "x", "o" }, "[<cr>", prev_line)
			vim.keymap.set({ "n", "x", "o" }, "]<space>", next_col)
			vim.keymap.set({ "n", "x", "o" }, "[<space>", prev_col)
			vim.keymap.set({ "n", "x", "o" }, "]<tab>", next_tab)
			vim.keymap.set({ "n", "x", "o" }, "[<tab>", prev_tab)
			vim.keymap.set({ "n" }, "]%", nnext_match)
			vim.keymap.set({ "n" }, "[%", nprev_match)
			vim.keymap.set({ "x" }, "]%", xnext_match)
			vim.keymap.set({ "x" }, "[%", xprev_match)
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

			vim.keymap.set("n", "<localleader>t", "<cmd>Inspect<cr>")
			vim.keymap.set("n", "<leader>i", function()
				local func = require("nvim-treesitter.textobjects.lsp_interop").peek_definition_code
				local captures = vim.treesitter.get_captures_at_cursor()
				if vim.list_contains(captures, "constructor") or vim.list_contains(captures, "type") then
					func("@class.outer")
				else
					func("@function.outer")
				end
			end, { silent = true })
		end,
	},
}
