-- Tema Lazarobox sin dependencias: `:colorscheme lazarobox`.
--
-- Pinta los grupos base con la paleta de lazarobox.palette. Hasta que se
-- independizo, el tema lo pintaba catppuccin/nvim; estos grupos se copiaron de
-- aquel resultado para que el cambio de motor fuera invisible. Por eso los
-- colores siguen el mapeo de catppuccin (p.ej. Function en azul, Type en
-- amarillo); los comentarios de la paleta documentan ese uso real.
--
-- Las integraciones de plugins viven en lua/lazarobox/integrations/. Fuera de
-- alcance: colores de terminal (catppuccin tampoco los pintaba: term_colors=false).

local M = {}

local NONE = "NONE"

local function hex_to_rgb(hex)
	return tonumber(hex:sub(2, 3), 16), tonumber(hex:sub(4, 5), 16), tonumber(hex:sub(6, 7), 16)
end

-- Mezcla lineal fg sobre bg: alpha 1 = fg, alpha 0 = bg. Es la misma formula
-- que usaba catppuccin para sus darken/lighten, asi CursorLine, Search o los
-- fondos de diff salieron al mismo hex sin tener que fijarlos a mano.
function M.blend(fg, bg, alpha)
	local fr, fgc, fb = hex_to_rgb(fg)
	local br, bgc, bb = hex_to_rgb(bg)
	local function channel(f, b)
		local v = alpha * f + (1 - alpha) * b
		return math.floor(math.min(math.max(0, v), 255) + 0.5)
	end
	return string.format("#%02X%02X%02X", channel(fr, br), channel(fgc, bgc), channel(fb, bb))
end

local function editor(c, o)
	local tr = o.transparent
	local bg = tr and NONE or c.bg
	local cursorline = M.blend(c.surface0, c.bg, 0.64)

	return {
		ColorColumn = { bg = c.surface0 },
		Conceal = { fg = c.gray3 },
		Cursor = { fg = c.bg, bg = c.gold },
		lCursor = { fg = c.bg, bg = c.gold },
		CursorIM = { fg = c.bg, bg = c.gold },
		CursorColumn = { bg = c.bg },
		CursorLine = { bg = cursorline },
		Dimmed = { fg = c.gray3 },
		Directory = { fg = c.blue },
		EndOfBuffer = { fg = c.surface1 },
		ErrorMsg = { fg = c.rose, bold = true, italic = true },
		-- Con fondo transparente el borde oscuro no se veria: se aclara a surface1
		VertSplit = { fg = tr and c.surface1 or c.border },
		WinSeparator = { fg = tr and c.surface1 or c.border },
		Folded = { fg = c.blue, bg = tr and NONE or c.surface1 },
		FoldColumn = { fg = c.gray4 },
		SignColumn = { fg = c.surface1 },
		SignColumnSB = { fg = c.surface1, bg = c.border },
		Substitute = { fg = c.violet, bg = c.surface1 },
		LineNr = { fg = c.surface1 },
		CursorLineNr = { fg = c.lavender },
		MatchParen = { fg = c.sand, bg = M.blend(c.surface1, c.bg, 0.70), bold = true },
		ModeMsg = { fg = c.fg, bold = true },
		MsgSeparator = { link = "WinSeparator" },
		MoreMsg = { fg = c.blue },
		NonText = { fg = c.gray4 },
		Normal = { fg = c.fg, bg = bg },
		NormalNC = { fg = c.fg, bg = bg },
		NormalSB = { fg = c.fg, bg = c.border },
		NormalFloat = { fg = c.fg, bg = bg },
		FloatBorder = { fg = c.blue, bg = bg },
		FloatTitle = { fg = c.fg_muted, bg = bg },
		-- Sin fondo en modo transparente: la sombra gris se veria como un borde sucio
		FloatShadow = { bg = tr and NONE or c.gray4, blend = 80 },
		FloatShadowThrough = { bg = tr and NONE or c.gray4, blend = 100 },
		OkMsg = { fg = c.green },
		Pmenu = { fg = c.fg_muted, bg = bg },
		PmenuBorder = { fg = c.blue, bg = bg },
		PmenuSel = { bg = c.surface0, bold = true },
		PmenuMatch = { fg = c.fg, bold = true },
		PmenuMatchSel = { bold = true },
		PmenuSbar = { bg = c.surface0 },
		PmenuThumb = { bg = c.gray4 },
		PmenuKind = { fg = c.blue, bg = bg },
		PmenuKindSel = { fg = c.blue, bg = c.surface0, bold = true },
		PmenuExtra = { fg = c.gray4 },
		PmenuExtraSel = { fg = c.gray4, bg = c.surface0, bold = true },
		ComplMatchIns = { link = "PreInsert" },
		PreInsert = { fg = c.fg_muted },
		ComplHint = { fg = c.fg_muted },
		ComplHintMore = { link = "Question" },
		Question = { fg = c.blue },
		QuickFixLine = { bg = M.blend(c.surface1, c.bg, 0.70), bold = true },
		Search = { fg = c.fg, bg = M.blend(c.aqua, c.bg, 0.30) },
		IncSearch = { fg = c.bg, bg = M.blend(c.aqua, c.bg, 0.90) },
		CurSearch = { fg = c.bg, bg = c.rose },
		SpecialKey = { link = "NonText" },
		SpellBad = { sp = c.rose, undercurl = true },
		SpellCap = { sp = c.yellow, undercurl = true },
		SpellLocal = { sp = c.blue, undercurl = true },
		SpellRare = { sp = c.green, undercurl = true },
		StatusLine = { fg = c.fg, bg = bg },
		StatusLineNC = { fg = c.surface1, bg = bg },
		TabLine = { fg = c.gray4, bg = c.border },
		TabLineFill = { bg = bg },
		TabLineSel = { link = "Normal" },
		TermCursor = { fg = c.bg, bg = c.gold },
		TermCursorNC = { fg = c.bg, bg = c.fg_muted },
		Title = { fg = c.blue, bold = true },
		Visual = { bg = c.surface1, bold = true },
		VisualNOS = { bg = c.surface1, bold = true },
		WarningMsg = { fg = c.yellow },
		Whitespace = { fg = c.surface1 },
		WildMenu = { bg = c.gray4 },
		WinBar = { fg = c.gold },
		WinBarNC = { link = "WinBar" },
	}
