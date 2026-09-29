-- Seleccion del proveedor de portapapeles.
-- La decision vive en select(env), una funcion pura, para poder testearla
-- sin tener delante una maquina WSL, macOS, Wayland o X11.
local M = {}

local function provider(name, copy_plus, copy_star, paste_plus, paste_star)
	return {
		name = name,
		copy = { ["+"] = copy_plus, ["*"] = copy_star },
		paste = { ["+"] = paste_plus, ["*"] = paste_star },
		cache_enabled = 0,
	}
end

-- clip.exe interpreta la entrada con la codepage de la consola y rompe la
-- UTF-8 (ñ, á), pero acepta UTF-16LE sin BOM tal cual.
local wsl_copy = { "sh", "-c", "iconv -f utf-8 -t utf-16le | clip.exe" }
-- Get-Clipboard devuelve CRLF y la salida por defecto no es UTF-8.
-- Out.Write evita el salto de linea final que PowerShell añade al imprimir,
-- asi un texto charwise no se pega como linewise.
local wsl_paste = {
	"sh",
	"-c",
	"powershell.exe -NoProfile -NonInteractive -Command "
		.. "'[Console]::OutputEncoding=[System.Text.Encoding]::UTF8; "
		.. "[Console]::Out.Write((Get-Clipboard -Raw))' | tr -d '\\r'",
}

-- env = { wsl, mac, wayland, executable = function(cmd) -> bool }
function M.select(env)
	if env.mac then
		return provider("macos-clipboard", "pbcopy", "pbcopy", "pbpaste", "pbpaste")
	end

	-- En WSL nunca se usa xclip/wl-copy: el puente de WSLg hacia Windows no
	-- funciona, y el texto se quedaria solo en el lado Linux.
	if env.wsl then
		if env.executable("win32yank.exe") then
			return provider(
				"win32yank-wsl",
				"win32yank.exe -i --crlf",
				"win32yank.exe -i --crlf",
				"win32yank.exe -o --lf",
				"win32yank.exe -o --lf"
			)
		end
		if env.executable("clip.exe") and env.executable("powershell.exe") then
			return provider("wsl-windows-clipboard", wsl_copy, wsl_copy, wsl_paste, wsl_paste)
		end
		return nil
	end

	-- wl-copy solo tiene sentido dentro de una sesion Wayland real
	if env.wayland and env.executable("wl-copy") and env.executable("wl-paste") then
		return provider("wl-clipboard", "wl-copy", "wl-copy", "wl-paste --no-newline", "wl-paste --no-newline")
	end

	if env.executable("xclip") then
		return provider(
			"xclip-x11",
			"xclip -selection clipboard -i",
			"xclip -selection primary -i",
			"xclip -selection clipboard -o",
			"xclip -selection primary -o"
		)
	end

	return nil
end

function M.detect_env()
	return {
		wsl = vim.fn.has("wsl") == 1,
		mac = vim.fn.has("mac") == 1,
		wayland = (os.getenv("WAYLAND_DISPLAY") or "") ~= "",
		executable = function(cmd)
			return vim.fn.executable(cmd) == 1
		end,
	}
end

function M.setup()
	local selected = M.select(M.detect_env())
	if selected then
		vim.g.clipboard = selected
	end
end

return M
