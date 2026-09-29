local clipboard = require("lazarobox.clipboard")

-- Construye un entorno falso: solo los ejecutables listados "existen"
local function env(opts)
	local bins = {}
	for _, b in ipairs(opts.bins or {}) do
		bins[b] = true
	end
	return {
		wsl = opts.wsl or false,
		mac = opts.mac or false,
		wayland = opts.wayland or false,
		executable = function(cmd)
			return bins[cmd] == true
		end,
	}
end

describe("clipboard.select", function()
	it("Linux Wayland con wl-clipboard usa wl-copy", function()
		local c = clipboard.select(env({ wayland = true, bins = { "wl-copy", "wl-paste", "xclip" } }))
		assert_eq("wl-clipboard", c.name)
		assert_eq("wl-copy", c.copy["+"])
		assert_eq("wl-paste --no-newline", c.paste["+"])
		assert_eq(0, c.cache_enabled)
	end)

	it("Wayland sin wl-copy pero con xclip cae a xclip", function()
		local c = clipboard.select(env({ wayland = true, bins = { "xclip" } }))
		assert_eq("xclip-x11", c.name)
	end)

	it("wl-copy instalado fuera de una sesion Wayland no se usa", function()
		local c = clipboard.select(env({ bins = { "wl-copy", "wl-paste", "xclip" } }))
		assert_eq("xclip-x11", c.name)
	end)

	it("X11 solo con xclip usa xclip", function()
		local c = clipboard.select(env({ bins = { "xclip" } }))
		assert_eq("xclip-x11", c.name)
		assert_eq("xclip -selection clipboard -i", c.copy["+"])
		assert_eq("xclip -selection clipboard -o", c.paste["+"])
		assert_eq("xclip -selection primary -i", c.copy["*"])
	end)

	it("WSL con win32yank usa win32yank", function()
		local c = clipboard.select(env({ wsl = true, wayland = true, bins = { "win32yank.exe", "xclip" } }))
		assert_eq("win32yank-wsl", c.name)
		assert_eq("win32yank.exe -i --crlf", c.copy["+"])
		assert_eq("win32yank.exe -o --lf", c.paste["+"])
	end)

	it("WSL sin win32yank usa herramientas de Windows, nunca xclip ni wl-copy", function()
		local c = clipboard.select(env({
			wsl = true,
			wayland = true,
			bins = { "xclip", "wl-copy", "wl-paste", "clip.exe", "powershell.exe" },
		}))
		assert_eq("wsl-windows-clipboard", c.name)
		assert_eq({ "sh", "-c", "iconv -f utf-8 -t utf-16le | clip.exe" }, c.copy["+"])
		assert_eq(c.copy["+"], c.copy["*"])
		assert_eq("sh", c.paste["+"][1])
		assert_eq(true, c.paste["+"][3]:find("powershell.exe", 1, true) ~= nil)
		assert_eq(true, c.paste["+"][3]:find("Get-Clipboard -Raw", 1, true) ~= nil)
		assert_eq(0, c.cache_enabled)
	end)

	it("WSL sin herramientas de Windows no cae a xclip", function()
		local c = clipboard.select(env({ wsl = true, bins = { "xclip" } }))
		assert_eq(nil, c)
	end)

	it("macOS usa pbcopy/pbpaste", function()
		local c = clipboard.select(env({ mac = true, bins = { "pbcopy", "pbpaste", "xclip" } }))
		assert_eq("macos-clipboard", c.name)
		assert_eq("pbcopy", c.copy["+"])
		assert_eq("pbpaste", c.paste["+"])
	end)

	it("sin nada disponible devuelve nil", function()
		assert_eq(nil, clipboard.select(env({})))
	end)
end)
