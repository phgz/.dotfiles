local bo = vim.bo

bo.shiftwidth = 2
bo.softtabstop = 2
bo.tabstop = 2

vim.opt.formatoptions:remove({ "l", "o", "r" })
