vim.keymap.set("v", "<Leader>e", function()
	require("refactoring").refactor("Extract Function")
end, { silent = true })
