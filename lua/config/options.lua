-- Leader key configuration
vim.g.mapleader = " " -- Espacio como leader
vim.g.maplocalleader = " " -- Espacio como local leader

-- Ensure PATH includes system bins (needed for sqlite3, etc.)
do
	local extra = {
		"/usr/local/bin",
		"/usr/bin",
		"/bin",
		"/home/linuxbrew/.linuxbrew/bin",
	}
	local path = vim.env.PATH or ""
	for _, p in ipairs(extra) do
		if not path:find(p, 1, true) then
			path = p .. ":" .. path
		end
	end
	vim.env.PATH = path
end

vim.opt.number = true
vim.opt.showtabline = 2
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.wrap = true
vim.opt.expandtab = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.clipboard = "unnamedplus"
vim.opt.swapfile = false
-- Cap how long Neovim waits for a follow-up key after a mapping prefix
-- (default is 1000ms, which stalls on every leader prefix).
vim.opt.timeoutlen = 300
vim.filetype.add({
	extension = {
		mdx = "markdown",
	},
})

-- Clipboard universal: la deteccion (WSL, macOS, Wayland, X11) vive en lazarobox.clipboard
require("lazarobox.clipboard").setup()
