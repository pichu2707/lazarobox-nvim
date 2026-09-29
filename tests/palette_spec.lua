local palette = require("lazarobox.palette")

-- Valores que tenia color_overrides en lua/plugins/catppuccin.lua antes de
-- extraer la paleta: el tema debe verse exactamente igual tras el cambio.
local EXPECTED_CATPPUCCIN = {
	base = "#191E28",
	mantle = "#191E28",
	crust = "#232A40",
	surface0 = "#1C212C",
	surface1 = "#232A36",
	surface2 = "#2A3142",
	text = "#F3F6F9",
	subtext1 = "#00FFFF",
	subtext0 = "#8892A4",
	overlay2 = "#8892A4",
	overlay1 = "#5A6480",
	overlay0 = "#3D4F7A",
	red = "#CB7C94",
	flamingo = "#C4746E",
	pink = "#B99BF2",
	mauve = "#C99AD6",
	blue = "#7FB4CA",
	sapphire = "#A3B5D6",
	sky = "#7AA89F",
	teal = "#A4DAA7",
	green = "#B7CC85",
	yellow = "#FFE066",
	peach = "#DEBA87",
	lavender = "#B4BEFE",
	rosewater = "#E0C15A",
}

describe("palette.colors", function()
	it("todos los colores son hex #RRGGBB", function()
		for name, value in pairs(palette.colors) do
			assert_eq(true, type(value) == "string" and value:match("^#%x%x%x%x%x%x$") ~= nil, name .. " = " .. tostring(value))
		end
	end)
end)

describe("palette.to_catppuccin", function()
	it("reproduce exactamente los overrides anteriores", function()
		local mapped = palette.to_catppuccin(palette.colors)
		for token, hex in pairs(EXPECTED_CATPPUCCIN) do
			assert_eq(hex, mapped[token], token)
		end
		for token in pairs(mapped) do
			assert_eq(true, EXPECTED_CATPPUCCIN[token] ~= nil, "token inesperado: " .. token)
		end
	end)
end)