end

-- Estilos: cursiva en comentarios, condicionales, funciones, variables y
-- booleanos; keywords y tipos rectos, como estaba configurado catppuccin.
local function syntax(c)
	return {
		Comment = { fg = c.fg_muted, italic = true },
		SpecialComment = { link = "Special" },
		Constant = { fg = c.sand },
		String = { fg = c.green },
		Character = { fg = c.mint },
		Number = { fg = c.sand },
		Float = { link = "Number" },
		Boolean = { fg = c.sand, italic = true },
		Identifier = { fg = c.coral, italic = true },
		Function = { fg = c.blue, italic = true },
		Statement = { fg = c.orchid },
		Conditional = { fg = c.orchid, italic = true },
		Repeat = { fg = c.orchid },
		Label = { fg = c.steel },
		Operator = { fg = c.aqua },
		Keyword = { fg = c.orchid },
		Exception = { fg = c.orchid },
		PreProc = { fg = c.violet },
		Include = { fg = c.orchid },
		Define = { link = "PreProc" },
		Macro = { fg = c.orchid },
		PreCondit = { link = "PreProc" },
		StorageClass = { fg = c.yellow },
		Structure = { fg = c.yellow },
		Special = { fg = c.violet },
		Type = { fg = c.yellow },
		Typedef = { link = "Type" },
		SpecialChar = { link = "Special" },
		Tag = { fg = c.lavender, bold = true },
		Delimiter = { fg = c.fg_muted },
		Debug = { link = "Special" },
		Underlined = { underline = true },
		Bold = { bold = true },
		Italic = { italic = true },
		Error = { fg = c.rose },
		Todo = { fg = c.bg, bg = c.coral, bold = true },
		qfLineNr = { fg = c.yellow },
		qfFileName = { fg = c.blue },

		-- syntax/csv.vim del runtime: una columna por color para seguirlas a ojo
		csvCol0 = { fg = c.rose },
		csvCol1 = { fg = c.sand },
		csvCol2 = { fg = c.yellow },
		csvCol3 = { fg = c.green },
		csvCol4 = { fg = c.aqua },
		csvCol5 = { fg = c.blue },
		csvCol6 = { fg = c.lavender },
		csvCol7 = { fg = c.orchid },
		csvCol8 = { fg = c.violet },
		escCsvCol0 = { link = "csvCol0" },

		-- Titulos en arcoiris que reutilizan markdown y treesitter
		rainbow1 = { fg = c.rose },
		rainbow2 = { fg = c.sand },
		rainbow3 = { fg = c.yellow },
		rainbow4 = { fg = c.green },
		rainbow5 = { fg = c.steel },
		rainbow6 = { fg = c.lavender },
		markdownHeadingDelimiter = { fg = c.sand, bold = true },
		markdownCode = { fg = c.coral },
		markdownCodeBlock = { fg = c.coral },
		markdownLinkText = { fg = c.blue, underline = true },
		markdownH1 = { link = "rainbow1" },
		markdownH2 = { link = "rainbow2" },
		markdownH3 = { link = "rainbow3" },
		markdownH4 = { link = "rainbow4" },
		markdownH5 = { link = "rainbow5" },
		markdownH6 = { link = "rainbow6" },

		htmlH1 = { fg = c.violet, bold = true },
		htmlH2 = { fg = c.blue, bold = true },
		mkdCodeDelimiter = { fg = c.fg, bg = c.bg },
		mkdCodeStart = { fg = c.coral, bold = true },
		mkdCodeEnd = { fg = c.coral, bold = true },
		gitcommitSummary = { fg = c.gold, italic = true },
		zshKSHFunction = { link = "Function" },
		debugBreakpoint = { fg = c.gray4, bg = c.bg },

		healthError = { fg = c.rose },
		healthSuccess = { fg = c.mint },
		healthWarning = { fg = c.yellow },
	}
