local keymap = vim.keymap

require("Comment").setup({
	toggler = {
		--Line-comment toggle keymap
		line = "KL",
		block = "<nop>",
	},

	--LHS of operator-pending mappings in NORMAL + VISUAL mode
	--@type table
	opleader = {
		-- Line-comment keymap
		line = "K",
		block = "<nop>",
	},
	extra = {
		--Add comment on the line above
		above = "KO",
		--Add comment on the line below
		below = "Ko",
		--Add comment at the end of line
		eol = "KA",
	},
})
keymap.set(
	"n",
	"KD",
	[[<cmd>lua require'registry'.set_position(vim.fn.getpos("."))<cr><cmd>let &operatorfunc = "v:lua.require'utils'.yank_comment_paste"<cr>g@]],
	{ silent = true }
)

keymap.set(
	"o",
	"K",
	"<cmd>lua require'utils'.adj_commented()<cr>",
	{ silent = true, desc = "Textobject for adjacent commented lines" }
)
