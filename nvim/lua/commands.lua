local api = vim.api
local call = api.nvim_call_function
local esc = vim.keycode("<esc>")

M = {}
M.is_i_ctrl_o = false
M.insert_mode_col = 0

call("matchadd", { "DiffText", "\\%97v" })

api.nvim_create_autocmd("FileType", {
	pattern = { "help", "startuptime", "qf", "lspinfo", "noice", "" },
	-- Not using `command` because for whatever reason, the cursor gets moved 1 char to the right
	-- after closing
	-- command = [[nnoremap <buffer><silent> q :close<cr> | let &stc=""]],

	callback = function()
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = true })
		vim.wo.stc = ""
	end,
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
		local event_info = vim.v.event
		if event_info.operator ~= "y" or M.is_i_ctrl_o then
			return
		end

		call("setreg", { "/", call("getreg", { '"' }) })

		local extra_visual_command = ""

		if not event_info.visual then
			local start_row, start_col = unpack(api.nvim_buf_get_mark(0, "["))
			local end_row, end_col = unpack(api.nvim_buf_get_mark(0, "]"))
			api.nvim_buf_set_mark(0, "<", start_row, start_col, {})
			api.nvim_buf_set_mark(0, ">", end_row, end_col - (event_info.inclusive and 0 or 1), {})
			local previous_mode = vim.fn.visualmode()
			if not (previous_mode == "" or previous_mode == event_info.regtype) then
				extra_visual_command = event_info.regtype
			end
		end

		api.nvim_feedkeys("gvo" .. extra_visual_command .. esc, "x", false)
	end,
})

local close_popups = function()
	local relative_focusable = function(win)
		local config = api.nvim_win_get_config(win)
		return config.relative ~= "" and config.focusable
	end
	vim.iter(api.nvim_list_wins()):filter(relative_focusable):each(function(win)
		if api.nvim_win_is_valid(win) then
			-- api.nvim_win_close(win, false) is not consistent
			api.nvim_set_current_win(win)
			vim.cmd.close()
		end
	end)
end

api.nvim_create_autocmd("VimEnter", {
	callback = function()
		vim.keymap.set("n", "<esc>", function() -- Close popups
			close_popups()
			-- api.nvim_feedkeys(esc, "n", false)
		end)
		vim.keymap.set("i", "<C-q>", function() -- Close popups in insert mode
			close_popups()
		end)
	end,
})

api.nvim_create_autocmd("BufReadPost", {
	callback = function()
		local row, col = unpack(api.nvim_buf_get_mark(0, '"'))
		if row > 0 and row <= api.nvim_buf_line_count(0) then
			api.nvim_win_set_cursor(0, { row, col })
			vim.api.nvim_feedkeys("zz", "n", false)
		end
		vim.defer_fn(function()
			vim.cmd("redrawstatus")
		end, 200)
	end,
})

api.nvim_create_augroup("lsp_warmup", {})
api.nvim_create_autocmd("LspProgress", {
	pattern = "end",
	group = "lsp_warmup",
	callback = function(arg)
		if arg.data.result.value.title == "Diagnosing" then
			api.nvim_del_augroup_by_name("lsp_warmup")
			vim.cmd("redrawstatus")
		end
	end,
})

api.nvim_create_autocmd("BufAdd", {
	callback = function()
		api.nvim_create_autocmd("BufEnter", {
			once = true,
			callback = function()
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

api.nvim_create_autocmd("InsertLeavePre", {
	callback = function()
		M.insert_mode_col = vim.fn.col(".")
	end,
})

api.nvim_create_autocmd("ModeChanged", {
	pattern = "i:niI",
	callback = function()
		M.is_i_ctrl_o = true
	end,
})
api.nvim_create_autocmd("ModeChanged", {
	pattern = { "niI:i", "niI:n" },
	callback = function()
		M.is_i_ctrl_o = false
	end,
})

return M