end

local function diff(c)
	return {
		Added = { fg = c.green },
		Changed = { fg = c.blue },
		diffAdded = { fg = c.green },
		diffRemoved = { fg = c.rose },
		diffChanged = { fg = c.blue },
		diffOldFile = { fg = c.yellow },
		diffNewFile = { fg = c.sand },
		diffFile = { fg = c.blue },
		diffLine = { fg = c.gray4 },
		diffIndexLine = { fg = c.mint },
		-- Fondos tenues: el color de la accion mezclado con el fondo
		DiffAdd = { bg = M.blend(c.green, c.bg, 0.18) },
		DiffChange = { bg = M.blend(c.blue, c.bg, 0.07) },
		DiffDelete = { bg = M.blend(c.rose, c.bg, 0.18) },
		DiffText = { bg = M.blend(c.blue, c.bg, 0.30) },
	}
end

local function treesitter(c)
	return {
		["@variable"] = { fg = c.fg, italic = true },
		["@variable.builtin"] = { fg = c.rose },
		["@variable.parameter"] = { fg = c.salmon, italic = true },
		["@variable.member"] = { fg = c.lavender },

		["@constant"] = { link = "Constant" },
		["@constant.builtin"] = { fg = c.sand },
		["@constant.macro"] = { link = "Macro" },

		["@module"] = { fg = c.yellow, italic = true },
		["@label"] = { link = "Label" },

		["@string"] = { link = "String" },
		["@string.documentation"] = { fg = c.mint },
		["@string.regexp"] = { fg = c.violet },
		["@string.escape"] = { fg = c.violet },
		["@string.special"] = { link = "Special" },
		["@string.special.path"] = { link = "Special" },
		["@string.special.symbol"] = { fg = c.coral },
		["@string.special.url"] = { fg = c.blue, italic = true, underline = true },
		["@punctuation.delimiter.regex"] = { link = "@string.regexp" },

		["@character"] = { link = "Character" },
		["@character.special"] = { link = "SpecialChar" },

		["@boolean"] = { link = "Boolean" },
		["@number"] = { link = "Number" },
		["@number.float"] = { link = "Float" },

		["@type"] = { link = "Type" },
		["@type.builtin"] = { fg = c.orchid },
		["@type.definition"] = { link = "Type" },

		["@attribute"] = { link = "Constant" },
		["@property"] = { fg = c.lavender },

		["@function"] = { link = "Function" },
		["@function.builtin"] = { fg = c.sand, italic = true },
		["@function.call"] = { link = "Function" },
		["@function.macro"] = { fg = c.violet, italic = true },
		["@function.method"] = { link = "Function" },
		["@function.method.call"] = { link = "Function" },

		["@constructor"] = { fg = c.yellow },
		["@operator"] = { link = "Operator" },

		["@keyword"] = { link = "Keyword" },
		["@keyword.modifier"] = { link = "Keyword" },
		["@keyword.type"] = { link = "Keyword" },
		["@keyword.coroutine"] = { link = "Keyword" },
		["@keyword.function"] = { fg = c.orchid },
		["@keyword.operator"] = { fg = c.orchid },
		["@keyword.import"] = { link = "Include" },
		["@keyword.repeat"] = { link = "Repeat" },
		["@keyword.return"] = { fg = c.orchid },
		["@keyword.debug"] = { link = "Exception" },
		["@keyword.exception"] = { link = "Exception" },
		["@keyword.conditional"] = { link = "Conditional" },
		["@keyword.conditional.ternary"] = { link = "Operator" },
		["@keyword.directive"] = { link = "PreProc" },
		["@keyword.directive.define"] = { link = "Define" },
		["@keyword.export"] = { fg = c.orchid },

		["@punctuation.delimiter"] = { link = "Delimiter" },
		["@punctuation.bracket"] = { fg = c.fg_muted },
		["@punctuation.special"] = { link = "Special" },

		["@comment"] = { link = "Comment" },
		["@comment.documentation"] = { link = "Comment" },
		["@comment.error"] = { fg = c.bg, bg = c.rose },
		["@comment.warning"] = { fg = c.bg, bg = c.yellow },
		["@comment.hint"] = { fg = c.bg, bg = c.blue },
		["@comment.todo"] = { fg = c.bg, bg = c.coral },
		-- catppuccin sobrescribia note con hint en su bloque de alias legacy
		["@comment.note"] = { fg = c.bg, bg = c.blue },

		["@markup"] = { fg = c.fg },
		["@markup.strong"] = { fg = c.rose, bold = true },
		["@markup.italic"] = { fg = c.rose, italic = true },
		["@markup.strikethrough"] = { fg = c.fg, strikethrough = true },
		["@markup.underline"] = { link = "Underlined" },
		["@markup.heading"] = { fg = c.blue },
		["@markup.heading.markdown"] = { bold = true },
		["@markup.math"] = { fg = c.blue },
		["@markup.quote"] = { fg = c.violet },
		["@markup.environment"] = { fg = c.violet },
		["@markup.environment.name"] = { fg = c.blue },
		["@markup.link"] = { fg = c.lavender },
		["@markup.link.label"] = { fg = c.lavender },
		["@markup.link.url"] = { fg = c.blue, italic = true, underline = true },
		["@markup.raw"] = { fg = c.green },
		["@markup.list"] = { fg = c.mint },
		["@markup.list.checked"] = { fg = c.green },
		["@markup.list.unchecked"] = { fg = c.gray3 },
		["@markup.heading.1.markdown"] = { link = "rainbow1" },
		["@markup.heading.2.markdown"] = { link = "rainbow2" },
		["@markup.heading.3.markdown"] = { link = "rainbow3" },
		["@markup.heading.4.markdown"] = { link = "rainbow4" },
		["@markup.heading.5.markdown"] = { link = "rainbow5" },
		["@markup.heading.6.markdown"] = { link = "rainbow6" },

		["@diff.plus"] = { link = "diffAdded" },
		["@diff.minus"] = { link = "diffRemoved" },
		["@diff.delta"] = { link = "diffChanged" },

		["@tag"] = { fg = c.blue },
		["@tag.builtin"] = { fg = c.blue },
		["@tag.attribute"] = { fg = c.yellow, italic = true },
		["@tag.delimiter"] = { fg = c.mint },

		["@error"] = { link = "Error" },

		-- Ajustes por lenguaje heredados de los que catppuccin traia de serie
		["@function.builtin.bash"] = { fg = c.rose, italic = true },
		["@variable.parameter.bash"] = { fg = c.green },
		["@constructor.lua"] = { link = "@punctuation.bracket" },
		["@constructor.python"] = { fg = c.aqua },
		["@property.css"] = { fg = c.blue },
		["@property.scss"] = { fg = c.blue },
		["@property.id.css"] = { fg = c.yellow },
		["@property.class.css"] = { fg = c.yellow },
		["@type.css"] = { fg = c.lavender },
		["@type.tag.css"] = { fg = c.blue },
		["@string.plain.css"] = { fg = c.fg },
		["@number.css"] = { fg = c.sand },
		["@keyword.directive.css"] = { link = "Keyword" },
		["@string.special.url.html"] = { fg = c.green },
		["@markup.link.label.html"] = { fg = c.fg },
		["@character.special.html"] = { fg = c.rose },
		["@markup.heading.html"] = { link = "@markup" },
		["@markup.heading.1.html"] = { link = "@markup" },
		["@markup.heading.2.html"] = { link = "@markup" },
		["@markup.heading.3.html"] = { link = "@markup" },
		["@markup.heading.4.html"] = { link = "@markup" },
		["@markup.heading.5.html"] = { link = "@markup" },
		["@markup.heading.6.html"] = { link = "@markup" },
		["@constant.java"] = { fg = c.mint },
		["@label.yaml"] = { fg = c.yellow },
		["@string.special.symbol.ruby"] = { fg = c.coral },
		["@function.method.php"] = { link = "Function" },
		["@function.method.call.php"] = { link = "Function" },
		["@keyword.import.c"] = { fg = c.yellow },
		["@keyword.import.cpp"] = { fg = c.yellow },
		["@attribute.c_sharp"] = { fg = c.yellow },
		["@comment.warning.gitcommit"] = { fg = c.yellow },
		["@string.special.path.gitignore"] = { fg = c.fg },
	}
