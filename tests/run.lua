-- Runner minimo sin dependencias: nvim --headless -u NONE -l tests/run.lua
-- Descubre tests/*_spec.lua, ejecuta cada caso y sale con codigo != 0 si algo falla.
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
package.path = root .. "/lua/?.lua;" .. root .. "/lua/?/init.lua;" .. package.path
-- colors/ se resuelve por runtimepath: sin esto :colorscheme lazarobox solo
-- funcionaria si el repo esta clonado en ~/.config/nvim (no es el caso en CI)
vim.opt.rtp:prepend(root)

local passed, failed = 0, 0

-- API minima que reciben los specs: describe/it y aserciones de igualdad
local ctx = { prefix = {} }
_G.describe = function(name, fn)
	table.insert(ctx.prefix, name)
	fn()
	table.remove(ctx.prefix)
end
_G.it = function(name, fn)
	local full = table.concat(ctx.prefix, " > ") .. " > " .. name
	local ok, err = pcall(fn)
	if ok then
		passed = passed + 1
		io.write("  ok   " .. full .. "\n")
	else
		failed = failed + 1
		io.write("  FAIL " .. full .. "\n       " .. tostring(err) .. "\n")
	end
end
_G.assert_eq = function(expected, actual, msg)
	if not vim.deep_equal(expected, actual) then
		error((msg or "valores distintos") .. ": esperado " .. vim.inspect(expected) .. ", obtenido " .. vim.inspect(actual), 2)
	end
end

local specs = vim.fn.globpath(root .. "/tests", "*_spec.lua", false, true)
table.sort(specs)
for _, spec in ipairs(specs) do
	io.write(vim.fn.fnamemodify(spec, ":t") .. "\n")
	local ok, err = pcall(dofile, spec)
	if not ok then
		failed = failed + 1
		io.write("  FAIL (carga) " .. tostring(err) .. "\n")
	end
end

io.write(string.format("\n%d passed, %d failed\n", passed, failed))
os.exit(failed == 0 and 0 or 1)
