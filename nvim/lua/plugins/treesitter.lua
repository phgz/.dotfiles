local api = vim.api
local fn = vim.fn
local keymap = vim.keymap

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

			local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")
			local utils = require("utils")
			local gs = require("gitsigns")
			local gs_is_open = require("gitsigns.popup").is_open

			local gs_cache = require("gitsigns.cache")
			local Hunks = require("gitsigns.hunks")

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
						enable = false,
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
							["abe"] = "@binary.outer",
							["ibl"] = "@binary.lhs",
							["ibr"] = "@binary.rhs",
							["abo"] = "@boolean",
							["ak"] = "@call.outer",
							["ik"] = "@call.inner",
							["aC"] = "@class.outer",
							["iC"] = "@class.inner",
							["aK"] = "@comment.outer",
							["iK"] = "@comment.outer",
							["ac"] = "@conditional.outer",
							["ic"] = "@conditional.inner",
							["ad"] = "@dictionary.outer",
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["al"] = "@loop.outer",
							["il"] = "@loop.inner",
							["aL"] = "@list.outer",
							["an"] = "@number.inner",
							["in"] = "@number.inner",
							["ap"] = "@parameter.outer",
							["ip"] = "@parameter.inner",
							["ar"] = "@return.outer",
							["ir"] = "@return.inner",
							["as"] = "@string.outer",
							["is"] = "@string.inner",
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
							["]be"] = "@binary.outer",
							["]bl"] = "@binary.lhs",
							["]br"] = "@binary.rhs",
							["]bo"] = "@boolean",
							["]a"] = "@assignment.lhs",
							["]v"] = "@assignment.rhs",
							["]k"] = "@call.outer",
							["]C"] = "@class.outer",
							["]K"] = "@comment.outer",
							["]c"] = "@conditional.outer",
							["]d"] = "@dictionary.outer",
							["]f"] = "@function.outer",
							["]l"] = "@loop.outer",
							["]L"] = "@list.outer",
							["]n"] = "@number.inner",
							["]p"] = "@parameter.inner",
							["]r"] = "@return.outer",
							["]s"] = "@string.outer",
						},
						goto_next_end = {
							["]gbe"] = "@binary.outer",
							["]gbl"] = "@binary.lhs",
							["]gbr"] = "@binary.rhs",
							["]gbo"] = "@boolean",
							["]ga"] = "@assignment.lhs",
							["]gv"] = "@assignment.rhs",
							["]gk"] = "@call.outer",
							["]gC"] = "@class.outer",
							["]gK"] = "@comment.outer",
							["]gc"] = "@conditional.outer",
							["]gd"] = "@dictionary.outer",
							["]gf"] = "@function.outer",
							["]gl"] = "@loop.outer",
							["]gL"] = "@list.outer",
							["]gn"] = "@number.inner",
							["]gp"] = "@parameter.inner",
							["]gr"] = "@return.outer",
							["]gs"] = "@string.outer",
						},
						goto_previous_start = {
							["[be"] = "@binary.outer",
							["[bl"] = "@binary.lhs",
							["[br"] = "@binary.rhs",
							["[bo"] = "@boolean",
							["[a"] = "@assignment.lhs",
							["[v"] = "@assignment.rhs",
							["[k"] = "@call.outer",
							["[C"] = "@class.outer",
							["[K"] = "@comment.outer",
							["[c"] = "@conditional.outer",
							["[d"] = "@dictionary.outer",
							["[f"] = "@function.outer",
							["[l"] = "@loop.outer",
							["[L"] = "@list.outer",
							["[n"] = "@number.inner",
							["[p"] = "@parameter.inner",
							["[r"] = "@return.outer",
							["[s"] = "@string.outer",
						},
						goto_previous_end = {
							["[gbe"] = "@binary.outer",
							["[gbl"] = "@binary.lhs",
							["[gbr"] = "@binary.rhs",
							["[gbo"] = "@boolean",
							["[ga"] = "@assignment.lhs",
							["[gv"] = "@assignment.rhs",
							["[gk"] = "@call.outer",
							["[gC"] = "@class.outer",
							["[gK"] = "@comment.outer",
							["[gc"] = "@conditional.outer",
							["[gd"] = "@dictionary.outer",
							["[gf"] = "@function.outer",
							["[gL"] = "@list.outer",
							["[gn"] = "@number.inner",
							["[gp"] = "@parameter.inner",
							["[gr"] = "@return.outer",
							["[gs"] = "@string.outer",
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
				local info = vim.inspect_pos(
					nil,
					nil,
					nil,
					{ syntax = false, extmarks = false, semantic_tokens = false, treesitter = true }
				)
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
					return name ~= "block.outer"
				end)

				return "@" .. query.captures[capture_id]
			end

			local pair_diagnostic_end = function(severity)
				return ts_repeat_move.make_repeatable_move_pair(function()
					local diagnostic_range = utils.get_diagnostic_under_cursor_range()
					if
						diagnostic_range and not vim.deep_equal(api.nvim_win_get_cursor(0), diagnostic_range.end_pos)
					then
						api.nvim_win_set_cursor(0, diagnostic_range.end_pos)
						vim.defer_fn(function()
							vim.diagnostic.open_float({ scope = "cursor" })
						end, 1)
					else
						vim.diagnostic.jump({
							count = 1,
							float = { border = "none" },
							severity = vim.diagnostic.severity[severity],
							wrap = false,
						})
						diagnostic_range = utils.get_diagnostic_under_cursor_range()
						if diagnostic_range then
							api.nvim_win_set_cursor(0, diagnostic_range.end_pos)
						end
					end
				end, function()
					local diagnostic_range = utils.get_diagnostic_under_cursor_range()

					vim.diagnostic.jump({
						count = -1,
						float = { border = "none" },
						severity = vim.diagnostic.severity[severity],
						wrap = false,
						pos = diagnostic_range and { diagnostic_range.start_pos[1], diagnostic_range.start_pos[2] - 1 }
							or nil,
					})

					diagnostic_range = utils.get_diagnostic_under_cursor_range()
					if diagnostic_range then
						api.nvim_win_set_cursor(0, diagnostic_range.end_pos)
					end
				end)
			end

			local pair_diagnostic_start = function(severity)
				return ts_repeat_move.make_repeatable_move_pair(function()
					vim.diagnostic.jump({
						count = 1,
						float = { border = "none" },
						wrap = false,
						severity = vim.diagnostic.severity[severity],
					})
				end, function()
					vim.diagnostic.jump({
						count = -1,
						float = { border = "none" },
						wrap = false,
						severity = vim.diagnostic.severity[severity],
					})
				end)
			end

			local next_diagnostic_start, prev_diagnostic_start = pair_diagnostic_start()
			local next_diagnostic_start_hint, prev_diagnostic_start_hint = pair_diagnostic_start("HINT")
			local next_diagnostic_start_info, prev_diagnostic_start_info = pair_diagnostic_start("INFO")
			local next_diagnostic_start_warning, prev_diagnostic_start_warning = pair_diagnostic_start("WARN")
			local next_diagnostic_start_error, prev_diagnostic_start_error = pair_diagnostic_start("ERROR")

			local next_diagnostic_end, prev_diagnostic_end = pair_diagnostic_end()
			local next_diagnostic_end_hint, prev_diagnostic_end_hint = pair_diagnostic_end("HINT")
			local next_diagnostic_end_info, prev_diagnostic_end_info = pair_diagnostic_end("INFO")
			local next_diagnostic_end_warning, prev_diagnostic_end_warning = pair_diagnostic_end("WARN")
			local next_diagnostic_end_error, prev_diagnostic_end_error = pair_diagnostic_end("ERROR")

			local diagnostic_wrapper = function(func)
				return function()
					func()
					vim.cmd("redrawstatus")
				end
			end

			local next_hunk = function(opts)
				return gs.nav_hunk("next", opts)
			end
			local prev_hunk = function(opts)
				return gs.nav_hunk("prev", opts)
			end

			local hunk_wrapper = function(func)
				return function()
					func()
					vim.cmd("redrawstatus")
					vim.defer_fn(function()
						local winid = gs_is_open("hunk")
						if winid then
							local filetype = vim.bo.filetype
							api.nvim_win_call(winid, function()
								vim.bo.filetype = filetype
								keymap.set("n", "q", "<cmd>close<cr>", { silent = true, buffer = true })
							end)
						end
					end, 1)
				end
			end

			-- ensure ; goes forward and , goes backward regardless of the last direction
			-- keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
			-- keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

			-- vim way: ; goes to the direction you were moving.
			keymap.set({ "n", "x", "o" }, ";", hunk_wrapper(ts_repeat_move.repeat_last_move))
			keymap.set({ "n", "x", "o" }, ",", hunk_wrapper(ts_repeat_move.repeat_last_move_opposite))

			local function get_cursor_hunk()
				local bufnr = api.nvim_get_current_buf()
				if not gs_cache.cache[bufnr] then
					return
				end
				local hunks = {}
				vim.list_extend(hunks, gs_cache.cache[bufnr].hunks or {})
				vim.list_extend(hunks, gs_cache.cache[bufnr].hunks_staged or {})

				local lnum = api.nvim_win_get_cursor(0)[1]

				return Hunks.find_hunk(lnum, hunks)
			end

			local hunk_opp = function(prev)
				return function()
					local view = fn.winsaveview()
					local cursor_hunk = get_cursor_hunk()
					local is_on_hunk_edge_or_outside = true
					if cursor_hunk then
						local hunk_start, hunk_end = cursor_hunk.added.start, cursor_hunk.vend
						local col_range_lt = prev and fn.col({ hunk_start, "$" }) - 1 or 0
						local col_range_gt = prev and fn.col("$") - 1 or 0
						local cursor_pos = api.nvim_win_get_cursor(0)
						is_on_hunk_edge_or_outside = utils.compare_pos(
							cursor_pos,
							{ hunk_start, col_range_lt },
							{ gt = false, eq = prev }
						) or utils.compare_pos(
							cursor_pos,
							{ hunk_end, col_range_gt },
							{ gt = true, eq = not prev }
						)
					end

					local opts = { navigation_message = false, preview = false }
					local wrap_opts = vim.tbl_extend("error", opts, { wrap = true })
					if is_on_hunk_edge_or_outside then
						if prev then
							local row_before_jump = api.nvim_win_get_cursor(0)[1]
							prev_hunk(opts)

							-- No prev hunk. We do not want to wrap and go to the first hunk. We want to stay still
							if api.nvim_win_get_cursor(0)[1] == row_before_jump then
								prev_hunk()
								fn.winrestview(view)
								return
							end
						else
							next_hunk(opts)
						end
					end
					if prev then
						prev_hunk(wrap_opts)
						next_hunk({ wrap = true })
					else
						api.nvim_win_set_cursor(0, { get_cursor_hunk().vend, 0 })
					end
					local cursor_pos = api.nvim_win_get_cursor(0)
					view.lnum = cursor_pos[1]
					view.col = cursor_pos[2]
					fn.winrestview(view)
				end
			end

			local next_hunk_start, prev_hunk_start = ts_repeat_move.make_repeatable_move_pair(next_hunk, hunk_opp(true))
			local next_hunk_end, prev_hunk_end = ts_repeat_move.make_repeatable_move_pair(hunk_opp(false), prev_hunk)

			local next_quote, prev_quote = ts_repeat_move.make_repeatable_move_pair(function()
				utils.goto_quote(true)
			end, function()
				utils.goto_quote(false)
			end)
			local next_fold, prev_fold = ts_repeat_move.make_repeatable_move_pair(function()
				vim.cmd("norm! zj")
			end, function()
				vim.cmd("norm! zk")
			end)
			local next_spell, prev_spell = ts_repeat_move.make_repeatable_move_pair(function()
				vim.cmd("norm! ]s")
			end, function()
				vim.cmd("norm! [s")
			end)
			-- local next_line, prev_line = ts_repeat_move.make_repeatable_move_pair(function()
			-- 	vim.cmd("norm! j")
			-- end, function()
			-- 	vim.cmd("norm! k")
			-- end)
			-- local next_col, prev_col = ts_repeat_move.make_repeatable_move_pair(function()
			-- 	vim.cmd("norm! l")
			-- end, function()
			-- 	vim.cmd("norm! h")
			-- end)
			local next_tab, prev_tab = ts_repeat_move.make_repeatable_move_pair(function()
				require("tabtree").next()
			end, function()
				require("tabtree").previous()
			end)
			local find_unmatched = function(visual, forward)
				return function()
					fn["matchup#motion#find_unmatched"](visual, forward)
				end
			end
			local nnext_match, nprev_match =
				ts_repeat_move.make_repeatable_move_pair(find_unmatched(0, 1), find_unmatched(0, 0))
			local xnext_match, xprev_match =
				ts_repeat_move.make_repeatable_move_pair(find_unmatched(1, 1), find_unmatched(1, 0))

			local rhs =
				"<cmd>lua require('multiline_ft').multiline_find(%s,%s,require('nvim-treesitter.textobjects.repeatable_move'))<cr>"
			keymap.set({ "n", "x" }, "f", string.format(rhs, "true", "false"))
			keymap.set({ "n", "x" }, "F", string.format(rhs, "false", "false"))
			keymap.set({ "n", "x" }, "t", string.format(rhs, "true", "true"))
			keymap.set({ "n", "x" }, "T", string.format(rhs, "false", "true"))
			keymap.set({ "n", "x", "o" }, "]h", hunk_wrapper(next_hunk_start))
			keymap.set({ "n", "x", "o" }, "[h", hunk_wrapper(prev_hunk_start))
			keymap.set({ "n", "x", "o" }, "]gh", hunk_wrapper(next_hunk_end))
			keymap.set({ "n", "x", "o" }, "[gh", hunk_wrapper(prev_hunk_end))
			keymap.set({ "n", "x", "o" }, "]D", diagnostic_wrapper(next_diagnostic_start))
			keymap.set({ "n", "x", "o" }, "[D", diagnostic_wrapper(prev_diagnostic_start))
			keymap.set({ "n", "x", "o" }, "]gD", diagnostic_wrapper(next_diagnostic_end))
			keymap.set({ "n", "x", "o" }, "[gD", diagnostic_wrapper(prev_diagnostic_end))
			keymap.set({ "n", "x", "o" }, "]H", diagnostic_wrapper(next_diagnostic_start_hint))
			keymap.set({ "n", "x", "o" }, "[H", diagnostic_wrapper(prev_diagnostic_start_hint))
			keymap.set({ "n", "x", "o" }, "]gH", diagnostic_wrapper(next_diagnostic_end_hint))
			keymap.set({ "n", "x", "o" }, "[gH", diagnostic_wrapper(prev_diagnostic_end_hint))
			keymap.set({ "n", "x", "o" }, "]I", diagnostic_wrapper(next_diagnostic_start_info))
			keymap.set({ "n", "x", "o" }, "[I", diagnostic_wrapper(prev_diagnostic_start_info))
			keymap.set({ "n", "x", "o" }, "]gI", diagnostic_wrapper(next_diagnostic_end_info))
			keymap.set({ "n", "x", "o" }, "[gI", diagnostic_wrapper(prev_diagnostic_end_info))
			keymap.set({ "n", "x", "o" }, "]W", diagnostic_wrapper(next_diagnostic_start_warning))
			keymap.set({ "n", "x", "o" }, "[W", diagnostic_wrapper(prev_diagnostic_start_warning))
			keymap.set({ "n", "x", "o" }, "]gW", diagnostic_wrapper(next_diagnostic_end_warning))
			keymap.set({ "n", "x", "o" }, "[gW", diagnostic_wrapper(prev_diagnostic_end_warning))
			keymap.set({ "n", "x", "o" }, "]E", diagnostic_wrapper(next_diagnostic_start_error))
			keymap.set({ "n", "x", "o" }, "[E", diagnostic_wrapper(prev_diagnostic_start_error))
			keymap.set({ "n", "x", "o" }, "]gE", diagnostic_wrapper(next_diagnostic_end_error))
			keymap.set({ "n", "x", "o" }, "[gE", diagnostic_wrapper(prev_diagnostic_end_error))
			keymap.set({ "n", "x", "o" }, "]q", next_quote)
			keymap.set({ "n", "x", "o" }, "[q", prev_quote)
			keymap.set({ "n", "x", "o" }, "]z", next_fold)
			keymap.set({ "n", "x", "o" }, "[z", prev_fold)
			-- keymap.set({ "n", "x", "o" }, "]<cr>", next_line)
			-- keymap.set({ "n", "x", "o" }, "[<cr>", prev_line)
			-- keymap.set({ "n", "x", "o" }, "]<space>", next_col)
			-- keymap.set({ "n", "x", "o" }, "[<space>", prev_col)
			keymap.set({ "n", "x", "o" }, "]<tab>", next_tab)
			keymap.set({ "n", "x", "o" }, "[<tab>", prev_tab)
			keymap.set({ "n" }, "]%", nnext_match)
			keymap.set({ "n" }, "[%", nprev_match)
			keymap.set({ "x" }, "]%", xnext_match)
			keymap.set({ "x" }, "[%", xprev_match)
			keymap.set({ "n" }, "]S", next_spell)
			keymap.set({ "n" }, "[S", prev_spell)
			keymap.set(
				"n",
				"sP",
				utils.mk_repeatable(function()
					require("nvim-treesitter.textobjects.swap").swap_previous(get_text_object())
				end),
				{ silent = true }
			)

			keymap.set(
				"n",
				"sN",
				utils.mk_repeatable(function()
					require("nvim-treesitter.textobjects.swap").swap_next(get_text_object())
				end),
				{ silent = true }
			)

			keymap.set("n", "<localleader>t", "<cmd>Inspect<cr>")
			keymap.set("n", "<localleader>T", "<cmd>InspectTree<cr>")
			keymap.set("n", "<leader>i", function()
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
