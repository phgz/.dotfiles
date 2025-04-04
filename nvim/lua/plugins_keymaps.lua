local keymap = vim.keymap
local api = vim.api
local fn = vim.fn
local utils = require("utils")
local plugins_utils = require("plugins_utils")
local silent_noremap = { silent = true, noremap = true }
local silent_noremap_expr = vim.tbl_extend("error", silent_noremap, { expr = true })

--------------------------------------------------------------------------------
--                                refactoring                                 --
--------------------------------------------------------------------------------
vim.keymap.set("v", "<Leader>e", function()
	require("refactoring").refactor("Extract Function")
end, { silent = true })

--------------------------------------------------------------------------------
--                                  builder                                   --
--------------------------------------------------------------------------------
keymap.set("n", "<localleader>B", function()
	require("builder").build()
end)

--------------------------------------------------------------------------------
--                                 substitute                                 --
--------------------------------------------------------------------------------
keymap.set("n", "sx", function()
	require("substitute").operator({ register = vim.v.register })
end, { noremap = true })

keymap.set("n", "sxn", function()
	require("treemonkey").select({ ignore_injections = false })
	if utils.get_visual_state().is_active then
		require("substitute").visual({ register = vim.v.register })
	end
end, { noremap = true })

keymap.set("n", "sxx", function()
	require("substitute").line()
end, { noremap = true })
keymap.set("n", "sX", function()
	require("substitute").eol()
end, { noremap = true })
keymap.set("n", "cx", function()
	require("substitute.exchange").operator()
end, { noremap = true })
keymap.set("x", "CX", function()
	require("substitute.exchange").operator()
end, { noremap = true })

--------------------------------------------------------------------------------
--                                 bufresize                                  --
--------------------------------------------------------------------------------
keymap.set("n", "<leader>q", function() -- Close window
	require("bufresize").block_register()
	local win = api.nvim_get_current_win()
	api.nvim_win_close(win, false)
	require("bufresize").resize_close()
end)

--------------------------------------------------------------------------------
--                                smart-splits                                --
--------------------------------------------------------------------------------
-- moving between splits
keymap.set({ "i", "n", "o", "v" }, "<S-left>", function()
	require("smart-splits").move_cursor_left()
end)
keymap.set({ "i", "n", "o", "v" }, "<S-down>", function()
	require("smart-splits").move_cursor_down()
end)
keymap.set({ "i", "n", "o", "v" }, "<S-up>", function()
	require("smart-splits").move_cursor_up()
end)
keymap.set({ "i", "n", "o", "v" }, "<S-right>", function()
	require("smart-splits").move_cursor_right()
end)
-- resizing splits
keymap.set({ "i", "n", "o", "v" }, "<C-S-left>", function()
	require("smart-splits").resize_left()
end)
keymap.set({ "i", "n", "o", "v" }, "<C-S-down>", function()
	require("smart-splits").resize_down()
end)
keymap.set({ "i", "n", "o", "v" }, "<C-S-up>", function()
	require("smart-splits").resize_up()
end)
keymap.set({ "i", "n", "o", "v" }, "<C-S-right>", function()
	require("smart-splits").resize_right()
end)
-- swapping buffers between windows
keymap.set({ "i", "n", "o", "v" }, "<S-M-left>", function()
	require("smart-splits").swap_buf_left()
end)
keymap.set({ "i", "n", "o", "v" }, "<S-M-down>", function()
	require("smart-splits").swap_buf_down()
end)
keymap.set({ "i", "n", "o", "v" }, "<S-M-up>", function()
	require("smart-splits").swap_buf_up()
end)
keymap.set({ "i", "n", "o", "v" }, "<S-M-right>", function()
	require("smart-splits").swap_buf_right()
end)

