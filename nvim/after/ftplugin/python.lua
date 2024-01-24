local fn = vim.fn

vim.wo.foldmethod = "syntax"

local match = vim.iter(fn.getmatches()):find(function(match)
	return match.group == "DiffText"
end)

if match ~= nil then
	fn.matchdelete(match.id)
end

fn.matchadd("DiffText", "\\%89v")
