local api = vim.api
local fn = vim.fn
local keymap = vim.keymap
local registry = require("registry")
local utils = require("utils")
local esc = vim.keycode("<esc>")
local opts = { silent = true, noremap = true }
local opts_expr = vim.tbl_extend("error", opts, { expr = true })

local M = {}

--------------------------------------------------------------------------------
--                                  gitsigns                                  --
--------------------------------------------------------------------------------
function M.goto_hunk(opts)
	require("gitsigns").nav_hunk(opts.forward and "next" or "prev", { greedy = false })
	vim.defer_fn(function()
		local winid = require("gitsigns.popup").is_open("hunk")
		if winid then
			local filetype = vim.bo.filetype
			vim.api.nvim_win_call(winid, function()
				local win_buffer = api.nvim_win_get_buf(winid)
				vim.bo[win_buffer].filetype = filetype
				keymap.set("n", "q", "<cmd>close<cr>", { silent = true, buffer = win_buffer })
			end)
		end
	end, 1)
end

--------------------------------------------------------------------------------
--                                  comment                                   --
--------------------------------------------------------------------------------
-- Textobject for adjacent commented lines
function M.adj_commented()
	local comment_utils = require("Comment.utils")
	local current_line = api.nvim_win_get_cursor(0)[1] -- current line
	local range = { srow = current_line, scol = 0, erow = current_line, ecol = 0 }
	local ctx = {
		ctype = comment_utils.ctype.linewise,
		range = range,
	}
	local cstr = require("Comment.ft").calculate(ctx) or vim.bo.commentstring
	local ll, rr = comment_utils.unwrap_cstr(cstr)
	local padding = true
	local is_commented = comment_utils.is_commented(ll, rr, padding)

	local line = api.nvim_buf_get_lines(0, current_line - 1, current_line, false)
	if next(line) == nil or not is_commented(line[1]) then
		api.nvim_feedkeys(esc, "n", false)
		return
	end

	local rs, re = current_line, current_line -- range start and end
	repeat
		rs = rs - 1
		line = api.nvim_buf_get_lines(0, rs - 1, rs, false)
	until next(line) == nil or not is_commented(line[1])
	rs = rs + 1
	repeat
		re = re + 1
		line = api.nvim_buf_get_lines(0, re - 1, re, false)
	until next(line) == nil or not is_commented(line[1])
	re = re - 1

	utils.update_selection(true, "V", rs, 0, re, 0)
end

function M.yank_comment_paste()
	local start_row = api.nvim_buf_get_mark(0, "[")[1]
	local end_row = api.nvim_buf_get_mark(0, "]")[1]
	local lines = api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
	local range = end_row - start_row + 1

	-- Copying the block
	api.nvim_buf_set_lines(0, end_row, end_row, true, lines)

	-- Doing the comment
	require("Comment.api").comment.linewise.count(range)

	-- Move the cursor
	local pre_motion_row, pre_motion_col = unpack(registry.get_position())
	registry.set_position({})
	api.nvim_win_set_cursor(0, { pre_motion_row + range, pre_motion_col })
end

--------------------------------------------------------------------------------
--                                 mason/lsp                                  --
--------------------------------------------------------------------------------
local get_venv = function(lock_file_path)
	local project_root = vim.fs.dirname(lock_file_path)
	local tool = vim.startswith(vim.fs.basename(lock_file_path), "uv") and "uv" or "poetry"

	if tool == "uv" then
		return project_root .. "/.venv"
	end

	local ret = require("plenary.job")
		:new({
			command = os.getenv("HOME") .. "/.miniconda3/bin/python3.12",
			args = {
				"-c",
				[[import base64, hashlib, pathlib, tomllib; h = base64.urlsafe_b64encode(hashlib.sha256(bytes(pathlib.Path.cwd())).digest()).decode()[:8]; p = tomllib.load(open("pyproject.toml", "rb"))["tool"]["poetry"]["name"].replace(".", "-").replace("_", "-"); cache = ".cache" if "$(uname -s)" == "Linux" else "Library/Caches"; virtualenvs = (pathlib.Path.home() / cache / "pypoetry/virtualenvs").iterdir(); env_name = next(dir for dir in virtualenvs if str(dir.name).startswith(p + "-" + h)); print(env_name)
]],
			},
			cwd = project_root,
			env = { ["PATH"] = vim.env.PATH },
		})
		:sync()[1]

	return ret
