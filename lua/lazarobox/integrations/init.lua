-- Integraciones de plugins del tema Lazarobox.
--
-- Solo estan las que catppuccin aplica hoy Y leen plugins instalados: el tema
-- debe verse igual, no "mejor". catppuccin tambien define Cmp*, Mini* y
-- NvimTree*, pero aqui no hay nvim-cmp (blink.cmp usa Pmenu*), ni mini.nvim,
-- ni nvim-tree (se usa oil), asi que esos grupos no pintan nada y no se copian.
--
-- Cada modulo devuelve function(c, o) -> { [grupo] = spec }, donde c es la
-- paleta y o las opciones del tema (o.transparent).

local M = {}

M.enabled = {
	"gitsigns",
}

-- Une los grupos de todas las integraciones activas. Pura: no toca Neovim.
function M.groups(c, o)
	local result = {}
	for _, name in ipairs(M.enabled) do
		for group, spec in pairs(require("lazarobox.integrations." .. name)(c, o)) do
			result[group] = spec
		end
	end
	return result
end

return M
