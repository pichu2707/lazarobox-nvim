-- Paleta de Lazarobox: Kanagawa Blur con acentos cyberpunk.
-- Basada en github.com/Gentleman-Programming/gentleman-kanagawa-blur (variante blur).
--
-- Los nombres son propios y no los de Catppuccin a proposito: la paleta es la
-- identidad del tema, y Catppuccin es solo el motor que la pinta por ahora.
-- Cuando exista colors/lazarobox.lua, leera de aqui sin tocar nada.

local M = {}

M.colors = {
	-- Fondos y superficies
	bg = "#191E28", -- fondo principal, sidebar y statusline
	border = "#232A40", -- bordes
	surface0 = "#1C212C",
	surface1 = "#232A36",
	surface2 = "#2A3142",

	-- Texto
	fg = "#F3F6F9",
	fg_neon = "#00FFFF", -- placeholder / texto secundario destacado
	fg_muted = "#8892A4", -- subido de tono para contrastar sobre fondo oscuro

	-- Grises para seleccion, texto inactivo y bordes
	gray3 = "#5A6480",
	gray4 = "#3D4F7A",

	-- Acentos (sintaxis)
	rose = "#CB7C94", -- constantes / embebido
	coral = "#C4746E", -- variables
	violet = "#B99BF2", -- funciones
	orchid = "#C99AD6", -- keywords
	blue = "#7FB4CA", -- tipos
	steel = "#A3B5D6", -- constructores
	aqua = "#7AA89F", -- cyan
	mint = "#A4DAA7", -- numeros / enums
	green = "#B7CC85",
	yellow = "#FFE066", -- warnings
	sand = "#DEBA87", -- operadores
	lavender = "#B4BEFE", -- identificadores / resaltado de seleccion
	gold = "#E0C15A", -- acento
}

-- Adaptador temporal: traduce la paleta a los tokens de Catppuccin. Desaparece
-- cuando el tema deje de depender de catppuccin/nvim.
function M.to_catppuccin(c)
	return {
		base = c.bg,
		mantle = c.bg,
		crust = c.border,

		surface0 = c.surface0,
		surface1 = c.surface1,
		surface2 = c.surface2,

		text = c.fg,
		subtext1 = c.fg_neon,
		subtext0 = c.fg_muted,

		overlay2 = c.fg_muted,
		overlay1 = c.gray3,
		overlay0 = c.gray4,

		red = c.rose,
		flamingo = c.coral,
		pink = c.violet,
		mauve = c.orchid,
		blue = c.blue,
		sapphire = c.steel,
		sky = c.aqua,
		teal = c.mint,
		green = c.green,
		yellow = c.yellow,
		peach = c.sand,
		lavender = c.lavender,
		rosewater = c.gold,
	}
end

return M
