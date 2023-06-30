local status_line = function()
	local status = "%{exists('b:gitsigns_status')?' ': ''}%{%get(b:,'gitsigns_status','')%}"
	status = status
		.. [[%=%#GreyStatusLine#%{%luaeval('require("noice.api.status").search.get() or require("noice.api.status").message.get() or ""')%}]]
	status = status .. "%=%h%#RedStatusLine#%m%#BlueStatusLine#%r%#StatusLine# %F"
	return status
end

vim.go.statusline = status_line()
vim.opt.formatoptions:remove({ "l", "o", "r" })
