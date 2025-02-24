local status_line = function()
	local git = "%{exists('b:gitsigns_status')?'  ': ''}%{%get(b:,'gitsigns_status','')%}"
	local diagnostics = [[%{%luaeval("require'utils'.diagnostics_status_line()")%}]]
	local flags = "%{&modified || &readonly?' ': ''}%#GreenStatusLine#%h%#YellowStatusLine#%r%#RedStatusLine#%m"
	local message = "%#GreyStatusLine#%{get(v:,'statusmsg', 'abc')}"
	-- local message =
	-- 	[[%#GreyStatusLine#%{%luaeval('require("noice.api.status").search.get() or require("noice.api.status").message.get() or ""')%}]]
	local error =
		[[%#RedStatusLine#%{get(v:,'errmsg', '') ==# ''?'':'  [' . strftime('%T') . '] ' . 'An error occured.' . luaeval("require'utils'.reset_errmsg()")}]]

	return "%F" .. git .. diagnostics .. flags .. "%=" .. message
end

vim.fn.matchadd("DiffText", "\\%97v")

vim.opt.formatoptions:remove({ "l", "o", "r" })
vim.go.statusline = status_line()
vim.wo.statuscolumn = [[%s%{%luaeval("require'utils'.status_column()")%}]]