--------------------------------------------------------------------------------
--                                  comment                                   --
--------------------------------------------------------------------------------
keymap.set(
	"n",
	"KD",
	[[<cmd>lua require'registry'.set_position(vim.fn.getpos("."))<cr><cmd>let &operatorfunc = "v:lua.require'plugins_utils'.yank_comment_paste"<cr>g@]],
	{ silent = true }
)

keymap.set(
	"o",
	"K",
	"<cmd>lua require'plugins_utils'.adj_commented()<cr>",
	{ silent = true, desc = "Textobject for adjacent commented lines" }
)

--------------------------------------------------------------------------------
--                             autocompletion/ddc                             --
--------------------------------------------------------------------------------
keymap.set(
	"i",
	"<C-[>",
	plugins_utils.hide_wrapper(function()
		return plugins_utils.jump_inside_snippet(-1)
	end),
	{ expr = true }
)
keymap.set(
	"i",
	"<C-]>",
	plugins_utils.hide_wrapper(function()
		return plugins_utils.jump_inside_snippet(1)
	end),
	{ expr = true }
)

keymap.set(
	"i",
	"<C-f>",
	plugins_utils.hide_wrapper(function() -- Go one character right
		return "<right>"
	end),
	{ expr = true }
)

keymap.set(
	"i",
	"<C-b>",
	plugins_utils.hide_wrapper(function() -- Go one character left
		return "<left>"
	end),
	{ expr = true }
)

keymap.set(
	"i",
	"<M-left>",
	plugins_utils.hide_wrapper(function() -- Go one subword left
		local col_pos = api.nvim_win_get_cursor(0)[2]
		local content_till_cursor = api.nvim_get_current_line():sub(1, col_pos)
		return string.rep("<left>", col_pos - utils.find_punct_in_string(content_till_cursor, true))
	end),
	{ expr = true }
)
keymap.set("i", "<Tab>", function()
	if fn.pumvisible() == 1 then
		api.nvim_feedkeys(vim.keycode("<Down>"), "n", false)
		plugins_utils.register_scroll_preview_keymaps()
	else
		plugins_utils.smart_action(vim.keycode("<Tab>"))
	end
end, silent_noremap)

keymap.set("i", "<M-right>", function() -- Go one subword right
	local col_pos = api.nvim_win_get_cursor(0)[2]
	local content_after_cursor = api.nvim_get_current_line():sub(col_pos + 2)
	plugins_utils.smart_action(
		string.rep(vim.keycode("<right>"), utils.find_punct_in_string(content_after_cursor)),
		true
	)
end, silent_noremap)

keymap.set("i", "<S-Tab>", function()
	if fn.pumvisible() == 1 then
		api.nvim_feedkeys(vim.keycode("<Up><Up><Down>"), "n", false)
		plugins_utils.register_scroll_preview_keymaps()
	else
		fn["ddc#map#manual_complete"]({ sources = { "lsp" }, ui = "native" })
	end
end, silent_noremap)

keymap.set("i", "<CR>", function()
	if fn.pumvisible() == 1 then
		plugins_utils.unregister_scroll_preview_keymaps()
		local col = api.nvim_win_get_cursor(0)[2]
		local wuc_start_col = plugins_utils.get_wuc_start_col()
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
end, silent_noremap_expr)

keymap.set("i", "<ESC>", function()
	if fn.pumvisible() == 1 then
		fn["ddc#denops#_notify"]("hide", { "CompleteDone" })
		plugins_utils.unregister_scroll_preview_keymaps()
		return "<C-e>"
	else
		return "<ESC>"
	end
end, silent_noremap_expr)

--------------------------------------------------------------------------------
--                                   neogen                                   --
--------------------------------------------------------------------------------
vim.keymap.set("n", "<leader>a", function()
	require("neogen").generate()
end, { silent = true })

