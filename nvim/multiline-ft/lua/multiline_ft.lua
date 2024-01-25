local M = {}
local api = vim.api
local fn = vim.fn
local esc = vim.keycode("<esc>")
local dummy_fn = "{_ -> v:true}"
local global_repeat_fn = "v:lua.require'multiline_ft'.multiline_find_repeat"
local utils = require("utils")
local registry = {}

local case_functions = {
	["g~"] = function(c)
		return c == c:upper() and c:lower() or c:upper()
	end,
	["gu"] = function(c)
		return c:lower()
	end,
	["gU"] = function(c)
		return c:upper()
	end,
}

local function get_escaped_char()
	local char = fn.escape(fn.getcharstr(), "^$.*~")
	if char == fn.nr2char(27) then
		-- escape
		return nil
	else
		return char
	end
end

local function abort()
	api.nvim_feedkeys(esc, "x", true)
	api.nvim_feedkeys(esc, "n", true)
end

local function reset_keymaps()
	vim.keymap.del("n", ".")
	vim.keymap.del("n", "p")
	vim.keymap.del("n", "P")
end

local function set_text_or_lines(text_tbl, visual_mode, sr, sc, er, ec)
	if visual_mode == "v" then
		api.nvim_buf_set_text(0, sr - 1, sc, er - 1, ec + 1, text_tbl)
	else
		api.nvim_buf_set_lines(0, sr - 1, er, true, text_tbl)
	end
end

local function get_text_or_lines(visual_mode, sr, sc, er, ec)
	local text_as_table

	if visual_mode == "v" then
		text_as_table = api.nvim_buf_get_text(0, sr - 1, sc, er - 1, ec + 1, {})
	else
		text_as_table = api.nvim_buf_get_lines(0, sr - 1, er, true)
		table.insert(text_as_table, "")
	end

	return text_as_table
end

local function yank(sr, sc, er, ec, visual_mode, register, highlight)
	local text_as_table = get_text_or_lines(visual_mode, sr, sc, er, ec)
	if visual_mode == "V" then
		sc, ec = 0, #text_as_table[#text_as_table]
	end

	fn.setreg(register, table.concat(text_as_table, "\n"))

	if highlight then
		local yank_ns = api.nvim_create_namespace("hlyank")

		vim.highlight.range(0, yank_ns, "IncSearch", { sr - 1, sc }, { er - 1, ec + 1 }, {
			regtype = visual_mode,
			inclusive = false,
			priority = vim.highlight.priorities.user,
		})

		vim.defer_fn(function()
			if api.nvim_buf_is_valid(0) then
				api.nvim_buf_clear_namespace(0, yank_ns, 0, -1)
			end
		end, 150)
	end
end

local function repeat_change_callback(opts)
	opts.operator = "repeat-change"
	local dot_register = fn.getreg(".")
	M.set_registry(opts)
	vim.go.operatorfunc = dummy_fn
	api.nvim_feedkeys("g@l", "n", false)

	vim.keymap.set("n", ".", function()
		reset_keymaps()

		if vim.v.operator == "g@" and vim.go.operatorfunc == dummy_fn and fn.getreg(".") == dot_register then
			vim.go.operatorfunc = global_repeat_fn
			api.nvim_feedkeys("g@l", "n", false)
		else
			api.nvim_feedkeys(".", "n", false)
		end
	end)

	vim.iter({ "p", "P" }):each(function(action)
		vim.keymap.set("n", action, function()
			reset_keymaps()
			api.nvim_feedkeys(action, "n", false)
		end)
	end)
end

