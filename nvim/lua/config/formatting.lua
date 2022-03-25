require('formatter').setup{
    logging = false,
    filetype = {
        python = {
            -- yapf
             --function()
             --    return {
             --        exe = "~/.miniconda3/envs/neovim/bin/yapf",
             --        args = {},
             --        stdin = true
             --    }
             --    end,
            -- black
            function()
                return {
                    exe = "~/.miniconda3/envs/neovim/bin/isort",
                    args = {"-", "--quiet", "--multi-line", "VERTICAL_HANGING_INDENT"},
                    stdin = true
                }
            end,
            -- isort
            function()
                return {
                    exe = "~/.miniconda3/envs/neovim/bin/black",
                    args = {"--quiet", "--line-length", "88", '-'},
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
