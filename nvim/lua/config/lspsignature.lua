require "lsp_signature".setup({
    bind = true, -- This is mandatory, otherwise border config won't get registered.
    handler_opts = {
        border = "rounded",
    },
    hint_enable = false,
    max_height = 6,
    extra_trigger_chars = {"(", ","},
    floating_window = true,
    toggle_key = '<M-h>'
})
