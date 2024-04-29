local api = vim.api
local fn = vim.fn
return {
	"lewis6991/gitsigns.nvim",
	event = "BufReadPre",
	config = function()
		-- Add close_preview_on_escape
		api.nvim_set_hl(0, "GitSignsDeleteLn", { default = true, link = "DiffDelete" })
		require("gitsigns").setup({
			signs = {
				add = { text = "│" },
				change = { text = "│" },
				delete = { show_count = true, text = "_" },
				topdelete = { show_count = true, text = "‾" },
				changedelete = { show_count = true, text = "~" },
			},
			count_chars = {
				[1] = "", --"₁",
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
			diff_opts = {
				ignore_whitespace = false,
			},
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns

				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				-- Actions
				map("n", "gr", gs.reset_hunk)
				map("v", "gr", function()
					gs.reset_hunk({ fn.line("v"), fn.line(".") })
				end)
				map("n", "ga", gs.stage_hunk)
				map("v", "ga", function()
					gs.stage_hunk({ fn.line("v"), fn.line(".") })
				end)
				map("n", "gs", gs.undo_stage_hunk)
				map("n", "gA", gs.stage_buffer)
				map("n", "gR", gs.reset_buffer)
				map("n", "gd", function()
					gs.preview_hunk()
					local winid = require("gitsigns.popup").is_open("hunk")
					if winid then
						local filetype = vim.bo.filetype
						api.nvim_win_call(winid, function()
							vim.bo.filetype = filetype
							map("n", "q", "<cmd>close<cr>", { silent = true })
						end)
					end
				end)
				map("n", "gb", function()
					gs.blame_line({ ignore_whitespace = true })
				end)
				map("n", "gc", function()
					local input = fn.input("Compare to: ")
					if input ~= "" then
						gs.diffthis(input)
					end
				end)

				-- Text objects
				map("o", "ih", gs.select_hunk)
				map("o", "ah", gs.select_hunk)
				map("x", "ih", function()
					api.nvim_feedkeys(vim.keycode("<esc>"), "x", false)
					gs.select_hunk()
				end)
				map("x", "ah", function()
					api.nvim_feedkeys(vim.keycode("<esc>"), "x", false)
					gs.select_hunk()
				end)
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
