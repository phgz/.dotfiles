local api = vim.api
local call = api.nvim_call_function

call("matchadd", { "DiffText", "\\%97v" })

api.nvim_create_autocmd("FileType", {
	pattern = { "help", "startuptime", "qf", "lspinfo", "noice" },
	command = [[nnoremap <buffer><silent> q :close<cr> | let &stc=""]],
})

api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
})

api.nvim_create_autocmd("VimEnter", {
	callback = function()
		vim.keymap.set("n", "<esc>", function() -- Close popups
			vim.cmd("fclose!")
			api.nvim_feedkeys(vim.keycode("<esc>"), "n", false)
		end)
	end,
})

api.nvim_create_autocmd("BufReadPost", {
	callback = function()
		local row, col = unpack(api.nvim_buf_get_mark(0, '"'))
		if row > 0 and row <= api.nvim_buf_line_count(0) then
			api.nvim_win_set_cursor(0, { row, col })
		end
	end,
})

api.nvim_create_autocmd("WinScrolled", {
	callback = function()
		vim.wo.statuscolumn = vim.wo.statuscolumn
	end,
})
