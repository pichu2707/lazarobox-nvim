local M = {}

local version_file = vim.fn.stdpath("config") .. "/VERSION"

local ok, version = pcall(vim.fn.readfile, version_file)
if ok and version and #version > 0 then
	M.version = vim.trim(version[1])
else
	M.version = "0.0.0"
end

function M.get()
	return M.version
end

function M.full()
	local ok, hash = pcall(vim.fn.system, {
		"git",
		"-C",
		vim.fn.stdpath("config"),
		"log",
		"--oneline",
		"-1",
	})
	if ok and hash then
		return M.version .. " (" .. vim.trim(hash) .. ")"
	end
	return M.version
end

function M.setup()
	vim.api.nvim_create_user_command("LazaroboxVersion", function()
		local mmdc = vim.fn.executable("mmdc") == 1 and "available" or "not found"
		local hash = M.full():match("%((.+)%)") or "n/a"
		vim.api.nvim_echo({
			{ "━━━ Lazarobox ━━━", "Title" },
			{ "\n" },
			{ "  󰃃  version:  " .. M.version, "Normal" },
			{ "\n" },
			{ "    commit:   " .. hash, "Comment" },
			{ "\n" },
			{ "  󰘬  node:     " .. (vim.fn.executable("node") == 1 and vim.fn.system("node --version"):gsub("%s+", "") or "not found"), "Comment" },
			{ "\n" },
			{ "  󰊢  mmdc:     " .. mmdc, "Comment" },
		}, false, {})
	end, {})
end

return M
