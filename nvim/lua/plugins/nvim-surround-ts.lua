local api = vim.api
local keymap = vim.keymap
local fn = vim.fn
local utils = require("utils")

require("nvim-surround").setup({
	move_cursor = "sticky",
	keymaps = {
		insert = "<C-s>",
		insert_line = "<C-g>s",
		normal = "s",
		normal_cur = false,
		normal_line = "sV",
		normal_cur_line = false,
		visual = "s",
		visual_line = "S",
		delete_line = "dVs",
		delete = "ds",
		change = "cs",
		change_line = "cS",
	},
	surrounds = {
		["c"] = "conditional",
		["f"] = "function",
		["l"] = "loop",
		["k"] = {
			add = function()
				vim.defer_fn(function()
					local row, col = unpack(require("nvim-surround.buffer").get_mark("["))
					api.nvim_win_set_cursor(0, { row, col - 1 })
					local feed_prefix = require("nvim-surround.cache").normal.line_mode and "_" or ""
					api.nvim_feedkeys(feed_prefix .. "i", "n", false)
				end, 0)

				api.nvim_create_autocmd("InsertLeave", {
					once = true,
					callback = function()
						vim.go.operatorfunc = "v:lua.require'nvim-surround.utils'.NOOP"
						api.nvim_feedkeys("g@l", "n", false)
					end,
				})

				return { { "(" }, { ")" } }
			end,
			find = function()
				if vim.g.loaded_nvim_treesitter then
					local selection = require("nvim-surround.queries").get_selection("@call.outer", "textobjects")
					if selection then
						return selection
					end
				end
				return require("nvim-surround.patterns").get_selection("[^=%s%(%){}]+%b()")
			end,
			delete = "^(.-%()().-(%))()$",
			change = {
				target = "^.-([%w%._]+)()%(.-%)()()$",
				replacement = function()
					api.nvim_feedkeys("i", "n", false)
					return { { "" }, { "" } }
				end,
			},
		},
	},
})

keymap.set("n", "S", function()
	return "<Plug>(nvim-surround-normal)g_"
end, { expr = true, silent = true })

keymap.set("n", "ss", function()
	local current_line = fn.line(".")

	require("nvim-surround.buffer").highlight_selection({
		first_pos = { current_line, api.nvim_get_current_line():find("[^%s]") or 0 },
		last_pos = { current_line, vim.fn.col("$") },
	})

	local input = vim.fn.getcharstr()
	if input == "V" then
		return "<Plug>(nvim-surround-normal-line)L"
	else
		return "<Plug>(nvim-surround-normal-cur)" .. input
	end
end, { expr = true, silent = true, remap = true })

keymap.set("n", "sn", function()
	require("treemonkey").select({ ignore_injections = false })
	if utils.get_visual_state().is_active then
		api.nvim_feedkeys(vim.keycode("<esc>") .. "sv`<", "", false)
	end
end, { silent = true })

keymap.set("n", "sVn", function()
	require("treemonkey").select({ ignore_injections = false })
	if utils.get_visual_state().is_active then
		api.nvim_feedkeys(vim.keycode("<esc>") .. "sVv`<", "", false)
	end
end, { silent = true })
