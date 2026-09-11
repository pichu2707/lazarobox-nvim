local capture_path = vim.fn.stdpath("cache") .. "/nvim-silicon-capture.png"

local function is_wsl()
	return vim.fn.has("wsl") == 1
end

-- WSLg puentea texto al portapapeles de Windows, pero no imagenes: hay que
-- empujar el PNG explicitamente como bitmap via PowerShell.
local function copy_to_windows_clipboard(path)
	local win_path = vim.fn.system({ "wslpath", "-w", path }):gsub("\n", "")
	local ps_cmd = ("Add-Type -AssemblyName System.Windows.Forms; "
		.. "[System.Windows.Forms.Clipboard]::SetImage([System.Drawing.Bitmap]::FromFile('%s'))"):format(win_path)
	vim.fn.system({ "powershell.exe", "-NoProfile", "-Command", ps_cmd })
	if vim.v.shell_error ~= 0 then
		vim.notify("No se pudo copiar la imagen al portapapeles de Windows", vim.log.levels.ERROR, { title = "nvim-silicon" })
	else
		vim.notify("Imagen copiada al portapapeles de Windows", vim.log.levels.INFO, { title = "nvim-silicon" })
	end
end

return {
	"michaelrommel/nvim-silicon",
	-- harfbuzz-sys 0.5.0 no compila con toolchains recientes (símbolo
	-- hb_ft_font_create_referenced no resuelto en el enlazado), pero esa
	-- misma feature "harfbuzz" es la que activa el loader de fuentes de
	-- font-kit (freetype + fontconfig). Se activan sueltas para evitar
	-- harfbuzz-sys sin perder la carga de fuentes.
	build = "cargo install silicon --no-default-features --features "
		.. "bin,font-kit/loader-freetype-default,font-kit/source-fontconfig-default",
	lazy = true,
	cmd = "Silicon",
	main = "nvim-silicon",
	keys = {
		{
			"<leader>cs",
			function()
				local silicon = require("nvim-silicon")
				if is_wsl() then
					silicon.file()
					copy_to_windows_clipboard(capture_path)
				else
					silicon.clip()
				end
			end,
			mode = "v",
			desc = "Capture selection as code image",
		},
	},
	opts = {
		font = "JetBrainsMono Nerd Font=34",
		theme = "Monokai Extended",
		background = "#1e1e2e",
		to_clipboard = true,
		output = capture_path,
		window_title = function()
			return vim.fn.expand("%:t")
		end,
	},
}
