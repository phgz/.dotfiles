local status_line = function()
	local git = "%{exists('b:gitsigns_status')?'  ': ''}%{%get(b:,'gitsigns_status','')%}"
	local flags = "%{&modified || &readonly?' ': ''}%#GreenStatusLine#%h%#YellowStatusLine#%r%#RedStatusLine#%m"
	local message =
		[[%#GreyStatusLine#%{%luaeval('require("noice.api.status").search.get() or require("noice.api.status").message.get() or ""')%}]]
	return "%F" .. git .. flags .. "%=" .. message
end

vim.go.statusline = status_line()
vim.opt.formatoptions:remove({ "l", "o", "r" })
vim.wo.statuscolumn = [[%s%{%luaeval("require'utils'.status_column()")%}]]
