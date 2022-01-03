local M = {}

local feed = function(motion)
    local seq = vim.api.nvim_replace_termcodes(motion, true, true, true)
    vim.api.nvim_feedkeys(seq, 'n', true)
end

local actualize_visual_selection = function(new_start, new_end)
    vim.api.nvim_buf_set_mark(0,"<",new_start,0,{})
    vim.api.nvim_buf_set_mark(0,">",new_end,0,{})
end

local get_input = function(prompt)
    local input = vim.fn.input(prompt)

    if input == "" then
        return
    else
        return (tonumber(input))
    end
end

local get_range_params = function(tbl, to)
    local forward  = to > tbl.start
    local range = tbl.end_ - tbl.start
    local new_start, new_end = forward and to-range or to, forward and to or to + range
    return {forward = forward, new_start = new_start, new_end = new_end, range = range}
end

local get_range_motion = function(mode)
    local range_start
    local range_end

    if mode == 'v' then
        range_start = vim.fn.line('v')
        range_end = vim.api.nvim_win_get_cursor(0)[1]
        if range_start > range_end then
            range_start, range_end = range_end, range_start
        end
    else
        range_start = vim.fn.line('.')
        range_end = range_start
    end

    return {start = range_start, end_ = range_end}
end

local swap_aux = function(other, current)
    if current < other then
        current, other = other, current
    end

    vim.cmd(current .. "m " .. other-1 .. "|" .. other+1 .. "m " .. current)
    feed(other .. "gg==" .. current .. "gg==")
end


local copy_aux = function(tbl,to)
    local params = get_range_params(tbl, to)
    local lines = vim.api.nvim_eval("getline(" .. tbl.start .. "," .. tbl.end_ .. ")")

    for i,l in ipairs(lines) do
        vim.api.nvim_eval("append(" .. to + i-1 .. ", '" .. l .. "')")
    end
    actualize_visual_selection(to+1, to+1+params.range)
    feed("gv=")
end


local move_aux = function(tbl, to)
    local params = get_range_params(tbl, to)
    vim.cmd(tbl.start .. "," .. tbl.end_ .. "m " .. to)
    offset = params.forward and 0 or 1
    actualize_visual_selection(params.new_start+offset, params.new_end+offset)
    feed("gv=")
end

M.move = function(mode)
    local input = get_input("Move line(s) to ")
    if input == nil then
        return
    end
    local range = get_range_motion(mode)
    move_aux(range, input)
end

M.copy = function(mode)
    local input = get_input("Copy line(s) at ")
    if input == nil then
        return
    end
    local range = get_range_motion(mode)
    copy_aux(range, input)
end

M.swap = function()
    local current = vim.fn.line('.')
    local input = get_input("Swap line " .. current .. " and ")
    if input == nil then
        return
    end
    swap_aux(input, current)
end

return M
