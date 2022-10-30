local actions = require("telescope.actions")
local builtin = require("telescope.builtin")

require('telescope').setup{
  defaults = {
    mappings = {
      i = {
        ["<esc>"] = actions.close,
        ["<C-u>"] = false
      },
    },
  },
  extensions = {
    repo = {
      list = {
        fd_opts = {
          "--exclude=.*/*",
        },
      },
    },
  },
}

require("telescope").load_extension "repo"

local dropdown_theme = require('telescope.themes').get_dropdown({
  layout_config = {
    width = function(_, max_columns, _)
      return math.min(max_columns, 98)
    end,

    height = function(_, _, max_lines)
      return math.min(max_lines, 12)
    end,
  },
})

vim.api.nvim_create_autocmd("User TelescopePreviewerLoaded", {command = "setlocal wrap" })

vim.keymap.set('n', '<localLeader>f', function() builtin.git_files(dropdown_theme) end)
vim.keymap.set('n', '<localLeader>g', function() builtin.grep_string(dropdown_theme) end)
vim.keymap.set('n', '<localLeader>b', function() builtin.buffers(dropdown_theme) end)
vim.keymap.set('n', '<localLeader>s', function() builtin.treesitter(dropdown_theme) end)
vim.keymap.set('n', '<localleader>l', function() builtin.lsp_workspace_symbols(vim.tbl_extend("error", dropdown_theme, {query=vim.fn.expand("<cword>")})) end)

vim.keymap.set('n', '<localleader>r', '<cmd> lua require"telescope".extensions.repo.list()<cr>')