end

local function lsp(c, o)
	local sev = { Error = c.rose, Warn = c.yellow, Info = c.aqua, Hint = c.mint, Ok = c.green }
	local groups = {
		LspReferenceText = { bg = c.surface1 },
		LspReferenceRead = { bg = c.surface1 },
		LspReferenceWrite = { bg = c.surface1 },
		LspSignatureActiveParameter = { bg = c.surface0, bold = true },
		LspCodeLens = { fg = c.gray4 },
		LspCodeLensSeparator = { link = "LspCodeLens" },
		-- Mismo fondo que CursorLine salvo en modo transparente
		LspInlayHint = { fg = c.gray4, bg = o.transparent and NONE or M.blend(c.surface0, c.bg, 0.64) },
		LspInfoBorder = { link = "FloatBorder" },

		-- Tokens semanticos: el resto de @lsp.type.* ya enlaza por defecto a
		-- las capturas de treesitter; aqui solo lo que el LSP hace mejor.
		["@lsp.type.enumMember"] = { fg = c.mint },
		["@lsp.type.variable"] = {},
		-- Neovim lo enlaza a @type.qualifier, captura legacy que no definimos
		["@lsp.type.modifier"] = { link = "@keyword.modifier" },
		["@lsp.typemod.function.defaultLibrary"] = { link = "@function.builtin" },
		["@lsp.typemod.function.builtin"] = { link = "@function.builtin" },
	}
	for name, color in pairs(sev) do
		-- El fondo tenue del virtual text solo tiene sentido sin transparencia
		local vt_tint = sev[name == "Ok" and "Hint" or name]
		groups["Diagnostic" .. name] = { fg = color, bg = NONE, italic = true }
		groups["DiagnosticVirtualText" .. name] = {
			fg = color,
			bg = o.transparent and NONE or M.blend(vt_tint, c.bg, 0.095),
			italic = true,
		}
		groups["DiagnosticUnderline" .. name] = { sp = color, underline = true }
		groups["DiagnosticFloating" .. name] = { fg = color }
		groups["DiagnosticSign" .. name] = { fg = color }
	end
	return groups