local function operate_func(pos)
	local orig_row, orig_col, new_row, new_col = unpack(pos)
	local opts = M.get_registry()
	local modes, operator = opts.modes, opts.operator

	orig_col = not opts.forward and orig_col - 1 or orig_col

	if operator == "c" then
		api.nvim_create_autocmd("InsertLeave", {
			once = true,
			callback = function()
				repeat_change_callback(opts)
			end,
		})
		utils.update_selection(false, modes.visual, orig_row, orig_col, new_row, new_col)
		return
	end

	local start_row, start_col, end_row, end_col = utils.get_range({
		start_row = orig_row,
		start_col = orig_col,
		end_row = new_row,
		end_col = new_col,
	})

	if modes.visual == vim.keycode("<C-v>") then
		error("Not implemented for <C-v>.")
	elseif modes.visual == "v" then
		api.nvim_buf_set_mark(0, "[", start_row, start_col, {})
		api.nvim_buf_set_mark(0, "]", end_row, end_col, {})
	else
		local last_line = api.nvim_buf_get_lines(0, end_row - 1, end_row, true)[1]
		api.nvim_buf_set_mark(0, "[", start_row, 0, {})
		api.nvim_buf_set_mark(0, "]", end_row, #last_line - 1, {})
	end

	if operator == "d" then
		yank(start_row, start_col, end_row, end_col, modes.visual, opts.register, false)
		set_text_or_lines({}, modes.visual, start_row, start_col, end_row, end_col)
		api.nvim_win_set_cursor(0, { start_row, start_col })
		return
	end
	api.nvim_win_set_cursor(0, { orig_row, orig_col })

	if operator == "y" then
		yank(start_row, start_col, end_row, end_col, modes.visual, opts.register, true)
	elseif operator == "repeat-change" then
		local dot_reg = fn.getreg(".")
		local chars = vim.iter(dot_reg:gmatch("."))

		local acc = chars:fold({ stack = {}, bs_shift = 0 }, function(t, c)
			if c == vim.keycode("<BS>") then
				if vim.tbl_isempty(t.stack) then
					t.bs_shift = t.bs_shift + 1
				else
					table.remove(t.stack)
				end
			else
				table.insert(t.stack, c)
			end
			return t
		end)

		local stack, bs_shift = acc.stack, acc.bs_shift
		api.nvim_win_set_cursor(0, { start_row, start_col - 1 - bs_shift + #stack })
		set_text_or_lines({ table.concat(stack) }, modes.visual, start_row, start_col - bs_shift, end_row, end_col)
	elseif operator == "g~" or operator == "gu" or operator == "gU" then
		local text_as_table = get_text_or_lines(modes.visual, start_row, start_col, end_row, end_col)

		local switched_case_table = vim.iter.map(function(line)
			local switched_case_line = string.gsub(line, "%a", case_functions[operator])
			return switched_case_line
		end, text_as_table)

		set_text_or_lines(switched_case_table, modes.visual, start_row, start_col, end_row, end_col)
	elseif operator == "g@" then
		if opts.is_repeating then
			vim.cmd("call " .. opts.old_operatorfunc .. "()")
		else
			vim.cmd("call " .. opts.old_operatorfunc .. "()")
			vim.go.operatorfunc = dummy_fn
			api.nvim_feedkeys("g@l", "x", false)
			vim.go.operatorfunc = global_repeat_fn
		end
	end
end

function M.set_registry(value)
	registry = value
end

function M.get_registry()
	return registry
end

function M.goto_pos_multiline(opts)
	local offset = opts.exclusive and (opts.forward and -1 or 1) or 0
	local searchpos_opts = "Wn"
	searchpos_opts = opts.forward and searchpos_opts or searchpos_opts .. "b"
	local count = vim.v.count == 0 and opts.count or vim.v.count
	local orig_row, orig_col = unpack(api.nvim_win_get_cursor(0))
	vim.cmd.normal({ "m'", bang = true })
	local new_row, new_col

	if opts.repeat_motion and opts.exclusive then
		api.nvim_win_set_cursor(0, { orig_row, orig_col - offset })
	end

	for _ = 1, count do
		new_row, new_col = unpack(fn.searchpos(opts.char, searchpos_opts))
		if new_row == 0 then
			api.nvim_win_set_cursor(0, { orig_row, orig_col })
			return
		end
		-- Decrement new_col since nvim api-indexing is (1,0)-indexed for `nvim_win_(g|s)et_cursor()`
		new_col = new_col - 1
		-- During search, do not add `offset` since it will stall for `exclusive`
		api.nvim_win_set_cursor(0, { new_row, new_col })
	end

	new_col = new_col + offset
	api.nvim_win_set_cursor(0, { new_row, new_col })

	return { orig_row, orig_col, new_row, new_col }
end

function M.multiline_find_repeat()
	local positions = M.goto_pos_multiline(M.get_registry())
	if positions == nil then
		abort()
		return
	end
	operate_func(positions)
end

function M.multiline_find(forward, exclusive, repeat_module)
	local char = get_escaped_char()

	if char == nil then
		abort()
		return
	end

	-- local modes = utils.get_modes()
	-- local operator = vim.v.operator
	local operator_count = M.get_registry().operator_count or 0
	-- local is_repeating = vim.go.operatorfunc == global_repeat_fn

	local opts = {
		char = char,
		forward = forward,
		exclusive = exclusive,
		count = operator_count > 0 and operator_count or vim.v.count1,
		-- modes = modes,
		-- operator = operator,
		-- operator_count = nil,
		-- is_repeating = is_repeating,
		-- old_operatorfunc = is_repeating and M.get_registry().old_operatorfunc or vim.go.operatorfunc,
		-- register = vim.v.register,
	}

	M.set_registry(opts)
	repeat_module.set_last_move(M.goto_pos_multiline, vim.tbl_extend("error", opts, { repeat_motion = true }))

	-- if not modes.operator_pending then
	M.goto_pos_multiline(opts)
	-- 	return
	-- end

	-- vim.go.operatorfunc = global_repeat_fn

	-- if operator == "c" then
	-- 	local positions = M.goto_pos_multiline(opts)
	-- 	if positions == nil then
	-- 		abort()
	-- 		return
	-- 	end
	-- 	operate_func(positions)
	-- elseif operator == "g@" then
	-- 	return
	-- else
	-- 	api.nvim_feedkeys("g@l", "n", false)
	-- end
end

return M
