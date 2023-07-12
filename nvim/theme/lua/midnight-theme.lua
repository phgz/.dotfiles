vim.cmd([[
	colorscheme ayu

	highlight! Substitute guifg=#0F1419 guibg=#36A3D9
	highlight! link IncSearch Substitute

	highlight! link Folded Comment
	highlight! clear SignColumn

	highlight! IlluminatedWordText gui=bold
	highlight! IlluminatedWordRead gui=bold
	highlight! IlluminatedWordWrite gui=bold

	highlight! LspSignatureActiveParameter gui=italic guifg=#B8CC52  

	highlight! MatchParen gui=None guifg=None guibg=#3E4B59 
	highlight! MatchWord gui=bold

	highlight! DiagnosticUnderlineOk gui=undercurl guibg=None guisp=magenta
	highlight! DiagnosticUnderlineHint gui=undercurl guibg=None guisp=#B8CC52
	highlight! DiagnosticUnderlineWarn gui=undercurl guibg=None guisp=#FFC300
	highlight! DiagnosticUnderlineInfo gui=undercurl guibg=None guisp=#36A3D9
	highlight! DiagnosticUnderlineError gui=undercurl guibg=None guisp=#FF3333

	highlight! DiagnosticLineNrOk gui=bold guibg=None guifg=magenta
	highlight! DiagnosticLineNrHint gui=bold guibg=None guifg=#B8CC52
	highlight! DiagnosticLineNrWarn gui=bold guibg=None guifg=#FFC300
	highlight! DiagnosticLineNrInfo gui=bold guibg=None guifg=#36A3D9
	highlight! DiagnosticLineNrError gui=bold guibg=None guifg=#FF3333

	highlight! DiagnosticOk guibg=None guifg=magenta
	highlight! DiagnosticHint guibg=None guifg=#B8CC52
	highlight! DiagnosticWarn guibg=None guifg=#FFC300
	highlight! DiagnosticInfo guibg=None guifg=#36A3D9
	highlight! DiagnosticError guibg=None guifg=#FF3333

	highlight! YellowStatusLine guifg=#FFC300 guibg=#14191F
	highlight! RedStatusLine guifg=#FF3333 guibg=#14191F
	highlight! GreenStatusLine guifg=#B8CC52 guibg=#14191F
	highlight! BlueStatusLine guifg=#36A3D9 guibg=#14191F
	highlight! GreyStatusLine guifg=grey guibg=#14191F

	highlight! LazyDimmed guifg=grey 
	highlight! LazyProp guifg=grey 

	highlight! link NoiceCmdlineIcon StatusLine
	highlight! link NoiceCmdline StatusLine
	highlight! NoiceCursor guibg=#F29718
]])
