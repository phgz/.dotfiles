local status_line = function()
	local git = "%{exists('b:gitsigns_status')?'  ': ''}%{%get(b:,'gitsigns_status','')%}"
	local diagnostics = [[%{%luaeval("require'utils'.diagnostics_status_line()")%}]]
	local flags = "%{&modified || &readonly?' ': ''}%#GreenStatusLine#%h%#YellowStatusLine#%r%#RedStatusLine#%m"
	local message =
		[[%#GreyStatusLine#%{%luaeval('require("noice.api.status").search.get() or require("noice.api.status").message.get() or ""')%}]]
	return "%F" .. git .. diagnostics .. flags .. "%=" .. message
end

vim.fn.matchadd("DiffText", "\\%97v")

vim.go.statusline = status_line()
vim.opt.formatoptions:remove({ "l", "o", "r" })
vim.wo.statuscolumn = [[%s%{%luaeval("require'utils'.status_column()")%}]]
