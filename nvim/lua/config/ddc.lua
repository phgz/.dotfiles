local api = vim.api
local call = api.nvim_call_function

vim.g.popup_preview_config = {
	border = false,
	winblend = 30,
	maxHeight = 12,
	supportUltisnips = true,
}

local feed_special = function(action)
	api.nvim_feedkeys(api.nvim_replace_termcodes(action, true, false, true), "n", true)
	return true
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
	return call("searchpos", { word_under_cursor, "Wcnb" })[2] - 1
end

local insert_suggestion = function(suggestion)
	local row, col = unpack(api.nvim_win_get_cursor(0))
	api.nvim_win_set_cursor(0, { row, col - 1 })
	local captures = vim.treesitter.get_captures_at_cursor()

	local punctuation_captures = vim.tbl_filter(function(capture)
		return capture:match("^punctuation%.")
	end, captures)

	local is_punctuation = not vim.tbl_isempty(punctuation_captures)
	local word_under_cursor_start_col = is_punctuation and col or get_wuc_start_col()

	local line_content = api.nvim_get_current_line()

	-- print(vim.inspect(word_under_cursor_start_col))
	-- print(vim.inspect(punctuation_captures))
	-- print(1, line_content:sub(1, col - (is_punctuation and 0 or #word_under_cursor)))
	-- print(2, line_content:sub(col + 1))

	local new_line_content = line_content:sub(1, word_under_cursor_start_col) .. suggestion .. line_content:sub(col + 1)

	api.nvim_set_current_line(new_line_content)
	api.nvim_win_set_cursor(0, { row, word_under_cursor_start_col + #suggestion })
end

local wise_tab = function()
	local items = vim.g["ddc#_items"]
	local complete_pos = vim.g["ddc#_complete_pos"]
	call("ddc#_hide", { "CompleteDone" })
	call("ddc#complete#_on_complete_done", { items[1] })

	if not vim.tbl_isempty(items) and complete_pos >= 0 then
		local item = items[1]
		local prev_input = vim.g["ddc#_prev_input"]
		local suggestion = item["word"]
		-- print("prev:", prev_input)
		-- print("sugg:", suggestion)

		if prev_input:sub(-#suggestion) == suggestion then
			insert_snippet_or_tab()
		else
			insert_suggestion(suggestion)
		end
	else
		feed_special("<tab>")
	end
end

local opts = { silent = true, noremap = true }
local opts_expr = vim.tbl_extend("error", opts, { expr = true })

vim.keymap.set("i", "<Tab>", function()
	return call("pumvisible", {}) == 1 and feed_special("<C-n>") or wise_tab()
end, opts)

local manual_complete = function()
	if not call("ddc#_denops_running", {}) then
		call("ddc#enable", {})
		call("denops#plugin#wait", { "ddc" })
	end
	call("denops#notify", { "ddc", "manualComplete", { { "nvim-lsp" }, "native" } })
end

vim.keymap.set("i", "<S-Tab>", function()
	return call("pumvisible", {}) == 1 and feed_special("<C-p>") or manual_complete()
end, opts)

vim.keymap.set("i", "<CR>", function()
	return call("pumvisible", {}) == 1 and "<C-y>" or "<CR>"
end, opts_expr)

vim.keymap.set("i", "<ESC>", function()
	return call("pumvisible", {}) == 1 and "<C-e>" or "<ESC>"
end, opts_expr)

vim.cmd([[
call ddc#custom#patch_global('sources', ['nvim-lsp', 'ultisnips', 'file'])
call ddc#custom#patch_global('sourceOptions', #{
            \ _: #{
            \   matchers: ['matcher_fuzzy'],
            \   sorters: ['sorter_fuzzy'],
            \   converters: ['converter_remove_overlap'],
            \   minAutoCompleteLength : 1,
            \   ignoreCase: v:false
            \     }
            \ })
call ddc#custom#patch_global('filterParams', #{
            \   matcher_fuzzy: #{ splitMode: 'word' }
            \ })
call ddc#custom#patch_global('sourceOptions', #{
            \ tabnine: #{ mark: 'TN', maxCandidates: 5, isVolatile: v:true },
            \ treesitter: #{mark: 'TS'},
            \ ultisnips: #{mark: 'U'},
            \ omni: #{mark: 'O'},
            \ nvim-lsp_by-treesitter: #{ mark: 'lsp'},
            \ nvim-lsp: #{mark: 'LSP',forceCompletionPattern: '\.\w*|:\w*|->\w*'},
            \ file: #{mark: 'F', forceCompletionPattern: '\S/\S*' }
            \})
call ddc#custom#patch_global('sourceParams', #{
            \ nvim-lsp_by-treesitter: #{ kindLabels: #{ Class: 'c' } },
            \ file: #{trailingSlash: v:false}
            \ })
call ddc#custom#patch_global('ui', 'inline')
call popup_preview#enable()
call ddc#enable()
]])