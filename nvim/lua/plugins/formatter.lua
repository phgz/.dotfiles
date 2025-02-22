local config = function()
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
end

local formatGrp = vim.api.nvim_create_augroup("FormatAutogroup", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "*",
	command = "FormatWrite",
	group = formatGrp,
})

return {
	"",
	config = config,
}
