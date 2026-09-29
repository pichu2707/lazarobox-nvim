local palette = require("lazarobox.palette")

describe("palette.colors", function()
	it("todos los colores son hex #RRGGBB", function()
		for name, value in pairs(palette.colors) do
			assert_eq(true, type(value) == "string" and value:match("^#%x%x%x%x%x%x$") ~= nil, name .. " = " .. tostring(value))
		end
	end)
end)
