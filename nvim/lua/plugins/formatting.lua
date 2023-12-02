return {
	"mhartington/formatter.nvim",
	event = "BufWritePost",
	config = function()
		require("formatter").setup({
			logging = false,
			log_level = vim.log.levels.DEBUG,
			filetype = {
				fish = {
					require("formatter.filetypes.fish").fishindent,
				},
				sh = {
					require("formatter.filetypes.sh").shfmt,
				},
				markdown = {
					require("formatter.filetypes.markdown").prettier,
				},
				toml = {
					require("formatter.filetypes.toml").taplo,
				},
				yaml = {
					require("formatter.filetypes.yaml").yamlfmt,
				},
				json = {
					require("formatter.filetypes.json").prettier,
				},
				sql = {
					{
						exe = "sql-formatter",
						args = { "--language", "sqlite", "--" },
						stdin = true,
					},
				},
				python = {
					-- black
					-- local home = os.getenv('HOME')
					-- local current_dir = call("expand", {'%:p:h'})
					-- local pyproject = current_dir .. 'pyproject.toml'
					--
					-- while not call("filereadable", {pyproject}) and current_dir ~= home do
					--   current_dir = call("fnamemodify", {current_dir, ':h'})
					--   pyproject = current_dir .. 'pyproject.toml'
					-- end
					--
					-- config_opt = call("filereadable", {pyproject}) and "--config " .. pyproject or ""
					-- isort
					function()
						return {
							exe = "black",
							args = { "--quiet", "-" },
							stdin = true,
						}
					end,
				},
				lua = {
					require("formatter.filetypes.lua").stylua,
				},
				["*"] = {
					require("formatter.filetypes.any").remove_trailing_whitespace,
				},
			},
		})

		local formatGrp = vim.api.nvim_create_augroup("FormatAutogroup", { clear = true })
		vim.api.nvim_create_autocmd("BufWritePost", {
			pattern = "*",
			command = "FormatWrite",
			group = formatGrp,
		})
	end,
}
