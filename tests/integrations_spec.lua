local theme = require("lazarobox.theme")
local palette = require("lazarobox.palette")
local c = palette.colors

local function is_color(v)
	return v == "NONE" or (type(v) == "string" and v:match("^#%x%x%x%x%x%x$") ~= nil)
end

-- Grupos clave por integracion: si falta alguno, el plugin cae a sus propios
-- defaults y el tema dejaria de verse como cuando lo pintaba catppuccin.
local REQUIRED = {
	gitsigns = {
		"GitSignsAdd", "GitSignsChange", "GitSignsDelete", "GitSignsCurrentLineBlame",
		"GitSignsAddPreview", "GitSignsDeletePreview",
		"GitSignsAddInline", "GitSignsChangeInline", "GitSignsDeleteInline",
	},
}

describe("lazarobox.integrations", function()
	local integrations = require("lazarobox.integrations")

	it("expone la lista de integraciones activas", function()
		assert_eq(true, type(integrations.enabled) == "table" and #integrations.enabled > 0)
	end)

	it("cada integracion requerida esta activa", function()
		for name in pairs(REQUIRED) do
			assert_eq(true, vim.tbl_contains(integrations.enabled, name), "integracion inactiva: " .. name)
		end
	end)

	for _, name in ipairs(integrations.enabled) do
		it(name .. " carga y devuelve specs validos (transparente y opaco)", function()
			local mod = require("lazarobox.integrations." .. name)
			assert_eq("function", type(mod), name .. " debe devolver function(c, o)")
			for _, transparent in ipairs({ true, false }) do
				local groups = mod(c, { transparent = transparent })
				assert_eq("table", type(groups))
				for group, spec in pairs(groups) do
					assert_eq("table", type(spec), group)
					for _, key in ipairs({ "fg", "bg", "sp" }) do
						if spec[key] ~= nil then
							assert_eq(true, is_color(spec[key]), group .. "." .. key .. " = " .. tostring(spec[key]))
						end
					end
				end
			end
		end)
	end
end)

describe("theme.groups con integraciones", function()
	local g = theme.groups(c)

	it("incluye los grupos clave de cada integracion", function()
		for name, groups in pairs(REQUIRED) do
			for _, group in ipairs(groups) do
				assert_eq(true, g[group] ~= nil, name .. ": falta " .. group)
			end
		end
	end)

	it("los links de las integraciones resuelven en el tema o en builtins", function()
		for name, spec in pairs(g) do
			if spec.link then
				local ok = g[spec.link] ~= nil or vim.fn.hlexists(spec.link) == 1
				assert_eq(true, ok, name .. " -> " .. spec.link)
			end
		end
	end)

	it("gitsigns usa los colores de diff de la paleta", function()
		assert_eq(c.green, g.GitSignsAdd.fg)
		assert_eq(c.yellow, g.GitSignsChange.fg)
		assert_eq(c.rose, g.GitSignsDelete.fg)
		assert_eq(c.surface1, g.GitSignsCurrentLineBlame.fg)
	end)

	it("gitsigns transparente: word diff con fondo solido y previews sin fondo", function()
		assert_eq({ fg = c.bg, bg = c.green, bold = true }, g.GitSignsAddInline)
		assert_eq({ fg = c.green, bg = "NONE" }, g.GitSignsAddPreview)
		assert_eq({ fg = c.rose, bg = "NONE" }, g.GitSignsDeleteVirtLn)
	end)

	it("gitsigns opaco: previews enlazan a diff y word diff con fondo mezclado", function()
		local o = theme.groups(c, { transparent = false })
		assert_eq({ link = "DiffAdd" }, o.GitSignsAddPreview)
		assert_eq({ bg = theme.blend(c.green, c.bg, 0.36) }, o.GitSignsAddInline)
		assert_eq(nil, o.GitSignsDeleteVirtLn)
	end)

	it("sigue siendo pura", function()
		local before = vim.deepcopy(c)
		assert_eq(g, theme.groups(c))
		assert_eq(before, c)
	end)
end)

-- Capturas treesitter anteriores a nvim 0.10. noice las usa para pintar la
-- documentacion LSP (@text.title, @text.reference, @parameter), asi que deben
-- seguir existiendo como copia exacta de su nombre moderno.
describe("theme.groups capturas legacy", function()
	local g = theme.groups(c)
	local ALIASES = {
		["@parameter"] = "@variable.parameter",
		["@field"] = "@variable.member",
		["@namespace"] = "@module",
		["@text.title"] = "@markup.heading",
		["@text.reference"] = "@markup.link",
		["@text.strong"] = "@markup.strong",
		["@method"] = "@function.method",
		["@conditional"] = "@keyword.conditional",
		["@text.title.1.markdown"] = "@markup.heading.1.markdown",
	}

	for legacy, modern in pairs(ALIASES) do
		it(legacy .. " copia a " .. modern, function()
			assert_eq(true, g[modern] ~= nil, "falta " .. modern)
			assert_eq(g[modern], g[legacy])
		end)
	end

	it("@type.qualifier enlaza a Keyword como hacia catppuccin", function()
		assert_eq(g["@keyword.modifier"], g["@type.qualifier"])
	end)
end)
