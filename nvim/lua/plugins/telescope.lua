return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"popup.nvim",
			"cljoly/telescope-repo.nvim",
			"debugloop/telescope-undo.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
		},

		keys = {
			"<leader>f",
			"<leader>g",
			"<leader>b",
			"<leader>s",
			"<leader>l",
			"<leader>r",
			"<leader>u",
			"<leader>B",
		},
		cmd = "Telescope",

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
						-- settings = {
						-- 	auto_lcd = true,
						-- },
					},
				},
			})

			require("telescope").load_extension("undo")
			require("telescope").load_extension("repo")
			require("telescope").load_extension("noice")
			require("telescope").load_extension("ui-select")

			vim.api.nvim_create_autocmd("User TelescopePreviewerLoaded", { command = "setlocal wrap" })

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "TelescopePrompt",
				callback = function()
					vim.wo.statusline =
						[[ %{%getbufvar(bufnr('#'),'gitsigns_status')%}%#StatusLine#%=%{%expand('#:~')%}]]
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
			vim.keymap.set("n", "<leader>b", function()
				builtin.buffers(vim.tbl_extend("error", dropdown_theme, { cwd_only = true }))
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
				local listed_bufs = vim.tbl_map(function(buf)
					return buf["f"]
				end, call("msgpackparse", { context["bufs"] })[4])
				local to_edit
				for i = #jumps, 1, -4 do
					local file = jumps[i]["f"]
					if vim.startswith(file, prefix) and vim.tbl_contains(listed_bufs, file) then
						to_edit = file
						break
					end
				end
				vim.cmd("e " .. to_edit)
			end

			vim.keymap.set("n", "<leader>s", function() --
				local home = os.getenv("HOME")
				local context = api.nvim_get_context({ types = { "bufs" } })
				local bufs_project_root = vim.tbl_map(function(buf)
					return buf["f"]:match("(" .. home .. "/.-)/.*")
				end, call("msgpackparse", { context["bufs"] })[4])
				local open_projects = {}
				for _, b in ipairs(bufs_project_root) do
					if not vim.tbl_contains(open_projects, b) then
						table.insert(open_projects, b)
					end
				end
				require("telescope").extensions.repo.list(vim.tbl_extend("error", dropdown_theme, {
					search_dirs = open_projects,
					post_action = post_action_fn,
					prompt = " (opened projects)",
				}))
			end)

			vim.keymap.set("n", "<leader>r", require("telescope").extensions.repo.list)
			vim.keymap.set("n", "<leader>u", require("telescope").extensions.undo.undo)
		end,
	},
}
