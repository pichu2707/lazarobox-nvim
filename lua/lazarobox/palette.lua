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
	border = "#232A40", -- fondos laterales (NormalSB, TabLine) y separadores sin transparencia
	surface0 = "#1C212C",
	surface1 = "#232A36",
	surface2 = "#2A3142",

	-- Texto
	fg = "#F3F6F9",
	fg_neon = "#00FFFF", -- texto secundario de plugins (subtext1); ningun grupo base lo usa
	fg_muted = "#8892A4", -- comentarios, puntuacion y popups; subido de tono para contrastar

	-- Grises para texto oculto e inactivo
	gray3 = "#5A6480", -- texto oculto (Conceal) y atenuado
	gray4 = "#3D4F7A", -- NonText, FoldColumn, TabLine inactiva

	-- Acentos. El uso indicado es el real: sigue el mapeo de catppuccin, que
	-- es el que reproduce lazarobox.theme.
	rose = "#CB7C94", -- errores, borrados en diff, @variable.builtin
	coral = "#C4746E", -- Identifier, TODO, codigo en markdown
	salmon = "#EBA0AC", -- parametros; es el `maroon` de Mocha, que la paleta nunca sobrescribio
	violet = "#B99BF2", -- PreProc, Special, regex, escapes y macros
	orchid = "#C99AD6", -- keywords, condicionales, bucles e include
	blue = "#7FB4CA", -- funciones, directorios y bordes flotantes
	steel = "#A3B5D6", -- Label
	aqua = "#7AA89F", -- operadores y fondo de busqueda
	mint = "#A4DAA7", -- caracteres, docstrings, listas y enum members
	green = "#B7CC85", -- strings y anadidos en diff
	yellow = "#FFE066", -- tipos y warnings
	sand = "#DEBA87", -- constantes, numeros, booleanos y builtins
	lavender = "#B4BEFE", -- propiedades, miembros y CursorLineNr
	gold = "#E0C15A", -- cursor y WinBar
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
