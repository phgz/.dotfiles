require('formatter').setup{
  logging = true,
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
          exe = "isort",
          args = {"--quiet", "--profile", "black", "--resolve-all-configs", "-"},
          stdin = true
        }
      end,
      -- isort
      function()
        return {
          exe = "black",
          args = {"--quiet", '-'},
          stdin = true
        }
      end
    }
  }
}

local formatGrp = vim.api.nvim_create_augroup("FormatAutogroup", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "*.py",
  command = "FormatWrite",
  group = formatGrp,
})

local function file_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end
