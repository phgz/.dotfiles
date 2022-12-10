vim.wo.foldmethod = "syntax"
local call = vim.api.nvim_call_function

for _, match in ipairs(call("getmatches", {})) do
	if match["group"] == "DiffText" then
		call("matchdelete", {match["id"]})
		break
	end
end

call("matchadd", {"DiffText", "\\%89v"})
