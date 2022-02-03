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
  local lines = vim.api.nvim_buf_get_lines(0, tbl.start-1, tbl.end_, false)
  vim.api.nvim_buf_set_lines(0, to, to, true, lines)
  actualize_visual_selection(to+1, to+1+params.range)
  feed("gv=")
end

local duplicate_aux = function(other)
  local line = vim.api.nvim_buf_get_lines(0, other-1, other, false)
  local current = vim.fn.line('.')
  vim.api.nvim_buf_set_lines(0, current-1, current, true, line)
  feed("==")
end

local kill_aux = function(line)
  vim.api.nvim_buf_set_lines(0, line-1, line, true, {})
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

M.duplicate = function()
  local input = get_input("Duplicate line ")
  if input == nil then
    return
  end
  duplicate_aux(input)
end

M.kill = function()
  local input = get_input("Kill line ")
  if input == nil then
    return
  end
  kill_aux(input)
end

M.yank_comment_paste = function(vmode)
  local U = require("Comment.utils")
  local A = require("Comment.api")

  local range = U.get_region(vmode)
  local lines = U.get_lines(range)

  -- Copying the block
  local srow = range.erow
  vim.api.nvim_buf_set_lines(0, srow, srow, false, lines)

  -- Doing the comment
  A.comment_linewise_op(vmode)

  -- Move the cursor
  local erow = srow + 1
  local line = U.get_lines({ srow = srow, erow = erow })
  local _, col = U.grab_indent(line[1])
  vim.api.nvim_win_set_cursor(0, { erow, col })
end

return M
