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
vim.filetype.add({
	extension = {
		mdx = "markdown",
	},
})

-- Clipboard universal: detecta WSL, X11, Wayland o macOS automáticamente
local function setup_clipboard()
	-- WSL: usa win32yank.exe
	if vim.fn.has("wsl") == 1 and vim.fn.executable("win32yank.exe") == 1 then
		vim.g.clipboard = {
			name = "win32yank-wsl",
			copy = { ["+"] = "win32yank.exe -i --crlf", ["*"] = "win32yank.exe -i --crlf" },
			paste = { ["+"] = "win32yank.exe -o --lf", ["*"] = "win32yank.exe -o --lf" },
			cache_enabled = 0,
		}
		return
	end

	-- Linux con Wayland: usa wl-copy/wl-paste
	if vim.fn.executable("wl-copy") == 1 and vim.fn.executable("wl-paste") == 1 then
		vim.g.clipboard = {
			name = "wl-clipboard",
			copy = { ["+"] = "wl-copy", ["*"] = "wl-copy" },
			paste = { ["+"] = "wl-paste --no-newline", ["*"] = "wl-paste --no-newline" },
			cache_enabled = 0,
		}
		return
	end

	-- Linux con X11: usa xclip
	if vim.fn.executable("xclip") == 1 then
		vim.g.clipboard = {
			name = "xclip-x11",
			copy = {
				["+"] = "xclip -selection clipboard -i",
				["*"] = "xclip -selection primary -i",
			},
			paste = {
				["+"] = "xclip -selection clipboard -o",
				["*"] = "xclip -selection primary -o",
			},
			cache_enabled = 0,
		}
		return
	end

	-- macOS: usa pbcopy/pbpaste
	if vim.fn.has("macunix") == 1 then
		vim.g.clipboard = {
			name = "macos-clipboard",
			copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
			paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
			cache_enabled = 0,
		}
		return
	end
end

setup_clipboard()
