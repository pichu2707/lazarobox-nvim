-- Paleta de Lazarobox: Kanagawa Blur con acentos cyberpunk.
-- Basada en github.com/Gentleman-Programming/gentleman-kanagawa-blur (variante blur).
--
-- Los nombres son propios: la paleta es la identidad del tema y la consumen
-- lazarobox.theme y lazarobox.integrations (via `:colorscheme lazarobox`).

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

	-- Acentos. El uso indicado es el real en lazarobox.theme; hereda el mapeo
	-- de catppuccin, que fue el motor del tema hasta que se independizo.
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

return M
