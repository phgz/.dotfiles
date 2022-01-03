local utils = require("utils")

local register_comamnd = function(kind)
    local common_part = '\'<cmd>lua require"nvim-treesitter.textobjects.move"'
    local ns = string.format('%s.goto_next_start("@%s.outer")<cr>\'', common_part, kind)
    local ps = string.format('%s.goto_previous_start("@%s.outer")<cr>\'', common_part, kind)
    return {ns = ns, ps= ps}
end

local kinds = {'function', 'block', 'conditional', 'loop', 'parameter', 'statement', 'call', 'comment'}

mapping = {}

for _, k in pairs(kinds) do
    mapping[k] = register_comamnd(k)
end

next_hunk = "&diff ? ']h' : '<cmd>lua require\"gitsigns.actions\".next_hunk()<CR>'"
prev_hunk = "&diff ? '[h' : '<cmd>lua require\"gitsigns.actions\".prev_hunk()<CR>'"
mapping.hunk = {ns = next_hunk, ps = prev_hunk}

mapping.parameter.ns = mapping.parameter.ns:gsub('outer', 'inner')
mapping.parameter.ps = mapping.parameter.ps:gsub('outer', 'inner')
mapping.kall = mapping.call
mapping.call = nil
mapping.Komment = mapping.comment
mapping.comment = nil

function map_cmd(c, direction)
utils.map('', ']' .. c, string.format('repmo#Key(%s,%s) <bar> sunmap ]%s)', direction.ns, direction.ps, c), {expr = true, noremap=false})
utils.map('', '[' .. c, string.format('repmo#Key(%s,%s) <bar> sunmap [%s)', direction.ps, direction.ns, c), {expr = true, noremap=false})
end

for k, v in pairs(mapping) do
    map_cmd(k:sub(1,1), v)
end

utils.map('', ']m', 'repmo#SelfKey("]m", "[m") <bar> sunmap ]m', {expr = true, noremap=true})
utils.map('', '[m', 'repmo#SelfKey("[m", "]m") <bar> sunmap [m', {expr = true, noremap=true})

utils.map('n', ';', 'repmo#LastKey(";") <bar> sunmap ;', {expr = true, noremap=false})
utils.map('n', ',', 'repmo#LastRevKey(",") <bar> sunmap ,', {expr = true, noremap=false})

vim.g.fing_enabled = 0

utils.map('n', ';', 'repmo#LastKey("<Plug>fanfingtastic_;") <bar> sunmap ;', {expr = true, noremap=false})
utils.map('n', ',', 'repmo#LastRevKey("<Plug>fanfingtastic_,") <bar> sunmap ,', {expr = true, noremap=false})

utils.map('n', 'f', 'repmo#ZapKey("<Plug>fanfingtastic_f") <bar> sunmap f', {expr = true, noremap=false})
utils.map('n', 'F', 'repmo#ZapKey("<Plug>fanfingtastic_F") <bar> sunmap F', {expr = true, noremap=false})
utils.map('n', 't', 'repmo#ZapKey("<Plug>fanfingtastic_t") <bar> sunmap t', {expr = true, noremap=false})
utils.map('n', 'T', 'repmo#ZapKey("<Plug>fanfingtastic_T") <bar> sunmap T', {expr = true, noremap=false})
