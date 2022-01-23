local utils = require("utils")

require("neogen").setup {
    enabled = true,
    input_after_comment = true,
    languages = {
        python = {
            template = {
                annotation_convention = "numpydoc"
            }
        },
    }
}

local opts = { noremap = true, silent = true }
utils.map("n", "<leader>a", "<CMD>lua require('neogen').generate()<CR>", opts)
