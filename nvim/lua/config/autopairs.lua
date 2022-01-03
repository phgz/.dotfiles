require('nvim-autopairs').setup({
    map_bs = true,  -- map the <BS> key
    map_c_w = false, -- map <c-w> to delete an pair if possible
    enable_check_bracket_line = false -- if next character is close pair and no open pair in same line, then no add close pair
})

local npairs = require("nvim-autopairs")

npairs.setup({
    check_ts = true,
})
