local api = vim.api
local fn = vim.fn
local keymap = vim.keymap
local esc = vim.keycode("<esc>")
local registry = require("registry")

M = {}

local relative_focusable = function(win)
	local config = api.nvim_win_get_config(win)
	return config.relative ~= "" and config.focusable
end

local fn_popups = function(func)
	vim.iter(api.nvim_list_wins()):filter(relative_focusable):each(function(win)
		if api.nvim_win_is_valid(win) then
			func(win)
		end
	end)
end

local win_close = function(win)
	api.nvim_set_current_win(win)
	vim.cmd.close()
end

local popup_update_config_from_scrolling = function(win)
	if vim.w[win].gitsigns_preview == nil then
		local win_conf = api.nvim_win_get_config(win)
		assert(win_conf.relative == "win", win_conf)
		if type(win_conf.row) == "number" then
			return
		end
		local updated_conf = vim.tbl_deep_extend("force", api.nvim_win_get_config(win), {
			row = {
				[false] = win_conf.row[false] - vim.v.event[fn.expand("<afile>")].topline,
				[true] = win_conf.row[true],
			},
		})
		api.nvim_win_set_config(win, updated_conf)
	end
end

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

api.nvim_create_autocmd("BufReadPost", {
	callback = function()
		local row, col = unpack(api.nvim_buf_get_mark(0, '"'))
		if row > 0 and row <= api.nvim_buf_line_count(0) then
			api.nvim_win_set_cursor(0, { row, col })
			api.nvim_feedkeys("zz", "n", false)
		end
		vim.defer_fn(function()
			vim.cmd("redrawstatus")
		end, 200)
	end,
})

api.nvim_create_autocmd("CmdwinEnter", {
	callback = function()
		keymap.set("n", "q", "<C-c>", { buffer = true })
	end,
})

api.nvim_create_autocmd("FileType", {
	pattern = { "help", "startuptime", "qf", "lspinfo", "noice", "" },
	-- Not using `command` because for whatever reason, the cursor gets moved 1 char to the right
	-- after closing
	-- command = [[nnoremap <buffer><silent> q :close<cr> | let &stc=""]],

	callback = function()
		keymap.set("n", "q", "<cmd>close<cr>", { buffer = true })
		vim.wo.stc = ""
	end,
})

api.nvim_create_autocmd("InsertLeavePre", {
	callback = function()
		registry.insert_mode_col = fn.col(".")
	end,
})

api.nvim_create_autocmd("DiagnosticChanged", {
	callback = function()
		pcall(vim.cmd.redrawstatus)
	end,
})

api.nvim_create_autocmd("ModeChanged", {
	pattern = "i:niI",
	callback = function()
		registry.is_i_ctrl_o = true
	end,
})
api.nvim_create_autocmd("ModeChanged", {
	pattern = { "niI:i", "niI:n" },
	callback = function()
		registry.is_i_ctrl_o = false
	end,
})

api.nvim_del_augroup_by_name("nvim_swapfile")
api.nvim_create_autocmd("SwapExists", {
	callback = function()
		local info = fn.swapinfo(vim.v.swapname)
		local user = vim.uv.os_get_passwd().username
		local iswin = 1 == fn.has("win32")
		if info.error or info.pid <= 0 or (not iswin and info.user ~= user) then
			vim.v.swapchoice = "" -- Show the prompt.
			return
		end

		vim.v.swapchoice = "o" -- Choose "Read-Only".
		vim.bo.modifiable = false
		vim.notify("This file is already opened elsewhere. Opening in RO mode.")
	end,
})

api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
		local event_info = vim.v.event
		if event_info.operator ~= "y" or registry.is_i_ctrl_o then
			return
		end

		fn.setreg("/", fn.getreg('"'))

		local extra_visual_command = ""

		if not event_info.visual then
			local start_row, start_col = unpack(api.nvim_buf_get_mark(0, "["))
			local end_row, end_col = unpack(api.nvim_buf_get_mark(0, "]"))
			api.nvim_buf_set_mark(0, "<", start_row, start_col, {})
			api.nvim_buf_set_mark(0, ">", end_row, end_col - (event_info.inclusive and 0 or 1), {})
			local previous_mode = fn.visualmode()
			if not (previous_mode == "" or previous_mode == event_info.regtype) then
				extra_visual_command = event_info.regtype
			end
		end

		api.nvim_feedkeys("gvo" .. extra_visual_command .. esc, "x", false)
	end,
})

api.nvim_create_autocmd("VimEnter", {
	callback = function()
		keymap.set("n", "<esc>", function() -- Close popups
			-- api.nvim_win_close(win, false) is not consistent
			fn_popups(win_close)
		end)
		keymap.set("i", "<C-q>", function() -- Close popups in insert mode
			fn_popups(win_close)
		end)
	end,
})

-- update popups position to follow the cursor when scrolling
api.nvim_create_autocmd("WinScrolled", {
	callback = function()
		vim.wo.statuscolumn = vim.wo.statuscolumn
		local win_id = tonumber(fn.expand("<afile>"))
		if win_id and not relative_focusable(win_id) then
			fn_popups(popup_update_config_from_scrolling)
		end
	end,
})

return M
