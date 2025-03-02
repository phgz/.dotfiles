local M = {}

M.insert_mode_col = nil
M.is_i_ctrl_o = nil
M.operator_pending = nil
M.last_deleted_buffer = nil
M.register = nil
M.keymaps = {}
M.message = ""

local position = nil
M.set_position = function(pos)
	-- We check the length of pos, as getpos() returns a 4 elements table.
	-- If it's the case, we also readjust to be neovim API o-based
	position = #pos == 4 and { pos[2], pos[3] - 1 } or pos
end
M.get_position = function()
	return position
end

return M
