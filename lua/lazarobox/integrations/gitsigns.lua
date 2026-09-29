-- gitsigns.nvim: signos de la columna, blame en linea y previews de hunks.
-- Los grupos Staged*, *Nr, *Cul, etc. no se definen: gitsigns los deriva de
-- estos, asi que basta con fijar los base para que todo cuadre.
return function(c, o)
	local groups = {
		GitSignsAdd = { fg = c.green },
		GitSignsChange = { fg = c.yellow },
		GitSignsDelete = { fg = c.rose },
		-- Casi invisible a proposito: el blame es contexto, no contenido
		GitSignsCurrentLineBlame = { fg = c.surface1 },
	}

	if o.transparent then
		-- Sin fondo del editor no hay sobre que mezclar: el word diff usa el
		-- acento solido y las previews solo colorean el texto
		groups.GitSignsAddPreview = { fg = c.green, bg = "NONE" }
		groups.GitSignsDeletePreview = { fg = c.rose, bg = "NONE" }
		groups.GitSignsAddInline = { fg = c.bg, bg = c.green, bold = true }
		groups.GitSignsDeleteInline = { fg = c.bg, bg = c.rose, bold = true }
		groups.GitSignsChangeInline = { fg = c.bg, bg = c.blue, bold = true }
		groups.GitSignsDeleteVirtLn = { fg = c.rose, bg = "NONE" }
	else
		-- Require diferido: theme.lua carga este modulo, y asi no hay ciclo al arrancar
		local blend = require("lazarobox.theme").blend
		groups.GitSignsAddPreview = { link = "DiffAdd" }
		groups.GitSignsDeletePreview = { link = "DiffDelete" }
		groups.GitSignsAddInline = { bg = blend(c.green, c.bg, 0.36) }
		groups.GitSignsChangeInline = { bg = blend(c.blue, c.bg, 0.14) }
		groups.GitSignsDeleteInline = { bg = blend(c.rose, c.bg, 0.36) }
	end

	return groups
end