end

-- Capturas treesitter renombradas en nvim 0.10 -> su nombre moderno. Se
-- mantienen porque aun hay quien las pide: noice pinta la documentacion LSP con
-- @text.title, @text.reference y @parameter. Son copias, no links, igual que
-- en catppuccin, para que el resultado resuelto fuera identico. @text.uri no
-- esta: catppuccin lo apuntaba a @markup.link.uri, que no existe, y quedaba vacio.
local LEGACY_CAPTURES = {
	["@parameter"] = "@variable.parameter",
	["@field"] = "@variable.member",
	["@namespace"] = "@module",
	["@float"] = "@number.float",
	["@symbol"] = "@string.special.symbol",
	["@symbol.ruby"] = "@string.special.symbol.ruby",
	["@string.regex"] = "@string.regexp",
	["@text"] = "@markup",
	["@text.strong"] = "@markup.strong",
	["@text.emphasis"] = "@markup.italic",
	["@text.underline"] = "@markup.underline",
	["@text.strike"] = "@markup.strikethrough",
	["@text.math"] = "@markup.math",
	["@text.environment"] = "@markup.environment",
	["@text.environment.name"] = "@markup.environment.name",
	["@text.title"] = "@markup.heading",
	["@text.title.1.markdown"] = "@markup.heading.1.markdown",
	["@text.title.2.markdown"] = "@markup.heading.2.markdown",
	["@text.title.3.markdown"] = "@markup.heading.3.markdown",
	["@text.title.4.markdown"] = "@markup.heading.4.markdown",
	["@text.title.5.markdown"] = "@markup.heading.5.markdown",
	["@text.title.6.markdown"] = "@markup.heading.6.markdown",
	["@text.literal"] = "@markup.raw",
	["@text.reference"] = "@markup.link",
	["@text.todo"] = "@comment.todo",
	["@text.todo.checked"] = "@markup.list.checked",
	["@text.todo.unchecked"] = "@markup.list.unchecked",
	["@text.warning"] = "@comment.warning",
	["@text.note"] = "@comment.note",
	["@text.danger"] = "@comment.error",
	["@text.diff.add"] = "@diff.plus",
	["@text.diff.delete"] = "@diff.minus",
	["@method"] = "@function.method",
	["@method.call"] = "@function.method.call",
	["@method.php"] = "@function.method.php",
	["@method.call.php"] = "@function.method.call.php",
	["@type.qualifier"] = "@keyword.modifier",
	["@define"] = "@keyword.directive.define",
	["@preproc"] = "@keyword.directive",
	-- catppuccin encadenaba @storageclass -> @keyword.storage -> @keyword.modifier
	["@storageclass"] = "@keyword.modifier",
	["@conditional"] = "@keyword.conditional",
	["@exception"] = "@keyword.exception",
	["@include"] = "@keyword.import",
	["@repeat"] = "@keyword.repeat",
}

