vim.wo.foldmethod = "syntax"
local call = vim.api.nvim_call_function

local match = vim.iter(call("getmatches", {})):find(function(match)
	return match["group"] == "DiffText"
end)

call("matchdelete", { match["id"] })
call("matchadd", { "DiffText", "\\%89v" })
