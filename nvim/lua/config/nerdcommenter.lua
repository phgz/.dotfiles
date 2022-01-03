local utils = require('utils')

vim.g.NERDSpaceDelims = 0
vim.g.NERDDefaultAlign = 'left'
vim.g.NERDCommentEmptyLines = 1
--vim.g.NERDCreateDefaultMappings = 0
vim.g.NERDCreateDefaultMappings = 0

utils.map('x', 'Kc', '<plug>NERDCommenterComment', {noremap = false})
utils.map('x', 'Ku', '<plug>NERDCommenterUncomment', {noremap = false})
utils.map('x', 'Ke', '<plug>NERDCommenterToEOL', {noremap = false})
utils.map('x', 'KA', '<plug>NERDCommenterAppend', {noremap = false})
utils.map('x', 'Ky', '<plug>NERDCommenterYank', {noremap = false})
utils.map('x', 'KK', '<plug>NERDCommenterToggle', {noremap = false})
utils.map('x', 'Ki', '<plug>NERDCommenterInvert', {noremap = false})

utils.map('n', 'KK', '<plug>NERDCommenterToggle', {noremap = false})
utils.map('n', 'Kc', '<plug>NERDCommenterComment', {noremap = false})
utils.map('n', 'Ku', '<plug>NERDCommenterUncomment', {noremap = false})
utils.map('n', 'Ke', '<plug>NERDCommenterToEOL', {noremap = false})
utils.map('n', 'KA', '<plug>NERDCommenterAppend', {noremap = false})
utils.map('n', 'Ky', 'm`:co .-1<cr><plug>NERDCommenterYank``', {noremap = false})
