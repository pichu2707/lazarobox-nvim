-- Diagnostico de LazaroBox.nvim: `:checkhealth lazarobox`
--
-- Comprueba lo que el config necesita del sistema y, sobre todo, si la Nerd Font
-- esta realmente instalada. No se puede consultar la fuente que usa el terminal
-- desde Neovim, asi que hacemos dos cosas complementarias:
--   1. verificar que los ficheros de fuente estan registrados en el sistema
--   2. pintar glifos para que los confirmes con la vista
--
-- Las dos cosas son necesarias: la fuente puede estar instalada y el terminal
-- seguir configurado con otra.

local M = {}

local health = vim.health

local FONT_FAMILY = "JetBrainsMono Nerd Font"
local MIN_NVIM = { 0, 10 }

-- Herramientas externas que usa el config, con el motivo real de cada una y el
-- nombre del paquete en cada gestor. `default` cubre los gestores que usan el
-- nombre habitual; solo se listan las excepciones.
--
-- Si cambias esta tabla, cambia tambien las listas de paquetes de install.sh.
local TOOLS = {
	{
		cmd = "git",
		why = "lazy.nvim y fugitive",
		required = true,
		pkg = { default = "git" },
	},
	{
		cmd = "rg",
		why = "telescope y snacks.picker (live grep)",
		required = true,
		pkg = { default = "ripgrep" },
	},
	{
		cmd = "fd",
		why = "telescope y snacks.picker (busqueda de ficheros)",
		alt = "fdfind",
		pkg = { default = "fd", apt = "fd-find", dnf = "fd-find" },
	},
	{
		cmd = "make",
		why = "telescope-fzf-native (build = 'make')",
		pkg = { default = "make", apt = "build-essential", pacman = "base-devel" },
	},
	{
		cmd = "cc",
		why = "nvim-treesitter (:TSUpdate)",
		alt = "gcc",
		pkg = { default = "gcc", apt = "build-essential", pacman = "base-devel" },
		macos_hint = "xcode-select --install",
	},
	{
		cmd = "node",
		why = "copilot, claudecode y live-server",
		pkg = { default = "nodejs", brew = "node" },
	},
	{
		cmd = "npm",
		why = "instalar servidores desde Mason",
		pkg = { default = "npm", brew = "node" },
	},
	{
		cmd = "magick",
		why = "image.nvim (processor = magick_cli)",
		alt = "convert",
		pkg = { default = "imagemagick", dnf = "ImageMagick", zypper = "ImageMagick" },
	},
	{
		-- No esta en los repositorios de ninguna distro: va por npm global.
		-- Lo usa diagram.nvim para renderizar bloques mermaid (tecla K en
		-- markdown) y version.lua lo muestra en la pantalla de version.
		cmd = "mmdc",
		why = "renderizar mermaid con K en markdown (diagram.nvim)",
		npm = "@mermaid-js/mermaid-cli",
	},
	{
		cmd = "python3",
		why = "DAP de Python e iron.nvim",
		alt = "python",
		pkg = { default = "python3", pacman = "python" },
	},
}

-- Gestores de paquetes soportados, en el mismo orden de deteccion que install.sh.
-- Homebrew va al final a proposito: tambien corre en Linux, pero quien tiene apt
-- y brew a la vez debe instalar con apt. Ver package_manager().
local PACKAGE_MANAGERS = {
	{ key = "apt", probe = "apt-get", template = "sudo apt install %s" },
	{ key = "pacman", probe = "pacman", template = "sudo pacman -S %s" },
	{ key = "dnf", probe = "dnf", template = "sudo dnf install %s" },
	{ key = "zypper", probe = "zypper", template = "sudo zypper install %s" },
	{ key = "brew", probe = "brew", template = "brew install %s" },
}

-- ---------------------------------------------------------------------------
-- Utilidades
-- ---------------------------------------------------------------------------

local function has(cmd)
	return vim.fn.executable(cmd) == 1
end

local function is_wsl()
	return vim.fn.has("wsl") == 1
end

local function is_macos()
	return vim.fn.has("mac") == 1
end

-- Detecta el gestor de paquetes de ESTA maquina, con el mismo criterio que
-- install.sh: brew solo en macOS, el resto solo en Linux. El resultado se cachea
-- porque `executable()` es una llamada al sistema y aqui se consulta por cada
-- herramienta de la lista.
local detected_manager = nil

