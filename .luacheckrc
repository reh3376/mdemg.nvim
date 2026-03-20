std = "luajit"
read_globals = { "vim" }
globals = { "describe", "it", "before_each", "after_each", "assert" }
max_line_length = 120
ignore = {
	"212",  -- unused argument
	"122",  -- setting read-only field of global (vim.bo/vim.wo/vim.g/vim.opt are writable)
}
exclude_files = { ".git/*", "node_modules/*" }
