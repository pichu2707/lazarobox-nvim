-- Lazarobox ya no depende de catppuccin/nvim: si algo vuelve a pedirlo, el
-- arranque fallaria en cuanto el plugin se desinstale (lazy-lock ya no lo trae).
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")

local function lua_files()
	local files = vim.fn.globpath(root .. "/lua", "**/*.lua", false, true)
	vim.list_extend(files, vim.fn.globpath(root .. "/colors", "*.lua", false, true))
	table.insert(files, root .. "/init.lua")
	return files
end

describe("independencia de catppuccin", function()
	it("la paleta ya no expone el adaptador to_catppuccin", function()
		assert_eq(nil, require("lazarobox.palette").to_catppuccin)
	end)

	it("no existe el spec lua/plugins/catppuccin.lua", function()
		assert_eq(0, vim.fn.filereadable(root .. "/lua/plugins/catppuccin.lua"))
	end)

	it("ningun fichero de configuracion requiere ni instala catppuccin", function()
		for _, file in ipairs(lua_files()) do
			local text = table.concat(vim.fn.readfile(file), "\n")
			assert_eq(nil, text:match("require%(%s*[\"']catppuccin"), file)
			assert_eq(nil, text:match("[\"']catppuccin/nvim[\"']"), file)
			assert_eq(nil, text:match("colorscheme%(%s*[\"']catppuccin"), file)
		end
	end)

	-- Sin plugin que lo cargue, el arranque es quien aplica el tema: si se
	-- pierde esta llamada, Neovim abre con su esquema por defecto.
	it("el arranque aplica lazarobox antes de lazy.setup", function()
		local text = table.concat(vim.fn.readfile(root .. "/lua/config/lazy.lua"), "\n")
		local cs = text:find('vim.cmd.colorscheme("lazarobox")', 1, true)
		local setup = text:find('require("lazy").setup', 1, true)
		assert_eq(true, cs ~= nil and setup ~= nil and cs < setup, "colorscheme antes de setup")
	end)
end)
