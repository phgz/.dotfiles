local api = vim.api
local fn = vim.fn
local keymap = vim.keymap
local registry = require("registry")
local utils = require("utils")

vim.g.popup_preview_config = {
	border = false,
	winblend = 30,
	maxHeight = 12,
	supportUltisnips = false,
	supportVsnip = false,
}
vim.g.signature_help_config = {
	contentsStyle = "currentLabel",
	viewStyle = "virtual",
}

local get_snippet = function(item)
	local json_lsp_item = vim.tbl_get(item, "user_data", "lspitem")
	local lsp_item = json_lsp_item and vim.json.decode(json_lsp_item) or nil
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
	if vim.snippet.active({ direction = direction }) then
		return "<cmd>lua vim.snippet.jump(" .. direction .. ")<cr>"
	else
		return ""
	end
end

local get_wuc_start_col = function()
	local word_under_cursor = fn.expand("<cword>")
	return fn.searchpos(word_under_cursor, "Wcnb")[2] - 1
end

local insert_suggestion = function(suggestion, is_snippet, subword)
	local row, col = unpack(api.nvim_win_get_cursor(0))
	api.nvim_win_set_cursor(0, { row, col - 1 })
	local captures = vim.treesitter.get_captures_at_cursor()

	local is_punctuation = vim.iter(captures):any(function(capture)
		return capture:match("^punctuation%.")
	end)

	local word_under_cursor_start_col = (is_punctuation or api.nvim_get_current_line():sub(col, col):match("[./]"))
			and col
		or get_wuc_start_col()
	api.nvim_win_set_cursor(0, { row, col })

	if is_snippet then
		api.nvim_buf_set_text(0, row - 1, word_under_cursor_start_col, row - 1, col, {})
		vim.snippet.expand(suggestion)
		assert(vim.snippet.active(), "Snippet did not expand.")
	else
		if subword then
			local word_under_cursor_length = col - word_under_cursor_start_col
			local next_subword_pos = suggestion:find("[_%-%u]", word_under_cursor_length + 1)
			if next_subword_pos == word_under_cursor_length + 1 then
				next_subword_pos = suggestion:find("[_%-%u]", word_under_cursor_length + 2)
			end
			suggestion = next_subword_pos and suggestion:sub(1, next_subword_pos - 1) or suggestion
		end
		local bs_sequence = string.rep(vim.keycode("<BS>"), col - word_under_cursor_start_col)
		api.nvim_feedkeys(bs_sequence .. suggestion:match(".*[^?]"), "n", false)
	end
end

local smart_action = function(fallback_sequence, subword)
	local items = vim.g["ddc#_items"]
	local complete_pos = vim.g["ddc#_complete_pos"]

	if not vim.tbl_isempty(items) and complete_pos >= 0 then
		local item = items[1]
		local prev_input = api.nvim_get_current_line():sub(1, api.nvim_win_get_cursor(0)[2])
		local suggestion = item.word

		if vim.endswith(prev_input, suggestion) then
			local snippet_text = get_snippet(item)
			if snippet_text then
				insert_suggestion(snippet_text, true, false)
			else
				api.nvim_feedkeys(fallback_sequence, "n", false)
			end
		else
			if not subword then
				fn["ddc#denops#_notify"]("hide", { "CompleteDone" })
				vim.v.completed_item = item
				vim.g["ddc#_skip_next_complete"] = vim.g["ddc#_skip_next_complete"] + 1
			end
			insert_suggestion(suggestion, false, subword)
		end
	else
		api.nvim_feedkeys(fallback_sequence, "n", false)
	end
end

local opts = { silent = true, noremap = true }
local opts_expr = vim.tbl_extend("error", opts, { expr = true })

local has_registered_scroll_preview_keymaps = false
local register_scroll_preview_keymaps = function()
	if not has_registered_scroll_preview_keymaps then
		registry.keymaps = { fn.maparg("<C-f>", "i", false, true), fn.maparg("<C-b>", "i", false, true) }
		keymap.set("i", "<C-f>", function()
			fn["popup_preview#scroll"](4)
		end, opts_expr)
		keymap.set("i", "<C-b>", function()
			fn["popup_preview#scroll"](-4)
		end, opts_expr)
		has_registered_scroll_preview_keymaps = true
	end
end

local unregister_scroll_preview_keymaps = function()
	fn.mapset("i", false, registry.keymaps[1])
	fn.mapset("i", false, registry.keymaps[2])
	has_registered_scroll_preview_keymaps = false
