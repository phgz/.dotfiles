return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"popup.nvim",
			{ "phgz/telescope-repo.nvim", branch = "feature/custom-post-action" },
			"debugloop/telescope-undo.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
		},

		config = function()
			local actions = require("telescope.actions")
			local builtin = require("telescope.builtin")
			local api = vim.api
			local call = api.nvim_call_function

			require("telescope").setup({
				defaults = {
					mappings = {
						i = {
							["<esc>"] = actions.close,
							["<C-u>"] = false,
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
		end,
	},
}
