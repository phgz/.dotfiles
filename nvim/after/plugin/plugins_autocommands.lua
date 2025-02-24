local plugins_utils = require("plugins_utils")

local formatGrp = vim.api.nvim_create_augroup("FormatAutogroup", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "*",
	command = "FormatWrite",
	group = formatGrp,
})

vim.api.nvim_create_autocmd("User", {
	pattern = "TelescopePreviewerLoaded",
	callback = function()
		if vim.api.nvim_win_get_config(0).relative ~= "" then
			vim.wo.wrap = true
		end
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "TelescopePrompt",
	callback = plugins_utils.set_telescope_statusline,
})