local function package_manager()
	if detected_manager ~= nil then
		return detected_manager or nil -- `false` = ya buscado y no encontrado
	end

	detected_manager = false
	for _, mgr in ipairs(PACKAGE_MANAGERS) do
		-- En macOS el unico gestor posible es brew: apt y dnf no existen ahi.
		-- En Linux valen todos, y el orden de la tabla decide la precedencia.
		local applies = not is_macos() or mgr.key == "brew"

		if applies and has(mgr.probe) then
			detected_manager = mgr
			break
		end
	end

	return detected_manager or nil
end

-- Construye la orden de instalacion exacta para esta maquina, o nil si no se
-- puede determinar. Es lo que convierte el diagnostico en algo accionable:
-- decir "falta chafa" sin decir como instalarlo deja el trabajo a medias.
local function install_hint(tool)
	-- Paquetes que no estan en los repositorios de las distros.
	if tool.npm then
		return ("npm install -g %s"):format(tool.npm)
	end

	-- En macOS el compilador no viene de un paquete, sino de las Command Line Tools.
	if is_macos() and tool.macos_hint then
		return tool.macos_hint
	end

	local mgr = package_manager()
	if not mgr or not tool.pkg then
		return nil
	end

	local package = tool.pkg[mgr.key] or tool.pkg.default
	if not package then
		return nil
	end

	return mgr.template:format(package)
end

-- ---------------------------------------------------------------------------
-- Version de Neovim
-- ---------------------------------------------------------------------------

local function check_neovim()
	health.start("Neovim")

	local v = vim.version()
	local current = string.format("%d.%d.%d", v.major, v.minor, v.patch)

	if v.major > MIN_NVIM[1] or (v.major == MIN_NVIM[1] and v.minor >= MIN_NVIM[2]) then
		health.ok("Neovim " .. current)
	else
		health.error(
			("Neovim %s es demasiado antigua"):format(current),
			{ ("LazaroBox necesita >= %d.%d"):format(MIN_NVIM[1], MIN_NVIM[2]) }
		)
	end
end

-- ---------------------------------------------------------------------------
-- Nerd Font
-- ---------------------------------------------------------------------------

-- En Linux y macOS fontconfig sabe que fuentes hay registradas.
local function font_in_fontconfig()
	if not has("fc-list") then
		return nil -- sin fontconfig no podemos afirmar nada
	end
	local out = vim.fn.system({ "fc-list", ":", "family" })
	if vim.v.shell_error ~= 0 then
		return nil
	end
	return out:find(FONT_FAMILY, 1, true) ~= nil
end

local function font_in_macos_dirs()
	local dirs = { vim.fn.expand("~/Library/Fonts"), "/Library/Fonts" }
	for _, dir in ipairs(dirs) do
		if #vim.fn.glob(dir .. "/JetBrainsMonoNerdFont*", false, true) > 0 then
			return true
		end
	end
	return false
end

