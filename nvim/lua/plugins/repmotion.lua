return {
	{
		"Houl/repmo-vim",
		dependencies = "dahu/vim-fanfingtastic", -- Use f/F/t/T multiline
		keys = { { "[", mode = { "x", "n" } }, { "]", mode = { "n", "x" } } },
		config = function()
			local map = vim.api.nvim_set_keymap

			vim.g.fing_enabled = 0

			local register_comamnd = function(kind, with_end)
				local common_part = '\'<cmd>lua require"nvim-treesitter.textobjects.move"'
				local ns = string.format('%s.goto_next_start("@%s.outer")<cr>\'', common_part, kind)
				local ps = string.format('%s.goto_previous_start("@%s.outer")<cr>\'', common_part, kind)
				if with_end then
					local ne = string.format('%s.goto_next_end("@%s.outer")<cr>\'', common_part, kind)
					local pe = string.format('%s.goto_previous_end("@%s.outer")<cr>\'', common_part, kind)
					return { ns = ns, ps = ps, ne = ne, pe = pe }
				end
				return { ns = ns, ps = ps }
			end

			local kinds = { "function", "block", "conditional", "loop", "class" }
			local kinds_no_end = { "parameter", "statement", "call", "comment" }

			local mapping = {}

			for _, k in ipairs(kinds) do
				mapping[k] = register_comamnd(k, true)
			end

			for _, k in ipairs(kinds_no_end) do
				mapping[k] = register_comamnd(k, false)
			end

			local next_hunk = "&diff ? ']h' : '<cmd>lua require\"gitsigns.actions\".next_hunk()<CR>'"
			local prev_hunk = "&diff ? '[h' : '<cmd>lua require\"gitsigns.actions\".prev_hunk()<CR>'"
			mapping.hunk = { ns = next_hunk, ps = prev_hunk }

			local next_diagnostic = "'<cmd>lua vim.diagnostic.goto_next({ float = { border = \"none\" } })<CR>'"
			local prev_diagnostic = "'<cmd>lua vim.diagnostic.goto_prev({ float = { border = \"none\" } })<CR>'"
			mapping.diagnostic = { ns = next_diagnostic, ps = prev_diagnostic }

			local next_quote = "'<cmd>lua require\"utils\".goto_quote(true)<CR>'"
			local prev_quote = "'<cmd>lua require\"utils\".goto_quote(false)<CR>'"
			mapping.quote = { ns = next_quote, ps = prev_quote }

			local next_fold = "'<cmd>norm! zj<CR>'"
			local prev_fold = "'<cmd>norm! zk<CR>'"
			mapping.zfold = { ns = next_fold, ps = prev_fold }

			local next_line = "'<cmd>norm! j<CR>'"
			local prev_line = "'<cmd>norm! k<CR>'"
			mapping["<cr>"] = { ns = next_line, ps = prev_line }

			local next_col = "'<cmd>norm! l<CR>'"
			local prev_col = "'<cmd>norm! h<CR>'"
			mapping["<space>"] = { ns = next_col, ps = prev_col }

			local next_match = "'<plug>(matchup-]%)'"
			local prev_match = "'<plug>(matchup-[%)'"
			mapping["%"] = { ns = next_match, ps = prev_match }

			mapping.kall = mapping.call
			mapping.call = nil
			mapping.Komment = mapping.comment
			mapping.comment = nil
			mapping.record = mapping.class
			mapping.class = nil

			local opts_noremap = { expr = true, noremap = true, silent = true }
			local opts = { expr = true, noremap = false, silent = true }

			local map_cmd = function(c, direction)
				for _, mode in ipairs({ "n", "x", "o" }) do
					map(
						mode,
						"]" .. c,
						string.format("repmo#Key(%s,%s) <bar> sunmap ]%s)", direction.ns, direction.ps, c),
						opts
					)
					map(
						mode,
						"[" .. c,
						string.format("repmo#Key(%s,%s) <bar> sunmap [%s)", direction.ps, direction.ns, c),
						opts
					)

					if direction.ne then
						map(
							mode,
							"]" .. c:upper(),
							string.format("repmo#Key(%s,%s) <bar> sunmap ]%s)", direction.ne, direction.pe, c:upper()),
							opts
						)
						map(
							mode,
							"[" .. c:upper(),
							string.format("repmo#Key(%s,%s) <bar> sunmap [%s)", direction.pe, direction.ne, c:upper()),
							opts
						)
					end
				end
			end

			for k, v in pairs(mapping) do
				local char = k:sub(1, 1)
				if vim.startswith(char, "<") then
					char = k
				end
				map_cmd(char, v)
			end

			map("", "]m", 'repmo#SelfKey("]m", "[m") <bar> sunmap ]m', opts_noremap)
			map("", "[m", 'repmo#SelfKey("[m", "]m") <bar> sunmap [m', opts_noremap)

			map("n", ";", 'repmo#LastKey("<Plug>fanfingtastic_;") <bar> sunmap ;', opts)
			map("n", ",", 'repmo#LastRevKey("<Plug>fanfingtastic_,") <bar> sunmap ,', opts)

			map("n", "f", 'repmo#ZapKey("<Plug>fanfingtastic_f") <bar> sunmap f', opts)
			map("n", "F", 'repmo#ZapKey("<Plug>fanfingtastic_F") <bar> sunmap F', opts)
			map("n", "t", 'repmo#ZapKey("<Plug>fanfingtastic_t") <bar> sunmap t', opts)
			map("n", "T", 'repmo#ZapKey("<Plug>fanfingtastic_T") <bar> sunmap T', opts)
		end,
	},
}