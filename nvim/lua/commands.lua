local api = vim.api
local call = api.nvim_call_function

call("matchadd", { "DiffText", "\\%97v" })

api.nvim_create_autocmd(
	"FileType",
	{ pattern = { "help", "startuptime", "qf", "lspinfo" }, command = [[nnoremap <buffer><silent> q :close<CR>]] }
)

api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
})

api.nvim_create_autocmd("VimEnter", {
	callback = function()
		vim.keymap.set("n", "<esc>", function() -- Close popups
			local relative = function(win)
				return api.nvim_win_get_config(win).relative ~= ""
			end
			vim.iter(api.nvim_list_wins()):filter(relative):each(function(win)
				if api.nvim_win_is_valid(win) then
					api.nvim_win_close(win, true)
				end
			end)
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