-- En WSL la fuente que dibuja el terminal vive en el host Windows, no aqui.
-- Consultamos el registro de Windows a traves de la interoperabilidad.
local function font_in_windows_host()
	if not has("powershell.exe") then
		return nil
	end
	local out = vim.fn.system({
		"powershell.exe",
		"-NoProfile",
		"-Command",
		[[(Get-ItemProperty 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts' -ErrorAction SilentlyContinue).PSObject.Properties.Name -like 'JetBrainsMonoNerdFont*']],
	})
	if vim.v.shell_error ~= 0 then
		return nil
	end
	return out:find("JetBrainsMonoNerdFont", 1, true) ~= nil
end

local function check_font()
	health.start("Nerd Font")

	local fix = {
		"Ejecuta el instalador desde la raiz del repositorio:",
		"  ./install.sh --fonts-only        (Linux, macOS, WSL)",
		"  .\\install.ps1 -FontsOnly        (Windows nativo)",
	}

	if is_macos() then
		if font_in_macos_dirs() then
			health.ok(FONT_FAMILY .. " instalada en ~/Library/Fonts")
		else
			health.warn(FONT_FAMILY .. " no encontrada en las carpetas de fuentes", fix)
		end
	else
		local installed = font_in_fontconfig()
		if installed == true then
			health.ok(FONT_FAMILY .. " registrada en fontconfig")
		elseif installed == false then
			health.warn(FONT_FAMILY .. " no aparece en fc-list", fix)
		else
			health.info("fontconfig no disponible: no puedo comprobar los ficheros de fuente")
		end
	end

	-- El caso que mas confusion genera: fuente correcta en Linux, cajas en
	-- pantalla, porque quien renderiza es el terminal de Windows.
	if is_wsl() then
		local on_host = font_in_windows_host()
		if on_host == true then
			health.ok(FONT_FAMILY .. " registrada tambien en el host Windows")
		elseif on_host == false then
			health.error("La fuente NO esta instalada en el host Windows", {
				"En WSL el terminal es una aplicacion de Windows: es Windows quien",
				"dibuja los glifos. Instalarla solo dentro de la distro no sirve.",
				"Ejecuta: ./install.sh --fonts-only",
			})
		else
			health.info("No he podido consultar el registro de fuentes de Windows")
		end
	end

	-- Verificacion visual: si algo de esto sale como caja o interrogante, la
	-- fuente activa del terminal no es una Nerd Font.
	health.info("Comprueba a ojo estos glifos:    󰅚 󰋼 󰌵   ")
	health.info("Si ves cajas o interrogantes, el terminal no usa una Nerd Font")
end

-- ---------------------------------------------------------------------------
-- Herramientas externas
-- ---------------------------------------------------------------------------

-- Consejo accionable para una herramienta que falta: primero la orden concreta
-- para este sistema, despues el instalador que lo resuelve todo de una vez.
local function tool_advice(tool)
	local advice = {}

	local hint = install_hint(tool)
	if hint then
		table.insert(advice, hint)
	end

	table.insert(advice, "O ejecuta ./install.sh, que instala todo lo que falte")

	if not tool.required then
		table.insert(advice, "Opcional: sin el, esa funcion queda degradada")
	end

	return advice
end

local function check_tools()
	health.start("Herramientas externas")

	local mgr = package_manager()
	if mgr then
		health.info("Gestor de paquetes detectado: " .. mgr.key)
	else
		health.info("Sin gestor de paquetes reconocido: los consejos seran genericos")
	end

	for _, tool in ipairs(TOOLS) do
		local found = has(tool.cmd) and tool.cmd or (tool.alt and has(tool.alt) and tool.alt or nil)

		if found then
			local note = found ~= tool.cmd and (" (via %s)"):format(found) or ""
			health.ok(("%s%s — %s"):format(tool.cmd, note, tool.why))
		elseif tool.required then
			health.error(("%s no encontrado — %s"):format(tool.cmd, tool.why), tool_advice(tool))
		else
			health.warn(("%s no encontrado — %s"):format(tool.cmd, tool.why), tool_advice(tool))
		end
	end
end

-- ---------------------------------------------------------------------------
-- Portapapeles
--
-- init.lua y lua/config/options.lua eligen proveedor segun el entorno, asi que
-- comprobamos el que corresponde a esta maquina y no una lista generica.
-- ---------------------------------------------------------------------------

local function check_clipboard()
	health.start("Portapapeles")

	if is_macos() then
		if has("pbcopy") then
			health.ok("pbcopy/pbpaste (nativo de macOS)")
		else
			health.error("pbcopy no encontrado")
		end
		return
	end

	if is_wsl() then
		if has("win32yank.exe") then
			health.ok("win32yank.exe (portapapeles compartido con Windows)")
		else
			health.warn("win32yank.exe no encontrado", {
				"lua/config/options.lua lo usa para compartir portapapeles con Windows",
				"Ejecuta ./install.sh para instalarlo en /usr/local/bin",
			})
		end
		return
	end

	if os.getenv("WAYLAND_DISPLAY") then
		if has("wl-copy") and has("wl-paste") then
			health.ok("wl-clipboard (sesion Wayland)")
		else
			health.warn("wl-clipboard no encontrado en una sesion Wayland", {
				"Instala wl-clipboard con tu gestor de paquetes",
			})
		end
	elseif has("xclip") then
		health.ok("xclip (sesion X11)")
	else
		health.warn("Sin proveedor de portapapeles", { "Instala xclip o wl-clipboard" })
	end
end

-- ---------------------------------------------------------------------------
-- Ubicacion del config
-- ---------------------------------------------------------------------------

local function check_config()
	health.start("Configuracion")

	local config_path = vim.fn.stdpath("config")
	health.info("Config activa: " .. config_path)

	local resolved = vim.fn.resolve(config_path)
	if resolved ~= config_path then
		health.ok("Enlazada desde " .. resolved)
	end

	local version_file = config_path .. "/VERSION"
	if vim.fn.filereadable(version_file) == 1 then
		local version = vim.fn.readfile(version_file)[1] or "?"
		health.ok("LazaroBox v" .. vim.trim(version))
	else
		health.warn("VERSION no encontrado: puede que el config no este completo")
	end
end

function M.check()
	check_neovim()
	check_font()
	check_tools()
	check_clipboard()
	check_config()
end

return M