--------------------------------------------------------------------------------
--                                  gitsigns                                  --
--------------------------------------------------------------------------------
-- Actions
keymap.set("n", "gr", require("gitsigns").reset_hunk)
keymap.set("v", "gr", function()
	require("gitsigns").reset_hunk({ vim.fn.line("v"), vim.fn.line(".") })
end)
keymap.set("n", "ga", require("gitsigns").stage_hunk)
keymap.set("v", "ga", function()
	require("gitsigns").stage_hunk({ vim.fn.line("v"), vim.fn.line(".") })
end)
keymap.set("n", "gA", require("gitsigns").stage_buffer)
keymap.set("n", "gR", require("gitsigns").reset_buffer)
keymap.set("n", "gd", function()
	require("gitsigns").preview_hunk()
	local winid = require("gitsigns.popup").is_open("hunk")
	if winid then
		local filetype = vim.bo.filetype
		vim.api.nvim_win_call(winid, function()
			local win_buffer = api.nvim_win_get_buf(winid)
			vim.bo[win_buffer].filetype = filetype
			keymap.set("n", "q", "<cmd>close<cr>", { silent = true, buffer = win_buffer })
		end)
	end
end)
keymap.set("n", "gb", function()
	require("gitsigns").blame_line({ ignore_whitespace = true })
end)
keymap.set("n", "gc", function()
	local input = vim.fn.input("Compare to: ")
	if input ~= "" then
		require("gitsigns").diffthis(input)
	end
end)

-- hunk objects
keymap.set("o", "ih", require("gitsigns").select_hunk)
keymap.set("o", "ah", require("gitsigns").select_hunk)
keymap.set("x", "ih", function()
	vim.api.nvim_feedkeys(vim.keycode("<esc>"), "x", false)
	require("gitsigns").select_hunk()
end)
keymap.set("x", "ah", function()
	vim.api.nvim_feedkeys(vim.keycode("<esc>"), "x", false)
	require("gitsigns").select_hunk()
end)

--------------------------------------------------------------------------------
--                                 telescope                                  --
--------------------------------------------------------------------------------
local dropdown_theme = {
	layout_config = {
		width = function(_, max_columns, _)
			return math.min(max_columns, 98)
		end,

		height = function(_, _, max_lines)
			return math.min(max_lines, 12)
		end,
	},
}

keymap.set("n", "<leader><M-f>", function()
	require("telescope.builtin").find_files(require("telescope.themes").get_dropdown(dropdown_theme))
end)
keymap.set("n", "<leader>F", function()
	local _, _, p_root = fn.expand("%:p"):find(string.format("(%s", os.getenv("HOME")) .. "/[^/]+/)")
	require("telescope.builtin").find_files(
		vim.tbl_extend("error", require("telescope.themes").get_dropdown(dropdown_theme), { cwd = p_root })
	)
end)
keymap.set("n", "<leader>f", function()
	require("telescope.builtin").git_files(require("telescope.themes").get_dropdown(dropdown_theme))
end)
keymap.set("n", "<leader>g", function()
	require("telescope.builtin").live_grep(require("telescope.themes").get_dropdown(dropdown_theme))
end)
keymap.set("n", "<leader>G", function()
	require("telescope.builtin").grep_string(require("telescope.themes").get_dropdown(dropdown_theme))
end)
keymap.set("n", "<leader>b", function()
	require("telescope.builtin").buffers(
		vim.tbl_extend("error", require("telescope.themes").get_dropdown(dropdown_theme), {
			cwd_only = true,
			sort_buffers = function(bufnr_a, bufnr_b)
				return api.nvim_buf_get_name(bufnr_a) < api.nvim_buf_get_name(bufnr_b)
			end,
		})
	)
end)
keymap.set("n", "<leader>B", function()
	require("telescope.builtin").buffers(
		vim.tbl_extend("error", require("telescope.themes").get_dropdown(dropdown_theme), {
			sort_buffers = function(bufnr_a, bufnr_b)
				return api.nvim_buf_get_name(bufnr_a) < api.nvim_buf_get_name(bufnr_b)
			end,
		})
	)
end)
keymap.set("n", "<leader>l", function()
	require("telescope.builtin").lsp_document_symbols(require("telescope.themes").get_dropdown(dropdown_theme))
end)
keymap.set("n", "<leader>L", function()
	require("telescope.builtin").lsp_document_symbols(
		vim.tbl_extend("error", require("telescope.themes").get_dropdown(dropdown_theme), { symbols = "function" })
	)
end)