end

local on_attach = function(client, bufnr)
	-- Enable completion triggered by <c-x><c-o>
	vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

	-- Mappings.
	local opts = { buffer = bufnr, silent = true }

	if client.server_capabilities.documentSymbolProvider then
		local navic = require("nvim-navic")
		local navic_lib = require("nvim-navic.lib")

		keymap.set("n", "<leader>w", function()
			if navic.is_available() then
				navic_lib.update_context(bufnr)
				vim.notify(navic.get_location())
			end
			vim.wo.statusline = vim.wo.statusline
		end, opts)

		navic.attach(client, bufnr)

		local navic_cursor_autocmds =
			api.nvim_get_autocmds({ group = "navic", event = { "CursorHold", "CursorMoved" } })
		api.nvim_del_autocmd(navic_cursor_autocmds[2].id)
		api.nvim_del_autocmd(navic_cursor_autocmds[3].id)
	end

	local function on_list(options)
		fn.setqflist({}, " ", options)
		vim.cmd("silent cfirst")
	end

	keymap.set("n", "<leader>j", function()
		vim.lsp.buf.definition({ on_list = on_list })
	end, opts)
	keymap.set("n", "<localleader>h", function()
		vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
	end, opts)
	keymap.set("n", "<localleader>r", vim.lsp.buf.rename)
	keymap.set("n", "H", function()
		local captures = vim.treesitter.get_captures_at_cursor()
		if vim.list_contains(captures, "function.call") or vim.list_contains(captures, "function.method.call") then
			vim.lsp.buf.hover()
		else
			vim.lsp.buf.signature_help()
		end
	end, opts)
end

function M.mason_lspconfig_setup_handlers()
	local capabilities = require("ddc_source_lsp").make_client_capabilities
	require("mason-lspconfig").setup_handlers({
		function(server_name) -- default handler
			require("lspconfig")[server_name].setup({ on_attach = on_attach, capabilities = capabilities() })
		end,
		["pyright"] = function()
			require("lspconfig").pyright.setup({
				on_attach = on_attach,
				capabilities = capabilities(),
				before_init = function(_, config)
					if not vim.env.VIRTUAL_ENV then
						local find_lock_file = function(path)
							return vim.fs.find(
								{ "uv.lock", "poetry.lock" },
								{ upward = true, path = path, type = "file", stop = vim.env.HOME }
							)[1]
						end
						local lock_file_path = find_lock_file(fn.expand("%:p:h"))
						if lock_file_path ~= nil then
							local venv_path = get_venv(lock_file_path)
							vim.env.VIRTUAL_ENV = venv_path
							config.settings.python.pythonPath = vim.env.VIRTUAL_ENV .. "/bin/python3"
						end
						api.nvim_create_autocmd("BufEnter", {
							callback = function(event_args)
								if event_args.file ~= "" then
									local new_lock_file_path = find_lock_file(event_args.file)
									if new_lock_file_path ~= lock_file_path then
										vim.env.VIRTUAL_ENV = nil
										vim.cmd("LspRestart")
										return true --return a truthy value (not false or nil) to delete the autocommand.
									end
								end
							end,
						})
					end
				end,
			})
		end,

		["lua_ls"] = function()
			require("lspconfig").lua_ls.setup({
				on_attach = on_attach,
				capabilities = capabilities(),
				settings = {
					Lua = {
						telemetry = {
							enable = false,
						},
						runtime = { version = "LuaJIT" },
						semantic = { enable = false },
						hint = {
							enable = true,
						},
						workspace = {
							checkThirdParty = false,
							library = {
								vim.fn.expand("$VIMRUNTIME/lua"),
								vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
								vim.fn.expand("$HOME/.local/share/nvim/lazy"),
								vim.fn.expand(
									"$HOME/.local/share/nvim/mason/packages/lua-language-server/libexec/meta/3rd/luv/library"
								),
							},
						},
					},
				},
			})
		end,
	})
