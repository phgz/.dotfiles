return {
	"lewis6991/gitsigns.nvim",
	event = "BufReadPre",
	config = function()
		local call = vim.api.nvim_call_function

		-- Add close_preview_on_escape
		vim.api.nvim_set_hl(0, "GitSignsDeleteLn", { default = true, link = "DiffDelete" })
		require("gitsigns").setup({
			signs = {
				add = { text = "│" },
				change = { text = "│" },
				delete = { show_count = true, text = "_" },
				topdelete = { show_count = true, text = "‾" },
				changedelete = { show_count = true, text = "~" },
			},
			count_chars = {
				[1] = "",
				[2] = "₂",
				[3] = "₃",
				[4] = "₄",
				[5] = "₅",
				[6] = "₆",
				[7] = "₇",
				[8] = "₈",
				[9] = "₉",
				["+"] = "₊",
			},
			signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
			numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
			linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
			word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns

				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				-- Actions
				map({ "n", "v" }, "gr", gs.reset_hunk)
				map({ "n", "v" }, "ga", gs.stage_hunk)
				map("n", "gA", gs.undo_stage_hunk)
				map("n", "gR", gs.reset_buffer)
				map("n", "gd", gs.preview_hunk)
				map("n", "gi", gs.preview_hunk_inline)
				map("n", "gb", function()
					gs.blame_line({ ignore_whitespace = true })
				end)
				map("n", "gc", function()
					gs.diffthis(call("input", { "Compare to: " }))
				end)

				-- Text objects
				map({ "o", "x" }, "ih", gs.select_hunk)
				map({ "o", "x" }, "ah", gs.select_hunk)
			end,
			status_formatter = function(status)
				local head = status.head
				local status_txt = { head }
				local added, changed, removed = status.added, status.changed, status.removed
				if added and added > 0 then
					table.insert(status_txt, "%#GreenStatusLine#+" .. added)
				end
				if changed and changed > 0 then
					table.insert(status_txt, "%#BlueStatusLine#~" .. changed)
				end
				if removed and removed > 0 then
					table.insert(status_txt, "%#RedStatusLine#-" .. removed)
				end
				return table.concat(status_txt, " ")
			end,
			preview_config = {
				-- Options passed to nvim_open_win
				anchor = "SW",
				border = "none",
				style = "minimal",
				title = " Git diff ",
				title_pos = "center",
				relative = "cursor",
			},
		})
	end,
}
