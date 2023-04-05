local api = vim.api
local call = api.nvim_call_function

call("matchadd", { "DiffText", "\\%97v" })

api.nvim_create_autocmd(
	"FileType",
	{ pattern = { "help", "startuptime", "qf", "lspinfo" }, command = [[nnoremap <buffer><silent> q :close<CR>]] }
)

-- api.nvim_create_autocmd("BufWritePost", {
-- 	callback = function()
-- 		vim.cmd("redraw")
-- 		print("saved")
-- 	end,
-- })

api.nvim_create_autocmd("VimEnter", {
	callback = function()
		vim.keymap.set("n", "<esc>", function() -- Close popups
			local filter = function(win)
				return api.nvim_win_get_config(win).relative ~= ""
			end
			local to_close = vim.tbl_filter(filter, api.nvim_list_wins())
			for _, win in ipairs(to_close) do
				api.nvim_win_close(win, false)
			end
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
