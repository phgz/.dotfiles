local api = vim.api
local M = {}

local feed = function(motion)
	local seq = api.nvim_replace_termcodes(motion, true, true, true)
	api.nvim_feedkeys(seq, "n", true)
end

local split = function(str, sep)
	local fields = {}
	local pattern = string.format("([^%s]+)", sep)
	str:gsub(pattern, function(captured)
		fields[#fields + 1] = captured
	end)

	return fields
end

M.delete_backward = function(bigWord)
	local col = api.nvim_win_get_cursor(0)[2]
	local char = api.nvim_get_current_line():sub(col + 1, col + 1)

	local keywords = vim.opt.iskeyword["_value"]
	local token_kw = {}

	for i, str in ipairs(split(keywords, ",")) do
		if str:len() == 1 and str ~= "@" then
			token_kw[#token_kw + 1] = str
		end
	end

	local all_kw = "%w" .. table.concat(token_kw)
	local all_kw_pattern = string.format("[%s]", all_kw)

	if char:match(all_kw_pattern) then
		if bigWord then
			feed("daW")
		else
			feed("<right>db")
		end
	else
		if bigWord then
			feed("BdW")
		else
			feed("<right>db")
		end
	end

	local next_char = api.nvim_get_current_line():sub(col + 2, col + 2)
	local prev_char = char
	i = 0

	while prev_char:match(all_kw_pattern) do
		i = i + 1
		prev_char = api.nvim_get_current_line():sub(col - i, col - i)
	end

	if next_char == " " then
		if prev_char == " " then
			feed("x")
		end
		feed("ge")
	end
end

return M
