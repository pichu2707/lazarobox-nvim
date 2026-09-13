-- Buffer navigation (legacy - BufferLine also provides <Tab>/<S-Tab>)
vim.keymap.set("n", "gb", ":bn<CR>", { noremap = true, silent = true, desc = "Next buffer" })
vim.keymap.set("n", "gB", ":bp<CR>", { noremap = true, silent = true, desc = "Previous buffer" })
-- Terminal manejado por toggleterm.nvim plugin
vim.keymap.set("n", "<leader>ac", "<cmd>ClaudeCode<cr>", { desc = "AI: Toggle Claude" })
vim.keymap.set("v", "<leader>as", "<cmd>ClaudeCodeSend<cr>", { desc = "AI: Send selection to Claude" })

-- Avante mappings removed: the plugin is not installed (no spec under
-- lua/plugins, absent from lazy-lock.json), so :AvanteAsk and friends only ever
-- returned E492. The <leader>a "AI" group stays: claudecode.nvim uses it.

-- Mover líneas de arriba/abajo (Modo Normal)
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { noremap = true, silent = true, desc = "Bajar una línea el código" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { noremap = true, silent = true, desc = "Subir una línea el código" })

-- Mover un bloque seleccionado (Modo Visual)
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true, desc = "Bajar bloque seleccionado" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { noremap = true, silent = true, desc = "Subir bloque seleccionado" })

-- Clipboard: no mappings needed. options.lua sets clipboard = "unnamedplus",
-- which makes the unnamed register the "+" register, so plain y/Y/p/P already
-- read and write the system clipboard. Explicit "+y / "+p mappings would be
-- exact duplicates of the builtins, and <leader>p also stalled behind
-- <leader>py for a full timeoutlen.

-- Split windows
vim.keymap.set("n", "<leader>wv", ":vsplit<CR>", { noremap = true, silent = true, desc = "Window: Split vertical" })
vim.keymap.set("n", "<leader>wh", ":split<CR>", { noremap = true, silent = true, desc = "Window: Split horizontal" })
vim.keymap.set("n", "<leader>wq", ":q<CR>", { noremap = true, silent = true, desc = "Window: Close" })

