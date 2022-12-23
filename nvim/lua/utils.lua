local api = vim.api

local call = api.nvim_call_function
local M = {}

function M.mk_repeatable(fn)
	return function(...)
		local args = { ... }
		local nargs = select("#", ...)
		vim.go.operatorfunc = "v:lua.require'utils'.repeat_action"

		M.repeat_action = function()
			fn(unpack(args, 1, nargs))
			-- if vim.fn.exists("*repeat#set") == 1 then
			-- 	local action = api.nvim_replace_termcodes(
			-- 		string.format("<cmd>call %s()<cr>", vim.go.operatorfunc),
			-- 		true,
			-- 		true,
			-- 		true
			-- 	)
			-- 	vim.fn["repeat#set"](action, -1)
			-- end
		end

		api.nvim_feedkeys("g@l", "n", false)
	end
end

function M.update_selection(selection_mode, start_row, start_col, end_row, end_col)
	api.nvim_buf_set_mark(0, "<", start_row, start_col - 1, {})
	api.nvim_buf_set_mark(0, ">", end_row, end_col - 1, {})

	local v_table = { charwise = "v", linewise = "V", blockwise = "<C-v>" }
	selection_mode = selection_mode or "charwise"

	-- Normalise selection_mode
	if vim.tbl_contains(vim.tbl_keys(v_table), selection_mode) then
		selection_mode = v_table[selection_mode]
	end

	-- Call to `nvim_replace_termcodes()` is needed for sending appropriate command to enter blockwise mode
	selection_mode = vim.api.nvim_replace_termcodes(selection_mode, true, true, true)

	local previous_mode = call("visualmode", {})

	-- visualmode() is set to "" when no visual selection has yet been made. Defaults it to "v"
	if previous_mode == "" then
		previous_mode = "v"
	end

	if previous_mode == selection_mode then
		selection_mode = ""
	end

	-- "gv": Start Visual mode with the same area as the previous area and the same mode.
	-- Hence, area will be what we defined in "<" and ">" marks. We only feed `selection_mode` if it is
	-- different than previous `visualmode`, otherwise it will stop visual mode.
	api.nvim_feedkeys("gv" .. selection_mode, "x", false)
end

function M.detect_selection_mode()
	local visual_mode = call("mode", { 1 })
	local selection_mode = visual_mode:sub(#visual_mode)

	return selection_mode
end

function M.get_range()
	local _, start_row, start_col, _ = unpack(call("getpos", { "v" }))
	local _, end_row, end_col, _ = unpack(call("getpos", { "." }))

	if start_row == end_row then
		if start_col > end_col then
			start_col, end_col = end_col, start_col
		end
	elseif start_row > end_row then
		start_row, end_row = end_row, start_row
		start_col, end_col = end_col, start_col
	end

	return start_row, start_col, end_row, end_col
end

return M
