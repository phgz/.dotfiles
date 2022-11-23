-- require plugin
local status, nvim_file_location = pcall(require, "nvim-file-location")
if not status then
  return
end

-- custom config
nvim_file_location.setup({
  keymap = "<localleader>f",
  mode = "absolute", -- options: workdir | absolute
  add_line = true,
  add_column = false,
})
