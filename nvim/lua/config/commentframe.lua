require("nvim-comment-frame").setup({

	-- if true, <leader>cf keymap will be disabled
	disable_default_keymap = false,

	-- adds custom keymap
	keymap = "Kf",
	multiline_keymap = "Km",

	-- width of the comment frame
	frame_width = 80,

	-- wrap the line after 'n' characters
	line_wrap_len = 76,

	-- automatically indent the comment frame based on the line
	auto_indent = true,

	-- add comment above the current line
	add_comment_above = false,

	-- configurations for individual language goes here
	languages = {},
})