keymap.set("n", "<leader>N", function()
	require("simple-note").listNotes()
end)

keymap.set("n", "<leader>s", function() --
	local opened_projects = plugins_utils.get_opened_projects()

	require("telescope").extensions.repo.list(
		vim.tbl_extend("error", require("telescope.themes").get_dropdown(dropdown_theme), {
			search_dirs = vim.tbl_isempty(opened_projects) and { "" } or opened_projects,
			post_action = plugins_utils.post_action_fn,
			prompt = " (opened projects)",
		})
	)
end)

keymap.set("n", "<leader>S", function() -- Toggle with last opened project
	local opened_projects = plugins_utils.get_opened_projects()

	if vim.tbl_isempty(opened_projects) then
		return
	end

	local current_buffer_path = fn.expand("%:p")
	local current_project_path = vim.iter(opened_projects):find(function(project_path)
		return vim.startswith(current_buffer_path, project_path)
	end)

	plugins_utils.post_action_fn(current_project_path, false)
end)

keymap.set("n", "<leader>R", function() --
	vim.go.autochdir = false
	require("telescope").extensions.repo.list(
		vim.tbl_extend("error", require("telescope.themes").get_dropdown(dropdown_theme), {
			post_action = function(prefix)
				vim.cmd.cd(prefix)
			end,
			prompt = " (cd into a repo)",
		})
	)
end)

keymap.set("n", "<leader>r", function()
	vim.go.autochdir = false
	require("telescope").extensions.repo.list(require("telescope.themes").get_dropdown(dropdown_theme))
end)
keymap.set("n", "<leader>u", function()
	require("telescope").extensions.undo.undo(require("telescope.themes").get_dropdown(dropdown_theme))
end)
keymap.set("n", "<leader>m", function()
	plugins_utils.yaml_symbols(require("telescope.themes").get_dropdown(dropdown_theme))
end)

--------------------------------------------------------------------------------
--                                   noice                                    --
--------------------------------------------------------------------------------
vim.keymap.set("n", "<C-f>", function()
	if not require("noice.lsp").scroll(4) then
		return "<C-f>"
	end
end, { silent = true, expr = true })

vim.keymap.set("n", "<C-b>", function()
	if not require("noice.lsp").scroll(-4) then
		return "<C-b>"
	end
end, { silent = true, expr = true })

--------------------------------------------------------------------------------
--                               nvim-surround                                --
--------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------
--                                 treemonkey                                 --
--------------------------------------------------------------------------------
keymap.set({ "x", "o" }, "n", function()
	require("treemonkey").select({ ignore_injections = false })
end)

--------------------------------------------------------------------------------
--                                sibling-swap                                --
--------------------------------------------------------------------------------
keymap.set("n", "<C-.>", function()
	require("sibling-swap")["swap_with_right_with_opp"]()
end)
keymap.set("n", "<C-,>", function()
	require("sibling-swap")["swap_with_left_with_opp"]()
end)

--------------------------------------------------------------------------------
--                                  lsplinks                                  --
--------------------------------------------------------------------------------
keymap.set("n", "gx", function()
	require("lsplinks").gx()
end)

--------------------------------------------------------------------------------
--                               vim-easy-align                               --
--------------------------------------------------------------------------------
keymap.set({ "n", "x" }, "<localleader>a", "<Plug>(LiveEasyAlign)")

