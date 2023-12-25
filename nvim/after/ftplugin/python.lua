vim.wo.foldmethod = "syntax"
local call = vim.api.nvim_call_function

local match = vim.iter(call("getmatches", {})):find(function(match)
	return match["group"] == "DiffText"
end)

if match ~= nil then
	call("matchdelete", { match["id"] })
end

call("matchadd", { "DiffText", "\\%89v" })