-- Devuelve { [grupo] = spec } listo para nvim_set_hl. Pura: no toca Neovim.
function M.groups(colors, opts)
	local o = vim.tbl_extend("force", { transparent = true }, opts or {})
	local result = {}
	local sections = {
		editor(colors, o),
		syntax(colors),
		diff(colors),
		treesitter(colors),
		lsp(colors, o),
		require("lazarobox.integrations").groups(colors, o),
	}
	for _, section in ipairs(sections) do
		for name, spec in pairs(section) do
			result[name] = spec
		end
	end
	for legacy, modern in pairs(LEGACY_CAPTURES) do
		-- Copia defensiva: compartir la tabla haria que editar una alterase la otra
		if result[modern] then
			result[legacy] = vim.deepcopy(result[modern])
		end
	end
	return result
end

function M.load(opts)
	if vim.g.colors_name then
		vim.cmd("hi clear")
	end
	if vim.fn.exists("syntax_on") == 1 then
		vim.cmd("syntax reset")
	end
	vim.o.termguicolors = true
	vim.o.background = "dark"
	vim.g.colors_name = "lazarobox"

	for name, spec in pairs(M.groups(require("lazarobox.palette").colors, opts)) do
		vim.api.nvim_set_hl(0, name, spec)
	end
end

return M