-- Navigate windows
vim.keymap.set("n", "<C-h>", "<C-w>h", { noremap = true, silent = true, desc = "Move to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { noremap = true, silent = true, desc = "Move to bottom window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { noremap = true, silent = true, desc = "Move to top window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { noremap = true, silent = true, desc = "Move to right window" })

-- Code configured
vim.keymap.set("n", "K", vim.lsp.buf.hover, {
	desc = "LSP Hover documentation",
})
-- Snacks presents these in the same picker as the rest of the config, with a
-- preview pane. vim.lsp.buf.* on its own dumps results into the quickfix list,
-- which is the only place this config drops out of that UI. The pcall keeps the
-- builtin as a fallback if snacks ever fails to load.
local function lsp_pick(picker, builtin)
	return function()
		local ok, snacks = pcall(require, "snacks")
		if ok and snacks.picker then
			snacks.picker[picker]()
		else
			builtin()
		end
	end
end

vim.keymap.set("n", "gd", lsp_pick("lsp_definitions", vim.lsp.buf.definition), {
	desc = "Go to definition",
})

vim.keymap.set("n", "gr", lsp_pick("lsp_references", vim.lsp.buf.references), {
	desc = "Find references",
})

vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, {
	desc = "Rename symbol",
})

vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {
	desc = "Code action",
})

-- Run file based on filetype
local function get_rust_project_root(file)
	local cargo_toml = vim.fs.find("Cargo.toml", { path = vim.fn.fnamemodify(file, ":h"), upward = true })[1]
	if not cargo_toml then
		return nil
	end

	return vim.fn.fnamemodify(cargo_toml, ":h")
end

local function cargo_bin_target_for_file(project_root, file)
	local metadata_output = vim.fn.systemlist(
		"cd " .. vim.fn.shellescape(project_root) .. " && cargo metadata --no-deps --format-version 1"
	)
	if vim.v.shell_error ~= 0 then
		return nil
	end

	local ok, metadata = pcall(vim.json.decode, table.concat(metadata_output, "\n"))
	if not ok or not metadata or not metadata.packages then
		return nil
	end

	local normalized_file = file:gsub("\\", "/")

	for _, package in ipairs(metadata.packages) do
		for _, target in ipairs(package.targets or {}) do
			local is_bin = vim.tbl_contains(target.kind or {}, "bin")
			local src_path = target.src_path and target.src_path:gsub("\\", "/")
			if is_bin and src_path == normalized_file then
				return target.name
			end
		end
	end

	return nil
end

local function get_rust_run_command(file)
	local crate_name = vim.fn.expand("%:t:r"):gsub("^%s+", ""):gsub("%s+$", ""):gsub("[^%w_]", "_")
	local project_root = get_rust_project_root(file)
	if not project_root then
		local output = vim.fn.expand("%:p:r")
		return "rustc --crate-name "
			.. vim.fn.shellescape(crate_name)
			.. " "
			.. vim.fn.shellescape(file)
			.. " -o "
			.. vim.fn.shellescape(output)
			.. " && "
			.. vim.fn.shellescape(output),
			nil
	end

	local bin_name = cargo_bin_target_for_file(project_root, file)
	if bin_name then
		return "cargo run --bin " .. vim.fn.shellescape(bin_name), project_root
	end

	local output = vim.fn.expand("%:p:r")
	vim.notify("No Cargo bin target found for this file; running it with rustc instead.", vim.log.levels.WARN)
	return "rustc --crate-name "
		.. vim.fn.shellescape(crate_name)
		.. " "
		.. vim.fn.shellescape(file)
		.. " -o "
		.. vim.fn.shellescape(output)
		.. " && "
		.. vim.fn.shellescape(output),
		nil
end

local function run_current_file()
	local ft = vim.bo.filetype
	local file = vim.fn.expand("%:p")

	if vim.fn.filereadable(file) == 0 then
		print("Not a readable file: " .. file)
		return
	end

	if ft == "python" then
		vim.cmd("!python3 " .. file)
	elseif ft == "javascript" then
		vim.cmd("!node " .. file)
	elseif ft == "typescript" then
		vim.cmd("!tsx " .. file)
	elseif ft == "sql" then
		vim.ui.input({ prompt = "Database file: " }, function(db)
			if db then
				vim.cmd("!sqlite3 " .. db .. " < " .. file)
			end
		end)
	elseif ft == "lua" then
		vim.cmd("!lua " .. file)
	elseif ft == "sh" or ft == "bash" then
		vim.cmd("!bash " .. file)
	elseif ft == "java" then
		local filename = vim.fn.expand("%:t:r") -- nombre sin extensión
		vim.cmd("!javac " .. file .. " && java " .. filename)
	elseif ft == "rust" then
		local cmd, project_root, err = get_rust_run_command(file)
		if not cmd then
			vim.notify(err or "Could not build Rust run command", vim.log.levels.ERROR)
			return
		end
		local previous_cwd = vim.fn.getcwd()
		if project_root then
			vim.cmd("lcd " .. vim.fn.fnameescape(project_root))
		end
		vim.cmd("!" .. cmd)
		if project_root then
			vim.cmd("lcd " .. vim.fn.fnameescape(previous_cwd))
		end
	elseif ft == "html" then
		vim.fn.jobstart({ "xdg-open", file }, { detach = true })
		vim.notify("Opening in browser: " .. vim.fn.expand("%:t"), vim.log.levels.INFO)
	else
		print("No run command configured for filetype: " .. ft)
	end
end

vim.keymap.set("n", "<leader>x", run_current_file, { desc = "Execute file inline" })

-- Quick run with toggleterm (keeps terminal open)
local function run_in_toggleterm()
	local ft = vim.bo.filetype
	local file = vim.fn.expand("%:p")
	local cmd = ""

	if vim.fn.filereadable(file) == 0 then
		print("Not a readable file: " .. file)
		return
	end

	if ft == "python" then
		cmd = 'python3 "' .. file .. '"'
	elseif ft == "javascript" then
		cmd = 'node "' .. file .. '"'
	elseif ft == "typescript" then
		cmd = 'tsx "' .. file .. '"'
	elseif ft == "lua" then
		cmd = 'lua "' .. file .. '"'
	elseif ft == "sh" or ft == "bash" then
		cmd = 'bash "' .. file .. '"'
	elseif ft == "java" then
		local dir = vim.fn.expand("%:p:h")
		local filename = vim.fn.expand("%:t:r")
		cmd = 'cd "' .. dir .. '" && javac "' .. vim.fn.expand("%:t") .. '" && java ' .. filename
	elseif ft == "rust" then
		local rust_cmd, project_root, err = get_rust_run_command(file)
		if not rust_cmd then
			vim.notify(err or "Could not build Rust run command", vim.log.levels.ERROR)
			return
		end
		if project_root then
			cmd = 'cd ' .. vim.fn.shellescape(project_root) .. ' && ' .. rust_cmd
		else
			local dir = vim.fn.expand("%:p:h")
			cmd = 'cd ' .. vim.fn.shellescape(dir) .. ' && ' .. rust_cmd
		end
	else
		print("No run command configured for filetype: " .. ft)
		return
	end

	-- Usa la API de toggleterm para ejecutar el comando
	local Terminal = require("toggleterm.terminal").Terminal
	local run_term = Terminal:new({
		cmd = cmd,
		direction = "float",
		close_on_exit = false,
		on_open = function(term)
			vim.cmd("startinsert!")
		end,
	})
	run_term:toggle()
end

vim.keymap.set("n", "<leader>X", run_in_toggleterm, { desc = "Execute file in terminal" })
vim.keymap.set("n", "<leader>ip", function()
	local src = vim.fn.expand("<cfile>")
	if src == "" then
		return
	end

	local base = vim.fn.expand("%:p:h")
	local path = src
	if not src:match("^https?://") and not src:match("^/") then
		path = base .. "/" .. src
	end

	local ok, img = pcall(require, "snacks.image")
	if ok and vim.fn.filereadable(path) == 1 then
		pcall(img.open, path)
	else
		vim.fn.jobstart({ "xdg-open", path }, { detach = true })
	end
end, { desc = "Image: Preview under cursor" })

-- LSP Diagnostics keymaps
vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, { desc = "LSP: Show diagnostic details" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "LSP: Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "LSP: Next diagnostic" })
vim.keymap.set("n", "<leader>lq", vim.diagnostic.setloclist, { desc = "LSP: List diagnostics" })

-- Vite dev server in split terminal
vim.keymap.set("n", "<leader>vd", function()
	local Terminal = require("toggleterm.terminal").Terminal
	local vite_dev = Terminal:new({
		cmd = "npm run dev",
		direction = "horizontal",
		close_on_exit = false,
		auto_scroll = true,
	})
	vite_dev:toggle()
end, { desc = "Terminal: Start Vite dev server" })

-- Buffer navigation (Tab/S-Tab)
vim.keymap.set("n", "<Tab>", ":bnext<CR>", { noremap = true, silent = true, desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>", { noremap = true, silent = true, desc = "Previous buffer" })
vim.keymap.set("n", "<leader>bc", ":bdelete<CR>", { noremap = true, silent = true, desc = "Buffer: Close" })
vim.keymap.set("n", "<leader>b1", "<cmd>LualineBuffersJump 1<CR>", { desc = "Buffer: Go to 1" })
vim.keymap.set("n", "<leader>b2", "<cmd>LualineBuffersJump 2<CR>", { desc = "Buffer: Go to 2" })
vim.keymap.set("n", "<leader>b3", "<cmd>LualineBuffersJump 3<CR>", { desc = "Buffer: Go to 3" })
vim.keymap.set("n", "<leader>b4", "<cmd>LualineBuffersJump 4<CR>", { desc = "Buffer: Go to 4" })
vim.keymap.set("n", "<leader>b5", "<cmd>LualineBuffersJump 5<CR>", { desc = "Buffer: Go to 5" })
