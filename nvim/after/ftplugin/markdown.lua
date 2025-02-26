vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "*.md",
	callback = require("md-pdf").convert_md_to_pdf,
})
