local theme = require("lazarobox.theme")
local palette = require("lazarobox.palette")

-- Grupos que el tema debe definir siempre: UI del editor, sintaxis clasica,
-- capturas de treesitter, tokens semanticos, diagnosticos y diff. Si falta uno,
-- Neovim cae a su default y el cambio desde catppuccin dejaria de ser invisible.
local REQUIRED = {
	-- UI del editor
	"Normal", "NormalNC", "NormalFloat", "FloatBorder", "FloatTitle",
	"Cursor", "CursorLine", "CursorColumn", "ColorColumn", "LineNr", "CursorLineNr",
	"SignColumn", "FoldColumn", "Folded", "Visual", "VisualNOS",
	"Search", "IncSearch", "CurSearch", "Substitute",
	"Pmenu", "PmenuSel", "PmenuSbar", "PmenuThumb", "PmenuKind", "PmenuKindSel",
	"PmenuExtra", "PmenuExtraSel", "PmenuMatch", "PmenuMatchSel",
	"StatusLine", "StatusLineNC", "TabLine", "TabLineFill", "TabLineSel",
	"WinSeparator", "VertSplit", "WinBar", "WinBarNC",
	"MatchParen", "NonText", "EndOfBuffer", "Whitespace", "SpecialKey",
	"Conceal", "Directory", "Title", "Question", "QuickFixLine",
	"ErrorMsg", "WarningMsg", "ModeMsg", "MoreMsg", "MsgSeparator",
	"SpellBad", "SpellCap", "SpellLocal", "SpellRare",
	"TermCursor",
	-- Sintaxis clasica
	"Comment", "Constant", "String", "Character", "Number", "Float", "Boolean",
	"Identifier", "Function", "Statement", "Conditional", "Repeat", "Label",
	"Operator", "Keyword", "Exception", "PreProc", "Include", "Define", "Macro",
	"PreCondit", "Type", "StorageClass", "Structure", "Typedef", "Special",
	"SpecialChar", "Tag", "Delimiter", "SpecialComment", "Debug",
	"Underlined", "Error", "Todo",
	-- Treesitter
	"@variable", "@variable.builtin", "@variable.parameter", "@variable.member",
	"@constant", "@constant.builtin", "@module", "@string", "@string.escape",
	"@string.regexp", "@boolean", "@number", "@type", "@type.builtin",
	"@property", "@function", "@function.builtin", "@function.call",
	"@function.method", "@constructor", "@operator", "@keyword",
	"@keyword.function", "@keyword.return", "@keyword.conditional",
	"@punctuation.delimiter", "@punctuation.bracket", "@comment",
	"@markup.heading", "@markup.link.url", "@tag", "@tag.attribute",
	-- Tokens semanticos LSP
	"@lsp.type.enumMember", "@lsp.type.variable",
	-- Diagnosticos
	"DiagnosticError", "DiagnosticWarn", "DiagnosticInfo", "DiagnosticHint", "DiagnosticOk",
	"DiagnosticVirtualTextError", "DiagnosticVirtualTextWarn", "DiagnosticVirtualTextInfo",
	"DiagnosticVirtualTextHint", "DiagnosticVirtualTextOk",
	"DiagnosticUnderlineError", "DiagnosticUnderlineWarn", "DiagnosticUnderlineInfo",
	"DiagnosticUnderlineHint", "DiagnosticUnderlineOk",
	"DiagnosticSignError", "DiagnosticSignWarn", "DiagnosticSignInfo", "DiagnosticSignHint",
	"DiagnosticFloatingError", "DiagnosticFloatingWarn",
	"LspInlayHint", "LspReferenceText", "LspReferenceRead", "LspReferenceWrite",
	"LspSignatureActiveParameter", "LspCodeLens",
	-- Diff
	"DiffAdd", "DiffChange", "DiffDelete", "DiffText", "Added", "Changed",
	"diffAdded", "diffRemoved", "diffChanged",
}

local function is_color(v)
	return v == "NONE" or (type(v) == "string" and v:match("^#%x%x%x%x%x%x$") ~= nil)
end

