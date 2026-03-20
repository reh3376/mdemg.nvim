vim.opt.rtp:append(".")
vim.opt.rtp:append("/tmp/plenary.nvim")
vim.cmd("runtime plugin/plenary.vim")

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = false

vim.g.mapleader = " "
