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

-- local signs = vim.iter.map(function(letter)
-- 	return { name = "StaticViewport" .. letter, text = letter, texthl = "mangenta" }
-- end, vim.gsplit("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", ""))
--
-- call("sign_define", { signs })
--
-- local function set_signs_for_viewport()
-- 	-- Clear existing signs for the window
-- 	vim.fn.sign_unplace("StaticViewport", { buffer = "%" })
--
-- 	local lnum_start = vim.fn.line("w0")
-- 	local lnum_end = vim.fn.line("w$")
--
-- 	for i, letter in ipairs(vim.list_slice(signs, 1, lnum_end - lnum_start + 1)) do
-- 		vim.fn.sign_place(0, "StaticViewport", letter.name, "%", { lnum = lnum_start + i - 1 })
-- 	end
-- end

api.nvim_create_autocmd("WinScrolled", {
	callback = function()
		vim.wo.statuscolumn = vim.wo.statuscolumn
	end,
})