--------------------------------------------------------------------------------
--                           ts-node-action/treesj                            --
--------------------------------------------------------------------------------
keymap.set({ "n" }, "<leader>k", function()
	local is_markup_lang = vim.list_contains({ "json", "toml", "yaml" }, vim.bo.ft)
	local is_yaml_bool_scalar = vim.bo.ft == "yaml"
		and vim.treesitter.get_node({ bufnr = 0 }):type() == "boolean_scalar"
	if is_markup_lang and not is_yaml_bool_scalar then
		require("treesj").toggle()
	else
		require("ts-node-action").node_action()
	end
end, { desc = "Trigger Node Action" })

--------------------------------------------------------------------------------
--                        nvim-treesitter-textobjects                         --
--------------------------------------------------------------------------------
local move_mappings = {
	["be"] = "@binary.outer",
	["bl"] = "@binary.lhs",
	["br"] = "@binary.rhs",
	["bo"] = "@boolean",
	["a"] = "@assignment.lhs",
	["v"] = "@assignment.rhs",
	["k"] = "@call.outer",
	["C"] = "@class.outer",
	["K"] = "@comment.outer",
	["c"] = "@conditional.outer",
	["D"] = "@dictionary.outer",
	["f"] = "@function.outer",
	["l"] = "@loop.outer",
	["L"] = "@list.outer",
	["n"] = "@number.inner",
	["p"] = "@parameter.inner",
	["r"] = "@return.outer",
	["s"] = "@string.outer",
}
for abbr, query in pairs(move_mappings) do
	keymap.set({ "n" }, "[g" .. abbr, function()
		require("nvim-treesitter-textobjects.move").goto_previous_end(query, "textobjects")
	end)
	keymap.set({ "n" }, "[" .. abbr, function()
		require("nvim-treesitter-textobjects.move").goto_previous_start(query, "textobjects")
	end)
	keymap.set({ "n" }, "]g" .. abbr, function()
		require("nvim-treesitter-textobjects.move").goto_next_end(query, "textobjects")
	end)
	keymap.set({ "n" }, "]" .. abbr, function()
		require("nvim-treesitter-textobjects.move").goto_next_start(query, "textobjects")
	end)
end

keymap.set(
	"n",
	"sP",
	utils.mk_repeatable(function()
		require("nvim-treesitter-textobjects.swap").swap_previous(utils.get_text_object())
	end),
	{ silent = true }
)

keymap.set(
	"n",
	"sN",
	utils.mk_repeatable(function()
		require("nvim-treesitter-textobjects.swap").swap_next(utils.get_text_object())
	end),
	{ silent = true }
)

local select_mappings = {
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
	["aD"] = "@dictionary.outer",
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
}

for abbr, query in pairs(select_mappings) do
	vim.keymap.set({ "x", "o" }, abbr, function()
		require("nvim-treesitter-textobjects.select").select_textobject(query, "textobjects")
	end)
end

-- Repeat movement with ; and ,
vim.keymap.set({ "n", "x", "o" }, ";", function()
	require("nvim-treesitter-textobjects.repeatable_move").repeat_last_move()
end)
vim.keymap.set({ "n", "x", "o" }, ",", function()
	require("nvim-treesitter-textobjects.repeatable_move").repeat_last_move_opposite()
end)
local rhs =
	"<cmd>lua require('multiline_ft').multiline_find(%s,%s,require('nvim-treesitter-textobjects.repeatable_move'))<cr>"
keymap.set({ "n", "x" }, "f", string.format(rhs, "true", "false"))
keymap.set({ "n", "x" }, "F", string.format(rhs, "false", "false"))
keymap.set({ "n", "x" }, "t", string.format(rhs, "true", "true"))
keymap.set({ "n", "x" }, "T", string.format(rhs, "false", "true"))

keymap.set(
	{ "n", "x" },
	"]h",
	utils.callable(
		require("nvim-treesitter-textobjects.repeatable_move").make_repeatable_move(plugins_utils.goto_hunk),
		{ forward = true }
	)
)
keymap.set(
	{ "n", "x" },
	"[h",
	utils.callable(
		require("nvim-treesitter-textobjects.repeatable_move").make_repeatable_move(plugins_utils.goto_hunk),
		{ forward = false }
	)
)

