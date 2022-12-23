local api = vim.api
local call = api.nvim_call_function

local M = {}

M.get_range = function()
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
