return {
	"Shougo/ddc.vim",
	ft = { "python", "lua", "json", "toml", "yaml", "haskell" },
	dependencies = {
		"vim-denops/denops.vim",
		{
			"matsui54/denops-popup-preview.vim",
			config = function()
				vim.g.popup_preview_config = {
					border = false,
					winblend = 30,
					maxHeight = 12,
					supportUltisnips = true,
				}
			end,
		},
		"matsui54/ddc-ultisnips",
		"LumaKernel/ddc-file",
		"Shougo/ddc-converter_remove_overlap",
		"Shougo/ddc-source-lsp",
		"Shougo/ddc-source-around",
		"Shougo/ddc-ui-inline",
		"Shougo/ddc-ui-native",
		"tani/ddc-fuzzy",
		"tani/ddc-path",
		"SirVer/ultisnips",
		"onsails/lspkind-nvim", -- LSP pictograms
		{
			"SirVer/ultisnips",
			dependencies = { "honza/vim-snippets" },
			config = function()
				vim.g.UltiSnipsSnippetDirectories =
					{ os.getenv("HOME") .. "/.local/share/nvim/site/pack/packer/start/vim-snippets/UltiSnips" }

				vim.g.UltiSnipsExpandTrigger = "`<nop>`"
				vim.g.UltiSnipsJumpForwardTrigger = "<tab>"
				vim.g.UltiSnipsJumpBackwardTrigger = "<s-tab>"
				vim.g.ultisnips_python_style = "numpy"
			end,
		},
	},

	config = function()
		local api = vim.api
		local call = api.nvim_call_function
		local npairs = require("nvim-autopairs")

		local insert_snippet_or_tab = function()
			if call("UltiSnips#CanExpandSnippet", {}) == 1 then
				call("UltiSnips#ExpandSnippet", {})
			else
				api.nvim_feedkeys(vim.keycode("<tab>"), "n", false)
			end
		end

		local get_wuc_start_col = function()
			local word_under_cursor = call("expand", { "<cword>" })
			-- print(word_under_cursor)
			return call("searchpos", { word_under_cursor, "Wcnb" })[2] - 1
		end
		-- TextChangedP
		local insert_suggestion = function(suggestion)
			local row, col = unpack(api.nvim_win_get_cursor(0))
			api.nvim_win_set_cursor(0, { row, col - 1 })
			local captures = vim.treesitter.get_captures_at_cursor()

			local is_punctuation = vim.iter(captures):any(function(capture)
				return capture:match("^punctuation%.")
			end)

			-- print(api.nvim_get_current_line():sub(col, col))
			local word_under_cursor_start_col = (is_punctuation or api.nvim_get_current_line():sub(col, col) == "/")
					and col
				or get_wuc_start_col()
			-- print(is_punctuation, col)
			-- print(word_under_cursor_start_col)
			api.nvim_win_set_cursor(0, { row, col })
			local construct = string.rep(vim.keycode("<BS>"), col - word_under_cursor_start_col)

			api.nvim_feedkeys(construct .. suggestion, "n", false)
		end

		local wise_tab = function()
			local items = vim.g["ddc#_items"]
			local complete_pos = vim.g["ddc#_complete_pos"]

			if not vim.tbl_isempty(items) and complete_pos >= 0 then
				local item = items[1]
				local prev_input = api.nvim_get_current_line():sub(1, api.nvim_win_get_cursor(0)[2])
				local suggestion = item["word"]

				if vim.endswith(prev_input, suggestion) then
					insert_snippet_or_tab()
				else
					call("ddc#_notify", { "hide", { "CompleteDone" } })
					vim.v.completed_item = item
					vim.g["ddc#_skip_next_complete"] = vim.g["ddc#_skip_next_complete"] + 1
					insert_suggestion(suggestion)
					call("ddc#on_complete_done", { item })
				end
			else
				api.nvim_feedkeys(vim.keycode("<tab>"), "n", false)
			end
		end

		local opts = { silent = true, noremap = true }
		local opts_expr = vim.tbl_extend("error", opts, { expr = true })

		vim.keymap.set("i", "<Tab>", function()
			if call("pumvisible", {}) == 1 then
				api.nvim_feedkeys(vim.keycode("<Down>"), "n", false)
			else
				wise_tab()
			end
		end, opts)

		vim.keymap.set("i", "<S-Tab>", function()
			if call("pumvisible", {}) == 1 then
				api.nvim_feedkeys(vim.keycode("<Up>"), "n", false)
			else
				vim.fn["ddc#map#manual_complete"]({ sources = { "lsp" }, ui = "native" })
			end
		end, opts_expr)

		vim.keymap.set("i", "<CR>", function()
			return call("pumvisible", {}) == 1 and "<C-y>" or vim.api.nvim_feedkeys(npairs.autopairs_cr(), "n", false)
		end, opts_expr)

		vim.keymap.set("i", "<ESC>", function()
			if call("pumvisible", {}) == 1 then
				call("ddc#_notify", { "hide", { "CompleteDone" } })
				return "<C-e>"
			else
				return "<ESC>"
			end
		end, opts_expr)

		vim.cmd([[
			call ddc#custom#load_config(expand('$HOME') . "/.dotfiles/nvim/ddc.ts")
			call popup_preview#enable()
			call ddc#enable(#{context_filetype: 'treesitter'})
				]])
	end,
}
