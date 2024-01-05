local api = vim.api
local call = api.nvim_call_function

call("matchadd", { "DiffText", "\\%97v" })

api.nvim_create_autocmd("FileType", {
	pattern = { "help", "startuptime", "qf", "lspinfo", "noice" },
	command = [[nnoremap <buffer><silent> q :close<cr> | let &stc=""]],
})

api.nvim_del_augroup_by_name("nvim_swapfile")
api.nvim_create_autocmd("SwapExists", {
	callback = function()
		local info = vim.fn.swapinfo(vim.v.swapname)
		local user = vim.uv.os_get_passwd().username
		local iswin = 1 == vim.fn.has("win32")
		if info.error or info.pid <= 0 or (not iswin and info.user ~= user) then
			vim.v.swapchoice = "" -- Show the prompt.
			return
		end

		vim.v.swapchoice = "o" -- Choose "Read-Only".
		vim.bo.modifiable = false
		vim.notify("This file is already opened elsewhere. Opening in RO mode")
	end,
})

api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
		call("setreg", { "/", call("getreg", { '"' }) })
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
		vim.defer_fn(function()
			vim.cmd("redrawstatus")
		end, 200)
	end,
})

api.nvim_create_autocmd("BufAdd", {
	callback = function()
		print("BufAdd")
		api.nvim_create_autocmd("BufEnter", {
			once = true,
			callback = function()
				print("BufEnter")
				vim.cmd.normal({ "zX", bang = true })
			end,
		})
	end,
})

api.nvim_create_autocmd("WinScrolled", {
	callback = function()
		vim.wo.statuscolumn = vim.wo.statuscolumn
	end,
})
