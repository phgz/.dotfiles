require("Comment").setup{
      toggler = {
        ---Line-comment toggle keymap
        line = 'KK',
        ---Block-comment toggle keymap
        block = 'gkb',
    },

    ---LHS of operator-pending mappings in NORMAL + VISUAL mode
    ---@type table
    opleader = {
        -- -Line-comment keymap
        line = 'K',
        ---Block-comment keymap
        block = 'gk',
    },
      extra = {
        ---Add comment on the line above
        above = 'KO',
        ---Add comment on the line below
        below = 'Ko',
        ---Add comment at the end of line
        eol = 'KA',
    },
}

vim.keymap.set('n', 'KD',
function()
	local U = require("Comment.utils")

	local col = vim.fn.col('.')
	local range = U.get_region()
	local lines = U.get_lines(range)

	-- Copying the block
	local srow = range.erow
	vim.api.nvim_buf_set_lines(0, srow, srow, false, lines)

	-- Doing the comment
	require("Comment.api").comment.linewise()

	-- Move the cursor
	vim.api.nvim_win_set_cursor(0, { srow+1, col-1 })
end
, { silent = true, noremap = true })
