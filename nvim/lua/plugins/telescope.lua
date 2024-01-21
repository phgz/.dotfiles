return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			{ "phgz/telescope-repo.nvim", branch = "feature/custom-post-action" },
			"debugloop/telescope-undo.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
		},

		config = function()
			local api = vim.api
			local call = api.nvim_call_function

			local actions = require("telescope.actions")
			local builtin = require("telescope.builtin")
			local pickers = require("telescope.pickers")
			local finders = require("telescope.finders")
			local make_entry = require("telescope.make_entry")
			local entry_display = require("telescope.pickers.entry_display")

			require("telescope").setup({
				defaults = {
					mappings = {
						i = {
							["<esc>"] = actions.close,
							["<C-u>"] = false,
							["<C-n>"] = actions.cycle_history_next,
							["<C-p>"] = actions.cycle_history_prev,
							["<C-b>"] = actions.preview_scrolling_up,
							["<C-f>"] = actions.preview_scrolling_down,
							["<c-d>"] = actions.delete_buffer + actions.move_to_top,
							["<tab>"] = actions.move_selection_next,
							["<S-tab>"] = actions.move_selection_previous,
						},
					},
				},
				extensions = {
					repo = {
						list = {
							fd_opts = {
								"--exclude=.*/*",
								"--exclude=[A-Z]*",
								"--max-depth=2",
							},
						},
						settings = {
							auto_lcd = true,
						},
					},
					undo = {
						time_format = "%c",
					},
				},
			})

			require("telescope").load_extension("undo")
			require("telescope").load_extension("repo")
			require("telescope").load_extension("noice")
			require("telescope").load_extension("ui-select")

			vim.api.nvim_create_autocmd("User", {
				pattern = "TelescopePreviewerLoaded",
				callback = function()
					if api.nvim_win_get_config(0).relative ~= "" then
						vim.wo.wrap = true
					end
				end,
			})

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "TelescopePrompt",
				callback = function()
					local is_modifiable = vim.fn.getbufvar(vim.fn.bufnr("#"), "&modifiable") == 1
					local is_modified = vim.fn.getbufvar(vim.fn.bufnr("#"), "&modified") == 1
					local is_read_only = vim.fn.getbufvar(vim.fn.bufnr("#"), "&readonly") == 1
					local modified = is_modifiable and (is_modified and "[+]" or "") or "[-]"
					local read_only = is_read_only and "[RO]" or ""
					local help = vim.fn.getbufvar(vim.fn.bufnr("#"), "&buftype") == "help" and "[Help]" or ""
					local git_status = vim.fn.getbufvar(vim.fn.bufnr("#"), "gitsigns_status")
					if git_status ~= "" then
						git_status = "  " .. git_status
					end
					vim.wo.statusline = [[%{%expand('#:~')%}]]
						.. git_status
						.. [[%#GreenStatusLin#]]
						.. ((is_modified or is_read_only) and " " or "")
						.. help
						.. [[%#YellowStatusLine#]]
						.. read_only
						.. [[%#RedStatusLine#]]
						.. modified
				end,
			})

			local dropdown_theme = require("telescope.themes").get_dropdown({
				layout_config = {
					width = function(_, max_columns, _)
						return math.min(max_columns, 98)
					end,

					height = function(_, _, max_lines)
						return math.min(max_lines, 12)
					end,
				},
			})

			vim.keymap.set("n", "<leader>F", function()
				local _, _, p_root = vim.fn.expand("%:p"):find(string.format("(%s", os.getenv("HOME")) .. "/[^/]+/)")
				builtin.find_files(vim.tbl_extend("error", dropdown_theme, { cwd = p_root }))
			end)
			vim.keymap.set("n", "<leader>f", function()
				builtin.git_files(dropdown_theme)
			end)
			vim.keymap.set("n", "<leader>g", function()
				builtin.live_grep(dropdown_theme)
			end)
			vim.keymap.set("n", "<leader>G", function()
				builtin.grep_string(dropdown_theme)
			end)
			vim.keymap.set("n", "<leader>b", function()
				builtin.buffers(vim.tbl_extend("error", dropdown_theme, {
					cwd_only = true,
					sort_buffers = function(bufnr_a, bufnr_b)
						return vim.api.nvim_buf_get_name(bufnr_a) < vim.api.nvim_buf_get_name(bufnr_b)
					end,
				}))
			end)
			vim.keymap.set("n", "<leader>B", function()
				builtin.buffers(vim.tbl_extend("error", dropdown_theme, {
					sort_buffers = function(bufnr_a, bufnr_b)
						return vim.api.nvim_buf_get_name(bufnr_a) < vim.api.nvim_buf_get_name(bufnr_b)
					end,
				}))
			end)
			vim.keymap.set("n", "<leader>l", function()
				builtin.lsp_workspace_symbols(
					vim.tbl_extend(
						"error",
						dropdown_theme,
						{ query = vim.api.nvim_call_function("expand", { "<cword>" }) }
					)
				)
			end)

			local post_action_fn = function(prefix)
				local context = api.nvim_get_context({ types = { "jumps", "bufs" } })
				local jumps = call("msgpackparse", { context["jumps"] })
				local listed_bufs = vim.iter.map(function(buf)
					return buf["f"]
				end, call("msgpackparse", { context["bufs"] })[4])
				local to_edit
				for i = #jumps, 1, -4 do
					local file = jumps[i]["f"]
					if vim.startswith(file, prefix) and vim.list_contains(listed_bufs, file) then
						to_edit = file
						break
					end
				end
				vim.cmd.edit(to_edit)
			end

			vim.keymap.set("n", "<leader>s", function() --
				local project_paths = require("telescope._extensions.repo.autocmd_lcd").get_project_paths()
				local context = api.nvim_get_context({ types = { "bufs" } })
				local bufs = call("msgpackparse", { context["bufs"] })[4]

				local open_projects = vim.iter.filter(function(project_path)
					local found = vim.iter(bufs):find(function(buf_path)
						return vim.startswith(buf_path["f"], project_path)
					end)
					return found or false
				end, project_paths)

				require("telescope").extensions.repo.list(vim.tbl_extend("error", dropdown_theme, {
					search_dirs = vim.tbl_isempty(open_projects) and { "" } or open_projects,
					post_action = post_action_fn,
					prompt = " (opened projects)",
				}))
			end)

			vim.keymap.set("n", "<leader>R", function() --
				vim.go.autochdir = false
				require("telescope").extensions.repo.list(vim.tbl_extend("error", dropdown_theme, {
					post_action = function(prefix)
						vim.cmd.cd(prefix)
					end,
					prompt = " (cd into a repo)",
				}))
			end)

			vim.keymap.set("n", "<leader>r", function()
				vim.go.autochdir = false
				require("telescope").extensions.repo.list(dropdown_theme)
			end)
			vim.keymap.set("n", "<leader>u", function()
				require("telescope").extensions.undo.undo(dropdown_theme)
			end)

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
					table.remove(yaml_path, table.maxn(yaml_path))
				end
			end

			local function gen_from_yaml_nodes(opts)
				local displayer = entry_display.create({
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
					return make_entry.set_default_entry_mt({
						ordinal = entry.text,
						display = make_display,
						filename = entry.filename,
						lnum = entry.lnum,
						text = entry.text,
						col = entry.col,
					}, opts)
				end
			end

			local yaml_symbols = function(opts)
				local conf = require("telescope.config").values
				local yaml_path = {}
				local result = {}
				local bufnr = vim.api.nvim_get_current_buf()
				local ft = vim.api.nvim_get_option_value("ft", { buf = bufnr })
				local tree = vim.treesitter.get_parser(bufnr, ft):parse()[1]
				local file_path = vim.api.nvim_buf_get_name(bufnr)
				local root = tree:root()
				for child_node, _ in root:iter_children() do
					visit_yaml_node(child_node, yaml_path, result, file_path, bufnr)
				end

				-- return result
				pickers
					.new(opts, {
						prompt_title = "YAML symbols",
						finder = finders.new_table({
							results = result,
							entry_maker = gen_from_yaml_nodes(opts),
						}),
						sorter = conf.generic_sorter(opts),
						previewer = conf.grep_previewer(opts),
					})
					:find()
			end

			vim.keymap.set("n", "<leader>m", function()
				yaml_symbols(dropdown_theme)
			end)
		end,
	},
}
