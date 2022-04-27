require('formatter').setup{
  logging = false,
  filetype = {
    python = {
      -- black
      function()
        -- local home = os.getenv('HOME')
        -- local current_dir = vim.fn.expand('%:p:h')
        -- local pyproject = current_dir .. 'pyproject.toml'
        --
        -- while not vim.fn.filereadable(pyproject) and current_dir ~= home do
        --   current_dir = vim.fn.fnamemodify(current_dir, ':h')
        --   pyproject = current_dir .. 'pyproject.toml'
        -- end
        --
        -- config_opt = vim.fn.filereadable(pyproject) and "--config " .. pyproject or ""
        return {
          exe = "~/.miniconda3/envs/neovim/bin/isort",
          args = {"-", "--quiet", "--multi-line", 3, "--resolve-all-configs"},
          stdin = true
        }
      end,
      -- isort
      function()
        return {
          exe = "~/.miniconda3/envs/neovim/bin/black",
          args = {"--quiet", '-'},
          stdin = true
        }
      end
    }
  }
}

vim.api.nvim_exec([[
augroup FormatAutogroup
autocmd!
autocmd BufWritePost *.py FormatWrite
augroup END
]], false)

local function file_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end
