return {
	"Shougo/ddc.vim",
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
		"Shougo/ddc-filter-sorter_rank",
		"Shougo/ddc-source-around",
		"Shougo/ddc-source-lsp",
		"Shougo/ddc-ui-inline",
		"Shougo/ddc-ui-native",
		"octaltree/cmp-look",
		"tani/ddc-fuzzy",
	},

	config = function()
		local api = vim.api
		local call = api.nvim_call_function
		local npairs = require("nvim-autopairs")

		local get_snippet = function(item)
			local lsp_item = vim.json.decode(vim.tbl_get(item, "user_data", "lspitem"))
			if
				lsp_item
				and lsp_item.insertTextFormat
				and lsp_item.insertTextFormat == 2
				and lsp_item.kind == vim.lsp.protocol.CompletionItemKind.Snippet
			then
				local snippet_text = lsp_item.insertText:gsub("${(%d).-}", "$%1")
				assert(snippet_text, "Language server indicated it had a snippet, but no snippet text could be found!")
				return snippet_text
			else
				return nil
			end
		end

		local jump_inside_snippet = function(direction)
			if vim.snippet.jumpable(direction) then
				return "<cmd>lua vim.snippet.jump(" .. direction .. ")<cr>"
			else
				return ""
			end
		end

		local get_wuc_start_col = function()
			local word_under_cursor = call("expand", { "<cword>" })
			return call("searchpos", { word_under_cursor, "Wcnb" })[2] - 1
		end

		-- TextChangedP
		local insert_suggestion = function(suggestion, is_snippet)
			local row, col = unpack(api.nvim_win_get_cursor(0))
			api.nvim_win_set_cursor(0, { row, col - 1 })
			local captures = vim.treesitter.get_captures_at_cursor()

			local is_punctuation = vim.iter(captures):any(function(capture)
				return capture:match("^punctuation%.")
			end)

			local word_under_cursor_start_col = (is_punctuation or api.nvim_get_current_line():sub(col, col) == "/")
					and col
				or get_wuc_start_col()
			api.nvim_win_set_cursor(0, { row, col })

			if is_snippet then
				api.nvim_buf_set_text(0, row - 1, word_under_cursor_start_col, row - 1, col, {})
				vim.snippet.expand(suggestion)
				assert(vim.snippet.active(), "Snippet did not expand.")
			else
				local construct = string.rep(vim.keycode("<BS>"), col - word_under_cursor_start_col)
				api.nvim_feedkeys(construct .. suggestion, "n", false)
			end
		end

		local wise_tab = function()
			local items = vim.g["ddc#_items"]
			local complete_pos = vim.g["ddc#_complete_pos"]

			if not vim.tbl_isempty(items) and complete_pos >= 0 then
				local item = items[1]
				local prev_input = api.nvim_get_current_line():sub(1, api.nvim_win_get_cursor(0)[2])
				local suggestion = item["word"]

				if vim.endswith(prev_input, suggestion) then
					local snippet_text = get_snippet(item)
					if snippet_text then
						insert_suggestion(snippet_text, true)
					else
						api.nvim_feedkeys(vim.keycode("<tab>"), "n", false)
					end
				else
					call("ddc#denops#_notify", { "hide", { "CompleteDone" } })
					vim.v.completed_item = item
					vim.g["ddc#_skip_next_complete"] = vim.g["ddc#_skip_next_complete"] + 1
					insert_suggestion(suggestion, false)
					call("ddc#on_complete_done", { item })
				end
			else
				api.nvim_feedkeys(vim.keycode("<tab>"), "n", false)
			end
		end

		local opts = { silent = true, noremap = true }
		local opts_expr = vim.tbl_extend("error", opts, { expr = true })

		local has_registered_scroll_preview_keymaps = false
		local keymaps_registry = {}
		local register_scroll_preview_keymaps = function()
			if not has_registered_scroll_preview_keymaps then
				keymaps_registry =
					{ vim.fn.maparg("<C-f>", "i", false, true), vim.fn.maparg("<C-b>", "i", false, true) }
				vim.keymap.set("i", "<C-f>", function()
					vim.fn["popup_preview#scroll"](4)
				end, opts_expr)
				vim.keymap.set("i", "<C-b>", function()
					vim.fn["popup_preview#scroll"](-4)
				end, opts_expr)
				has_registered_scroll_preview_keymaps = true
			end
		end
		local unregister_scroll_preview_keymaps = function()
			local keymaps = keymaps_registry
			vim.fn.mapset("i", false, keymaps[1])
			vim.fn.mapset("i", false, keymaps[2])
			has_registered_scroll_preview_keymaps = false
		end

		vim.keymap.set("i", "<Tab>", function()
			if call("pumvisible", {}) == 1 then
				api.nvim_feedkeys(vim.keycode("<Down>"), "n", false)
				register_scroll_preview_keymaps()
			else
				wise_tab()
			end
		end, opts)

		vim.keymap.set("i", "<S-Tab>", function()
			if call("pumvisible", {}) == 1 then
				api.nvim_feedkeys(vim.keycode("<Up><Up><Down>"), "n", false)
				register_scroll_preview_keymaps()
			else
				vim.fn["ddc#map#manual_complete"]({ sources = { "lsp" }, ui = "native" })
			end
		end, opts)

		vim.keymap.set("i", "<CR>", function()
			if call("pumvisible", {}) == 1 then
				unregister_scroll_preview_keymaps()
				return "<C-y>"
			else
				return vim.api.nvim_feedkeys(npairs.autopairs_cr(), "n", false)
			end
		end, opts_expr)

		vim.keymap.set("i", "<ESC>", function()
			if call("pumvisible", {}) == 1 then
				call("ddc#denops#_notify", { "hide", { "CompleteDone" } })
				unregister_scroll_preview_keymaps()
				return "<C-e>"
			else
				return "<ESC>"
			end
		end, opts_expr)

		vim.keymap.set("i", "<C-[>", function()
			return jump_inside_snippet(-1)
		end, { expr = true })
		vim.keymap.set("i", "<C-]>", function()
			return jump_inside_snippet(1)
		end, { expr = true })

		vim.cmd([[
			call ddc#custom#load_config(expand('$HOME') . "/.dotfiles/nvim/ddc.ts")
			call popup_preview#enable()
			call signature_help#enable()
			call ddc#enable(#{context_filetype: 'treesitter'})
				]])
	end,
}
