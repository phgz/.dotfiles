return {
	"Shougo/ddc.vim",
	event = "InsertEnter",
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
		"Shougo/ddc-nvim-lsp",
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

		local _denops_running = function()
			return vim.g.loaded_denops
				and call("denops#server#status", {}) == "running"
				and call("denops#plugin#is_loaded", { "ddc" }) == 1
		end

		local feed_special = function(action)
			api.nvim_feedkeys(api.nvim_replace_termcodes(action, true, false, true), "n", false)
		end

		local insert_snippet_or_tab = function()
			if call("UltiSnips#CanExpandSnippet", {}) == 1 then
				call("UltiSnips#ExpandSnippet", {})
			else
				feed_special("<tab>")
			end
		end

		local get_wuc_start_col = function()
			local word_under_cursor = call("expand", { "<cword>" })
			print(word_under_cursor)
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

			print(api.nvim_get_current_line():sub(col, col))
			local word_under_cursor_start_col = (is_punctuation or api.nvim_get_current_line():sub(col, col) == "/")
					and col
				or get_wuc_start_col()
			print(is_punctuation, col)
			print(word_under_cursor_start_col)
			api.nvim_win_set_cursor(0, { row, col })
			local bs_seq = api.nvim_replace_termcodes("<BS>", true, true, true)
			local construct = string.rep(bs_seq, col - word_under_cursor_start_col)

			api.nvim_feedkeys(construct .. suggestion, "n", false)
		end

		local wise_tab = function()
			local items = vim.g["ddc#_items"]
			local complete_pos = vim.g["ddc#_complete_pos"]

			if not vim.tbl_isempty(items) and complete_pos >= 0 then
				local item = items[1]
				local prev_input = api.nvim_get_current_line()
				local suggestion = item["word"]

				if vim.endswith(prev_input, suggestion) then
					insert_snippet_or_tab()
				else
					vim.v.completed_item = item
					call("ddc#_notify", { "hide", { "CompleteDone" } })
					if type(item.user_data) == "table" then
						call("denops#request", { "ddc", "onCompleteDone", { item.__sourceName, item.user_data } })
					end
					-- Is this nvim_create_autocmd necessary?
					-- api.nvim_cmd("TextChangedI", {
					-- 	once = true,
					-- 	group = "ddc",
					-- 	callback = function()
					-- 		vim.v.completed_item = item
					-- 		api.nvim_exec_autocmds("CompleteDone", {
					-- 			modeline = false,
					-- 		})
					-- 	end,
					-- })
					insert_suggestion(suggestion)
				end
			else
				feed_special("<tab>")
			end
		end

		local manual_complete = function(opts)
			if not _denops_running() then
				call("ddc#enable", {})
				call("denops#plugin#wait", { "ddc" })
			end

			call("denops#notify", { "ddc", "manualComplete", { opts } })
		end

		local opts = { silent = true, noremap = true }
		local opts_expr = vim.tbl_extend("error", opts, { expr = true })

		vim.keymap.set("i", "<Tab>", function()
			if call("pumvisible", {}) == 1 then
				feed_special("<C-n>")
			else
				wise_tab()
			end
		end, opts)

		vim.keymap.set("i", "<S-Tab>", function()
			if call("pumvisible", {}) == 1 then
				feed_special("<C-p>")
			else
				manual_complete({ sources = { "nvim-lsp" }, ui = "native" })
			end
		end, opts)
		local npairs = require("nvim-autopairs")
		vim.keymap.set("i", "<CR>", function()
			return call("pumvisible", {}) == 1 and "<C-y>" or npairs.autopairs_cr()
		end, opts_expr)

		vim.keymap.set("i", "<ESC>", function()
			return call("pumvisible", {}) == 1 and "<C-e>" or "<ESC>"
		end, opts_expr)

		vim.cmd([[
			call ddc#custom#load_config(expand('$HOME') . "/.dotfiles/nvim/ddc.ts")
			call popup_preview#enable()
			call ddc#enable(#{context_filetype: 'treesitter'})
				]])
	end,
}
