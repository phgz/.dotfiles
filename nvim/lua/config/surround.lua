local config = require("nvim-surround.config")

require("nvim-surround").setup({
  keymaps = {
    insert = "<C-g>s",
    insert_line = "<C-g>S",
    normal = "s",
    normal_cur = "ss",
    normal_line = "yS",
    normal_cur_line = "ySS",
    visual = "s",
    visual_line = "S",
    delete = "ds",
    change = "cs",
  },
})

local opts = {
    expr = true,
    remap = true,
    silent = true,
}
vim.keymap.set('n', 'S',
function()
  return config.get_opts().keymaps.normal .. "g_"
end
, opts)