end

--------------------------------------------------------------------------------
--                             autocompletion/ddc                             --
--------------------------------------------------------------------------------
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

local insert_suggestion = function(suggestion, is_snippet, subword)
	local row, col = unpack(api.nvim_win_get_cursor(0))
	api.nvim_win_set_cursor(0, { row, col - 1 })
	local captures = vim.treesitter.get_captures_at_cursor()

	local is_punctuation = vim.iter(captures):any(function(capture)
		return capture:match("^punctuation%.")
	end)

	local word_under_cursor_start_col = (is_punctuation or api.nvim_get_current_line():sub(col, col):match("[./]"))
			and col
		or M.get_wuc_start_col()
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

function M.jump_inside_snippet(direction)
	if vim.snippet.active({ direction = direction }) then
		return "<cmd>lua vim.snippet.jump(" .. direction .. ")<cr>"
	else
		return ""
	end
end

function M.get_wuc_start_col()
	local word_under_cursor = fn.expand("<cword>")
	return fn.searchpos(word_under_cursor, "Wcnb")[2] - 1
end

function M.smart_action(fallback_sequence, subword)
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

function M.hide_wrapper(func)
	return function()
		fn["ddc#denops#_notify"]("hide", { "CompleteDone" })
		return func()
	end
end

function M.register_scroll_preview_keymaps()
	if not registry.has_registered_scroll_preview_keymaps then
		registry.keymaps = { fn.maparg("<C-f>", "i", false, true), fn.maparg("<C-b>", "i", false, true) }
		keymap.set("i", "<C-f>", function()
			fn["popup_preview#scroll"](4)
		end, opts_expr)
		keymap.set("i", "<C-b>", function()
			fn["popup_preview#scroll"](-4)
		end, opts_expr)
		registry.has_registered_scroll_preview_keymaps = true
	end
end

function M.unregister_scroll_preview_keymaps()
	fn.mapset("i", false, registry.keymaps[1])
	fn.mapset("i", false, registry.keymaps[2])
	registry.has_registered_scroll_preview_keymaps = false
end

