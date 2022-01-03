-- autocmd TextYankPost * if (v:event.operator is 'y' || v:event.operator is 'd') && v:event.regname is '' | OSCYankReg " | endif
-- Copy yank everywhere
vim.cmd([[ autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | OSCYankReg " | endif]])
