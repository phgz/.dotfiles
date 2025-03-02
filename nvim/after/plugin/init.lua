local status_line = function()
	local git = "%{exists('b:gitsigns_status')?'  ': ''}%{%get(b:,'gitsigns_status','')%}"
	local diagnostics = [[%{%luaeval("require'utils'.diagnostics_status_line()")%}]]
	local flags = "%{&modified || &readonly?' ': ''}%#GreenStatusLine#%h%#YellowStatusLine#%r%#RedStatusLine#%m"
	local message = [[%{%luaeval("require'registry'.message")%}]]

	return "%F" .. git .. diagnostics .. flags .. "%=" .. message
end

vim.fn.matchadd("DiffText", "\\%97v")

vim.opt.formatoptions:remove({ "l", "o", "r" })
vim.go.statusline = status_line()
vim.wo.statuscolumn = [[%s%{%luaeval("require'utils'.status_column()")%}]]
