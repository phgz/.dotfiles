local M = {}

M.get_range_motion = function(mode)
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

return M