describe("theme.groups", function()
	local groups = theme.groups(palette.colors)

	it("define todos los grupos obligatorios", function()
		for _, name in ipairs(REQUIRED) do
			assert_eq(true, groups[name] ~= nil, "falta el grupo " .. name)
		end
	end)

	it("fg/bg/sp son NONE o hex #RRGGBB", function()
		for name, spec in pairs(groups) do
			for _, key in ipairs({ "fg", "bg", "sp" }) do
				if spec[key] ~= nil then
					assert_eq(true, is_color(spec[key]), name .. "." .. key .. " = " .. tostring(spec[key]))
				end
			end
		end
	end)

	it("cada link apunta a un grupo del tema o builtin", function()
		for name, spec in pairs(groups) do
			if spec.link then
				local ok = groups[spec.link] ~= nil or vim.fn.hlexists(spec.link) == 1
				assert_eq(true, ok, name .. " -> " .. spec.link)
			end
		end
	end)

	it("es pura: no muta la paleta y repite el mismo resultado", function()
		local before = vim.deepcopy(palette.colors)
		assert_eq(groups, theme.groups(palette.colors))
		assert_eq(before, palette.colors)
	end)
end)

describe("theme.groups transparencia", function()
	it("transparente por defecto", function()
		assert_eq("NONE", theme.groups(palette.colors).Normal.bg)
	end)

	it("transparent=true deja Normal y NormalFloat sin fondo", function()
		local g = theme.groups(palette.colors, { transparent = true })
		assert_eq("NONE", g.Normal.bg)
		assert_eq("NONE", g.NormalFloat.bg)
	end)

	it("transparent=false pinta el fondo de la paleta", function()
		local g = theme.groups(palette.colors, { transparent = false })
		assert_eq(palette.colors.bg, g.Normal.bg)
		assert_eq(palette.colors.bg, g.NormalFloat.bg)
	end)
end)

describe("theme.groups estilos", function()
	local g = theme.groups(palette.colors)

	it("Comment en cursiva", function()
		assert_eq(true, g.Comment.italic)
	end)
	it("Function en cursiva", function()
		assert_eq(true, g.Function.italic)
	end)
	it("Keyword sin cursiva", function()
		assert_eq(nil, g.Keyword.italic)
	end)
	it("@variable en cursiva", function()
		assert_eq(true, g["@variable"].italic)
	end)
	it("@boolean en cursiva (via Boolean)", function()
		local spec = g["@boolean"].link and g[g["@boolean"].link] or g["@boolean"]
		assert_eq(true, spec.italic)
	end)
	it("subrayado de diagnosticos con color de severidad", function()
		assert_eq(true, g.DiagnosticUnderlineError.underline)
		assert_eq(palette.colors.rose, g.DiagnosticUnderlineError.sp)
	end)
end)

describe("theme.blend", function()
	it("alpha 1 devuelve el color y alpha 0 el fondo", function()
		assert_eq("#FF0000", theme.blend("#FF0000", "#000000", 1))
		assert_eq("#000000", theme.blend("#FF0000", "#000000", 0))
	end)
	it("mezcla lineal redondeando", function()
		assert_eq("#808080", theme.blend("#FFFFFF", "#000000", 0.5))
	end)
end)

describe("colors/lazarobox.lua", function()
	it(":colorscheme lazarobox carga el tema", function()
		vim.cmd.colorscheme("lazarobox")
		assert_eq("lazarobox", vim.g.colors_name)
		local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
		assert_eq(tonumber(palette.colors.fg:sub(2), 16), normal.fg)
	end)
end)

-- syntax/csv.vim del runtime colorea cada columna con csvCol0..8 (sin
-- treesitter para csv). catppuccin los pinta en arcoiris; si faltan, las
-- columnas salen con los links por defecto del runtime.
describe("theme.groups csv", function()
	local g = theme.groups(palette.colors)
	local c = palette.colors
	it("columnas csv en arcoiris", function()
		local expected = { c.rose, c.sand, c.yellow, c.green, c.aqua, c.blue, c.lavender, c.orchid, c.violet }
		for i, color in ipairs(expected) do
			assert_eq({ fg = color }, g["csvCol" .. (i - 1)], "csvCol" .. (i - 1))
		end
	end)
	it("escCsvCol0 enlaza a csvCol0", function()
		assert_eq({ link = "csvCol0" }, g.escCsvCol0)
	end)
end)