--------------------------------------------------------------------------------
--                                 telescope                                  --
--------------------------------------------------------------------------------
function M.set_telescope_statusline()
	local is_modifiable = fn.getbufvar(fn.bufnr("#"), "&modifiable") == 1
	local is_modified = fn.getbufvar(fn.bufnr("#"), "&modified") == 1
	local is_read_only = fn.getbufvar(fn.bufnr("#"), "&readonly") == 1
	local modified = is_modifiable and (is_modified and "[+]" or "") or "[-]"
	local read_only = is_read_only and "[RO]" or ""
	local help = fn.getbufvar(fn.bufnr("#"), "&buftype") == "help" and "[Help]" or ""
	local git_status = fn.getbufvar(fn.bufnr("#"), "gitsigns_status")
	local diagnostics = utils.diagnostics_status_line(fn.bufnr("#"))
	if git_status ~= "" then
		git_status = "  " .. git_status
	end
	vim.wo.statusline = [[%{%expand('#:p:~')%}]]
		.. git_status
		.. diagnostics
		.. [[%#GreenStatusLine#]]
		.. ((is_modified or is_read_only) and " " or "")
		.. help
		.. [[%#YellowStatusLine#]]
		.. read_only
		.. [[%#RedStatusLine#]]
		.. modified
end

function M.post_action_fn(prefix, is_equal)
	is_equal = is_equal == nil and true or is_equal
	local context = api.nvim_get_context({ types = { "jumps", "bufs" } })
	local jumps = fn.msgpackparse(context.jumps)
	local listed_bufs = vim.iter(fn.msgpackparse(context.bufs)[4])
		:map(function(buf)
			return buf.f
		end)
		:totable()
	local to_edit
	for i = #jumps, 1, -4 do
		local file = jumps[i].f
		if is_equal == vim.startswith(file, prefix) and vim.list_contains(listed_bufs, file) then
			to_edit = file
			break
		end
	end
	vim.cmd.edit(to_edit)
end

function M.get_opened_projects()
	local project_paths = require("telescope._extensions.repo.autocmd_lcd").get_project_paths()
	local context = api.nvim_get_context({ types = { "bufs" } })
	local bufs = fn.msgpackparse(context.bufs)[4]

	local opened_projects = vim.iter(project_paths)
		:filter(function(project_path)
			local found = vim.iter(bufs):find(function(buf_path)
				return vim.startswith(buf_path.f, project_path)
			end)
			return found or false
		end)
		:totable()

	return opened_projects
end

--------------------------------------------------------------------------------
--                      Fuzzy search among YAML objects                       --
--------------------------------------------------------------------------------

local function visit_yaml_node(node, yaml_path, result, file_path, bufnr)
	local key = ""
	if node:type() == "block_mapping_pair" then
		local field_key = node:field("key")[1]
		key = vim.treesitter.get_node_text(field_key, bufnr)
	end

	if key ~= nil and string.len(key) > 0 then
		table.insert(yaml_path, key)
		local line, col = node:start()
		table.insert(result, {
			lnum = line + 1,
			col = col + 1,
			bufnr = bufnr,
			filename = file_path,
			text = table.concat(yaml_path, "."),
		})
	end

	for child_node, _ in node:iter_children() do
		visit_yaml_node(child_node, yaml_path, result, file_path, bufnr)
	end

	if key ~= nil and string.len(key) > 0 then
		local maxn = 0
		for k, _ in pairs(yaml_path) do
			maxn = math.max(maxn, k)
		end
		table.remove(yaml_path, maxn)
	end
end

local function gen_from_yaml_nodes(options)
	local displayer = require("telescope.pickers.entry_display").create({
		separator = " │ ",
		items = {
			{ width = 5 },
			{ remaining = true },
		},
	})

	local make_display = function(entry)
		return displayer({
			{ entry.lnum, "TelescopeResultsSpecialComment" },
			{
				entry.text,
				function()
					return {}
				end,
			},
		})
	end

	return function(entry)
		return require("telescope.make_entry").set_default_entry_mt({
			ordinal = entry.text,
			display = make_display,
			filename = entry.filename,
			lnum = entry.lnum,
			text = entry.text,
			col = entry.col,
		}, options)
	end
end

function M.yaml_symbols(options)
	local conf = require("telescope.config").values
	local yaml_path = {}
	local result = {}
	local bufnr = api.nvim_get_current_buf()
	local ft = api.nvim_get_option_value("ft", { buf = bufnr })
	local tree = vim.treesitter.get_parser(bufnr, ft):parse()[1]
	local file_path = api.nvim_buf_get_name(bufnr)
	local root = tree:root()
	for child_node, _ in root:iter_children() do
		visit_yaml_node(child_node, yaml_path, result, file_path, bufnr)
	end

	-- return result
	require("telescope.pickers")
		.new(options, {
			prompt_title = "YAML symbols",
			finder = require("telescope.finders").new_table({
				results = result,
				entry_maker = gen_from_yaml_nodes(options),
			}),
			sorter = conf.generic_sorter(options),
			previewer = conf.grep_previewer(options),
		})
		:find()
end

return M