end

keymap.set("i", "<Tab>", function()
	if fn.pumvisible() == 1 then
		api.nvim_feedkeys(vim.keycode("<Down>"), "n", false)
		register_scroll_preview_keymaps()
	else
		smart_action(vim.keycode("<Tab>"))
	end
end, opts)

keymap.set("i", "<M-right>", function() -- Go one subword right
	local col_pos = api.nvim_win_get_cursor(0)[2]
	local content_after_cursor = api.nvim_get_current_line():sub(col_pos + 2)
	smart_action(string.rep(vim.keycode("<right>"), utils.find_punct_in_string(content_after_cursor)), true)
end, opts)

local native_not_loaded = true
keymap.set("i", "<S-Tab>", function()
	if fn.pumvisible() == 1 then
		api.nvim_feedkeys(vim.keycode("<Up><Up><Down>"), "n", false)
		register_scroll_preview_keymaps()
	else
		if native_not_loaded then
			fn["ddc#denops#_notify"]("show", { "native" })
			native_not_loaded = false
		end
		fn["ddc#map#manual_complete"]({ sources = { "lsp" }, ui = "native" })
	end
end, opts)

keymap.set("i", "<CR>", function()
	if fn.pumvisible() == 1 then
		unregister_scroll_preview_keymaps()
		local col = api.nvim_win_get_cursor(0)[2]
		local wuc_start_col = get_wuc_start_col()
		local next_col = api.nvim_get_current_line():sub(col + 1, col + 1)
		local is_eow = next_col:match("^$") or next_col:match("[^%w_]")
		if is_eow then
			return "<C-y>"
		else
			local del = string.rep("<DEL>", wuc_start_col + #fn.expand("<cword>") - col)
			return "<C-y>" .. del
		end
	else
		return api.nvim_feedkeys(require("nvim-autopairs").autopairs_cr(), "n", false)
	end
end, opts_expr)

keymap.set("i", "<ESC>", function()
	if fn.pumvisible() == 1 then
		fn["ddc#denops#_notify"]("hide", { "CompleteDone" })
		unregister_scroll_preview_keymaps()
		return "<C-e>"
	else
		return "<ESC>"
	end
end, opts_expr)

local hide_wrapper = function(func)
	return function()
		fn["ddc#denops#_notify"]("hide", { "CompleteDone" })
		return func()
	end
end

keymap.set(
	"i",
	"<C-[>",
	hide_wrapper(function()
		return jump_inside_snippet(-1)
	end),
	{ expr = true }
)
keymap.set(
	"i",
	"<C-]>",
	hide_wrapper(function()
		return jump_inside_snippet(1)
	end),
	{ expr = true }
)

keymap.set(
	"i",
	"<C-f>",
	hide_wrapper(function() -- Go one character right
		return "<right>"
	end),
	{ expr = true }
)

keymap.set(
	"i",
	"<C-b>",
	hide_wrapper(function() -- Go one character left
		return "<left>"
	end),
	{ expr = true }
)

keymap.set(
	"i",
	"<M-left>",
	hide_wrapper(function() -- Go one subword left
		local col_pos = api.nvim_win_get_cursor(0)[2]
		local content_till_cursor = api.nvim_get_current_line():sub(1, col_pos)
		return string.rep("<left>", col_pos - utils.find_punct_in_string(content_till_cursor, true))
	end),
	{ expr = true }
)

local config = function()
	vim.fn["popup_preview#enable"]()
	vim.fn["signature_help#enable"]()
	vim.fn["ddc#custom#load_config"](os.getenv("HOME") .. "/.dotfiles/nvim/ddc.ts")
	vim.fn["ddc#enable"]({ context_filetype = "treesitter" })
end

return {
	-- reload cache with, for example: `deno cache --reload denops/ddc/deps.ts`
	"Shougo/ddc.vim",
	event = "VeryLazy",
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
		{
			"windwp/nvim-autopairs", -- End pairs like (), [], {}
			opts = {
				enable_afterquote = true, -- add bracket pairs after quote
				enable_check_bracket_line = true, -- check bracket in same line
				check_ts = true,
				map_cr = false,
				map_bs = true,
			},
		},
		"Shougo/ddc-converter_remove_overlap",
		"Shougo/ddc-source-around",
		"Shougo/ddc-source-lsp",
		"Shougo/ddc-ui-inline",
		"Shougo/ddc-ui-native",
		"octaltree/cmp-look",
		"tani/ddc-fuzzy",
	},
	config = config,
}