keymap.set(
	{ "n", "x" },
	"]q",
	utils.callable(
		require("nvim-treesitter-textobjects.repeatable_move").make_repeatable_move(utils.goto_quote),
		{ forward = true }
	)
)
keymap.set(
	{ "n", "x" },
	"[q",
	utils.callable(
		require("nvim-treesitter-textobjects.repeatable_move").make_repeatable_move(utils.goto_quote),
		{ forward = false }
	)
)
keymap.set(
	{ "n", "x" },
	"]z",
	utils.callable(
		require("nvim-treesitter-textobjects.repeatable_move").make_repeatable_move(utils.goto_fold),
		{ forward = true }
	)
)
keymap.set(
	{ "n", "x" },
	"[z",
	utils.callable(
		require("nvim-treesitter-textobjects.repeatable_move").make_repeatable_move(utils.goto_fold),
		{ forward = false }
	)
)
keymap.set(
	{ "n", "x" },
	"]S",
	utils.callable(
		require("nvim-treesitter-textobjects.repeatable_move").make_repeatable_move(utils.goto_spell),
		{ forward = true }
	)
)
keymap.set(
	{ "n", "x" },
	"[S",
	utils.callable(
		require("nvim-treesitter-textobjects.repeatable_move").make_repeatable_move(utils.goto_spell),
		{ forward = false }
	)
)
keymap.set(
	{ "n", "x" },
	"]d",
	utils.callable(
		require("nvim-treesitter-textobjects.repeatable_move").make_repeatable_move(utils.goto_diagnostic()),
		{ forward = true }
	)
)
keymap.set(
	{ "n", "x" },
	"[d",
	utils.callable(
		require("nvim-treesitter-textobjects.repeatable_move").make_repeatable_move(utils.goto_diagnostic()),
		{ forward = false }
	)
)
keymap.set(
	{ "n", "x" },
	"]H",
	utils.callable(
		require("nvim-treesitter-textobjects.repeatable_move").make_repeatable_move(utils.goto_diagnostic("HINT")),
		{ forward = true }
	)
)
keymap.set(
	{ "n", "x" },
	"[H",
	utils.callable(
		require("nvim-treesitter-textobjects.repeatable_move").make_repeatable_move(utils.goto_diagnostic("HINT")),
		{ forward = false }
	)
)
keymap.set(
	{ "n", "x" },
	"]I",
	utils.callable(
		require("nvim-treesitter-textobjects.repeatable_move").make_repeatable_move(utils.goto_diagnostic("INFO")),
		{ forward = true }
	)
)
keymap.set(
	{ "n", "x" },
	"[I",
	utils.callable(
		require("nvim-treesitter-textobjects.repeatable_move").make_repeatable_move(utils.goto_diagnostic("INFO")),
		{ forward = false }
	)
)
keymap.set(
	{ "n", "x" },
	"]W",
	utils.callable(
		require("nvim-treesitter-textobjects.repeatable_move").make_repeatable_move(utils.goto_diagnostic("WARN")),
		{ forward = true }
	)
)
keymap.set(
	{ "n", "x" },
	"[W",
	utils.callable(
		require("nvim-treesitter-textobjects.repeatable_move").make_repeatable_move(utils.goto_diagnostic("WARN")),
		{ forward = false }
	)
)
keymap.set(
	{ "n", "x" },
	"]E",
	utils.callable(
		require("nvim-treesitter-textobjects.repeatable_move").make_repeatable_move(utils.goto_diagnostic("ERROR")),
		{ forward = true }
	)
)
keymap.set(
	{ "n", "x" },
	"[E",
	utils.callable(
		require("nvim-treesitter-textobjects.repeatable_move").make_repeatable_move(utils.goto_diagnostic("ERROR")),
		{ forward = false }
	)
)
